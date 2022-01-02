# TODO: 
# Improve based on resources below:
# https://github.com/AliceO2Group/ReadoutCard/blob/master/cmake/CPackConfig.cmake
# 
cmake_minimum_required(VERSION 3.21)

set(CPACK_VERBATIM_VARIABLES YES)

#set(CPACK_COMPONENTS_GROUPING ONE_PER_GROUP) # use this if want 1 debian package per cmake install component
set(CPACK_COMPONENTS_GROUPING ALL_COMPONENTS_IN_ONE) # use this if want 1 debian package for all cmake install components

# https://cmake.org/cmake/help/latest/variable/CPACK_SET_DESTDIR.html
set(CPACK_SET_DESTDIR OFF)

set(CPACK_COMPONENT_INSTALL ON) 
set(CPACK_STRIP_FILES ON)

set(CPACK_GENERATOR ) # empty list
set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
set(CPACK_PACKAGE_VENDOR "Carl Mattatall")
set(CPACK_PACKAGE_CONTACT "cmattatall2@gmail.com")

set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})

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

set(CPACK_PACKAGING_INSTALL_PREFIX "/usr") # Sorry windows folks
set(CPACK_PACKAGE_INSTALL_DIRECTORY ${CPACK_PACKAGE_NAME})
set(CPACK_OUTPUT_FILE_PREFIX "${PROJECT_BINARY_DIR}/packages")


set(CPACK_GENERATOR "") # Empty list, user will specific with functions which generators they want
#include(packaging/cpack_zip)
#include(packaging/cpack_tgz)
include(packaging/cpack_deb)
#include(packaging/cpack_rpm)


#include(packaging/cpack_postinst)
include(InstallRequiredSystemLibraries)


include(CPack)