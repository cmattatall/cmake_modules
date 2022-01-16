cmake_minimum_required(VERSION 3.20)
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

project(foobar VERSION 0.1.2)

find_package(GraphvizDocugen REQUIRED)
find_package(PackagerApi REQUIRED)
find_package(PackagerDeb REQUIRED)


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
target_sources(foo_target_objects PRIVATE src/foo.cpp)
target_include_directories(foo_target_objects PUBLIC ${JSONCPP_INCLUDE_DIRS})
target_link_libraries(foo_target_objects PUBLIC ${JSONCPP_LIBRARIES})

PackagerApi_target_install_headers(
    PACKAGE foo
    TARGET foo_target_objects
    FILES include/foo.hpp
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
target_sources(bar_target_objects PRIVATE src/bar.cpp)
target_include_directories(bar_target_objects PUBLIC ${JSONCPP_INCLUDE_DIRS})
target_link_libraries(bar_target_objects PUBLIC ${JSONCPP_LIBRARIES})


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
    FILES include/bar.hpp
)
packager_configure_deb(bar)

packager_finalize_config()

if(COMMAND graphviz_configure)
    graphviz_configure()
endif(COMMAND graphviz_configure)

