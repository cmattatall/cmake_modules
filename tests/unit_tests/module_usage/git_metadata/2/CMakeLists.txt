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


# FIND PACKAGES 
find_package(GitMetadata REQUIRED)

add_library(hello ${SOURCE_CODE_DIR_ABSOLUTE}/hello.cpp)
target_include_directories(hello PUBLIC ${HEADER_FILE_DIR_ABSOLUTE})

add_executable(hello_main ${SOURCE_CODE_DIR_ABSOLUTE}/hello_main.cpp)
target_link_libraries(hello_main PRIVATE hello)

GitMetadata_target_add_metadata_sources(hello_main)
