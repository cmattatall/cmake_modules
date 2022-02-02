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

set(CMAKE_BUILD_TYPE Debug)

if(NOT DEFINED SOURCE_CODE_DIR_ABSOLUTE)
    message(FATAL_ERROR "SOURCE_CODE_DIR_ABSOLUTE not defined")
endif(NOT DEFINED SOURCE_CODE_DIR_ABSOLUTE)

if(NOT DEFINED HEADER_FILE_DIR_ABSOLUTE)
    message(FATAL_ERROR "HEADER_FILE_DIR_ABSOLUTE not defined") 
endif(NOT DEFINED HEADER_FILE_DIR_ABSOLUTE)


find_package(GnuCoverage REQUIRED)
GnuCoverage_init()


add_library(lib_to_profile src/lib_to_profile.cpp)
target_include_directories(lib_to_profile PUBLIC include/)
add_executable(test_runner src/test_runner.cpp)


GnuCoverage_add_report_target(                                            
    COVERAGE_TARGET     coverage                                          
    TEST_RUNNER         test_runner                                        
    TARGETS             lib_to_profile
)   

