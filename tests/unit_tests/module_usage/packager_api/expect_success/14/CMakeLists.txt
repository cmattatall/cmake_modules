cmake_minimum_required(VERSION 3.20)

if(NOT DEFINED TESTS_ROOT_DIR_ABSOLUTE)
    message(FATAL_ERROR "TESTS_ROOT_DIR_ABSOLUTE not defined") 
endif(NOT DEFINED TESTS_ROOT_DIR_ABSOLUTE)

# We will use the directory structure to create a unique name for this test
file(RELATIVE_PATH TEST_SOURCE_DIR_RELATIVE ${TESTS_ROOT_DIR_ABSOLUTE} ${CMAKE_CURRENT_SOURCE_DIR})
file(TO_CMAKE_PATH ${TEST_SOURCE_DIR_RELATIVE} TEST_PROJECT_NAME)
string(REPLACE "/" "_" TEST_PROJECT_NAME ${TEST_PROJECT_NAME})
string(REPLACE "\\ " "_" TEST_PROJECT_NAME ${TEST_PROJECT_NAME})
string(REPLACE " " "_" TEST_PROJECT_NAME ${TEST_PROJECT_NAME})
string(REPLACE "\t" "_" TEST_PROJECT_NAME ${TEST_PROJECT_NAME})
project(
    ${TEST_PROJECT_NAME}
    VERSION 0.1.2
    LANGUAGES C CXX
)


# FIND PACKAGES 
find_package(PackagerApi REQUIRED)

set(PACKAGE_NAME package_api_pkg_include_directories_test)
set(TARGET_NAME ${PACKAGE_NAME})

PackagerApi_add_package(
    PACKAGE ${PACKAGE_NAME}
    VERSION ${PROJECT_VERSION}    
)

PackagerApi_add_library(
    PACKAGE ${PACKAGE_NAME}
    TARGET  ${TARGET_NAME}
)

PackagerApi_target_headers(
    PACKAGE ${PACKAGE_NAME}
    TARGET  ${TARGET_NAME}
    HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/include/lib.hpp # Expect success when an absolute path is given
)


target_sources(${TARGET_NAME} PRIVATE src/lib.cpp)

PackagerApi_finalize_config()