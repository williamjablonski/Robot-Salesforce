#!/bin/sh
set -eu
# A virtual display supports existing chrome calls without changing test keywords.
exec xvfb-run --auto-servernum --server-args='-screen 0 1920x1080x24 -nolisten tcp' \
    python -m libraries.robot_runner --outputdir /app/results "$@"
