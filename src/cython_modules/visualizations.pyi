def ascends_per_grade(series: list, colors: list[str], x_axis_labels: list[str]) -> tuple[str, str]:
    """Create the ascends per grade visual.

    Args:
        series: The series of data
        colors: The colors of the series
        x_axis_labels: The labels of the x axis

    Returns:
        A tuple containing the chart id and the javascript code
    """

def ascends_over_time(series: list, colors: list[str], x_axis_labels: list[str]) -> tuple[str, str]:
    """Create the ascends over time visual.

    Args:
        series: The series of data
        colors: The colors of the series
        x_axis_labels: The labels of the x axis

    Returns:
        A tuple containing the chart id and the javascript code
    """

def max_grade_over_time(
    series: list, colors: list[str], y_axis_labels: list[str], x_axis_labels: list[str], _max: int
) -> tuple[str, str]:
    """Create the max grade over time visual.

    Args:
        series: The series of data
        colors: The colors of the series
        y_axis_labels: The labels of the y axis
        x_axis_labels: The labels of the x axis
        _max: The maximum value of the y axis

    Returns:
        A tuple containing the chart id and the javascript code
    """

def rating_accuracy(series: list, counts: list[int], colors: list[str]) -> tuple[str, str]:
    """Create the rating accuracy visual.

    Args:
        series: The series of data
        counts: The counts of the series
        colors: The colors of the series

    Returns:
        A tuple containing the chart id and the javascript code
    """

def grading_accuracy(
    series: list, axis_labels: list[str], counts: list[int], colors: list[str], _min: int, _max: int
) -> tuple[str, str]:
    """Create the grading accuracy visual.

    Args:
        series: The series of data
        axis_labels: The labels of the axis
        counts: The counts of the series
        colors: The colors of the series
        _min: The minimum value of the y axis
        _max: The maximum value of the y axis

    Returns:
        A tuple containing the chart id and the javascript code
    """

def ascends_per_x(name: str, series: list, colors: list[str], x_axis_labels: list[str]) -> tuple[str, str]:
    """Create the ascends per x visual.

    Args:
        name: The name of the visual
        series: The series of data
        colors: The colors of the series
        x_axis_labels: The labels of the x axis

    Returns:
        A tuple containing the chart id and the javascript code
    """

def max_grade_per_x(
    name: str, series: list, colors: list[str], x_axis_labels: list[str], y_axis_labels: list[str], _min: int, _max: int
) -> tuple[str, str]:
    """Create the max grade per x visual.

    Args:
        name: The name of the visual
        series: The series of data
        colors: The colors of the series
        x_axis_labels: The labels of the x axis
        y_axis_labels: The labels of the y axis
        _min: The minimum value of the y axis
        _max: The maximum value of the y axis

    Returns:
        A tuple containing the chart id and the javascript code
    """

def flash_rate(series: list, labels: list[str], colors: list[str]) -> tuple[str, str]:
    """Create the flash rate visual.

    Args:
        series: The series of data
        labels: The labels of the series
        colors: The colors of the series

    Returns:
        A tuple containing the chart id and the javascript code
    """

def flash_rate_per_x(name: str, series: list, labels: list[str], colors: list[str]) -> tuple[str, str]:
    """Create the flash rate per x visual.

    Args:
        name: The name of the visual
        series: The series of data
        labels: The labels of the series
        colors: The colors of the series

    Returns:
        A tuple containing the chart id and the javascript code
    """

def rating_per_x(name: str, series: list, labels: list[str]) -> tuple[str, str]:
    """Create the rating per x visual.

    Args:
        name: The name of the visual
        series: The series of data
        labels: The labels of the series

    Returns:
        A tuple containing the chart id and the javascript code
    """
