cmake_minimum_required(VERSION 3.21)

project(PackagerDeb 
    VERSION 0.0.1
    LANGUAGES NONE
)


file(GLOB 
    MODULE_CONFIG_FILES 
    "${CMAKE_CURRENT_SOURCE_DIR}/*-config\.cmake"
)

install(
    FILES ${MODULE_CONFIG_FILES}
    COMPONENT ${PROJECT_NAME}
    DESTINATION share/cmake/${PROJECT_NAME}/
)


if(NOT (PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR))
    add_subdirectory(tests)
endif(NOT (PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR))