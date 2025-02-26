# cython: language_level=3str, binding=False, boundscheck=False, wraparound=False, initializedcheck=False, nonecheck=False, infer_types=False, profile=False, cdivision=False, type_version_tag=False, unraisable_tracebacks=False
# distutils: language=c++

import re

cdef object pat1 = re.compile(r'\s+')
cdef object pat2 = re.compile(r'<!--.*?-->', flags=re.DOTALL)
cdef object pat3 = re.compile(r'>\s+<')


cpdef list filter_gyms(list all_gyms, set gym_ids, object gym):
    """Filters the gyms based on the gym_ids and the gym name

    If no gym name is provided, all gyms with the provided gym ids will be returned. If a gym 
    name is provided, only the gyms within the provided gym ids and gym name will be returned.

    Arguments:
        all_gyms (list): The list of all gyms
        gym_ids (set): The set of gym ids
        gym (object): The gym name or None

    Returns:
        list: The filtered gyms
    """
    return [g for g in all_gyms if g[0] in gym_ids and (gym is None or g[2] == gym)]


cpdef str minify(str html):
    """Minifies the html code

    Arguments:
        html (str): The html code

    Returns:
        str: The minified html code
    """
    return pat3.sub('><', pat2.sub('',  pat1.sub(' ', html)))


cpdef tuple filter_remembered_users(list remembered_users, str last_remembered_user):
    """Filters the remembered users if the last remembered user is not empty

    If the last remembered user is not empty, it will be added to the list of remembered users.
    This function will ensure the list of remembered users is unique and sorted.

    Arguments:
        remembered_users (list): The list of remembered users, this is a list of identifiers
            e.g. "John Doe:::1234567890::Gym Name"
        last_remembered_user (str): The last remembered user

    Returns:
        tuple: An tuple with all remembered users and the structured remembered users (list of tuples with user, uid, and gym name)
    """
    if last_remembered_user == '':
        return (remembered_users, [(user, user.split(":::")) for user in remembered_users])

    remembered_users.append(last_remembered_user)
    cdef list structured_remembered_users = [(user, user.split(":::")) for user in remembered_users]
    cdef list uids = [user[1][1] for user in structured_remembered_users]

    for i, uid in enumerate(uids):
        if uid in uids[:i]:
            del structured_remembered_users[i]
            del remembered_users[i]

    return (remembered_users, structured_remembered_users)


cpdef unsigned short convert_grade(str old_grade):
    """Normalizes the grade to the our own grade metric

    TopLogger has two internal grade metrics:
    - 200, 250, 300, etc.
    - 2.00, 2.50, 3.00, etc.

    When there is no grade, the API should pass "0" and this function should return 0.

    Arguments:
        old_grade (str): The old grade

    Returns:
        unsigned short: The new grade
    """
    cdef float grade = float(old_grade)
    if grade == 200 or grade * 100 <= 201:
        return 0
    elif grade < 100:
        return int(grade * 100)
    else:
        return int(grade)
