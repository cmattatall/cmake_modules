cmake_minimum_required(VERSION 3.21)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

set(MODULE_NAME TargetUtils)

project(${MODULE_NAME} 
    VERSION 0.0.1
    LANGUAGES NONE
)

set(MODULE_CONFIG_FILE ${CMAKE_CURRENT_BINARY_DIR}/${MODULE_NAME}-config.cmake)
set(MODULE_VERSION_FILE ${CMAKE_CURRENT_BINARY_DIR}/${MODULE_NAME}-config-version.cmake)

write_basic_package_version_file(
    ${MODULE_VERSION_FILE}
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)


install(
    FILES 
        ${MODULE_CONFIG_FILE}
        ${MODULE_VERSION_FILE}
    COMPONENT ${MODULE_NAME}
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/cmake/${MODULE_NAME}/"
)

enable_testing()