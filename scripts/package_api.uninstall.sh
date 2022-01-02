#!/bin/bash
# Bash script to uninstall the package api
set -e

WORKDIR=$(pwd)

if [ ! -f "$(pwd)/.gitignore" ]; then
    echo "Script not being invoked from repository root! Exiting ... "
    exit -1
fi

function uninstall () {




}

function main () {

    uninstall

}

main