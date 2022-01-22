cmake_minimum_required(VERSION 3.21)

project(CMateModules
    VERSION 0.0.1
    DESCRIPTION "A Collection of my own (hopeully) useful cmake modules to make cmake friendlier!"
)

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


if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
    set(CPACK_GENERATOR DEB)
    include(CPack)
endif(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
