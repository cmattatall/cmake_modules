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

set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})

set(CPACK_PACKAGING_INSTALL_PREFIX "/usr" CACHE INTERNAL "") # Sorry windows folks
set(CPACK_OUTPUT_FILE_PREFIX "${CMAKE_BINARY_DIR}/packages" CACHE INTERNAL "")

set(CPACK_GENERATOR "") # Empty list, user will specific with functions which generators they want


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
