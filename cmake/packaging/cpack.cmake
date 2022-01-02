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
    message(VERBOSE " Cannot set CPACK_RESOURCE_FILE_LICENSE. File: ${PROJECT_SOURCE_DIR}/LICENSE does not exist.")
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

# CONFIGURE VARIOUS CPACK GENERATORS
include(cpack/cpack_tgz)


function(package_update_generators)
    foreach(GENERATOR ${CPACK_GENERATOR})
    # Sadly, we have to manually specify CPACK_<GENERATOR>_COMPONENT_INSTALL manually.
    # If we do not, then the value of CPACK_COMPONENT_INSTALL will be ignored when
    # generating a specific package. This is a bug in my opinion but at least it 
    # is well documented.
    set(CPACK_${GENERATOR}_COMPONENT_INSTALL ${CPACK_COMPONENT_INSTALL})
    endforeach(GENERATOR ${CPACK_GENERATOR})
endfunction(package_update_generators)


function(package_create_deb)
    include(cpack/cpack_deb)
    package_update_generators()
endfunction(package_create_deb)


function(package_create_rpm)
    include(cpack/cpack_rpm)
    package_update_generators()
endfunction(package_create_rpm)


function(package_create_zip)
    include(cpack/cpack_zip)
    package_update_generators()
endfunction(package_create_zip)


function(package_create_all)
    package_create_deb()
    package_create_zip()
    package_create_rpm()
endfunction(package_create_all)






#include(packaging/cpack_postinst)
include(InstallRequiredSystemLibraries)
include(CPack)
