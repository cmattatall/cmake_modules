cmake_minimum_required(VERSION 3.21)
# Make this file test itself if 
# added as a subdirectory from a higher-level project
# With a call to enable_testing()
if(NOT (CMAKE_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR))
    file(RELATIVE_PATH CMAKELISTS_PATH_RELATIVE ${PROJECT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR})
    file(TO_CMAKE_PATH ${CMAKELISTS_PATH_RELATIVE} CMAKELISTS_PATH_RELATIVE_AS_CMAKE_PATH)
    string(REPLACE "/" "_" TEST_NAME "${CMAKELISTS_PATH_RELATIVE_AS_CMAKE_PATH}")
    string(REPLACE "\ " "_" TEST_NAME ${TEST_NAME})
    string(REPLACE "\t" "_" TEST_NAME ${TEST_NAME}) # If you put tabs in filepaths please go see a psychiatrist ...
    set(TEST_NAME "${PROJECT_NAME}_${TEST_NAME}")
    add_test(
        NAME ${TEST_NAME}
        COMMAND ${CMAKE_COMMAND} -S ${CMAKE_CURRENT_SOURCE_DIR} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
    )
endif(NOT (CMAKE_SOURCE_DIR STREQUAL PROJECT_SOURCE_DIR))

find_package(TargetUtils REQUIRED)

