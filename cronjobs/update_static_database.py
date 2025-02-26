import os
import sys
import logging
import time
from datetime import datetime as dt, timedelta as td
from typing import Annotated, Callable, TypedDict

from pytz import utc, country_timezones, timezone

from database import retrieve_all_gyms

directory = os.path.dirname(os.path.realpath(__file__))
if directory not in sys.path:
    sys.path.append(directory)

from cython_modules.engine import update_climbs, update_gyms, update_walls
from cython_modules.constants import LOG_DIRECTORY

logging.basicConfig(
    filename=os.path.join(LOG_DIRECTORY, dt.now().strftime("%Y-%m-%d") + ".log"),
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO,
)
logger = logging.getLogger(__name__)


MINUTES_DELAY = 3


u16 = Annotated[int, "Unsigned 16-bit integer"]


class Job(TypedDict):
    function: Callable[[set[u16], int], None] | Callable[[set[u16]], None]
    run_date: dt
    args: tuple[set[u16], int] | tuple[set[u16]]


def custom_array_split[T](array: list[T], sections: int) -> list[list[T]]:
    """Function that splits an array into a number of sections

    Arguments:
        array (list): List of items to split
        sections (int): Number of sections

    Returns:
        list: List of sections
    """
    if sections <= 0:
        raise ValueError("Number of sections must be a positive integer.")

    n = len(array)
    # Determine the size of each chunk
    quotient, remainder = divmod(n, sections)

    # Build the indices to split the array
    split_indices = []
    start = 0
    for i in range(sections):
        end = start + quotient + (1 if i < remainder else 0)
        split_indices.append(array[start:end])
        start = end

    return split_indices


def parse_offset(offset: str) -> td:
    """Function that converts a timezone offset to a timedelta object

    Arguments:
        offset (str): Timezone offset string

    Returns:
        timedelta: Offset from UTC
    """

    sign = -1 if offset[0] == "-" else 1
    hours = sign * int(offset[1:3])
    minutes = sign * int(offset[3:5])
    return td(hours=hours, minutes=minutes)


def convert_timezone_to_offset(text: str) -> td:
    """Function that converts a timezone to a timedelta object representing the offset from UTC

    Arguments:
        tz (str): Timezone string

    Returns:
        timedelta: Offset from UTC
    """

    tz = timezone(text).localize(dt(2500, 1, 1)).strftime("%z")

    return parse_offset(tz)


def divide_gyms_into_timezones(gyms: list[tuple]) -> dict[td, list[int]]:
    """Function that divides gyms into timezones

    Arguments:
        gyms (list): List of gyms

    Returns:
        dict[td, list]: Dictionary of timezone offsets and gym ids
    """
    timezones_updates: dict[td, list[int]] = {}
    for g in gyms:
        # Get all unique offsets of the country of the gym
        offsets = {convert_timezone_to_offset(tz) for tz in country_timezones[g[6]]}
        mean_offset = td(seconds=sum(map(lambda x: x.total_seconds(), offsets)) / len(offsets))

        if mean_offset not in timezones_updates:
            timezones_updates[mean_offset] = []

        timezones_updates[mean_offset].append(g[0])

    return timezones_updates


def create_jobs_for_gyms(timezones_updates: dict[td, list[int]], utc_based_hour: int) -> list[Job]:
    """Function that creates the jobs for the scheduler

    Args:
        timezones_updates (dict): Dictionary of timezone offsets and gym ids
        utc_based_hour (int): Hour in utc for the database update. Defaults to 4.

    Returns:
        list: List of jobs for the scheduler
    """
    jobs = []

    for offset, gym_ids in timezones_updates.items():

        # The base time for the gyms in this time zone
        # When there are more than 20 gyms, split to prevent overload on the TL servers
        initial_datetime = dt.now(utc).replace(hour=utc_based_hour, minute=0) + td(days=1) + offset
        number_of_requests = len(gym_ids) // 10 + (len(gym_ids) > 0)

        # Make sure that the number of request are not even
        # In this way there is always a request on the 'utc_based_hour'
        number_of_requests += 0 if number_of_requests % 2 else 1

        logger.info(f"Number of requests for {offset}: {number_of_requests}")

        for i, items in enumerate(custom_array_split(gym_ids, number_of_requests)):
            jobs += create_jobs_batch(initial_datetime, number_of_requests, items, i)

    return jobs


def create_jobs_batch(base_timedelta: dt, number_of_requests: int, gyms: list[int], nr: int) -> list[Job]:
    """Function that creates jobs for a batch of gyms within a specific timezone

    Arguments:
        base_timedelta (dt): Base time for the jobs
        number_of_requests (int): Number of requests
        gyms (list): List of gym ids
        nr (int): Number of the request in the batch

    Returns:
        list: List of jobs for the scheduler
    """

    actual_timedelta = base_timedelta + td(minutes=nr - (number_of_requests - 1) / 2 * 30 - 10)

    jobs_batch.append({"function": update_walls, "run_date": actual_timedelta, "args": (set(gyms),)})

    gyms_string = "; ".join(str(_id) for _id in gyms)
    logger.info(f"The following gyms will be fetched at {actual_timedelta}: {gyms_string}")

    jobs_batch: list[Job] = []
    for ix in range(len(gyms) // MINUTES_DELAY + len(gyms) % MINUTES_DELAY):
        gyms_in_request = set(gyms[ix * MINUTES_DELAY : (ix + 1) * MINUTES_DELAY])
        micro_adjusted_datetime = actual_timedelta + td(minutes=ix)

        jobs_batch.append(
            {"function": update_climbs, "run_date": micro_adjusted_datetime, "args": (gyms_in_request, 1)}
        )

    return jobs_batch


def update_database(utc_based_hour: int = 4) -> None:
    """Function that is called each day to update all gyms according to their own timezone

    Keyword Arguments:
        utc_based_hour {int} -- Hour in utc for the database update. Defaults to 4.
    """
    # Get gyms
    update_gyms()

    gyms = retrieve_all_gyms()
    timezones_updates = divide_gyms_into_timezones(gyms)
    to_be_scheduled_jobs = create_jobs_for_gyms(timezones_updates, utc_based_hour)
    to_be_scheduled_jobs.sort(key=lambda x: x["run_date"])

    logger.info(
        f"Jobs to be scheduled: \n"
        + "\n".join([f"{job['run_date']} - {job['function'].__name__}" for job in to_be_scheduled_jobs])
    )

    for job in to_be_scheduled_jobs:
        current_time = dt.now(utc)
        time_difference = (job["run_date"] - current_time).total_seconds()
        time_difference = time_difference if time_difference > 0 else 0

        logger.info(f"Sleeping for {time_difference} seconds")

        time.sleep(time_difference)

        job["function"](*job["args"])
        logger.info(f"Job {job['function']} finished at {dt.now(utc)}")


if __name__ == "__main__":
    update_database()
    logger.info("Finished updating database")
