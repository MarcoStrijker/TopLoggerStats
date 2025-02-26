# Run the setup.py file
python cythonize -i src\cython_modules\*.pyx

# Run the post-installation tasks
python scripts/create_directories.py
python scripts/create_databases.py
python scripts/populate_databases.py


# Add cronjob to run the update script every day at 01:00
echo "0 1 * * * /usr/bin/python3 cronjobs/update_static_database.py" | crontab -
