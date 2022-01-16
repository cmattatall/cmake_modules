cmake_minimum_required(VERSION 3.21)

project(CMattModules
    VERSION 0.0.1
)
enable_testing()

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")
file(GLOB_RECURSE CMAKE_MODULE_CONFIG_FILES 
    "${PROJECT_SOURCE_DIR}/cmake/*-config\.cmake"
    "${PROJECT_SOURCE_DIR}/cmake/*Config\.cmake"
)

foreach(CONFIG_FILE ${CMAKE_MODULE_CONFIG_FILES})
    get_filename_component(CONFIG_FILE_DIR ${CONFIG_FILE} DIRECTORY)
    message(DEBUG "Adding - ${CONFIG_FILE_DIR} to CMAKE_PREFIX_PATH")
    list(APPEND CMAKE_PREFIX_PATH ${CONFIG_FILE_DIR})
endforeach(CONFIG_FILE ${CMAKE_MODULE_CONFIG_FILES})


include(packaging/PackagerApi/PackagerApiConfig)
include(packaging/PackagerDeb/PackagerDebConfig)

add_subdirectory(cmake)

set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
set(CPACK_GENERATOR DEB)
include(CPack)