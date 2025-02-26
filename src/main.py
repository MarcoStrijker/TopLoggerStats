import os

from datetime import timedelta, datetime as dt
from os import urandom
from sqlite3 import connect
from typing import Any

from flask import Flask, Response, render_template, request, url_for, redirect, abort, session, make_response
from flask_caching import Cache
from werkzeug.wrappers import Response as WerkzeugResponse

from src.custom_types import GymsRow, check_climb_type, check_system
from src.database import copy_user_db, enrich_user_table_and_get_ascends, retrieve_all_gyms
from src.cython_modules.utils import filter_gyms, filter_remembered_users, minify
from src.cython_modules.api import fetch_users
from src.cython_modules.engine import update_user_data, create_visuals
from src.cython_modules.constants import (
    CSP_DASHBOARD_FORMAT_STRING,
    USER_DB_FORMAT_STRING,
    CSP_START,
    CSP_ERROR,
)


app = Flask(__name__, static_folder="static", static_url_path="/static", template_folder="templates")
app.config["PERMANENT_SESSION_LIFETIME"] = timedelta(days=365)
app.secret_key = os.getenv("SECRET_KEY")

# We have only enabled caching for the actual server
# If we are running locally, we don't want caching but we want the response times
if os.getenv("PROD"):
    cache = Cache(app, config={"CACHE_TYPE": "MemcachedCache", "CACHE_MEMCACHED_SERVERS": ("127.0.0.1:11211",)})
else:
    cache = Cache(app, config=None)


class NoAscendsFound(Exception):
    """Exception raised when no ascends are found at the selected gyms."""


@cache.cached(timeout=21600)
def gyms() -> list[GymsRow]:
    """Retrieves and sorts the gyms from the database. Sorting will happen by the gym name.
    This function will be cached, so the gyms are only retrieved once every 6 hours.

    Returns:
        list: The gyms sorted by name.
    """
    return sorted(retrieve_all_gyms(), key=lambda d: d[1])


def error_handler(error_code: int, title: str, message: str) -> Response:
    """Handles the error response.

    Args:
        error_code (int): The error code
        title (str): The title of the error
        message (str): The message of the error

    Returns:
        tuple: The error response
    """
    html = minify(
        render_template(
            "error_template.html",
            error_title=title,
            error_message=message,
        )
    )

    response = make_response(html, error_code)
    response.headers["Content-Security-Policy"] = CSP_ERROR
    return response


@app.errorhandler(400)
def error_400(*args: Any, **kwargs: Any) -> Response:
    return error_handler(400, "400: Bad request", "The request you've made seemed wrong")


@app.errorhandler(404)
def error_404(*args: Any, **kwargs: Any) -> Response:
    return error_handler(404, "404: Page not found", "Nothing here")


@app.errorhandler(NoAscendsFound)
def error_404_no_ascends(*args: Any, **kwargs: Any) -> Response:
    return error_handler(
        404, "404: No ascends found at the selected gyms", "Did you choose the right gyms and type of climbing?"
    )


@app.errorhandler(500)
def error_500(*args: Any, **kwargs: Any) -> Response:
    return error_handler(
        500, "500: Internal server error", "The application didn't work properly. We're very sorry for that :("
    )


@app.route("/", methods=("GET",))
def home() -> Response:
    """Endpoint for the home page. This page is the first step in the process of rendering the dashboard.

    This function should pass the fingerprint, so it can be used to preload the user data.
    """

    remembered_users, structured_remembered_users = filter_remembered_users(
        session.get("remember-me", []), request.cookies.get("remembered", "")
    )
    session["remember-me"] = remembered_users

    response = make_response(
        minify(
            render_template(
                "start.html",
                gyms=gyms(),
                remembered_users=structured_remembered_users,
                preload_key=str(hash(dt.now().strftime("%Y-%m-%d-%H"))),
            )
        ),
        200,
    )
    response.headers["Content-Security-Policy"] = CSP_START
    response.set_cookie("remembered", "", expires=0)
    return response


