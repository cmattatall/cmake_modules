#!/bin/bash
# Bash script to build the docker image and run the tests
# 
# To properly test if the modules are installed, we need to do the testing
# in a fresh virtual environment 
# (because host environment could be coincidentally passing)
set -e
THIS_SCRIPT=$0

function main () {
    which docker > /dev/null
    WORKDIR=$(pwd)

    if [ ! -d "${WORKDIR}/cmake" ]; then
        echo "$THIS_SCRIPT invoked from the wrong directory: ${WORKDIR}. Please invoke from the project root"
        exit 0
    fi

    docker build -f tests/Dockerfile "${WORKDIR}"
}

main