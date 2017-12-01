#!/bin/bash
set -eu

ABC="abc"
DEF="def"

NEW="${ABC}"/"${DEF}"

echo "${NEW}"

tme() {
    start_time=$(date +%s)
    echo "${NEW}"
    end_time=$(date +%s)
    time=$(( start_time-end_time ))
    echo "execution time was ${time}s"
}

tme