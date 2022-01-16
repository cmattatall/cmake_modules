#!/bin/bash
# Bash script to configure and test the project
set -e


function main () {
    cmake -S . -B build
    cmake --build build


    # LOCAL_CMAKE_MODULE_PATH=""
    # for cmake_module_configfile in $(find cmake -name "*Config\.cmake"); do
    #     cmake_module_dir=$(dirname ${cmake_module_configfile})
    #     LOCAL_CMAKE_MODULE_PATH="${LOCAL_CMAKE_MODULE_PATH};${cmake_module_dir};"
    # done
    # echo "LOCAL_CMAKE_MODULE_PATH:${LOCAL_CMAKE_MODULE_PATH}"

    # for cmakelists in $(find tests -name "*CMakeLists\.txt"); do
    #     set +e
    #     source_dir=$(dirname ${cmakelists})
    #     cmake -S ${source_dir} -B ${source_dir}/build -DCMAKE_PREFIX_PATH="${LOCAL_CMAKE_MODULE_PATH}"
    #     cmake --build ${source_dir}/build
    #     pushd ${source_dir}/build
    #         cpack
    #     popd
    #     rm -r ${source_dir}/build
    #     set -e
    # done

    pushd build
        cpack
        #find packages/ -name "*\.deb" -exec dpkg -i {} \;
    popd
}

main