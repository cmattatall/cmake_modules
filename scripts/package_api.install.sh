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
    for DEBIAN_PKG in $(find ${WORKDIR}/build/packages/ -name "*\.deb"); do
        local PKG_DIR=$(dirname ${DEBIAN_PKG})
        dpkg -x "${DEBIAN_PKG}" "${PKG_DIR}"
        tree "${PKG_DIR}"
    done
}

function main () {

    install

}

main