#!/usr/bin/env bash
set -u
set -o pipefail

nohup ./power.sh > power.log 2>&1 &
echo "power.sh is running in the background. Output is logged to power.log"