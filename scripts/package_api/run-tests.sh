#!/bin/bash
# Bash script to run the tests against the package api cmake modules

set -e
WORKDIR=$(pwd)
TESTS_DIR="${WORKDIR}/tests"

if [ ! -f "$(pwd)/.gitignore" ]; then
    echo "Script not being invoked from repository root! Exiting ... "
    exit -1
fi

function setup() {
    $SHELL "${WORKDIR}/scripts/package_api/install.sh"    
}


function teardown () {
    $SHELL "${WORKDIR}/scripts/package_api/uninstall.sh"    
}

function run_package_api_tests () {
    local PACKAGE_API_TESTS_DIR="${TESTS_DIR}/package_api"

    for CMAKE_LISTS_FILE in $(find ${PACKAGE_API_TESTS_DIR} -name "CMakeLists\.txt"); do
        local SOURCE_TREE=$(dirname ${CMAKE_LISTS_FILE})
        local BUILD_TREE="${SOURCE_TREE}/build"

        echo "SOURCE_TREE=${SOURCE_TREE}"
        echo "BUILD_TREE=${BUILD_TREE}"
        if [ -d "${BUILD_TREE}" ]; then
            rm -r "${BUILD_TREE}"
        fi
        cmake -S "${SOURCE_TREE}" -B "${BUILD_TREE}"
        cmake --build "${BUILD_TREE}"
    done
}

function run_tests () {
    run_package_api_tests
}


function main () {
    setup 
    
    #run_tests
    
    #teardown
}

main