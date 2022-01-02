#!/bin/bash
# Bash script to uninstall the package api
set -e

WORKDIR=$(pwd)

if [ ! -f "$(pwd)/.gitignore" ]; then
    echo "Script not being invoked from repository root! Exiting ... "
    exit -1 
fi

function uninstall () {
    # this is hardcoded between the install and uninstall
    # scripts but that's alright for now
    local BUILD_DIR="${WORKDIR}/build" 
    while IFS= read -r pkg; do
        if [ $pkg != "" ]; then
            sudo dpkg -r $pkg
        fi
    done < "${BUILD_DIR}/package-list.txt"
}

function main () {

    uninstall

}

main