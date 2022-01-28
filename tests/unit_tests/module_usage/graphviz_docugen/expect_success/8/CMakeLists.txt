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
find_package(GraphvizDocugen REQUIRED)


add_library(a src/a.cpp)
add_library(b src/b.cpp)
add_library(c src/c.cpp)

target_link_libraries(a PUBLIC b)
target_link_libraries(a PUBLIC c)

add_executable(main src/main.cpp)
target_link_libraries(main PRIVATE a)


set(CUSTOM_GRAPHVIZ_WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/graphviz)
if(NOT EXISTS ${CUSTOM_GRAPHVIZ_WORKING_DIRECTORY})
    file(MAKE_DIRECTORY ${CUSTOM_GRAPHVIZ_WORKING_DIRECTORY})
endif(NOT EXISTS ${CUSTOM_GRAPHVIZ_WORKING_DIRECTORY})


GraphvizDocugen_make_target_graph(
    TARGET_PREFIX foo
    OUTPUT_PNG my_output.png
    DOTFILE my_file.dot
)

#[[

if(NOT DEFINED SOURCE_CODE_DIR_ABSOLUTE)
    message(FATAL_ERROR "SOURCE_CODE_DIR_ABSOLUTE not defined")
endif(NOT DEFINED SOURCE_CODE_DIR_ABSOLUTE)

if(NOT DEFINED HEADER_FILE_DIR_ABSOLUTE)
    message(FATAL_ERROR "HEADER_FILE_DIR_ABSOLUTE not defined") 
endif(NOT DEFINED HEADER_FILE_DIR_ABSOLUTE)

#]]