#!/bin/bash

# Script to activate Python virtual environment
VENV_NAME="venv"  # Change this to your venv directory name

python3 -m venv "$VENV_NAME"

# Check if virtual environment exists
if [ -d "$VENV_NAME" ]; then
    echo "Activating virtual environment: $VENV_NAME"
    source "$VENV_NAME/bin/activate"
    echo "Virtual environment activated!"
else
    echo "Error: Virtual environment '$VENV_NAME' not found."
    echo "Available virtual environments:"
    ls -d */ | grep venv || echo "No venv directories found"
    exit 1
fi