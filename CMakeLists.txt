cmake_minimum_required(VERSION 3.20)

project(foobar
    VERSION 0.1.2
)


set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(package_api)




find_package(PkgConfig REQUIRED)
pkg_check_modules(JSONCPP jsoncpp REQUIRED)

package_add(foo ${PROJECT_VERSION})
package_add_library(
    TARGET foo_target_objects
    PACKAGE foo
    TARGET_TYPE OBJECT
)
target_sources(foo_target_objects PRIVATE src/foo.cpp)
target_include_directories(foo_target_objects PUBLIC ${JSONCPP_INCLUDE_DIRS})
target_link_libraries(foo_target_objects PUBLIC ${JSONCPP_LIBRARIES})

package_add_library(
    TARGET foo_target 
    PACKAGE foo
    TARGET_TYPE SHARED
    $<TARGET_OBJECTS:foo_target_objects>
)



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
