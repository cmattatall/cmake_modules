cmake_minimum_required(VERSION 3.20)

project(foo
    VERSION 0.1.2
)


set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(package_api)


package_add(my_package ${PROJECT_VERSION})


find_package(PkgConfig REQUIRED)
pkg_check_modules(JSONCPP jsoncpp REQUIRED)

set(sources 
    src/foo.cpp
)

package_add_library(
    TARGET my_target_objects
    PACKAGE my_package
    TARGET_TYPE OBJECT
)
target_sources(my_target_objects PRIVATE ${sources})

target_include_directories(my_target_objects PUBLIC ${JSONCPP_INCLUDE_DIRS})
target_link_libraries(my_target_objects PUBLIC ${JSONCPP_LIBRARIES})


package_add_library(
    TARGET my_target 
    PACKAGE my_package
    TARGET_TYPE SHARED
    VERSION 0.0.1
    $<TARGET_OBJECTS:my_target_objects>
)


#[[
package_add(my_create_lib_pkg ${PROJECT_VERSION})

package_create_libraries(
    TARGET foobar_target
    PACKAGE my_create_lib_pkg
    SOURCES ${sources}
)
#]]

include(packaging/cpack)
