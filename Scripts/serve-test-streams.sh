#!/bin/bash

pkill -if "python -m http.server --directory .*/Streams$"
python3 -m http.server --directory "$(dirname "$0")/../Streams" > /dev/null 2>&1 &
