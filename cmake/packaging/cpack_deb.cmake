cmake_minimum_required(VERSION 3.21)

#################################
# Debian packages common configs
#################################
list(APPEND CPACK_GENERATOR "DEB")
if(CPACK_COMPONENT_INSTALL)
    set(CPACK_DEB_COMPONENT_INSTALL ${CPACK_COMPONENT_INSTALL})
endif(CPACK_COMPONENT_INSTALL)




set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_VENDOR} <${CPACK_PACKAGE_CONTACT}>")
set(CPACK_DEBIAN_PACKAGE_DESCRIPTION ${PROJECT_DESCRIPTION})
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
set(CPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS ON) # generate dependencies for upstream packages
set(CPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS_POLICY ">=")
set(CPACK_DEBIAN_PACKAGE_VERSION_MAJOR ${CPACK_PACKAGE_VERSION_MAJOR})
set(CPACK_DEBIAN_PACKAGE_VERSION_MINOR ${CPACK_PACKAGE_VERSION_MINOR})
set(CPACK_DEBIAN_PACKAGE_VERSION_PATCH ${CPACK_PACKAGE_VERSION_PATCH})
set(CPACK_DEBIAN_PACKAGE_VERSION ${CPACK_DEBIAN_PACKAGE_VERSION_MAJOR}.${CPACK_DEBIAN_PACKAGE_VERSION_MINOR}.${CPACK_DEBIAN_PACKAGE_VERSION_PATCH})
set(CPACK_DEBIAN_PACKAGE_FILE_BASE_NAME ${CPACK_PACKAGE_NAME}-${CPACK_DEBIAN_PACKAGE_VERSION})
set(CPACK_DEBIAN_PACKAGE_CONTROL_STRICT_PERMISSION ON)
                                    

if(NOT CMAKE_CROSSCOMPILING)
    # Configure the debian package architecture
    find_program(DPKG_ARCH_EXECUTABLE dpkg-architecture REQUIRED)
    execute_process(
        COMMAND ${DPKG_ARCH_EXECUTABLE} -qDEB_HOST_ARCH
        OUTPUT_VARIABLE CMAKE_DEB_HOST_ARCH
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${CMAKE_DEB_HOST_ARCH})

else()
    message(FATAL_ERROR "TODO: Add CPACK_DEBIAN_FILE_NAME configuration for cross-compiled projects")
endif(NOT CMAKE_CROSSCOMPILING)


######################################
# Debian package component configs
######################################
# careful about capitalization: https://cmake.org/cmake/help/v3.6/module/CPackDeb.html
# CPACK_DEBIAN_<ALL_CAPS_COMPONENT>_FILE_NAME controls the name of the packaged debian output file

#[[
https://cmake.org/cmake/help/v3.6/module/CPackDeb.html
CPACK_DEBIAN_FILE_NAME may be set to DEB-DEFAULT to allow CPackDeb to generate package file name by itself in deb format:
<PackageName>_<VersionNumber>-<DebianRevisionNumber>_<DebianArchitecture>.deb
#]]
set(CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT")