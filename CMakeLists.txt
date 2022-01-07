cmake_minimum_required(VERSION 3.20)

project(foobar VERSION 0.1.2)
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(package_api)
include(graphviz)


find_package(PkgConfig REQUIRED)
pkg_check_modules(JSONCPP jsoncpp REQUIRED)

package_add(
    PACKAGE foo
    VERSION 2.0.1    
)

package_add_library(
    TARGET foo_target_objects
    PACKAGE foo
    TARGET_TYPE OBJECT
)
target_sources(foo_target_objects PRIVATE src/foo.cpp)
target_include_directories(foo_target_objects PUBLIC ${JSONCPP_INCLUDE_DIRS})
target_link_libraries(foo_target_objects PUBLIC ${JSONCPP_LIBRARIES})

package_install_headers(
    PACKAGE foo
    TARGET foo_target_objects
    FILES include/foo.hpp
)


package_add_library(
    TARGET foo_target 
    PACKAGE foo
    TARGET_TYPE SHARED
    $<TARGET_OBJECTS:foo_target_objects>
)

packager_configure_deb(foo)


package_add(
    PACKAGE bar 
    VERSION 9.9.9
)
package_add_library(
    TARGET bar_target_objects
    PACKAGE bar
    TARGET_TYPE OBJECT
)
target_sources(bar_target_objects PRIVATE src/bar.cpp)
target_include_directories(bar_target_objects PUBLIC ${JSONCPP_INCLUDE_DIRS})
target_link_libraries(bar_target_objects PUBLIC ${JSONCPP_LIBRARIES})
package_add_library(
    TARGET bar_target 
    PACKAGE bar
    TARGET_TYPE SHARED
    $<TARGET_OBJECTS:bar_target_objects>
)
package_target_install_headers(
    PACKAGE bar
    TARGET bar_target_objects
    FILES include/bar.hpp
)
packager_configure_deb(bar)


#[[
package_add(
    PACKAGE baz 
    VERSION ${PROJECT_VERSION}
)
package_create_libraries(
    TARGET baz
    PACKAGE baz
    SOURCES src/baz.cpp
)
target_link_libraries(baz-objects PUBLIC ${JSONCPP_LIBRARIES})
target_include_directories(baz-objects PUBLIC ${JSONCPP_INCLUDE_DIRS})
packager_configure_deb(baz)
#]]

packager_finalize_config()

if(COMMAND graphviz_configure)
    graphviz_configure()
endif(COMMAND graphviz_configure)
