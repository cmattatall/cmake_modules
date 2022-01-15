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

    package_get_ldconfig_file_path(${PKG} PKG_LDCONFIG_FILE)
    package_get_library_files_install_destination(${PKG} PKG_INSTALL_LIBDIR)
    package_get_postinst_component_name(${PKG} PKG_POSTINST_COMPONENT_NAME)
    package_get_ldconfig_install_dir(${PKG} PKG_LDCONFIG_INSTALL_DIR)

    if(NOT EXISTS ${PKG_LDCONFIG_INSTALL_DIR})
        message(DEBUG "Directory ${PKG_LDCONFIG_INSTALL_DIR} does not exist. Ldconfig installation for package : \"${PACKAGE}\" may fail.")
    elseif(NOT IS_DIRECTORY ${PKG_LDCONFIG_INSTALL_DIR})
        message(DEBUG "${PKG_LDCONFIG_INSTALL_DIR} exist, but is not a directory. Ldconfig installation for package : \"${PACKAGE}\" may fail.")
    endif()


    message(DEBUG "PKG_LDCONFIG_FILE:${PKG_LDCONFIG_FILE} (${CMAKE_CURRENT_FUNCTION}:${CMAKE_CURRENT_LIST_LINE})")
    message(DEBUG "PKG_LDCONFIG_INSTALL_DIR:${PKG_LDCONFIG_INSTALL_DIR} (${CMAKE_CURRENT_FUNCTION}:${CMAKE_CURRENT_LIST_LINE})")

    file(
        WRITE "${PKG_LDCONFIG_FILE}"
        "# ${PKG} default configuration\n${PKG_INSTALL_LIBDIR}\n"
    )

    message("PKG_LDCONFIG_FILE:${PKG_LDCONFIG_FILE}")

    install(
        FILES "${PKG_LDCONFIG_FILE}"
        DESTINATION "${PKG_LDCONFIG_INSTALL_DIR}"
        PERMISSIONS
            OWNER_WRITE OWNER_READ
            GROUP_READ
            WORLD_READ
        COMPONENT ${PKG_POSTINST_COMPONENT_NAME}
    )

    package_get_configfile_staging_dir(${PKG} PKG_CONFIGFILE_DIR)
    if(NOT EXISTS "${PKG_CONFIGFILE_DIR}")
        file(MAKE_DIRECTORY "${PKG_CONFIGFILE_DIR}")
    endif(NOT EXISTS "${PKG_CONFIGFILE_DIR}")
    
    set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "${PKG_CONFIGFILE_DIR}/postinst")
    file(
        WRITE ${CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA}
        "#!/bin/bash\necho \"performing postinst steps for package: ${PKG}\"\nldconfig\n"
    )

endfunction(packager_configure_deb PKG)







