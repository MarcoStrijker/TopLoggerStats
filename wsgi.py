"""
WSGI entry point for TopLoggerStats.
"""

import os
import sys

project_directory = os.path.dirname(__file__)

if project_directory not in sys.path:
    sys.path.append(project_directory)


from src.main import app


if __name__ == "__main__":
    app.run()
