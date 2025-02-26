# cython: language_level=3, binding=False, boundscheck=False, wraparound=False, initializedcheck=False, nonecheck=False, infer_types=False, profile=False, cdivision=False, type_version_tag=False, unraisable_tracebacks=False
# distutils: language=c++

from markupsafe import Markup

from src.cython_modules.constants cimport JS_VISUAL_NAMES, JS_VISUAL_PATH_FORMAT_STRING, CLEAN_JS_PAT


cdef dict js_visuals = {name: import_js_file(name) for name in JS_VISUAL_NAMES}


cdef list import_js_file(str filename):
    """
    Import the JavaScript file and return the cleaned content as a list of strings.

    Args:
        filename (str): The name of the JavaScript file to import.

    Returns:
        list: A list of strings representing the cleaned content of the JavaScript file.
    """
    with open(JS_VISUAL_PATH_FORMAT_STRING.format(filename), 'r') as f:
        return CLEAN_JS_PAT.sub('', f.read()).split("$$$")


cpdef tuple ascends_per_grade(list series, list colors, list x_axis_labels):
    """ Create the ascends per grade visual

    Args:
        series (list): The series of data
        colors (list): The colors of the series
        x_axis_labels (list): The labels of the x axis

    Returns:
        tuple: The chart id and the javascript code
    """
    cdef list v = js_visuals['Ascends per grade']
    cdef str series_str = str(series).replace("None", "null")
    return "ascends-per-grade", Markup(v[0] + series_str + v[1] + str(colors) + v[2] + str(x_axis_labels) + v[3])


cpdef tuple ascends_over_time(list series, list colors, list x_axis_labels):
    """ Create the ascends over time visual

    Args:
        series (list): The series of data
        colors (list): The colors of the series
        x_axis_labels (list): The labels of the x axis

    Returns:
        tuple: The chart id and the javascript code
    """
    cdef list v = js_visuals['Ascends over time']
    cdef str series_str = str(series).replace("None", "null")
    return "ascends-over-time", Markup(v[0] + series_str + v[1] + str(colors) + v[2] + str(x_axis_labels) + v[3])


cpdef tuple max_grade_over_time(series, colors, y_axis_labels, x_axis_labels, _max):
    """ Create the max grade over time visual

    Args:
        series (list): The series of data
        colors (list): The colors of the series
        y_axis_labels (list): The labels of the y axis
        x_axis_labels (list): The labels of the x axis
        _max (int): The maximum value of the y axis

    Returns:
        tuple: The chart id and the javascript code
    """
    cdef list v = js_visuals['Max grade over time']
    cdef str series_str = str(series).replace("None", "null")
    cdef str max_str = str(_max - 1)
    cdef str y_axis_labels_str = str(y_axis_labels)
    return "max-grade-over-time", Markup(v[0] + series_str + v[1] + str(colors) + v[2] + max_str + v[3] + y_axis_labels_str + v[4] + y_axis_labels_str + v[5] + max_str + v[6] + max_str + v[7] + str(x_axis_labels) + v[8])


cpdef tuple rating_accuracy(list series, list counts, list colors):
    """ Create the rating accuracy visual

    Args:
        series (list): The series of data
        counts (list): The counts of the series
        colors (list): The colors of the series

    Returns:
        tuple: The chart id and the javascript code
    """
    cdef list v = js_visuals['Rating accuracy']
    return "rating-accuracy", Markup(v[0] + str(series).replace("None", "null") + v[1] + str(colors) + v[2])


cpdef tuple grading_accuracy(list series, list axis_labels, list counts, list colors, int _min, int _max):
    """ Create the grading accuracy visual

    Args:
        series (list): The series of data
        axis_labels (list): The labels of the axis
        counts (list): The counts of the series
        colors (list): The colors of the series
        _min (int): The minimum value of the y axis
        _max (int): The maximum value of the y axis

    Returns:
        tuple: The chart id and the javascript code
    """
    cdef list v = js_visuals['Grading accuracy']
    cdef str series_str = str(series).replace("None", "null")
    cdef str axis_labels_str = str(axis_labels)
    cdef str max_str = str(_max)
    return "grading-accuracy", Markup(v[0] + series_str + v[1] + str(colors) + v[2] + max_str + v[3] + max_str + v[4] + axis_labels_str + v[5] + max_str + v[6] + max_str + v[7] + axis_labels_str + v[8])

