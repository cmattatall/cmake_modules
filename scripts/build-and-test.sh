#!/bin/bash
# Bash script to configure and test the project
set -e


function main () {
    cmake -S . -B build
    pushd build
        make -j$(nproc)
        ctest -V
        #cpack
        #find . -name "*\.deb" -exec dpkg -i {} \;


    popd
}

main