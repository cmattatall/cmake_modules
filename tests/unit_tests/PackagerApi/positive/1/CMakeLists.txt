cmake_minimum_required(VERSION 3.20)


project(
    foobar
    VERSION 0.1.2
    LANGUAGES C CXX
)
find_package(GraphvizDocugen REQUIRED)
find_package(PackagerApi REQUIRED)
find_package(PackagerDeb REQUIRED)

if(NOT DEFINED SOURCE_CODE_DIR)
    message(FATAL_ERROR "SOURCE_CODE_DIR not defined")
endif(NOT DEFINED SOURCE_CODE_DIR)

if(NOT DEFINED HEADER_FILE_DIR)
    message(FATAL_ERROR "HEADER_FILE_DIR not defined") 
endif(NOT DEFINED HEADER_FILE_DIR)

message("SOURCE_CODE_DIR:${SOURCE_CODE_DIR}")
message("HEADER_FILE_DIR:${HEADER_FILE_DIR}")


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
        ${SOURCE_CODE_DIR}/foo.cpp
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
    FILES ${HEADER_FILE_DIR}/foo.hpp
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
    ${SOURCE_CODE_DIR}/bar.cpp
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
    FILES ${HEADER_FILE_DIR}/bar.hpp
)


packager_configure_deb(bar)
packager_finalize_config()

if(COMMAND graphviz_configure)
    graphviz_configure()
endif(COMMAND graphviz_configure)