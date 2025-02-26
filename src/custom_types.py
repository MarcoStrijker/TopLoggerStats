from typing import Literal, TypedDict
from typing_extensions import TypeIs


ClimbType = Literal["boulder", "route"]
System = Literal["french", "french_rounded", "v_grade", "british", "yds", "uiaa", "ewbank"]

AscendsRow = tuple[int, int, str, ClimbType, int]
OpinionsRow = tuple[int, int, int, bool, bool]
GymsRow = tuple[int, str, str, int, int, int, str]
WallsRow = tuple[int, str, int]
ClimbsRow = tuple[int, int, ClimbType, str, str, int, int, bool, float, int, float]


class AscendsJson(TypedDict):
    id: int
    climb_id: int
    date_logged: str
    type: ClimbType
    gym_id: int


class OpinionsJson(TypedDict):
    id: int
    climb_id: int
    uid: int
    project: bool
    voted_renew: bool
    grade_rating: int
    rating: float


class GymsJson(TypedDict):
    id: int
    name: str
    id_name: str
    nr_of_climbs: int
    nr_of_boulders: int
    nr_of_routes: int
    country: str


class WallsJson(TypedDict):
    id: int
    name: str
    gym_id: int


class ClimbsJson(TypedDict):
    id: int
    gym_id: int
    type: ClimbType
    date_live_start: str
    date_live_end: str
    wall_id: int
    grade: int
    auto_grade: bool
    grade_stability: float
    nr_of_ascends: int
    average_opinion: float


def check_system(system: str) -> TypeIs[System]:
    """Check if the system is valid

    Args:
        system (str): The system to check

    Returns:
        TypeIs[System]
    """
    return system in {"french", "french_rounded", "v_grade", "british", "yds", "uiaa", "ewbank"}


def check_climb_type(climb_type: str) -> TypeIs[ClimbType]:
    """Check if the climb type is valid

    Args:
        climb_type (str): The climb type to check

    Returns:
        TypeIs[ClimbType]
    """
    return climb_type in {"boulder", "route"}
