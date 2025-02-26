""" Handles the creation of the needed databases """

import sqlite3

from src.cython_modules.constants import (
    DATA_DB,
    UPDATE_DB,
    DEFAULT_USER_DB,
)


def create_data_db() -> None:
    with sqlite3.connect(DATA_DB) as conn:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS gyms (
                id INTEGER PRIMARY KEY,
                name TEXT,
                id_name TEXT,
                nr_of_climbs INTEGER, -- Total number of boulders and routes
                nr_of_boulders INTEGER,
                nr_of_routes INTEGER,
                country CHAR(2)
            )
        """
        )

        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS walls (
                id INTEGER PRIMARY KEY,
                name TEXT,
                gym_id INTEGER
            )
        """
        )

        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS climbs (
                id BIGINT PRIMARY KEY,
                gym_id INTEGER,
                type VARCHAR(7),
                date_live_start DATE,
                date_live_end DATE,
                wall_id INTEGER,
                grade INTEGER,
                auto_grade BOOL,
                grade_stability FLOAT,
                nr_of_ascends INTEGER,
                average_opinion FLOAT
            )
        """
        )

        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS boulder (
                id INTEGER NOT NULL UNIQUE,
                french INTEGER NOT NULL,
                french_rounded INTEGER NOT NULL,
                v_grade INTEGER NOT NULL,
                british INTEGER NOT NULL,
                PRIMARY KEY(id AUTOINCREMENT)
            )
        """
        )

        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS route (
                id INTEGER NOT NULL UNIQUE,
                french INTEGER NOT NULL,
                ewbank INTEGER NOT NULL,
                uiaa INTEGER NOT NULL,
                yds INTEGER NOT NULL,
                PRIMARY KEY(id AUTOINCREMENT)
            )
        """
        )

        conn.commit()


def create_default_user_db() -> None:
    """This function creates the default user database. This is copied as the user's db
    when the user first visits the site. This skips the need to create the database for every new user"""
    with sqlite3.connect(DEFAULT_USER_DB) as conn:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS ascends (
                id BIGINT PRIMARY KEY,
                climb_id BIGINT,
                date_logged DATE,
                type VARCHAR(8),
                gym_id INTEGER
            )
        """
        )

        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS opinions (
                id BIGINT PRIMARY KEY,
                climb_id BIGINT,
                uid BIGINT,
                project BOOL,
                voted_renew BOOL,
                grade_rating INTEGER,
                rating FLOAT
            )
        """
        )

        conn.execute("PRAGMA journal_mode = OFF")
        conn.execute("PRAGMA ignore_check_constraints = ON")
        conn.commit()


def create_update_db() -> None:
    with sqlite3.connect(UPDATE_DB) as conn:
        conn.execute(
            """
            CREATE TABLE IF NOT EXISTS user_updates (
                update_timestamp UNSIGNED INTEGER,
                type TEXT,
                gym_id INTEGER,
                uid INTEGER
            )
        """
        )
        conn.commit()


def create_db_index() -> None:
    with sqlite3.connect(DATA_DB) as conn:
        conn.execute('CREATE UNIQUE INDEX "boulder_index" ON "boulder" ("id" ASC);')
        conn.execute('CREATE UNIQUE INDEX "route_index" ON "route" ("id" ASC);')
        conn.execute('CREATE UNIQUE INDEX "climbs_index" ON "climbs" ("id" ASC);')
        conn.execute('CREATE UNIQUE INDEX "walls_index" ON "walls" ("id" ASC);')
        conn.execute('CREATE UNIQUE INDEX "gyms_index" ON "gyms" ("id" ASC);')
        conn.commit()


def main() -> None:
    create_data_db()
    create_default_user_db()
    create_update_db()
    create_db_index()

    print("Database tables are in place...")


if __name__ == "__main__":
    main()
