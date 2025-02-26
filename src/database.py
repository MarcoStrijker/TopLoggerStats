import sqlite3

from collections.abc import Sequence
from os.path import exists
from typing import Any, Iterable
from shutil import copyfile

from src.cython_modules.constants import (
    DATA_DB,
    UPDATE_DB,
    DEFAULT_USER_DB,
    GYMS_URI,
    USER_UPDATE_URI,
    DATA_URI,
)
from src.custom_types import AscendsJson, ClimbType, ClimbsJson, GymsJson, GymsRow, OpinionsJson, System, WallsJson


def copy_user_db(db_path: str) -> bool:
    """Copies the default user database to the user database of the user.

    Arguments:
        db_path (str): Path to the user database

    Returns:
        bool: True if the user database did not exist, False otherwise
    """
    db_not_exists = not exists(db_path)
    if db_not_exists:
        copyfile(DEFAULT_USER_DB, db_path)

    return db_not_exists


def add_user_update(uid: int, climb_type: ClimbType, gym_ids: Iterable[int]) -> None:
    """Adds a user update to the update database. This is used to keep track of which gyms
    have been updated for a specific user.

    Arguments:
        uid (int): User id
        climb_type (ClimbType): Climb type
        gym_ids (Iterable[int]): Gym ids
    """

    query = """INSERT INTO user_updates (update_timestamp, type, gym_id, uid) 
               VALUES (strftime('%s','now'), ?,?,?)
               """
    with sqlite3.connect(UPDATE_DB) as conn:
        conn.executemany(query, [(climb_type, _id, uid) for _id in gym_ids])
        conn.commit()


def drop_ascends_and_opinions(conn: sqlite3.Connection, gyms: tuple[int]) -> None:
    """Drops the ascends and opinions table from the user database

    This is sometimes necessary when a user has deleted an ascend opinion
    after this application fetched the data.

    Arguments:
        conn (sqlite3.Connection): Connection to the user database
        gyms (tuple): Gym ids
    """
    gyms_str = str(tuple(gyms)).replace(",)", ")")

    conn.execute(f'ATTACH DATABASE "{DATA_DB}" AS master')
    conn.execute(
        f"""
            DELETE FROM ascends 
            WHERE climb_id IN (
                SELECT id 
                FROM master.climbs 
                WHERE gym_id IN {gyms_str}
            )
        """
    )
    conn.execute(
        f"""
        DELETE FROM opinions 
        WHERE climb_id IN (
            SELECT id 
            FROM master.climbs 
            WHERE gym_id IN {gyms_str}
        )
    """
    )
    conn.commit()


def add_ascends(conn: sqlite3.Connection, _json: list[AscendsJson]) -> None:
    """Adds ascends to the user database. If the ascend already exists, it will update the
    climb id, date logged and type.

    Arguments:
        _json (list): List with ascend data

    """
    query = """
    INSERT INTO ascends (id, climb_id, date_logged, type) 
    VALUES (?, ?, ?, ?)
    ON CONFLICT (id)
    DO UPDATE SET
    (climb_id, date_logged, type) = (EXCLUDED.climb_id, EXCLUDED.date_logged, EXCLUDED.type)
    """

    conn.executemany(query, _json)
    conn.commit()


def add_opinions(conn: sqlite3.Connection, _json: list[OpinionsJson]) -> None:
    """Adds opinions to the user database. If the opinion already exists, it will update the
    project, voted renew, grade rating and rating.

    Arguments:
        _json (list): List with opinion data
    """

    query = """INSERT INTO opinions 
              (id, climb_id, uid, project, voted_renew, grade_rating, rating) 
              VALUES (?,?,?,?,?,?,?)
              ON CONFLICT (id)
              DO UPDATE SET
              (project, voted_renew, grade_rating, rating)
              = (EXCLUDED.project, EXCLUDED.voted_renew, EXCLUDED.grade_rating, EXCLUDED.rating)
              """

    conn.executemany(query, _json)
    conn.commit()


def enrich_user_table_and_get_ascends(
    conn: sqlite3.Connection, climb_type: ClimbType, system: System, gyms: tuple[int, ...]
) -> set[int]:
    """Enriches the user database with the data from the static database. This is done by
    joining the tables of the static database with the tables of the user database. The
    enriched data is stored in the main table. This table is used to retrieve the data for the
    statistics.

    Arguments:
        conn (sqlite3.Connection): Connection to the user database
        climb_type (ClimbType): Climb type
        system (System): Grading system
        gyms (tuple): Gym ids

    Returns:
        set: Gym ids for which data is available
    """

    # Make sure the table is renewed by dropping it if it already exists
    # There have been instances where the table was not updated correctly
    conn.execute("DROP TABLE IF EXISTS main")

    try:
        # For joining we need to attach the static database to the user database
        # Sometimes this already happened, thus we catch the error and be happy
        conn.execute(f'ATTACH DATABASE "{DATA_DB}" AS master')
    except sqlite3.OperationalError:
        pass

    conn.execute(
        f"""
        CREATE TABLE main AS
            SELECT ascends.id, master.climbs.id as climb_id, ascends.date_logged, 
                    ascends.type AS ascend_type, climbs.gym_id, grade_reference.{system} AS grade, 
                    master.climbs.type AS climb_type, master.climbs.average_opinion, master.climbs.date_live_start, 
                    master.climbs.date_live_end, master.walls.name AS wall_name, master.gyms.name AS gym_name, 
                    opinions.project, opinions.voted_renew, grading_reference.{system} AS grade_rating, 
                    opinions.rating
            FROM master.climbs
            INNER JOIN master.gyms 
                ON master.climbs.gym_id = master.gyms.id
            LEFT JOIN ascends
                ON ascends.climb_id = master.climbs.id    
            LEFT JOIN opinions
                ON opinions.climb_id = master.climbs.id
            INNER JOIN master.walls  
                ON master.climbs.wall_id = master.walls.id
            LEFT JOIN master.{climb_type} AS grade_reference
                ON grade_reference.id = master.climbs.grade
            LEFT JOIN master.{climb_type} AS grading_reference
                ON grading_reference.id = opinions.grade_rating                    
            WHERE master.climbs.type = ?
                AND master.gyms.id IN {str(gyms).replace(',)', ')')}
                AND master.climbs.date_live_start IS NOT NULL
                AND (ascends.date_logged IS NOT NULL
                OR grading_reference.{system} IS NOT NULL
                OR opinions.rating IS NOT NULL)
    """,
        (climb_type,),
    )
    conn.execute("DETACH DATABASE master")
    conn.commit()

    # To reduce loading times we retrieve available gym ids
    # This will be returned so the program knows what it can display
    c = conn.cursor()
    c.execute(
        """
        SELECT DISTINCT gym_id
        FROM main
        WHERE climb_type = ? AND ascend_type IS NOT NULL
        """,
        (climb_type,),
    )

    return {g[0] for g in c.fetchall()}


def add_gyms(_json: list[GymsJson]) -> None:
    """Adds gyms to the static database. If the gym already exists, it will update the number
    of climbs, boulders and routes.

    Arguments:
        _json (list): List with gym data
    """

    query = """
        INSERT INTO gyms(id, name, id_name, nr_of_climbs, nr_of_boulders, nr_of_routes, country) 
        VALUES (?, ?, ?, ?, ?, ?, ?) 
        ON CONFLICT (id)
        DO UPDATE SET
            (
                nr_of_climbs, 
                nr_of_boulders, 
                nr_of_routes
            ) = (
                EXCLUDED.nr_of_climbs,
                EXCLUDED.nr_of_boulders, 
                EXCLUDED.nr_of_routes
            )
    """

    with sqlite3.connect(DATA_DB) as conn:
        conn.executemany(query, _json)
        conn.commit()


def add_walls(_json: list[WallsJson]) -> None:
    """Adds walls to the static database. If the wall already exists, it will update the name.

    Arguments:
        _json (list): List with wall data

    """

    query = """
        INSERT INTO walls (id, name, gym_id) 
        VALUES (?, ?, ?)
        ON CONFLICT (id)
        DO UPDATE SET
            (name) = (EXCLUDED.name)
    """

    with sqlite3.connect(DATA_DB) as conn:
        conn.executemany(query, _json)
        conn.commit()


def add_climbs(_json: list[ClimbsJson]) -> None:
    """Adds climbs to the static database. If the climb already exists, it will update the
    date live start, date live end, grade, grade stability, number of ascends and average
    opinion.

    Arguments:
        _json (list): List with climb data
    """
    query = """
        INSERT INTO climbs (
            id, gym_id, type, date_live_start, date_live_end, wall_id,
            grade, auto_grade, grade_stability, nr_of_ascends, average_opinion
        ) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT (id)
        DO UPDATE SET (
            date_live_start,
            date_live_end,
            grade,
            grade_stability, 
            nr_of_ascends,
            average_opinion
        ) = (
            EXCLUDED.date_live_start,
            EXCLUDED.date_live_end,
            EXCLUDED.grade,
            EXCLUDED.grade_stability,
            EXCLUDED.nr_of_ascends,
            EXCLUDED.average_opinion
        )
    """

    with sqlite3.connect(DATA_DB) as conn:
        conn.executemany(query, _json)
        conn.commit()


def _retrieve_data_from_static_db(
    db_uri: str, query: str, params: Sequence[int] | None = None
) -> list[tuple[Any, ...]]:
    """Retrieves data from the static databases

    Arguments:
        db_path (str): Path to the database
        query (str): Query to be executed

    Keyword Arguments:
        params (Sequence | None): Parameters for the query {None}

    Returns:
        list: The results of the query
    """
    with sqlite3.connect(db_uri, uri=True) as conn:
        c = conn.cursor()
        c.execute(query, params if params else [])
        return c.fetchall()


def retrieve_data(query: str, params: Sequence[int] | None = None) -> list[tuple[Any, ...]]:
    """Wrapper function for retrieving data from the static database

    Arguments:
        query (str): Query to be executed
        params (Sequence[int] | None): Parameters for the query {None}

    Returns:
        list: The results of the query
    """
    return _retrieve_data_from_static_db(DATA_URI, query, params)


def retrieve_all_gyms(params: Sequence[int] | None = None) -> list[GymsRow]:
    """Wrapper function for retrieving data from the gym database

    Arguments:
        query (str): Query to be executed
        params (Sequence[int] | None): Parameters for the query {None}

    Returns:
        list: The results of the query
    """
    return _retrieve_data_from_static_db(GYMS_URI, "SELECT * FROM gyms", params)


def retrieve_user_updates(query: str, params: Sequence[int] | None = None) -> list[tuple[Any, ...]]:
    """Wrapper function for retrieving data from the update database

    Arguments:
        query (str): Query to be executed

    Keyword Arguments:
        params (Sequence[int] | None): Parameters for the query {None}

    Returns:
        list: The results of the query
    """
    return _retrieve_data_from_static_db(USER_UPDATE_URI, query, params)
