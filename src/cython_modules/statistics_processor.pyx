# cython: language_level=3, binding=False, boundscheck=False, wraparound=False, initializedcheck=False, nonecheck=False, infer_types=False, profile=False, cdivision=False, type_version_tag=False, unraisable_tracebacks=False
# distutils: language=c++

from src.cython_modules import visualizations as vis
from src.cython_modules.constants cimport THRESHOLD_RATINGS


cdef list retrieve_data(object cursor, str q):
    """Retrieves the data from the database

    Arguments:
        cursor (object): The database cursor
        q (str): The query to execute

    Returns:
        list: The data from the database
    """
    cursor.execute(q)
    return cursor.fetchall()


cdef list create_series(bint route):
    """Creates the series for the chart

    Arguments:
        route (bint): Whether the climb type is route

    Returns:
        list: The series for the chart
    """
    if route: return [
        {"name": "Onsight", "data": []},
        {"name": "Flash", "data": []},
        {"name": "Redpoint", "data": []}
    ]

    return [
        {"name": "Flash", "data": []},
        {"name": "Redpoint", "data": []}
    ]


cpdef list top_grade(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the top grade for each ascend type and returns the stats

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        list: The top grade for each ascend type
    """
    cdef dict result = {item[0]: item[1] for item in retrieve_data(cursor, f"""
        SELECT ascend_type, MAX(grade)
        FROM main
        WHERE grade IS NOT NULL
        AND gym_id IN {sql_gyms}
        GROUP BY ascend_type
    """)}

    return [(system.strings[result[ascend_type]], f"Max grade {ascend_type.lower()}")
            for ascend_type in system.ascend_types[::-1] if ascend_type in result]


cpdef list number_of_ascends(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the number of ascends for each ascend type and returns the stats

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        list: The number of ascends for each ascend type
    """
    cdef dict result = {item[0]: item[1] for item in retrieve_data(cursor, f"""
        SELECT ascend_type, COUNT(ascend_type)
        FROM main
        WHERE grade IS NOT NULL
        AND gym_id IN {sql_gyms}
        GROUP BY ascend_type
    """)}

    return [(result[ascend_type], f"{ascend_type} tops")
            for ascend_type in system.ascend_types[::-1] if ascend_type in result]


cpdef tuple flash_rate(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the flash rate for each ascend type and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the flash rate for each ascend type
    """
    cdef list series = list(retrieve_data(cursor, f"""
        SELECT
            ROUND(SUM(CASE WHEN ascend_type = 'Onsight' THEN 1.0 ELSE 0.0 END)  / COUNT(*) * 100, 1),
            ROUND(SUM(CASE WHEN ascend_type = 'Flash' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100, 1),
            ROUND(SUM(CASE WHEN ascend_type = 'Redpoint' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100, 1)
        FROM main
        WHERE date_logged IS NOT NULL
            AND ascend_type IS NOT NULL
            AND gym_id IN {sql_gyms}
    """)[0])

    # Cut off the onsight rate if the climb type is not route
    series = series[system.climb_type != "route":]

    return vis.flash_rate(series=series, labels=list(system.ascend_types), colors=list(system.ascend_colors))



cpdef tuple max_grade_over_time(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the max grade over time and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the max grade over time
    """
    cdef unsigned short i
    cdef bint route = system.route

    cdef list data = retrieve_data(cursor, f"""
        SELECT CAST(strftime('%s', date_logged) * 1000 + 40000000 AS INTEGER),
           IFNULL(MAX(0, MAX(CASE WHEN ascend_type = 'Redpoint' THEN grade ELSE 0 END) - MAX(CASE WHEN ascend_type = 'Flash' THEN grade ELSE 0 END) - MAX(CASE WHEN ascend_type = 'Onsight' THEN grade ELSE 0 END)), 0) AS Redpoint,
           IFNULL(MAX(0, MAX(CASE WHEN ascend_type = 'Flash' THEN grade ELSE 0 END) - MAX(CASE WHEN ascend_type = 'Onsight' THEN grade ELSE 0 END)), 0) AS Flash,
           IFNULL(MAX(0, MAX(CASE WHEN ascend_type = 'Onsight' THEN grade ELSE 0 END)), 0) AS Onsight
        FROM main
        WHERE date_logged IS NOT NULL
        AND gym_id IN {sql_gyms}
        GROUP BY strftime('%m-%Y', date_logged)
        ORDER BY CAST(strftime('%s', date_logged) AS INTEGER) ASC;
    """)

    if len(data) <= 2: return None

    cdef unsigned char R = 1 + route
    cdef bint F = route
    cdef bint O = 0
    cdef list dates = []
    cdef list series = create_series(route)
    cdef tuple dat
    cdef unsigned char _min = 100
    cdef unsigned char _max = 0
    cdef unsigned char m

    for i, dat in enumerate(data):
        dates.append(dat[0])

        m = sum((dat[1], dat[2], dat[3])) if route else sum((dat[1], dat[2]))
        if m > _max:
            _max = m

        # Determine the minimum value of the y-axis
        # This is the minimum value of the first series with data
        if route and dat[3]:
            if dat[3] < _min: _min = dat[3]
        elif dat[2]:
            if dat[2] < _min: _min = dat[2]
        elif dat[1] and dat[1] < _min: _min = dat[1]

        series[R]["data"].append(dat[1])
        series[F]["data"].append(dat[2] if dat[2] or (route and dat[3]) else None)
        if route: series[O]["data"].append(dat[3] if dat[3] else None)

    # Establish the min and max of the index
    _min = max(_min, 1) - 1
    _max = _max + 2 if len(system.strings) > _max + 2 else len(system.strings) - 1

    # Adjust the first series to the y-axis
    # Since the chart is stacked, we need to adjust the first series with data to the y-axis
    # This means we need to subtract the minimum from the data
    # However, ApexCharts is not able to handle null values at all, in those cases we need to subtract the maximum
    # Don't ask me why, I don't know but it works
    for i, item in enumerate(series[0]["data"]):
        if route and item: series[O]["data"][i] -= _min
        elif route and series[F]["data"][i] and series[O]["data"][i] is None:
            series[F]["data"][i] -= _max
        elif series[F]["data"][i]:
            series[F]["data"][i] -= _min
        elif series[R]["data"][i]:
            series[R]["data"][i] -= _max

    return vis.max_grade_over_time(
        series=series,
        colors=list(system.ascend_colors),
        x_axis_labels=dates,
        y_axis_labels=list(system.strings[_min: _max]),
        _max=_max - _min)


cpdef tuple ascends_over_time(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the ascends over time and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the ascends over time
    """
    cdef list data = retrieve_data(cursor, f"""
        SELECT
            CAST(strftime('%s', date_logged) * 1000 + 40000000 AS INTEGER),
            SUM(CASE WHEN ascend_type = 'Redpoint' THEN 1 ELSE 0 END),
            SUM(CASE WHEN ascend_type = 'Flash' THEN 1 ELSE 0 END),
            SUM(CASE WHEN ascend_type = 'Onsight' THEN 1 ELSE 0 END)
        FROM main
        WHERE date_logged IS NOT NULL
            AND gym_id IN {sql_gyms}
        GROUP BY strftime('%m-%Y', date_logged)
        ORDER BY CAST(strftime('%s', date_logged) AS INTEGER) ASC;
    """)

    if len(data) <= 1: return None

    cdef bint route = system.route
    cdef unsigned short i
    cdef list dates = []
    cdef list series = create_series(route)
    cdef unsigned char R = 1 + route
    cdef bint F = route
    cdef bint O = 0

    for i in range(len(data)):
        dates.append(data[i][0])
        series[R]["data"].append(data[i][1])
        series[F]["data"].append(data[i][2])
        if route: series[O]["data"].append(data[i][3])

    return vis.ascends_over_time(
        series=series,
        colors=list(system.ascend_colors),
        x_axis_labels=dates
    )


cpdef tuple ascends_per_grade(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the ascends per grade and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the ascends per grade
    """
    cdef list data = retrieve_data(cursor, f"""
        SELECT grade,
        SUM(CASE WHEN ascend_type = 'Redpoint' THEN 1 ELSE 0 END),
        SUM(CASE WHEN ascend_type = 'Flash' THEN 1 ELSE 0 END),
        SUM(CASE WHEN ascend_type = 'Onsight' THEN 1 ELSE 0 END)
        FROM main
        WHERE grade IS NOT NULL
        AND ascend_type IS NOT NULL
        AND gym_id IN {sql_gyms}
        GROUP BY grade
    """)

    if len(data) <= 1: return None

    cdef bint route = system.route
    cdef unsigned char R = 1 + route
    cdef bint F = route
    cdef bint O = 0
    cdef unsigned char i
    cdef list grades = []
    cdef list series = create_series(route)

    for i in range(len(data)):
        grades.append(system.strings[data[i][0]])
        series[R]["data"].append(data[i][1])
        series[F]["data"].append(data[i][2])
        if route: series[O]["data"].append(data[i][3])

    return vis.ascends_per_grade(
        series=series,
        colors=list(system.ascend_colors),
        x_axis_labels=grades
    )


cpdef tuple flash_rate_per_grade(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Wrapper function which uses the flash_rate_per_x to retrieve the flash rate per grade

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the flash rate per grade
    """
    cdef object structured_data = flash_rate_per_x(cursor, uid, sql_gyms, f"""
        SELECT
            grade,
            ROUND(SUM(CASE WHEN ascend_type = 'Onsight' THEN 1.0 ELSE 0.0 END)  / COUNT(*) * 100, 1),
            ROUND(SUM(CASE WHEN ascend_type = 'Flash' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100, 1)
        FROM main
        WHERE date_logged IS NOT NULL
            AND ascend_type IS NOT NULL
	        AND grade IS NOT NULL
            AND gym_id IN {sql_gyms}
        GROUP BY
            grade
        ORDER BY
            grade ASC;
    """, system, 1)
    if structured_data is None: return None
    return vis.flash_rate_per_x(name="Flash rate per grade", series=structured_data[0], colors=structured_data[1], labels=structured_data[2])




cpdef tuple grading_accuracy(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the grading accuracy and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the grading accuracy
    """
    cdef unsigned char x, y
    cdef unsigned char _min = 100
    cdef unsigned char _max = 0

    cdef list data = retrieve_data(cursor, f"""
        SELECT
            grade_rating,
            grade,
            COUNT(*)
        FROM main
        WHERE
            grade IS NOT NULL
            AND grade_rating IS NOT NULL
            AND gym_id IN {sql_gyms}
        GROUP BY
            grade,
            grade_rating
    """)

    if len(data) < THRESHOLD_RATINGS: return None

    cdef list series = []

    for i in range(len(data)):
        x = data[i][0]
        y = data[i][1]

        series.append({"x": x, "y": y})

        if x > _max: _max = x
        if y > _max: _max = y
        if x < _min: _min = x
        if y < _min: _min = y

    # Get the axes in strings from system
    # _min cannot be lower than 0, thus we subtract 1 only if it is larger than 0
    if _min > 0: _min -= 1

    # Subsequently, _max cannot be larger than the length of the strings
    # Thus we set _max to be the length of the strings - 2, so we can always add 2
    if len(system.strings) < _max + 2: _max = len(system.strings) - 3

    cdef list axis_labels = list(system.strings[_min: _max + 2])

    cdef list counts = [item[2] for item in data]
    cdef list colors = ["#df007a" for _ in counts]

    for i, item in enumerate(series):
        series[i]["x"] -= _min
        series[i]["y"] -= _min

    return vis.grading_accuracy(
        series=[{"name": "grading", "data": series}],
        axis_labels=axis_labels,
        counts=counts,
        colors=colors,
        _min=_min,
        _max=_max - _min
    )


cpdef tuple rating_accuracy(object cursor, unsigned long long uid, str sql_gyms, object system):
    cdef list data = retrieve_data(cursor, f"""
        SELECT
            rating,
            ROUND(average_opinion, 1)
        FROM main
        WHERE
            rating IS NOT NULL
            AND average_opinion IS NOT NULL
            AND gym_id IN {sql_gyms}
    """)

    if len(data) < THRESHOLD_RATINGS: return None

    cdef list series = []

    for i in range(len(data)):
        series.append({"x": data[i][0], "y": data[i][1]})

    cdef list counts = [series.count(item) for item in series]
    cdef list colors = ["#df007a" for _ in counts] # color_scale(counts)

    return vis.rating_accuracy(series=[{"name": "ratings", "data": series}], counts=counts, colors=colors)


cpdef tuple number_of_ascends_per_x(object cursor, unsigned long long uid, unicode query, object system):
    """Retrieves the number of ascends per x and returns the data

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        query (str): The query
        system (object): The system

    Returns:
        tuple: The data with the number of ascends per x
    """
    cdef unsigned short i

    cdef list data = retrieve_data(cursor, query)

    if len(data) <= 1: return None

    cdef bint route = system.route
    cdef list series = create_series(route)
    cdef list labels = []

    cdef unsigned char R = 1 + route
    cdef bint F = route
    cdef bint O = 0

    for i in range(len(data)):
        if data[i][0] not in labels:
            if len(series[R]["data"]) < len(labels): series[R]["data"].append(0)
            if len(series[F]["data"]) < len(labels): series[F]["data"].append(0)
            if route and len(series[O]["data"]) < len(labels): series[O]["data"].append(0)
            labels.append(data[i][0])

        if data[i][1] == "Redpoint": series[R]["data"].append(data[i][2])
        elif data[i][1] == "Flash": series[F]["data"].append(data[i][2])
        elif data[i][1] == "Onsight": series[O]["data"].append(data[i][2])


    return (series, list(system.ascend_colors), labels)



cpdef tuple number_of_ascends_per_wall(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the number of ascends per wall and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the number of ascends per wall
    """
    if "," in sql_gyms: return None

    cdef object structured_data = number_of_ascends_per_x(cursor, uid, f"""
        SELECT
            wall_name,
            ascend_type,
            COUNT(id)
        FROM main
        WHERE
            gym_id IN {sql_gyms}
            AND ascend_type IS NOT NULL
        GROUP BY
            wall_name,
            ascend_type
        ORDER BY
            wall_name,
            CASE WHEN ascend_type = 'Onsight' THEN 0
            WHEN ascend_type = 'Flash' THEN 1
            ELSE 2 END
    """, system)
    if structured_data is None: return None

    return vis.ascends_per_x(name="Ascends per wall", series=structured_data[0], colors=structured_data[1], x_axis_labels=structured_data[2])


cpdef tuple number_of_ascends_per_gym(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the number of ascends per gym and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the number of ascends per gym
    """
    if "," not in sql_gyms: return None

    cdef object structured_data = number_of_ascends_per_x(cursor, uid, f"""
        SELECT
            gym_name,
            ascend_type,
            COUNT(id)
        FROM main
        WHERE
            ascend_type IS NOT NULL
        GROUP BY
            gym_name,
            ascend_type
        ORDER BY
            gym_name,
            CASE
                WHEN ascend_type = 'Onsight' THEN 0
                WHEN ascend_type = 'Flash' THEN 1
                ELSE 2 END
    """, system)
    if structured_data is None: return None

    return vis.ascends_per_x(name="Ascends per gym", series=structured_data[0], colors=structured_data[1], x_axis_labels=structured_data[2])


cpdef tuple max_grade_per_x(object cursor, unsigned long long uid, str sql_gyms, unicode query, object system):
    """Retrieves the max grade per x and returns the data

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        query (str): The query
        system (object): The system

    Returns:
        tuple: The data with the max grade per x
    """
    cdef unsigned short i

    cdef list data = retrieve_data(cursor, query)
    if len(data) <= 1: return None

    cdef bint route = system.route
    cdef unsigned char R = 1 + route
    cdef bint F = route
    cdef bint O = 0
    cdef list x_axis_labels = []
    cdef list series = create_series(route)
    cdef tuple dat
    cdef unsigned char _min = 100
    cdef unsigned char _max = 0
    cdef unsigned char m

    for i, dat in enumerate(data):
        x_axis_labels.append(dat[0])

        m = sum((dat[1], dat[2], dat[3])) if route else sum((dat[1], dat[2]))

        # If the cumulative max is larger than the current max, replace it
        if m > _max: _max = m

        # We need to determine the minimum value of the y-axis
        # This is the minimum value of the first series with data
        if route and dat[3]:
            if dat[3] < _min: _min = dat[3]
        elif dat[2]:
            if dat[2] < _min: _min = dat[2]
        elif dat[1] and dat[1] < _min: _min = dat[1]

        # Add the data to the series
        series[R]["data"].append(dat[1])
        series[F]["data"].append(dat[2])
        if route: series[O]["data"].append(dat[3])

    _min = min(_min, 1) - 1
    _max = _max + 2 if len(system.strings) > _max + 2 else len(system.strings) - 1

    # The chart is stacked, we need to adjust the first series with data to the y-axis
    for i, item in enumerate(series[0]["data"]):
        if route and item: series[O]["data"][i] -= _min
        elif series[F]["data"][i]: series[F]["data"][i] -= _min
        elif series[R]["data"][i]: series[R]["data"][i] -= _min

    return (series, list(system.ascend_colors), x_axis_labels, list(system.strings[_min: _max]), _min, _max - _min)


cpdef tuple max_grade_per_wall(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the max grade per wall and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the max grade per wall
    """

    if "," in sql_gyms: return None

    cdef object structured_data = max_grade_per_x(cursor, uid, sql_gyms, f"""
        SELECT
            wall_name,
            MAX(0, MAX(CASE WHEN ascend_type = 'Redpoint' THEN grade ELSE 0 END) - MAX(CASE WHEN ascend_type = 'Flash' THEN grade ELSE 0 END) - MAX(CASE WHEN ascend_type = 'Onsight' THEN grade ELSE 0 END)),
            MAX(0, MAX(CASE WHEN ascend_type = 'Flash' THEN grade ELSE 0 END) - MAX(CASE WHEN ascend_type = 'Onsight' THEN grade ELSE 0 END)),
            MAX(CASE WHEN ascend_type = 'Onsight' THEN grade ELSE 0 END)
        FROM main
        WHERE
            grade IS NOT NULL
            AND wall_name IS NOT NULL
            AND gym_id IN {sql_gyms}
        GROUP BY
            wall_name
    """, system)
    if structured_data is None: return None

    return vis.max_grade_per_x(name="Max grade per wall", series=structured_data[0], colors=structured_data[1], x_axis_labels=structured_data[2], y_axis_labels=structured_data[3], _min=structured_data[4], _max=structured_data[5])


cpdef tuple max_grade_per_gym(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the max grade per gym and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the max grade per gym
    """
    if "," not in sql_gyms: return None

    cdef object structured_data = max_grade_per_x(cursor, uid, sql_gyms, f"""
        SELECT
            gym_name,
            MAX(0, MAX(CASE WHEN ascend_type = 'Redpoint' THEN grade ELSE 0 END) - MAX(CASE WHEN ascend_type = 'Flash' THEN grade ELSE 0 END) - MAX(CASE WHEN ascend_type = 'Onsight' THEN grade ELSE 0 END)),
            MAX(0, MAX(CASE WHEN ascend_type = 'Flash' THEN grade ELSE 0 END) - MAX(CASE WHEN ascend_type = 'Onsight' THEN grade ELSE 0 END)),
            MAX(CASE WHEN ascend_type = 'Onsight' THEN grade ELSE 0 END)
        FROM main
        WHERE
            grade IS NOT NULL
            AND gym_name IS NOT NULL
            AND gym_id IN {sql_gyms}
        GROUP BY
            gym_name
    """, system)
    if structured_data is None: return None

    return vis.max_grade_per_x(name="Max grade per gym", series=structured_data[0], colors=structured_data[1], x_axis_labels=structured_data[2], y_axis_labels=structured_data[3], _min=structured_data[4], _max=structured_data[5])


cpdef tuple flash_rate_per_x(object cursor, unsigned long long uid, str sql_gyms, unicode query, object system, bint label_is_grade = 0):
    """Retrieves the flash rate per x and returns the data

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        query (str): The query
        system (object): The system

    Keyword Arguments:
        label_is_grade (bint): Whether the labels are grades {0}

    Returns:
        tuple: The data with the flash rate per x
    """
    cdef unsigned short i

    # Retrieve the data from the database
    cdef list data = retrieve_data(cursor, query)

    # The minimum walls is 3, otherwise the graph is not worth showing
    if len(data) <= 1: return None

    cdef bint route = system.route

    cdef list series = [{"name": "Onsight", "data": []}, {"name": "Flash", "data": []}] if route else [{"name": "Flash", "data": []}]
    cdef list labels = []

    for i in range(len(data)):
        labels.append(system.strings[data[i][0]] if label_is_grade else data[i][0])

        series[route]["data"].append(data[i][2])
        if route: series[0]["data"].append(data[i][1])

    return (series, list(system.ascend_colors), labels)


cpdef tuple flash_rate_per_wall(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the flash rate per wall and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the flash rate per wall
    """
    if "," in sql_gyms: return None

    cdef object structured_data = flash_rate_per_x(cursor, uid, sql_gyms, f"""
        SELECT
		    wall_name,
            ROUND(SUM(CASE WHEN ascend_type = 'Onsight' THEN 1.0 ELSE 0.0 END)  / COUNT(*) * 100, 1),
            ROUND(SUM(CASE WHEN ascend_type = 'Flash' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100, 1)
        FROM main
        WHERE date_logged IS NOT NULL
            AND ascend_type IS NOT NULL
	        AND wall_name IS NOT NULL
            AND gym_id IN {sql_gyms}
        GROUP BY
            wall_name
        ORDER BY
            wall_name ASC;
    """, system)
    if structured_data is None: return None


    return vis.flash_rate_per_x(name="Flash rate per wall", series=structured_data[0], colors=structured_data[1], labels=structured_data[2])


cpdef tuple flash_rate_per_gym(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the flash rate per gym and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the flash rate per gym
    """
    if "," not in sql_gyms: return None

    cdef object structured_data = flash_rate_per_x(cursor, uid, sql_gyms, f"""
        SELECT
		    gym_name,
            ROUND(SUM(CASE WHEN ascend_type = 'Onsight' THEN 1.0 ELSE 0.0 END)  / COUNT(*) * 100, 1),
            ROUND(SUM(CASE WHEN ascend_type = 'Flash' THEN 1.0 ELSE 0.0 END) / COUNT(*) * 100, 1)
        FROM main
        WHERE date_logged IS NOT NULL
            AND ascend_type IS NOT NULL
	        AND gym_name IS NOT NULL
            AND gym_id IN {sql_gyms}
        GROUP BY
            gym_name
        ORDER BY
            gym_name ASC;
    """, system)
    if structured_data is None: return None

    return vis.flash_rate_per_x(name="Flash rate per gym", series=structured_data[0], colors=structured_data[1], labels=structured_data[2])


cpdef tuple rating_per_x(object cursor, unsigned long long uid, str sql_gyms, unicode query, object system):
    """Retrieves the rating per x and returns the data

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        query (str): The query
        system (object): The system

    Returns:
        tuple: The data with the rating per x
    """
    cdef list data = retrieve_data(cursor, query)
    if len(data) <= 1: return None

    return ({"name": "ratings", "data": [d[1] for d in data]}, [d[0] for d in data])


cpdef tuple rating_per_ascends_type(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the rating per ascend type and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the rating per ascend type
    """
    cdef object structured_data = rating_per_x(cursor, uid, sql_gyms, f"""
        SELECT
            IFNULL(ascend_type, "Not ascended"),
            AVG(rating),
            COUNT(rating)
        FROM main
        WHERE
            gym_id IN {sql_gyms}
            AND rating IS NOT NULL
        GROUP BY
            IFNULL(ascend_type, "Not ascended")
        ORDER BY
            CASE WHEN ascend_type = 'Onsight' THEN 3
            WHEN ascend_type = 'Flash' THEN 2
            WHEN ascend_type = 'Redpoint' THEN 1
            ELSE 0 END
    """, system)
    if structured_data is None: return None

    color_scheme = {"Onsight": "#B50060", "Flash": "#df007a", "Redpoint": "#ffa4ff", "Not ascended": "#aaaaaa"}
    colors = [color_scheme[t] for t in structured_data[1]]

    return vis.rating_per_x(name="Rating per ascend type", series=[structured_data[0]], labels=structured_data[1])


cpdef tuple rating_per_wall(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the rating per wall and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the rating per wall
    """
    if "," in sql_gyms: return None

    cdef object structured_data = rating_per_x(cursor, uid, sql_gyms, f"""
        SELECT
            wall_name,
            AVG(rating),
            COUNT(rating)
        FROM main
        WHERE
            rating IS NOT NULL
            AND wall_name IS NOT NULL
            AND gym_id IN {sql_gyms}
        GROUP BY
            wall_name
    """, system)
    if structured_data is None: return None

    return vis.rating_per_x(name="Rating per wall", series=[structured_data[0]], labels=structured_data[1])

cpdef tuple rating_per_gym(object cursor, unsigned long long uid, str sql_gyms, object system):
    """Retrieves the rating per gym and returns the visual

    Arguments:
        cursor (object): The database cursor
        uid (unsigned long long): The user id
        sql_gyms (str): The gym ids
        system (object): The system

    Returns:
        tuple: The visual with the rating per gym
    """
    if "," not in sql_gyms: return None

    cdef object structured_data = rating_per_x(cursor, uid, sql_gyms, f"""
        SELECT
            gym_name,
            AVG(rating),
            COUNT(rating)
        FROM main
        WHERE
            rating IS NOT NULL
            AND gym_name IS NOT NULL
        GROUP BY
            gym_name
    """, system)
    if structured_data is None: return None
    return vis.rating_per_x(name="Rating per gym", series=[structured_data[0]], labels=structured_data[1])
