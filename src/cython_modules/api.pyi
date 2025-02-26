from typing import Any, Annotated, TypeAlias

from requests import Session
from httpx import AsyncClient

from src.custom_types import AscendsJson, ClimbType, GymsJson, WallsJson, OpinionsJson, ClimbsJson

u64: TypeAlias = Annotated[int, "64-bit unsigned integer"]
u16: TypeAlias = Annotated[int, "16-bit unsigned integer"]

s: Session
client: AsyncClient

def fetch_first_name_user(uid: u64) -> str:
    """Get the first name of the user, so the application gives a more personal touch.

    Args:
      uid {str} -- The internal TopLogger user id

    Returns:
      The first name of the user {str}

    """

def fetch_gyms() -> list[GymsJson]:
    """Fetch all gyms from TopLogger."""

def fetch_walls(gym_ids: set[u16]) -> list[WallsJson]:
    """Fetch all walls from TopLogger.

    Args:
      gym_ids {set} -- The internal TopLogger gym ids

    Returns:
        A list of walls {list}

    """

def fetch_opinions(gym_ids: set[u16], uid: u64, only_active: bool = False) -> list[OpinionsJson]:
    """Fetch all opinions from TopLogger.

    Args:
      gym_ids {set} -- The internal TopLogger gym ids
      uid {int} -- The internal TopLogger user id

    Keyword Arguments:
      only_active {int} -- Whether to fetch opinions from active climbs only (default: 0)

    Returns:
        A list of opinions {list}

    """

def fetch_ascends(gym_ids: set[u16], uid: u64, climb_type: ClimbType, only_active: bool = False):
    """Fetch all ascends from TopLogger.

    Args:
      gym_ids {set} -- The internal TopLogger gym ids
      uid {int} -- The internal TopLogger user id
      climb_type {CLIMB_TYPES} -- The type of ascends to fetch (boulders or routes)

    Keyword Arguments:
        only_active {int} -- Whether to fetch ascends from active climbs only (default: 0)

    Returns:
        A list of ascends {list[Ascend]}

    """

def fetch_climbs(gym_ids: set[u16], only_active: bool = False) -> list[ClimbsJson]:
    """Fetch all climbs from TopLogger.

    Args:
      gym_ids {set} -- The internal TopLogger gym ids

    Keyword Arguments:
      only_active {int} -- Whether to fetch climbs from active climbs only (default: 0)

    Returns:
        A list of climbs {list}

    """

def fetch_users(gym_id: u64) -> list[tuple[int, str]]:
    """Fetch all users from TopLogger. Executes two requests, one for the climb
    users and one for the boulder users.

    Args:
      gym_id {int} -- The internal TopLogger gym id

    Returns:
        A list of users {list}

    """

async def async_fetch_ascends(encoded_params: str) -> list[AscendsJson]:
    """Fetches the ascends from the API asynchronously."""

async def async_fetch_opinions(encoded_params: str) -> list[OpinionsJson]:
    """Fetches the opinions from the API asynchronously."""

async def async_fetch_user_data(
    uid: u64, gym_ids_full: set[u16], gym_ids_partial: set[u16], climb_type: ClimbType
) -> tuple[list[AscendsJson], list[OpinionsJson]]:
    """Fetches the user data asynchronously. Creates different tasks for the full and partial gyms."""
