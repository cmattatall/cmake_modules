cmake_minimum_required(VERSION 3.21)

project(CMateModules
    VERSION 1.6.0
    DESCRIPTION "A Collection of my own (hopeully) useful cmake modules to make cmake friendlier!"
)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")
file(GLOB_RECURSE CMAKE_MODULE_CONFIG_FILES 
    "${PROJECT_SOURCE_DIR}/cmake/*Config\.cmake"
)

foreach(CONFIG_FILE ${CMAKE_MODULE_CONFIG_FILES})
    get_filename_component(CONFIG_FILE_DIR ${CONFIG_FILE} DIRECTORY)
    message(DEBUG "Adding - ${CONFIG_FILE_DIR} to CMAKE_PREFIX_PATH")
    list(APPEND CMAKE_PREFIX_PATH ${CONFIG_FILE_DIR})
endforeach(CONFIG_FILE ${CMAKE_MODULE_CONFIG_FILES})

# Use the project's own packaging API to bootstrap itself
include(packaging/PackagerApi/PackagerApiConfig)
include(packaging/PackagerDeb/PackagerDebConfig)


# If built as a top-level project, we want to package the project.
# 
# However, don't self-package if not the top-level project - e.g.
#   - as part of tests
#   - grabbed using FetchContent
#   - grabbed using ExternalProject
#   - added from another project using find_package( )
#   - etc.
if(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)

    Packager_init()
    Packager_config_metadata()

    PackagerApi_init()
    PackagerDeb_init()

    foreach(CONFIG_FILE ${CMAKE_MODULE_CONFIG_FILES})
        PackagerApi_cmake_add_package(
            VERSION ${PROJECT_VERSION}
            CONFIG_FILE ${CONFIG_FILE}
            PKG_TYPE DEB
        )
    endforeach(CONFIG_FILE ${CMAKE_MODULE_CONFIG_FILES})

    PackagerApi_finalize_config()

endif(CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)


