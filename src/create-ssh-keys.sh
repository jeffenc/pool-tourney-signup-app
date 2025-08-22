#!/bin/bash
# This script runs the Flask application.

# create ssh keys:
ssh-keygen -t ed25519 -C "jeff.enc07@gmail.com"

# Start the ssh-agent in the background:
eval "$(ssh-agent -s)"

# Add your private SSH key to the ssh-agent:
ssh-add ~/.ssh/id_ed25519

git remote set-url origin git@github.com:jeffenc/pool-tourney-signup-app.git

