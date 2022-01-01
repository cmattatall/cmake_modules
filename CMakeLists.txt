cmake_minimum_required(VERSION 3.20)

project(foo
    VERSION 0.1.2
)


set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(package_api)


package_add(my_package ${PROJECT_VERSION})

package_add_library(
    TARGET my_target_objects
    PACKAGE my_package
    TARGET_TYPE OBJECT
)
target_sources(my_target_objects PRIVATE src/foo.cpp)


package_add_library(
    TARGET my_target 
    PACKAGE my_package
    TARGET_TYPE SHARED
    VERSION 0.0.1
    $<TARGET_OBJECTS:my_target_objects>
)


package_add(my_create_lib_pkg ${PROJECT_VERSION})

set(srcs 
    src/src1.cpp;
    src/src2.cpp
)
package_create_libraries(
    TARGET foobar_target
    PACKAGE my_create_lib_pkg
    SOURCES ${srcs}
)

include(cpack/cpack)