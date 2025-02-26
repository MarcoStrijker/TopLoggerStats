""" 
This script populates the database with all gyms, walls, climbs, but also constructs the grade systems lookup tables

"""

import sqlite3
import time

from src.cython_modules.constants import DATA_DB
from src.cython_modules.engine import GradingSystem, update_gyms, update_walls, update_climbs
from src.database import retrieve_all_gyms


def populate_static_database() -> None:
    print("Updating gyms...")
    update_gyms()

    gyms = [g[0] for g in retrieve_all_gyms()]

    # Divide the gyms into groups of 10
    group_size = 10
    groups = [set(gyms[i : i + group_size]) for i in range(0, len(gyms), group_size)]

    # Update the climbs and walls for each group
    print("Updating climbs and walls...")
    for i, group in enumerate(groups):
        update_climbs(group, 0)
        update_walls(group)

        print(f"Progress: {i / len(groups)}%".ljust(5), end="\r")
        if i + 1 < len(groups):
            time.sleep(10)

    print()
    print("Database is populated...")


def populate_grade_database() -> None:
    insert_boulder_grade_query = """
        INSERT INTO boulder 
        (id, french, french_rounded, v_grade, british) 
        VALUES (?, ?, ?, ?, ?)
    """
    insert_climb_grade_query = """
        INSERT INTO route 
        (id, french, ewbank, uiaa, yds) 
        VALUES (?, ?, ?, ?, ?)
    """

    boulder_grades = []
    route_grades = []

    bf = GradingSystem("boulder", "french")
    bfr = GradingSystem("boulder", "french_rounded")
    bv = GradingSystem("boulder", "v_grade")
    bb = GradingSystem("boulder", "british")
    rf = GradingSystem("route", "french")
    re = GradingSystem("route", "ewbank")
    ru = GradingSystem("route", "uiaa")
    ry = GradingSystem("route", "yds")

    # Add all the grades to a list
    for i in range(200, 1001):
        boulder_grades.append((i, bf.get_closest(i), bfr.get_closest(i), bv.get_closest(i), bb.get_closest(i)))
        route_grades.append((i, rf.get_closest(i), re.get_closest(i), ru.get_closest(i), ry.get_closest(i)))

    # Add the grades to the database
    with sqlite3.connect(DATA_DB) as conn:
        conn.executemany(insert_boulder_grade_query, boulder_grades)
        conn.executemany(insert_climb_grade_query, route_grades)
        conn.commit()


def main() -> None:
    populate_static_database()
    populate_grade_database()


if __name__ == "__main__":
    main()
