cmake_minimum_required(VERSION 3.21)
message(FATAL_ERROR "This is deprecated!")

######################################
# Configure Post-install steps
######################################
# Write the post-install script
set(PROJECT_CONFIG_FILE_STAGING_DIR "${PROJECT_BINARY_DIR}/configFiles") 

if(NOT EXISTS ${PROJECT_BINARY_DIR}/configFiles)
    file(MAKE_DIRECTORY ${PROJECT_BINARY_DIR}/configFiles)
endif(NOT EXISTS ${PROJECT_BINARY_DIR}/configFiles)

file(
    WRITE ${PROJECT_BINARY_DIR}/configFiles/postinst
    "#!/bin/bash\necho \"performing postinst steps for ${PROJECT_NAME}\"\nldconfig\n"
)
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA ${PROJECT_BINARY_DIR}/configFiles/postinst)


# Write, set permissions, and install the ld config file
set(PACKAGE_LDCONFIG_FILE ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.conf)
file(
    WRITE ${PACKAGE_LDCONFIG_FILE}
    "# ${PROJECT_NAME} default configuration\n${CPACK_PACKAGING_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}\n"
)

install(
    FILES ${PACKAGE_LDCONFIG_FILE}
    DESTINATION "/etc/ld.so.conf.d/${PROJECT_NAME}/"
    PERMISSIONS
        OWNER_WRITE OWNER_READ
        GROUP_READ
        WORLD_READ
    COMPONENT lib
)