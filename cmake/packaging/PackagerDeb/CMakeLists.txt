cmake_minimum_required(VERSION 3.21)

get_filename_component(MODULE_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
project(${MODULE_NAME}
    VERSION 0.0.1
    LANGUAGES NONE
)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

set(MODULE_CONFIG_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${MODULE_NAME}Config.cmake)
set(MODULE_VERSION_FILE ${CMAKE_CURRENT_BINARY_DIR}/${MODULE_NAME}ConfigVersion.cmake)

write_basic_package_version_file(
    ${MODULE_VERSION_FILE}
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(
    FILES 
        ${MODULE_CONFIG_FILE}
        ${MODULE_VERSION_FILE}
    COMPONENT ${CMAKE_PROJECT_NAME}
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/cmake/${MODULE_NAME}/"
)