from typing import Final

from src.custom_types import System

# Project paths
PROJECT_DIRECTORY: Final[str]
DATA_DIRECTORY: Final[str]
USER_DATA_DIRECTORY: Final[str]
LOG_DIRECTORY: Final[str]

DATA_DB: Final[str]
UPDATE_DB: Final[str]

DEFAULT_USER_DB: Final[str]
USER_DB_FORMAT_STRING: Final[str]

JS_VISUAL_PATH_FORMAT_STRING: Final[str]

# Database URIs
DATA_URI: Final[str]
GYMS_URI: Final[str]
USER_UPDATE_URI: Final[str]

# Content Security Policy strings
CSP_START: Final[str]
CSP_ERROR: Final[str]
CSP_DASHBOARD_FORMAT_STRING: Final[str]

# visualization.pyx constants
JS_VISUAL_NAMES: Final[tuple[str, ...]]

# statistics processor.pyx constants
THRESHOLD_RATINGS: Final[int]

# engine.pyx constants
SYSTEMS: Final[dict[str, dict[str, dict[int, str]]]]

# api.pyx constants
VERSION: Final[str]
BASE_URL: Final[str]
REQUEST_URL: Final[str]
ASCEND_TYPES: Final[dict[int, str]]

# main.py constants
GRADING_SYSTEMS: Final[dict[System, set[str]]]
FORM_FIELDS: Final[set[str]]
