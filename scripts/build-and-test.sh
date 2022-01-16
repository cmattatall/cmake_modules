#!/bin/bash
# Bash script to configure and test the project
set -e


function main () {
    cmake -S . \
        -B build \
        --log-level=debug
    pushd build
        make -j$(nproc)
        ctest \
        --extra-verbose \
        --output-on-failure \
        --output-log test.log \
        -R PackagerApi_tests_positive_1_configure

        #-R Pack* # for now, we will just be testing the package api


        #cpack
        #find . -name "*\.deb" -exec dpkg -i {} \;
    popd
}

main