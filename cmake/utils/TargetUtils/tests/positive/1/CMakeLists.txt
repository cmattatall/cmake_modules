cmake_minimum_required(VERSION 3.21)

project(${MODULE_NAME}_find_package_required_test)
find_package(TargetUtils REQUIRED)

add_test(
    NAME ${MODULE_NAME}_find_package_required_test
    COMMAND ${CMAKE_COMMAND} -S ${CMAKE_CURRENT_SOURCE_DIR} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
)