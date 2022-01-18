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
find_package(GraphvizDocugen REQUIRED)

find_package(PkgConfig REQUIRED)
pkg_check_modules(JSONCPP jsoncpp REQUIRED)

PackagerApi_add_package(
    PACKAGE foo
    VERSION 2.0.1    
)

PackagerApi_add_library(
    TARGET foo_target_objects
    PACKAGE foo
    TARGET_TYPE OBJECT
)
target_sources(foo_target_objects 
    PRIVATE 
        ${SOURCE_CODE_DIR_ABSOLUTE}/foo.cpp
)
target_include_directories(foo_target_objects 
    PUBLIC 
        ${JSONCPP_INCLUDE_DIRS}
)
target_link_libraries(foo_target_objects 
    PUBLIC 
        ${JSONCPP_LIBRARIES}
)

PackagerApi_target_install_headers(
    PACKAGE foo
    TARGET foo_target_objects
    FILES ${HEADER_FILE_DIR_ABSOLUTE}/foo.hpp
)


PackagerApi_add_library(
    TARGET foo_target_shared 
    PACKAGE foo
    TARGET_TYPE SHARED
    $<TARGET_OBJECTS:foo_target_objects>
)

PackagerApi_add_library(
    TARGET foo_target_static
    PACKAGE foo
    TARGET_TYPE STATIC
    $<TARGET_OBJECTS:foo_target_objects>
)
packager_configure_deb(foo)




PackagerApi_add_package(
    PACKAGE bar 
    VERSION 9.9.9
)
PackagerApi_add_library(
    TARGET bar_target_objects
    PACKAGE bar
    TARGET_TYPE OBJECT
)
target_sources(bar_target_objects 
    PRIVATE 
    ${SOURCE_CODE_DIR_ABSOLUTE}/bar.cpp
)
target_include_directories(bar_target_objects 
    PUBLIC 
    ${JSONCPP_INCLUDE_DIRS}
)
target_link_libraries(bar_target_objects 
    PUBLIC 
    ${JSONCPP_LIBRARIES}
)


PackagerApi_add_library(
    TARGET bar_target_shared 
    PACKAGE bar
    TARGET_TYPE SHARED
    $<TARGET_OBJECTS:bar_target_objects>
)
PackagerApi_add_library(
    TARGET bar_target_static 
    PACKAGE bar
    TARGET_TYPE STATIC
    $<TARGET_OBJECTS:bar_target_objects>
)

PackagerApi_target_install_headers(
    PACKAGE bar
    TARGET bar_target_objects
    FILES ${HEADER_FILE_DIR_ABSOLUTE}/bar.hpp
)


packager_configure_deb(bar)
packager_finalize_config()


GraphvizDocugen_make_target_graph()