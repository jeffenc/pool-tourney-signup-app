#!/bin/bash

lsof -i :5000

kill -9 $(lsof -t -i :5000)

# one-liner
# lsof -ti:5000 | xargs kill -9

echo "Killed process on port 5000"