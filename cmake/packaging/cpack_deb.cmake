cmake_minimum_required(VERSION 3.21)

#################################
# Debian packages common configs
#################################

list(APPEND CPACK_GENERATOR "DEB")

if(DEFINED CPACK_COMPONENT_INSTALL)
    set(CPACK_DEB_COMPONENT_INSTALL ${CPACK_COMPONENT_INSTALL})
else()
    set(CPACK_DEB_COMPONENT_INSTALL OFF)
    message(DEBUG "CPACK_COMPONENT_INSTALL not defined. Setting CPACK_DEB_COMPONENT_INSTALL=${CPACK_DEB_COMPONENT_INSTALL}")
endif(DEFINED CPACK_COMPONENT_INSTALL)


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

function(packager_configure_deb PKG)
    string(TOUPPER ${PKG} PKG_UPPER)
    package_get_version(${PKG} PKG_VER)
    set(PKG_ARCH ${CPACK_DEBIAN_PACKAGE_ARCHITECTURE})
    set(PKG_NAME "${PKG}")
    set(CPACK_DEBIAN_${PKG_UPPER}_FILE_NAME "${PKG_NAME}_${PKG_VER}_${PKG_ARCH}.deb" CACHE INTERNAL "")
    set(CPACK_DEBIAN_${PKG_UPPER}_PACKAGE_SHLIBDEPS ON CACHE INTERNAL "")
endfunction(packager_configure_deb PKG)







