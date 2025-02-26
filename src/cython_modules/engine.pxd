# distutils: language=c++

cdef tuple SINGLE_GYM_CHART_FUNCTIONS
cdef tuple MULTIPLE_GYM_VISUALS
cdef dict GRADING_SYSTEMS
cdef object loop
cdef str USER_UPDATES_QUERY


cdef class GradingSystem:
    cdef readonly str climb_type
    cdef readonly tuple integers, strings, ascend_types, ascend_colors
    cdef readonly bint route
