cmake_minimum_required(VERSION 3.20)


if(NOT DEFINED SOURCE_CODE_DIR_ABSOLUTE)
    message(FATAL_ERROR "SOURCE_CODE_DIR_ABSOLUTE not defined")
endif(NOT DEFINED SOURCE_CODE_DIR_ABSOLUTE)

if(NOT DEFINED HEADER_FILE_DIR_ABSOLUTE)
    message(FATAL_ERROR "HEADER_FILE_DIR_ABSOLUTE not defined") 
endif(NOT DEFINED HEADER_FILE_DIR_ABSOLUTE)

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
find_package(PackagerApi REQUIRED)
find_package(PackagerDeb REQUIRED)


message("SOURCE_CODE_DIR_ABSOLUTE:${SOURCE_CODE_DIR_ABSOLUTE}")
message("HEADER_FILE_DIR_ABSOLUTE:${HEADER_FILE_DIR_ABSOLUTE}")


find_package(PkgConfig REQUIRED)

PackagerApi_add_package(
    PACKAGE hello
    VERSION 2.0.1    
)

PackagerApi_add_library(
    TARGET hello_target_objects
    PACKAGE hello
    TARGET_TYPE OBJECT
)
target_sources(hello_target_objects 
    PRIVATE 
        ${SOURCE_CODE_DIR_ABSOLUTE}/hello.cpp
)

PackagerApi_target_install_headers(
    PACKAGE hello
    TARGET hello_target_objects
    FILES ${HEADER_FILE_DIR_ABSOLUTE}/hello.hpp
)


PackagerApi_add_library(
    TARGET hello_target_shared 
    PACKAGE hello
    TARGET_TYPE SHARED
    $<TARGET_OBJECTS:hello_target_objects>
)

PackagerApi_add_library(
    TARGET hello_target_static
    PACKAGE hello
    TARGET_TYPE STATIC
    $<TARGET_OBJECTS:hello_target_objects>
)
packager_configure_deb(hello)

packager_finalize_config()
