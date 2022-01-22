cmake_minimum_required(VERSION 3.21)


macro(Packager_config_metadata)

    set(CPACK_PACKAGE_NAME ${PROJECT_NAME} CACHE INTERNAL "")
    set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
    set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
    set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})

    set(CPACK_PACKAGE_VENDOR "Carl Mattatall" CACHE INTERNAL "")
    set(CPACK_PACKAGE_CONTACT "cmattatall2@gmail.com" CACHE INTERNAL "")

endmacro(Packager_config_metadata)


# This must be the first thing you call.
macro(Packager_init)

    set(CPACK_COMPONENTS_GROUPING ONE_PER_GROUP CACHE INTERNAL "")
    set(CPACK_COMPONENT_INSTALL ON CACHE INTERNAL "")

    set(CPACK_STRIP_FILES ON CACHE INTERNAL "")
    set(CPACK_STRIP_FILES ON CACHE INTERNAL "")
    set(CPACK_SET_DESTDIR OFF CACHE INTERNAL "")


    set(CPACK_VERBATIM_VARIABLES YES CACHE INTERNAL "")

    if(UNIX)
        if(NOT APPLE)
            set(CPACK_PACKAGING_INSTALL_PREFIX "/usr" CACHE INTERNAL "") 
        endif()
    else()
        message(WARNING "Cannot set CPACK_PACKAGING_INSTALL_PREFIX. ${CMAKE_CURRENT_LIST_FILE} does not currently have support for ${CMAKE_HOST_SYSTEM_NAME}")
    endif()

    set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_BINARY_DIR}/packages" CACHE INTERNAL "")

    # Empty list.
    # Caller will use other PackagerX functions e.g. PackagerDeb to populate.
    set(CPACK_GENERATOR "") 

endmacro(Packager_init)


function(Packager_configure_license)
    if(EXISTS "${PROJECT_SOURCE_DIR}/LICENSE")
        set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE")
        message(VERBOSE "Using ${PROJECT_SOURCE_DIR}/LICENSE as CPACK_RESOURCE_FILE_LICENSE.")
    else()
        message(VERBOSE "Cannot set CPACK_RESOURCE_FILE_LICENSE. File: ${PROJECT_SOURCE_DIR}/LICENSE does not exist.")
    endif(EXISTS "${PROJECT_SOURCE_DIR}/LICENSE")
endfunction(Packager_configure_license)


function(Packager_configure_readme)
    if(EXISTS "${PROJECT_SOURCE_DIR}/README.md")
        set(CPACK_RESOURCE_FILE_README "${PROJECT_SOURCE_DIR}/README.md")
        message(VERBOSE "Using ${PROJECT_SOURCE_DIR}/README.md as CPACK_RESOURCE_FILE_README.")
    else()
        message(VERBOSE "Cannot set CPACK_RESOURCE_FILE_README. File: ${PROJECT_SOURCE_DIR}/README.md does not exist.")
    endif(EXISTS "${PROJECT_SOURCE_DIR}/README.md")  
endfunction(Packager_configure_readme)


################################################################################
# THIS MUST BE CALLED LAST IN THE TOP-LEVEL CMAKELISTS.TXT                     #
################################################################################
# AS IT FINALIZES THE SETTIGNS FOR ALL THE VARIABLES                           #
# CONFIGURED USING THIS MODULE'S FUNCTIONS AND GENERATES THE CPACK CONFIG. #
################################################################################
macro(Packager_finalize_config)
    include(CPack)
endmacro(Packager_finalize_config)


include(InstallRequiredSystemLibraries)
