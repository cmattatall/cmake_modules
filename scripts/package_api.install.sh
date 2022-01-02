#!/bin/bash
# Bash script to install the package api

set -e

WORKDIR=$(pwd)

if [ ! -f "$(pwd)/.gitignore" ]; then
    echo "Script not being invoked from repository root! Exiting ... "
    exit -1
fi

#if  [ -f "$(realpath $(pwd))/.gitignore" ]; then if [ -d "$(realpath $(pwd))/build" ]; then rm -r "$(realpath $(pwd))/build"; fi; mkdir build && cd build; fi; cmake ../ --log-level=debug && make && cpack && cd packages && find . -name "*\.tar\.gz" -exec tar -xf {} -C . \; && tree; cd ../../
function install () {

    local BUILD_DIR="$(realpath ${WORKDIR})/build"
    if [ -d "${BUILD_DIR}" ]; then 
        rm -r "${BUILD_DIR}"

    fi
    mkdir "${BUILD_DIR}"
    cmake -S . -B "${BUILD_DIR}" --log-level=debug 
    cmake --build "${BUILD_DIR}"
    cd "${BUILD_DIR}"
    cpack
    cd "${WORKDIR}"
    for TARBALL in $(find build -name "*\.tar\.gz"); do
        local TARBALL_DIR=$(dirname ${TARBALL})
        tar -xvf ${TARBALL} -C "${TARBALL_DIR}"
        tree "${TARBALL_DIR}"
    done
}

function main () {

    install

}

main