@app.route("/<int:uid>", defaults={"gym": None})
@app.route("/<int:uid>/<gym>")
def main_dashboard(uid: int, gym: str | None) -> Response:
    """This function will render the user specific dashboard.

    Can be called for a combined dashboard or a single gym dashboard.

    Arguments:
        uid (int): The user id of the user
        gym (str | None): The id of the gym the user wants to see. If combined, this will be None.

    """
    try:
        climb_type = request.cookies["climb_type"]
        grading_system = request.cookies["grading_system"]
        requested_gyms = tuple(int(g) for g in request.cookies["gyms"].split(","))
        name = request.cookies["name"]
    except KeyError:
        abort(400)

    if not check_climb_type(climb_type):
        abort(400)

    if not check_system(grading_system):
        abort(400)

    # Only combined paged are cached since child pages always have their data fetched
    # in advance, and thus have minor loading times
    if not gym:
        cache_identifier = str(hash((uid, climb_type, grading_system, requested_gyms)))
        data = cache.get(cache_identifier)
        if data is not None:
            return data

    requested_gyms_set = set(requested_gyms)

    db_copied = copy_user_db(USER_DB_FORMAT_STRING.format(uid))

    with connect(USER_DB_FORMAT_STRING.format(uid), isolation_level="EXCLUSIVE") as c:
        update_user_data(c, uid, climb_type, requested_gyms, db_copied)
        all_gyms = gyms()

        gym_ids_with_ascends = enrich_user_table_and_get_ascends(c, climb_type, grading_system, requested_gyms)
        all_gyms_selected = filter_gyms(all_gyms, requested_gyms_set, None)
        gyms_in_view = filter_gyms(all_gyms, requested_gyms_set, gym)

        if not gym_ids_with_ascends:
            raise NoAscendsFound

        if len(gym_ids_with_ascends) == 1:
            gyms_with_ascends = filter_gyms(all_gyms, gym_ids_with_ascends, None)
            dashboard_objects = create_visuals(c, uid, gyms_with_ascends, climb_type, grading_system)
        else:
            dashboard_objects = create_visuals(c, uid, gyms_in_view, climb_type, grading_system)

    # To prevent XSS, we generate a nonce and pass it into the template
    nonce = urandom(16).hex()

    # Render the page
    response = make_response(
        minify(
            render_template(
                "dashboard.html",
                username=name,
                gyms=all_gyms_selected,
                multiple_gyms_requested=len(requested_gyms_set) > 1,
                gyms_in_view=gyms_in_view,
                gyms_with_ascends=gym_ids_with_ascends,
                uid=uid,
                nonce=nonce,
                stats=dashboard_objects[0],
                visuals=dashboard_objects[1],
            )
        ),
        200,
    )
    response.headers["Content-Security-Policy"] = CSP_DASHBOARD_FORMAT_STRING.format(nonce)

    # Only cache the combined dashboard
    if not gym:
        cache.set(cache_identifier, response, timeout=900)

    return response


@app.route("/example-dashboard", methods=("GET",))
def example_dashboard() -> Response | WerkzeugResponse:
    """This endpoint is used to show the example dashboard. It will redirect to the dashboard page
    of the creator of the app.
    """
    response = redirect(url_for("main_dashboard", uid=6693546282))
    response.set_cookie("uid", "6693546282")
    response.set_cookie("gyms", "130,183,95")
    response.set_cookie("climb_type", "boulder")
    response.set_cookie("grading_system", "french_rounded")
    response.set_cookie("name", "Marco")

    cache.delete("6693546282")

    return response


# API endpoints
##########################


@app.route("/api/users/<int:gym_id>", methods=("GET",))
@cache.memoize(timeout=43200)
def get_users_by_name(gym_id: int) -> list[tuple[int, str]]:
    """Retrieves the users from the database by the name of the gym.

    Arguments:
        gym_id (int): The id of the gym

    Returns:
        list: The users from the gym
    """
    return fetch_users(gym_id)


@app.route("/api/preload/<int:uid>", methods=("POST",))
def preload(uid: int) -> tuple[str, int]:
    """To reduce load times, we have a preload endpoint that will preload the user data for the user.

    In the front end the page will send preload request based on certain events. The front end
    has to send a fingerprint of the current hour in the request data, so we can check if the preload
    is still valid.

    Args:
        uid (int): The user id of the user

    Notes:
        - The fingerprint is a hash of current hour and should be passed to the front end.
        - The preload is check against the current hour, so if the user visits the page at 10:59,
          the preload will be invalidated at 11:00. However, this only results in a small
          amount of requests being invalidated.
    """

    data = request.get_json()
    if "fp" not in data or data["fp"] != str(hash(dt.now().strftime("%Y-%m-%d-%H"))):
        return "Invalid request", 400

    try:
        climb_type = data["climb_type"]
        requested_gyms = data["gym_ids"]
    except KeyError:
        return "Invalid request", 400

    if climb_type not in {"boulder", "route"}:
        return "Invalid request", 400

    db_copied = copy_user_db(USER_DB_FORMAT_STRING.format(uid))

    with connect(USER_DB_FORMAT_STRING.format(uid), isolation_level="EXCLUSIVE") as c:
        update_user_data(c, uid, climb_type, tuple(requested_gyms), db_copied)

    return "Preloaded", 200
