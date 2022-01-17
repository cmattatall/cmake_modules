#!/bin/bash
# Bash script to configure and test the project
set -e

WORKDIR=$(pwd)
THIS_SCRIPT=$0

if [ ! -f README.md ]; then
    echo "$THIS_SCRIPT invoked from wrong working directory: $WORKDIR. Please invoke from the project root."
    exit -1
fi

function main () {
    cmake -S . -B build
    cmake --build build

    LOCAL_CMAKE_MODULE_PATH=""
    for cmake_module_configfile in $(find cmake -name "*Config\.cmake"); do
        cmake_module_dir=$(dirname ${cmake_module_configfile})
        cmake_module_dir_abs=$(realpath ${cmake_module_dir})
        LOCAL_CMAKE_MODULE_PATH="${LOCAL_CMAKE_MODULE_PATH};${cmake_module_dir_abs};"
    done

    for cmakelists in $(find tests -name "*CMakeLists\.txt"); do
        set +e
        source_dir=$(dirname ${cmakelists})
        cmake \
            -S ${source_dir} \
            -B ${source_dir}/build \
            -DCMAKE_PREFIX_PATH="${LOCAL_CMAKE_MODULE_PATH}" \
            -DSOURCE_CODE_DIR=$(realpath $(pwd)/tests/src) \
            -DHEADER_FILE_DIR=$(realpath $(pwd)/tests/include)

        cmake --build ${source_dir}/build
        pushd ${source_dir}/build
            cpack
        popd
        rm -r ${source_dir}/build
        set -e
    done

    pushd build
        cpack
    popd
}

main