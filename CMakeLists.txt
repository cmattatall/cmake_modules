cmake_minimum_required(VERSION 3.21)

project(CMattModules
    VERSION 0.0.1
)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")
file(GLOB_RECURSE CMAKE_MODULE_CONFIG_FILES "cmake/*-config\.cmake")
foreach(CONFIG_FILE ${CMAKE_MODULE_CONFIG_FILES})
    get_filename_component(CONFIG_FILE_DIR ${CONFIG_FILE} DIRECTORY)
    list(APPEND CMAKE_PREFIX_PATH ${CONFIG_FILE_DIR})
endforeach(CONFIG_FILE ${CMAKE_MODULE_CONFIG_FILES})

# When we improve the package_api to support creation of cmake module packages
# And when we can make self-installing packages, then we can write this module
# in terms of itself!
# Until then, this stays commented out
#include(packaging/PackageApi/PackageApi-config)
#include(packaging/PackagerDeb/PackagerDeb-config)

add_subdirectory(cmake)

set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
set(CPACK_GENERATOR DEB)
include(CPack)