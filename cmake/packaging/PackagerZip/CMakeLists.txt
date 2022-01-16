cmake_minimum_required(VERSION 3.21)

project(PackagerZip
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
