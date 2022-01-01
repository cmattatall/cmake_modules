cmake_minimum_required(VERSION 3.20)

project(foo
    VERSION 0.1.2
)


set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(package_api)


package_add(my_package ${PROJECT_VERSION})
package_add(my_package ${PROJECT_VERSION})
package_add(my_package ${PROJECT_VERSION})
package_add(my_package ${PROJECT_VERSION})


package_add_library(
    TARGET my_target 
    PACKAGE my_package
    TARGET_TYPE OBJECT
)


target_sources(my_target PRIVATE src/foo.cpp)

include(cpack/cpack)