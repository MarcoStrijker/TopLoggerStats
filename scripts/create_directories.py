""" Handles the creation of the needed directories """

import os

from src.cython_modules.constants import (
    DATA_DIRECTORY,
    USER_DATA_DIRECTORY,
    LOG_DIRECTORY,
)


def main() -> None:
    for directory in [DATA_DIRECTORY, USER_DATA_DIRECTORY, LOG_DIRECTORY]:
        os.makedirs(directory, exist_ok=True)

    print("Directories are all in place...")


if __name__ == "__main__":
    main()
