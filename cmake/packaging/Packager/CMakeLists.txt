cmake_minimum_required(VERSION 3.21)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

set(MODULE_NAME Packager)
project(${MODULE_NAME} 
    VERSION 0.0.1
    LANGUAGES NONE
)

set(MODULE_CONFIG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${MODULE_NAME}Config.cmake)
set(MODULE_VERSION_FILE ${CMAKE_CURRENT_BINARY_DIR}/${MODULE_NAME}ConfigVersion.cmake)


install(
    FILES ${MODULE_CONFIG_FILE}
    COMPONENT ${MODULE_NAME}
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/cmake/${MODULE_NAME}/"
)