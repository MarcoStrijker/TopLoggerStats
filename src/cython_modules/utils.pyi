import re

from custom_types import GymsRow

pat1: re.Pattern[str]
pat2: re.Pattern[str]
pat3: re.Pattern[str]

def filter_gyms(all_gyms: list[GymsRow], gym_ids: set[int], gym: str | None) -> list[GymsRow]:
    """Filters the gyms based on the gym_ids and the gym name

    If no gym name is provided, all gyms with the provided gym ids will be returned. If a gym
    name is provided, only the gyms within the provided gym ids and gym name will be returned.

    Arguments:
        all_gyms: The list of all gyms
        gym_ids: The set of gym ids
        gym: The gym name or None

    Returns:
        The filtered gyms
    """

def minify(html: str) -> str:
    """Minifies the html code

    Arguments:
        html: The html code

    Returns:
        The minified html code
    """

def filter_remembered_users(
    remembered_users: list[str], last_remembered_user: str
) -> tuple[list[str], list[tuple[str, str, str]]]:
    """Filters the remembered users if the last remembered user is not empty

    If the last remembered user is not empty, it will be added to the list of remembered users.
    This function will ensure the list of remembered users is unique and sorted.

    Arguments:
        remembered_users: The list of remembered users, this is a list of identifiers
            e.g. "John Doe:::1234567890::Gym Name"
        last_remembered_user: The last remembered user

    Returns:
        An tuple with all remembered users and the structured remembered users (list of tuples with user, uid, and gym name)
    """

def convert_grade(old_grade: str) -> int:
    """Normalizes the grade to the our own grade metric

    TopLogger has two internal grade metrics:
    - 200, 250, 300, etc.
    - 2.00, 2.50, 3.00, etc.

    When there is no grade, the API should pass "0" and this function should return 0.

    Arguments:
        old_grade: The old grade

    Returns:
        The new grade
    """
