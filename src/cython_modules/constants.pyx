# cython: language_level=3, binding=False, boundscheck=False, wraparound=False, initializedcheck=False, nonecheck=False, infer_types=False, profile=False, cdivision=False, type_version_tag=False, unraisable_tracebacks=False
# distutils: language=c++

import os
import re


# Project paths
cdef str PROJECT_DIRECTORY = os.path.dirname(os.path.dirname(__file__))
cdef str DATA_DIRECTORY = os.path.join(PROJECT_DIRECTORY, "data")
cdef str USER_DATA_DIRECTORY = os.path.join(DATA_DIRECTORY, "user databases")
cdef str LOG_DIRECTORY = os.path.join(DATA_DIRECTORY, "logs")

cdef str DATA_DB = os.path.join(DATA_DIRECTORY, "data.db")
cdef str UPDATE_DB = os.path.join(DATA_DIRECTORY, "updates.db")

cdef str DEFAULT_USER_DB = os.path.join(USER_DATA_DIRECTORY, "default_user.db")
cdef str USER_DB_FORMAT_STRING = os.path.join(USER_DATA_DIRECTORY, "{}.db")

cdef str JS_VISUAL_PATH_FORMAT_STRING = os.path.join(PROJECT_DIRECTORY, 'visuals', '{}.js')

# Database URIs
cdef str DATA_URI = rf"file:{DATA_DB}?mode=ro"
cdef str GYMS_URI = rf"file:{DATA_DB}?mode=ro#gyms"
cdef str USER_UPDATE_URI = rf"file:{UPDATE_DB}?mode=ro#user_updates"

# Content Security Policy strings
cdef str CSP_START = "default-src 'self'; img-src 'self'; script-src 'self' https://code.jquery.com https://cdnjs.cloudflare.com/ajax/libs/apexcharts/3.43.0/apexcharts.min.js 'sha256-5VWfW+C81JGn+ecvhWvwNSBRjrBUw91+zOefqi5fCo0=' 'sha256-aDVVMAay2NANFRPzq3S+H/U++HC/cROM0caCSNpShsY='; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src https://fonts.gstatic.com;"
cdef str CSP_ERROR = "default-src 'self'; img-src 'self'; script-src 'self' https://code.jquery.com https://cdnjs.cloudflare.com/ajax/libs/apexcharts/3.43.0/apexcharts.min.js 'sha256-5VWfW+C81JGn+ecvhWvwNSBRjrBUw91+zOefqi5fCo0='; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src https://fonts.googleapis.com;"
cdef str CSP_DASHBOARD_FORMAT_STRING = "default-src 'self'; img-src 'self' https://cdn1.toplogger.nu/; script-src 'self' https://code.jquery.com https://cdnjs.cloudflare.com/ajax/libs/apexcharts/3.43.0/apexcharts.min.js 'sha256-5VWfW+C81JGn+ecvhWvwNSBRjrBUw91+zOefqi5fCo0=' 'nonce-{}'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; font-src https://fonts.gstatic.com;"


# File specific constants
#########################

# visualization.pyx
cdef tuple JS_VISUAL_NAMES = (
    'Ascends over time',
    'Ascends per grade',
    'Ascends per X',
    'Flash rate',
    'Flash rate per X',
    'Grading accuracy',
    'Max grade over time',
    'Max grade per X',
    'Rating accuracy',
    'Rating per X'
)

# This regex pattern is used to remove all comments and unnecessary whitespace from the javascript code.
cdef CLEAN_JS_PAT = re.compile(r"(?s)\s{2,}|/\*.*?\*/|//[^\r\n]*")


# statistics processor.pyx
cdef unsigned char THRESHOLD_RATINGS = 10


