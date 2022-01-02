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
        sync
    fi
    mkdir "${BUILD_DIR}"
    sync
    cmake -S . -B "${BUILD_DIR}" --log-level=debug 
    cmake --build "${BUILD_DIR}"
    cd "${BUILD_DIR}"
    cpack
    cd "${WORKDIR}"

    local PKG_OUTPUT_DIR="${BUILD_DIR}/packages"
    for DEBIAN_PKG in $(find ${PKG_OUTPUT_DIR} -name "*\.deb"); do
        local PKG_DIR=$(dirname ${DEBIAN_PKG})
        local EXTRACT_DIR="${PKG_DIR}/$(basename ${DEBIAN_PKG} | awk 'BEGIN { FS = "." } ; { print $1 }' | awk 'BEGIN {FS = "_"}; {print $1}')"
        [ -d "${EXTRACT_DIR}" ] && rm -r "${EXTRACT_DIR}" && sync
        mkdir -p "${EXTRACT_DIR}"
        dpkg -x "${DEBIAN_PKG}" "${EXTRACT_DIR}"
        #sudo dpkg -i "${DEBIAN_PKG}"
    done
    tree "${PKG_OUTPUT_DIR}"
}

function main () {

    install

}

main