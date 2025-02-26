# cython: language_level=3, binding=False, boundscheck=False, wraparound=False, initializedcheck=False, nonecheck=False, infer_types=False, profile=False, cdivision=False, type_version_tag=False, unraisable_tracebacks=False
# distutils: language=c++

import httpx
import asyncio
import json

from urllib.parse import urlencode
from urllib.parse import quote
from httpx import AsyncHTTPTransport
from requests import Session
from requests.adapters import Retry, HTTPAdapter

from src.cython_modules.utils import convert_grade
from src.cython_modules.constants cimport REQUEST_URL, ASCEND_TYPES


cdef object client = httpx.AsyncClient(transport=AsyncHTTPTransport(retries=3))
cdef object s = Session()
s.mount('https://', HTTPAdapter(max_retries=Retry(total=5, backoff_factor=0.1, status_forcelist=[500, 502, 503, 504])))


cpdef list fetch_gyms():
    """Fetches the gyms from the API.

    Returns:
        list: The gyms
    """

    return [(
        r['id'],
        r['name'],
        r["id_name"],
        r['nr_of_climbs'],
        r['nr_of_boulders'],
        r['nr_of_routes'],
        r['country']
    ) for r in _get(f"{REQUEST_URL}/gyms.json")]


cpdef list fetch_walls(set gym_ids):
    """Fetches the walls from the API.

    Args:
        gym_ids (set): The gym ids to fetch the walls for

    Returns:
        list: The walls
    """

    cdef list walls
    cdef unsigned short gym
    walls = []
    for gym in gym_ids:
        walls += [(
            r["id"],
            r.get("name", "Unknown"),
            r["gym_id"]
        ) for r in _get(f"{REQUEST_URL}/gyms/{gym}/walls.json")]

    return walls


cpdef list fetch_climbs(set gym_ids, bint only_active = 0):
    """Fetches the climbs from the API.

    Args:
        gym_ids (set): The gym ids to fetch the climbs for
        only_active (bool): Whether to fetch only active climbs

    Returns:
        list: The climbs

    Note:
        Since the request url is unreadable, here is a more readable version:
        Url: https://api.toplogger.nu/v1/gyms/{gym_id}/climbs.json_params
        Json params (but only when only_active is true): {
            filters: {
                deleted: false
            }
        }
    """

    cdef unsigned short _id
    cdef list climbs = []

    json_params = '?json_params=%7B"filters":%7B"deleted":false%7D%7D' if only_active else ''
    for _id in gym_ids:
        climbs += [(
            r["id"],
            r["gym_id"],
            r["climb_type"],
            r.get("date_live_start", "")[:19].replace("T", " "),
            r.get("date_live_end", "")[:19].replace("T", " "),
            r.get("wall_id", 0),
            convert_grade(r.get("grade", "0")),
            r.get("auto_grade", 0),
            r.get("grade_stability", ""),
            r.get("nr_of_ascends", 0),
            r.get("average_opinion", "")
        ) for r in _get(f'{REQUEST_URL}/gyms/{_id}/climbs.json{json_params}')
        ]
    return climbs


cpdef list fetch_users(unsigned short gym_id):
    """Fetches the users from the API.

    Args:
        gym_id (unsigned short): The gym id

    Returns:
        list: The users
    """

    return [[user['uid'], user['full_name'].strip()] for user in _get(f"{REQUEST_URL}/gyms/{gym_id}/ranked_gym_users.json?climbs_type=boulders&ranking_type=grade") + _get(f"{REQUEST_URL}/gyms/{gym_id}/ranked_gym_users.json?climbs_type=routes&ranking_type=grade")]


cdef list _get(str request_url):
    """Actually makes the request to the API and returns the response

    Args:
        request_url (str): The request url

    Returns:
        list: The response
    """
    return s.get(request_url).json()


async def async_fetch_ascends(encoded_params: str):
    """Fetches the ascends from the API asynchronously.

    Args:
        encoded_params (str): The encoded parameters

    Returns:
        list: The ascends
    """
    response = await client.get(f"{REQUEST_URL}/ascends.json?{encoded_params}&serialize_checks=true")
    return convert_response_ascends(response.json())


cdef list convert_response_ascends(list response):
    """Converts the response from the API to a list of ascends

    Args:
        response (list): The response

    Returns:
        list: The ascends
    """
    return [(
        r["id"],
        r["climb_id"],
        r['date_logged'][:19].replace("T", " "),
        ASCEND_TYPES[r['checks']]
    ) for r in response]


async def async_fetch_opinions(encoded_params: str, uid: int):
    """Fetches the opinions from the API asynchronously.

    Args:
        encoded_params (str): The encoded parameters
        uid (int): The user id

    Returns:
        list: The opinions
    """
    response = await client.get(f"{REQUEST_URL}/opinions.json?{encoded_params}&serialize_checks=true")
    return convert_response_opinions(response.json(), uid)


cdef list convert_response_opinions(list response, unsigned long long uid):
    """Converts the response from the API to a list of opinions

    Args:
        response (list): The response
        uid (int): The user id

    Returns:
        list: The opinions
    """
    return [(
        r["id"],
        r["climb_id"],
        uid,
        r["project"],
        r["voted_renew"],
        convert_grade(r.get("grade", "0")),
        float(r.get("rating", 'nan'))
    ) for r in response]


async def async_fetch_user_data(uid: int, gym_ids_full: set, gym_ids_partial: set, climb_type: str):
    """Fetches the user data asynchronously. Creates different tasks for the full and partial gyms.

    Args:
        uid (int): The user id
        gym_ids_full (set): The gym ids to fetch the full data for
        gym_ids_partial (set): The gym ids to fetch the partial data for
        climb_type (str): The type of climbs to fetch

    Returns:
        list: The user data
    """
    tasks = []
    if gym_ids_full:
        full_params = urlencode({"json_params": json.dumps({
            "filters": {
                "used": True,
                "user": {"uid": uid},
                "climb": {"gym_id": list(gym_ids_full)},
                "type": climb_type,
            }
        })}, quote_via=quote)
        tasks.append(async_fetch_ascends(full_params))
        tasks.append(async_fetch_opinions(full_params, uid))

    if gym_ids_partial:
        partial_params = urlencode({"json_params": json.dumps({
            "filters": {
                "used": True,
                "user": {"uid": uid},
                "climb": {"gym_id": list(gym_ids_partial)},
                "deleted": True,
                "type": climb_type,
            }
        })}, quote_via=quote)
        tasks.append(async_fetch_ascends(partial_params))
        tasks.append(async_fetch_opinions(partial_params, uid))

    return await asyncio.gather(*tasks)