# engine.pyx
cdef dict SYSTEMS = {'boulder': {'french': {250: '2', 275: '2+', 300: '3A', 333: '3B', 367: '3C', 400: '4A', 433: '4B', 467: '4C', 500: '5A', 517: '5A+', 533: '5B', 550: '5B+', 567: '5C', 583: '5C+', 600: '6A', 617: '6A+', 633: '6B', 650: '6B+', 667: '6C', 683: '6C+', 700: '7A', 717: '7A+', 733: '7B', 750: '7B+', 767: '7C', 783: '7C+', 800: '8A', 817: '8A+', 833: '8B', 850: '8B+', 867: '8C', 883: '8C+', 900: '9A', 917: '9A+', 933: '9B', 950: '9B+'}, 'french_rounded': {250: '2', 275: '2+', 300: '3', 333: '3+', 367: '4-', 400: '4', 433: '4+', 467: '5-', 500: '5', 550: '5+', 600: '6A', 617: '6A+', 633: '6B', 650: '6B+', 667: '6C', 683: '6C+', 700: '7A', 717: '7A+', 733: '7B', 750: '7B+', 767: '7C', 783: '7C+', 800: '8A', 817: '8A+', 833: '8B', 850: '8B+', 867: '8C', 883: '8C+', 900: '9A', 917: '9A+', 933: '9B', 950: '9B+'}, 'v_grade': {300: 'VB', 350: 'V0-', 400: 'V0', 450: 'V0+', 500: 'V1', 550: 'V2', 600: 'V3', 633: 'V4', 667: 'V5', 700: 'V6', 720: 'V7', 740: 'V8', 760: 'V9', 780: 'V10', 800: 'V11', 817: 'V12', 833: 'V13', 850: 'V14', 867: 'V15', 883: 'V16', 900: 'V17'}, 'british': {200: 'B0', 300: 'B1', 383: 'B2', 500: 'B3', 600: 'B4', 628: 'B5', 656: 'B6', 683: 'B7', 711: 'B8', 739: 'B9', 767: 'B10', 787: 'B11', 808: 'B12', 829: 'B13', 850: 'B14', 867: 'B15', 883: 'B16', 900: 'B17'}}, 'route': {'french': {250: '2', 300: '3a', 333: '3b', 367: '3c', 400: '4a', 433: '4b', 467: '4c', 500: '5a', 517: '5a+', 533: '5b', 550: '5b+', 567: '5c', 583: '5c+', 600: '6a', 617: '6a+', 633: '6b', 650: '6b+', 667: '6c', 683: '6c+', 700: '7a', 717: '7a+', 733: '7b', 750: '7b+', 767: '7c', 783: '7c+', 800: '8a', 817: '8a+', 833: '8b', 850: '8b+', 867: '8c', 883: '8c+', 900: '9a', 917: '9a+', 933: '9b', 950: '9b+'}, 'ewbank': {200: '7', 300: '8', 333: '9', 367: '10', 400: '11', 433: '12', 466: '13', 500: '14', 533: '15', 567: '16', 600: '17', 617: '18', 633: '19', 650: '20', 667: '21', 683: '22', 700: '23', 717: '24', 733: '25', 750: '26', 767: '27', 783: '28', 800: '29', 817: '30', 833: '31', 850: '32', 867: '33', 883: '34', 900: '35', 917: '36', 933: '37', 950: '38'}, 'uiaa': {200: 'III', 300: 'IV-', 344: 'IV', 389: 'IV+', 433: 'V-', 467: 'V', 492: 'V+', 521: 'VI-', 550: 'VI', 578: 'VI+', 606: 'VII-', 633: 'VII', 656: 'VII+', 678: 'VIII-', 700: 'VIII', 722: 'VIII+', 744: 'IX-', 767: 'IX', 789: 'IX+', 811: 'X-', 833: 'X', 856: 'X+', 878: 'XI-', 900: 'XI', 922: 'XI+', 944: 'XII-'}, 'yds': {200: '5.3', 300: '5.4', 400: '5.5', 433: '5.6', 467: '5.7', 500: '5.8', 533: '5.9', 567: '5.10a', 600: '5.10b', 617: '5.10c', 633: '5.10d', 650: '5.11a', 667: '5.11b', 683: '5.11c', 700: '5.11d', 717: '5.12a', 733: '5.12b', 750: '5.12c', 767: '5.12d', 783: '5.13a', 800: '5.13b', 817: '5.13c', 833: '5.13d', 850: '5.14a', 867: '5.14b', 883: '5.14c', 900: '5.14d', 917: '5.15a', 933: '5.15b', 950: '5.15c'}}}



# api.pyx
cdef str VERSION = "v1"
cdef str BASE_URL = "https://api.toplogger.nu"
cdef str REQUEST_URL = str(f"{BASE_URL}/{VERSION}")
cdef dict ASCEND_TYPES = {1: "Redpoint", 2: "Flash", 3: "Onsight"}


# main.py
cdef dict GRADING_SYSTEMS = {
    "boulder": {"french", "french_rounded", "v_grade", "british"},
    "route": {"french", "yds", "uiaa", "ewbank"},
}

cdef set FORM_FIELDS = {"uid", "climb-type", "grading-system", "remember-me", "name"}



