#!/bin/bash
# Bash script to run the tests 
# 
# MEANT TO BE EXECUTED FROM WITHIN A DOCKER IMAGE.
set -e

function dirstack_cleanup () {
    while [ $(popd > /dev/null) ]; do 
        : # this is a bash NO-OP
    done
}
trap dirstack_cleanup EXIT


function install_modules () {
    cmake -S . -B build
    pushd build
        make -j$(nproc)
        cpack
        find . -name "*\.deb" -exec dpkg -i {} \;
    popd
}

function run_test () {
    local TEST_SOURCE_DIR_CMAKELISTS=${1:?"Error: argument for TEST_SOURCE_DIR_CMAKELISTS not provided"}
    echo "Running test rooted at ${TEST_SOURCE_DIR_CMAKELISTS}"
    pushd $(dirname ${TEST_SOURCE_DIR_CMAKELISTS})
        cmake -S . -B build
    popd
}

function run_tests () {
    for CMAKELISTS in $(find cmake/ -name "tests/*/CMakeLists.txt"); do
        echo "CMAKELISTS:${CMAKELISTS}"
        #run_test "${CMAKELISTS}"
    done
}


function main () {
    install_modules
    run_tests
}


main
