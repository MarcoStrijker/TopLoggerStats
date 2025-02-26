from ctypes import c_uint64 as u64
from sqlite3 import Cursor

from src.cython_modules.engine import GradingSystem

def top_grade(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> list[tuple[str, str]]:
    """Retrieves the top grade for each ascend type and returns the stats

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        list: The top grade for each ascend type
    """

def number_of_ascends(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> list[tuple[str, str]]:
    """Retrieves the number of ascends for each ascend type and returns the stats

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        list: The number of ascends for each ascend type
    """

def flash_rate(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the flash rate for each ascend type and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the flash rate for each ascend type
    """

def max_grade_over_time(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the max grade over time and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the max grade over time
    """

def ascends_over_time(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple:
    """Retrieves the ascends over time and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the ascends over time
    """

def ascends_per_grade(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the ascends per grade and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the ascends per grade
    """

def flash_rate_per_grade(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Wrapper function which uses the flash_rate_per_x to retrieve the flash rate per grade

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the flash rate per grade
    """

def grading_accuracy(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the grading accuracy and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the grading accuracy
    """

def rating_accuracy(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the rating accuracy and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the rating accuracy
    """

def number_of_ascends_per_x(cursor: Cursor, uid: u64, query: str, system: GradingSystem) -> tuple:
    """Retrieves the number of ascends per x and returns the data

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        query (str): The query
        system (GradingSystem): The system

    Returns:
        tuple: The data with the number of ascends per x
    """

def number_of_ascends_per_wall(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the number of ascends per wall and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the number of ascends per wall
    """

def number_of_ascends_per_gym(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the number of ascends per gym and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the number of ascends per gym
    """

def max_grade_per_x(cursor: Cursor, uid: u64, sql_gyms: str, query: str, system: GradingSystem) -> tuple:
    """Retrieves the max grade per x and returns the data

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        query (str): The query
        system (GradingSystem): The system

    Returns:
        tuple: The data with the max grade per x
    """

def max_grade_per_wall(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the max grade per wall and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the max grade per wall
    """

def max_grade_per_gym(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the max grade per gym and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the max grade per gym
    """

def flash_rate_per_x(
    cursor: Cursor, uid: u64, sql_gyms: str, query: str, system: GradingSystem, label_is_grade: bool = False
) -> tuple:
    """Retrieves the flash rate per x and returns the data

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        query (str): The query
        system (GradingSystem): The system
        label_is_grade (bool): Whether the labels are grades

    Returns:
        tuple: The data with the flash rate per x
    """

def flash_rate_per_wall(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the flash rate per wall and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the flash rate per wall
    """

def flash_rate_per_gym(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the flash rate per gym and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the flash rate per gym
    """

def rating_per_x(cursor: Cursor, uid: u64, sql_gyms: str, query: str, system: GradingSystem) -> tuple:
    """Retrieves the rating per x and returns the data

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        query (str): The query
        system (GradingSystem): The system

    Returns:
        tuple: The data with the rating per x
    """

def rating_per_ascends_type(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the rating per ascend type and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the rating per ascend type
    """

def rating_per_wall(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the rating per wall and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the rating per wall
    """

def rating_per_gym(cursor: Cursor, uid: u64, sql_gyms: str, system: GradingSystem) -> tuple[str, str]:
    """Retrieves the rating per gym and returns the visual

    Arguments:
        cursor (Cursor): The database cursor
        uid (u64): The user id
        sql_gyms (str): The gym ids
        system (GradingSystem): The system

    Returns:
        tuple: The visual with the rating per gym
    """