cpdef tuple ascends_per_x(str name, list series, list colors, list x_axis_labels):
    """ Create the ascends per x visual

    Args:
        name (str): The name of the visual
        series (list): The series of data
        colors (list): The colors of the series
        x_axis_labels (list): The labels of the x axis

    Returns:
        tuple: The chart id and the javascript code
    """
    cdef list v = js_visuals['Ascends per X']
    cdef str chart_id = name.lower().replace(" ", "-")
    cdef str series_str = str(series).replace("None", "null")
    cdef unsigned short width = min(160 * len(x_axis_labels), 600)
    return chart_id, Markup(v[0] + series_str + v[1] + str(width) + v[2] + str(colors) + v[3] + name + v[4] + str(x_axis_labels) + v[5] + chart_id + v[6])


cpdef tuple max_grade_per_x(str name, list series, list colors, list x_axis_labels, list y_axis_labels, int _min, int _max):
    """ Create the max grade per x visual

    Args:
        name (str): The name of the visual
        series (list): The series of data
        colors (list): The colors of the series
        x_axis_labels (list): The labels of the x axis
        y_axis_labels (list): The labels of the y axis
        _min (int): The minimum value of the y axis
        _max (int): The maximum value of the y axis

    Returns:
        tuple: The chart id and the javascript code
    """
    cdef list v = js_visuals['Max grade per X']
    cdef str chart_id = name.lower().replace(" ", "-")
    cdef str series_str = str(series).replace("None", "null")
    cdef str max_str = str(_max - 1)
    cdef unsigned short width = min(160 * len(x_axis_labels), 600)
    cdef str y_axis_labels_str = str(y_axis_labels)
    return chart_id, Markup(v[0] + series_str + v[1] + str(width) + v[2] + str(colors) + v[3] + name + v[4] + y_axis_labels_str + v[5] + str(x_axis_labels) + v[6] + y_axis_labels_str + v[7] + max_str + v[8] + max_str + v[9] + chart_id + v[10])


cpdef tuple flash_rate(list series, list labels, list colors):
    """ Create the flash rate visual

    Args:
        series (list): The series of data
        labels (list): The labels of the series
        colors (list): The colors of the series

    Returns:
        tuple: The chart id and the javascript code
    """
    cdef list v = js_visuals['Flash rate']
    cdef str series_str = str(series).replace("None", "null")
    return "flash-rate", Markup(v[0] + series_str + v[1] + str(labels) + v[2] + str(colors) + v[3])


cpdef tuple flash_rate_per_x(str name, list series, list labels, list colors):
    """ Create the flash rate per x visual

    Args:
        name (str): The name of the visual
        series (list): The series of data
        labels (list): The labels of the series
        colors (list): The colors of the series

    Returns:
        tuple: The chart id and the javascript code
    """
    cdef list v = js_visuals['Flash rate per X']
    cdef str chart_id = name.lower().replace(" ", "-")
    cdef str series_str = str(series).replace("None", "null")
    cdef unsigned short width = min(160 * len(labels), 600)
    return chart_id, Markup(v[0] + series_str + v[1] + str(width) + v[2] + str(colors) + v[3] + name + v[4] + str(labels) + v[5] + chart_id + v[6])


cpdef tuple rating_per_x(str name, list series, list labels):
    """ Create the rating per x visual

    Args:
        name (str): The name of the visual
        series (list): The series of data
        labels (list): The labels of the series

    Returns:
        tuple: The chart id and the javascript code
    """
    cdef list v = js_visuals['Rating per X']
    cdef str chart_id = name.lower().replace(" ", "-")
    cdef str series_str = str(series).replace("None", "null")
    cdef unsigned short width = min(160 * len(labels), 600)
    return chart_id, Markup(v[0] + series_str + v[1] + str(width) + v[2] + name + v[3] + str(labels) + v[4] + chart_id + v[5])
