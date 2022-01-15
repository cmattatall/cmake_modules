cmake_minimum_required(VERSION 3.21)

# If no LANGUAGES field is specified, C and CXX are implicitly enabled
project(modules
    VERSION 0.0.1 
    #LANGUAGES NONE
)

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}/cmake")
file(GLOB_RECURSE CMAKE_MODULE_CONFIG_FILES "cmake/*Config\.cmake")
foreach(CONFIG_FILE ${CMAKE_MODULE_CONFIG_FILES})
    get_filename_component(CONFIG_FILE_DIR ${CONFIG_FILE} DIRECTORY)
    list(APPEND CMAKE_PREFIX_PATH ${CONFIG_FILE_DIR})
endforeach(CONFIG_FILE ${CMAKE_MODULE_CONFIG_FILES})


include(packaging/PackagerConfig/PackagerConfigConfig)
include(packaging/PackagerDeb/PackagerDebConfig)
include(packaging/PackageApi/PackageApiConfig)




add_subdirectory(cmake)

#set(CPACK_DEB_COMPONENT_INSTALL OFF CACHE INTERNAL "")
#set(CPACK_COMPONENT_INSTALL OFF CACHE INTERNAL "")
set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")
set(CPACK_GENERATOR DEB)
include(CPack)