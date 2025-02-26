# Declare public constants
cdef str PROJECT_DIRECTORY
cdef str DATA_DIRECTORY
cdef str USER_DATA_DIRECTORY
cdef str DATA_DB
cdef str UPDATE_DB
cdef str DEFAULT_USER_DB
cdef str USER_DB_FORMAT_STRING
cdef str JS_VISUAL_PATH_FORMAT_STRING
cdef str DATA_URI
cdef str GYMS_URI
cdef str USER_UPDATE_URI
cdef str CSP_START
cdef str CSP_ERROR
cdef str CSP_DASHBOARD_FORMAT_STRING 
cdef dict GRADING_SYSTEMS
cdef set FORM_FIELDS


# Visualizations.pyx
cdef tuple JS_VISUAL_NAMES
cdef object CLEAN_JS_PAT


# Statistics processor.pyx
cdef unsigned char THRESHOLD_RATINGS


# Engine.pyx
cdef dict SYSTEMS


# api.pyx
cdef str VERSION
cdef str BASE_URL
cdef str REQUEST_URL
cdef dict ASCEND_TYPES

