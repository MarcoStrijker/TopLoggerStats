# cython: language_level=3, binding=False, boundscheck=False, wraparound=False, initializedcheck=False, nonecheck=False, infer_types=False, profile=False, cdivision=False, type_version_tag=False, unraisable_tracebacks=False
# distutils: language=c++

import asyncio

from threading import Thread

from src.cython_modules.api import async_fetch_user_data, fetch_climbs, fetch_walls, fetch_gyms
from src.cython_modules import statistics_processor as stats
from src.cython_modules.constants import SYSTEMS

from src.database import add_climbs, add_walls, add_gyms, add_ascends, add_opinions, add_user_update, drop_ascends_and_opinions, retrieve_user_updates

# Define the wanted visuals for faster looping and access
cdef tuple SINGLE_GYM_CHART_FUNCTIONS = (
    stats.ascends_per_grade,
    stats.ascends_over_time,
    stats.flash_rate_per_grade,
    stats.max_grade_over_time,
    stats.flash_rate,
    stats.grading_accuracy,
    stats.rating_accuracy,
    stats.rating_per_ascends_type,
    stats.number_of_ascends_per_wall,
    stats.max_grade_per_wall,
    stats.rating_per_wall,
    stats.flash_rate_per_wall
)
cdef tuple MULTIPLE_GYM_VISUALS = (
    stats.ascends_per_grade,
    stats.ascends_over_time,
    stats.flash_rate_per_grade,
    stats.max_grade_over_time,
    stats.flash_rate,
    stats.grading_accuracy,
    stats.rating_accuracy,
    stats.rating_per_ascends_type,
    stats.number_of_ascends_per_gym,
    stats.max_grade_per_gym,
    stats.rating_per_gym,
    stats.flash_rate_per_gym
)

# Initialize the grading systems for faster access
cdef dict GRADING_SYSTEMS = {
    ("boulder", "french"): GradingSystem("boulder", "french"),
    ("boulder", "french_rounded"): GradingSystem("boulder", "french_rounded"),
    ("boulder", "v_grade"): GradingSystem("boulder", "v_grade"),
    ("boulder", "british"): GradingSystem("boulder", "british"),
    ("route", "french"): GradingSystem("route", "french"),
    ("route", "ewbank"): GradingSystem("route", "ewbank"),
    ("route", "uiaa"): GradingSystem("route", "uiaa"),
    ("route", "yds"): GradingSystem("route", "yds")
}

cdef object loop = asyncio.new_event_loop()

cdef str USER_UPDATES_QUERY = """
    WITH requested_gyms AS (
        {}
    )
    SELECT
        rg.gym_id,
        CASE
            WHEN MAX(uu.update_timestamp) IS NULL THEN 1
            WHEN MAX(uu.update_timestamp) < strftime('%s','now') - 604800 THEN 1
            WHEN MAX(uu.update_timestamp) < strftime('%s','now') - 43200 THEN 0
        END AS update_size
    FROM requested_gyms rg
    LEFT JOIN user_updates uu
        ON rg.gym_id = uu.gym_id AND uu.uid = ? AND uu.type = ?
    GROUP BY rg.gym_id
    HAVING update_size IS NOT NULL;
"""


cpdef void update_climbs(set requested_gyms, bint only_active):
    add_climbs(fetch_climbs(requested_gyms, only_active))

cpdef void update_walls(set requested_gyms):
    add_walls(fetch_walls(requested_gyms))

cpdef void update_gyms():
    add_gyms(fetch_gyms())

cpdef void update_user_data(object conn, unsigned long long uid, str climb_type, tuple requested_gyms, bint db_didnt_existed):
    cdef set gyms_big_update = set()
    cdef set gyms_small_update = set()
    cdef dict gyms_update_database
    cdef list response_big = [[], []]
    cdef list response_small = [[], []]
    cdef bint delete = 0

    if db_didnt_existed:
        gyms_big_update = set(requested_gyms)
    else:
        gym_ids_union = ' UNION ALL '.join([f"SELECT {gym_id} AS gym_id" for gym_id in requested_gyms])
        for g in retrieve_user_updates(USER_UPDATES_QUERY.format(gym_ids_union=gym_ids_union), (uid, climb_type)):
            if g[1] == 1:
                gyms_big_update.add(g[0])
            else:
                gyms_small_update.add(g[0])

        if gyms_big_update:
            delete = 1

    if not (gyms_big_update or gyms_small_update):
        return

    while loop.is_running():
        pass

    response = loop.run_until_complete(async_fetch_user_data(uid, gyms_big_update, gyms_small_update, climb_type))

    if delete:
        drop_ascends_and_opinions(conn, gyms_big_update)

    add_ascends(conn, response[0])
    add_opinions(conn, response[1])

    add_user_update(uid, climb_type, gyms_big_update.union(gyms_small_update))


cpdef tuple create_visuals(object conn, unsigned long long uid, list gwa, str climb_type, str grading_system):
    return _create_visuals(conn, uid, gwa, climb_type, grading_system)


cdef tuple _create_visuals(object conn, unsigned long long uid, list gwa, str climb_type, str grading_system):
    """ Creates all visuals for the dashboard

    Arguments:
        conn (object): The connection to the database
        uid (unsigned long long): The id of the user
        gwa (list): The gyms with ascends
        climb_type (str): The type of the climb
        grading_system (str): The grading system

    Returns:
        tuple: The static stats and the visuals
    """
    cdef list static_stats
    cdef list visuals = []
    cdef object func
    cdef str gym_sql_string

    cdef object GS = GRADING_SYSTEMS[(climb_type, grading_system)]

    # Create the string that we can inject into the SQL query
    gym_sql_string = str(tuple(g[0] for g in gwa)).replace(',)', ')')

    # Create the cursor
    c = conn.cursor()

    # Create the stats for the first row
    static_stats = stats.number_of_ascends(c, uid, gym_sql_string, GS) + stats.top_grade(c, uid, gym_sql_string, GS)

    # Create all charts, if there is only one gym, we loop over the single gym charts, otherwise we loop over the multiple gym charts
    for func in SINGLE_GYM_CHART_FUNCTIONS if len(gwa) == 1 else MULTIPLE_GYM_VISUALS:
        viz = func(c, uid, gym_sql_string, GS)
        if viz: 
            visuals.append(viz)

    return (static_stats, visuals)


cdef class GradingSystem:
    """Represents a grading system

    Attributes:
        climb_type (str): The type of the climb
        integers (tuple): The integers of the grading system
        strings (tuple): The strings of the grading system
        ascend_types (tuple): The types of the ascends
        ascend_colors (tuple): The colors of the ascends
        route (bint): Whether the climb is a route
    """

    def __cinit__(self, climb_type: str, grading_system: str):
        self.climb_type = climb_type
        self.integers = tuple(SYSTEMS[climb_type][grading_system].keys())
        self.strings = tuple(SYSTEMS[climb_type][grading_system].values())
        self.ascend_types = ("Flash", "Redpoint") if climb_type == "boulder" else ("Onsight", "Flash", "Redpoint")
        self.ascend_colors = ("#df007a", "#ffa4ff") if climb_type == "boulder" else ("#B50060", "#df007a", "#ffa4ff")
        self.route = climb_type == "route"

    def get_closest(self, unsigned short item):
        """Gets the closest integer to the item

        Arguments:
            item (unsigned short): The item to get the closest integer to

        Returns:
            int: The closest integer
        """
        if item == 0: return
        return min(range(len(self.integers)), key=lambda i: abs(self.integers[i] - item))

