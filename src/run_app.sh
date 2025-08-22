#!/bin/bash
# This script runs the Flask application.

# install flask if not already installed
if ! python -c "import flask" &> /dev/null; then    
    echo "Flask not found, installing..."
    python3 -m pip install Flask
else
    echo "Flask is already installed."
fi

# install openpxyl if not already installed
if ! python -c "import openpyxl" &> /dev/null; then    
    echo "openpyxl not found, installing..."
    python3 -m pip install openpyxl
else
    echo "openpyxl is already installed."
fi  

# install xlsxwriter if not already installed
if ! python -c "import xlsxwriter" &> /dev/null; then    
    echo "xlsxwriter not found, installing..."
    python3 -m pip install xlsxwriter
else
    echo "xlsxwriter is already installed."
fi  

# install pandas if not already installed
if ! python -c "import pandas" &> /dev/null; then    
    echo "pandas not found, installing..."
    python3 -m pip install pandas
else
    echo "pandas is already installed."
fi

# start the Flask app
python app.py 


