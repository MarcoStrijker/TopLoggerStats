from typing import Annotated, TypeAlias
from sqlite3 import Connection

from src.custom_types import ClimbType, GymsRow

u64: TypeAlias = Annotated[int, "64-bit unsigned integer"]
u16: TypeAlias = Annotated[int, "16-bit unsigned integer"]

class GradingSystem:
    climb_type: str
    integers: tuple[int, ...]
    strings: tuple[str, ...]
    ascend_types: tuple[str, ...]
    ascend_colors: tuple[str, ...]
    route: bool

    def __init__(self, climb_type: ClimbType, grading_system: str) -> None: ...
    def get_closest(self, item: u16) -> int | None: ...

def update_climbs(requested_gyms: set[u16], only_active: bool) -> None: ...
def update_walls(requested_gyms: set[u16]) -> None: ...
def update_gyms() -> None: ...
def update_user_data(
    conn: Connection, uid: u64, climb_type: ClimbType, requested_gyms: tuple[u16, ...], db_didnt_existed: bool
) -> None: ...
def create_visuals(
    conn: Connection, uid: u64, gwa: list[GymsRow], climb_type: ClimbType, grading_system: str
) -> tuple[list[str], list[tuple[str, str]]]: ...
