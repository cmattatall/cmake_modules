cmake_minimum_required(VERSION 3.21)

set(CPACK_COMPONENTS_GROUPING ONE_PER_GROUP CACHE INTERNAL "")
set(CPACK_COMPONENT_INSTALL ON CACHE INTERNAL "")

set(CPACK_STRIP_FILES ON CACHE INTERNAL "")
set(CPACK_STRIP_FILES ON CACHE INTERNAL "")
set(CPACK_SET_DESTDIR OFF CACHE INTERNAL "")

set(CPACK_PACKAGE_NAME ${PROJECT_NAME} CACHE INTERNAL "")
set(CPACK_PACKAGE_VENDOR "Carl Mattatall" CACHE INTERNAL "")
set(CPACK_PACKAGE_CONTACT "cmattatall2@gmail.com" CACHE INTERNAL "")
set(CPACK_VERBATIM_VARIABLES YES CACHE INTERNAL "")

set(CPACK_PACKAGING_INSTALL_PREFIX "/usr" CACHE INTERNAL "") # Sorry windows folks
set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_BINARY_DIR}/packages" CACHE INTERNAL "")

set(CPACK_GENERATOR "") # Empty list, user will specific with functions which generators they want


if(EXISTS "${PROJECT_SOURCE_DIR}/LICENSE")
    set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")
    message(VERBOSE "Using ${PROJECT_SOURCE_DIR}/LICENSE as CPACK_RESOURCE_FILE_LICENSE.")
else()
    message(VERBOSE "Cannot set CPACK_RESOURCE_FILE_LICENSE. File: ${PROJECT_SOURCE_DIR}/LICENSE does not exist.")
endif(EXISTS "${PROJECT_SOURCE_DIR}/LICENSE")


if(EXISTS "${PROJECT_SOURCE_DIR}/README.md")
    set(CPACK_RESOURCE_FILE_README "${PROJECT_SOURCE_DIR}/README.md")
    message(VERBOSE "Using ${PROJECT_SOURCE_DIR}/README.md as CPACK_RESOURCE_FILE_README.")
else()
    message(VERBOSE "Cannot set CPACK_RESOURCE_FILE_README. File: ${PROJECT_SOURCE_DIR}/README.md does not exist.")
endif(EXISTS "${PROJECT_SOURCE_DIR}/README.md")

include(packaging/cpack_deb)
include(packaging/cpack_tgz)
include(packaging/cpack_zip)
include(packaging/cpack_rpm)

#include(packaging/cpack_postinst)

include(InstallRequiredSystemLibraries)
