cmake_minimum_required(VERSION 3.21)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)


function(package_get_packages_listfile OUT_packages_listfile)
    set(${OUT_packages_listfile} ${CMAKE_BINARY_DIR}/package-list.txt PARENT_SCOPE) # top level of build tree
endfunction(package_get_packages_listfile OUT_packages_listfile)


function(package_get_exists PACKAGE OUT_package_exists)
    package_get_packages_listfile(PACKAGE_LISTFILE)
    set(${OUT_package_exists} 0 PARENT_SCOPE)
    if(EXISTS ${PACKAGE_LISTFILE})
        file(STRINGS ${PACKAGE_LISTFILE} PACKAGE_LIST)
        list(LENGTH PACKAGE_LIST PACKAGE_COUNT)
        if(PACKAGE_COUNT GREATER 0)
            if(${PACKAGE} IN_LIST PACKAGE_LIST)
                set(${OUT_package_exists} 1 PARENT_SCOPE)
            endif(${PACKAGE} IN_LIST PACKAGE_LIST)
        endif(PACKAGE_COUNT GREATER 0)
    else()
        # Create the empty file
        file(TOUCH ${PACKAGE_LISTFILE})
    endif(EXISTS ${PACKAGE_LISTFILE})
endfunction(package_get_exists PACKAGE OUT_package_exists)


function(package_check_exists PACKAGE)
    package_get_exists(${PACKAGE} PACKAGE_EXISTS)
    message("PACKAGE_EXISTS=${PACKAGE_EXISTS}")
    if(NOT PACKAGE_EXISTS)
        message(FATAL_ERROR "Cannot invoke ${CMAKE_CURRENT_FUNCTION} with arguments: ${ARGN}. Reason: package: \"${PACKAGE}\" does not exist.")
    endif(NOT PACKAGE_EXISTS)
endfunction(package_check_exists PACKAGE)


function(package_get_staging_dir PACKAGE OUT_package_staging_dir)
    package_check_exists(${PACKAGE})
    set(PACKAGE_STAGING_DIR "${CMAKE_BINARY_DIR}/staging/packages/${PACKAGE}/")
    get_filename_component(PARENT_PACKAGE_STAGING_DIR ${PACKAGE_STAGING_DIR} DIRECTORY)
    message("PARENT_PACKAGE_STAGING_DIR=${PARENT_PACKAGE_STAGING_DIR}")
    if(NOT EXISTS ${PARENT_PACKAGE_STAGING_DIR})
        file(MAKE_DIRECTORY ${PARENT_PACKAGE_STAGING_DIR})
    endif(NOT EXISTS ${PARENT_PACKAGE_STAGING_DIR})
    set(${OUT_package_staging_dir} ${PACKAGE_STAGING_DIR} PARENT_SCOPE)
endfunction(package_get_staging_dir PACKAGE OUT_package_staging_dir)


function(package_get_cmake_files_staging_dir PACKAGE OUT_package_cmake_files_staging_dir)
    package_get_staging_dir(${PACKAGE} PACKAGE_STAGING_PREFIX)
    set(${OUT_package_cmake_files_staging_dir} "${PACKAGE_STAGING_PREFIX}/cmake" PARENT_SCOPE)
endfunction(package_get_cmake_files_staging_dir PACKAGE OUT_package_cmake_files_staging_dir)


function(package_get_version_file_path PACKAGE OUT_package_version_file_path)
    package_get_cmake_files_staging_dir(${PACKAGE} PACKAGE_CMAKE_FILES_STAGING_DIR)
    set(${OUT_package_version_file_path} "${PACKAGE_CMAKE_FILES_STAGING_DIR}/${PACKAGE}Version.cmake" PARENT_SCOPE)
endfunction(package_get_version_file_path PACKAGE OUT_package_version_file_path)


function(package_get_config_file_path PACKAGE OUT_package_config_file_path)
    package_check_exists(${PACKAGE})
    package_get_cmake_files_staging_dir(${PACKAGE} PACKAGE_CMAKE_FILES_STAGING_DIR)
    set(${OUT_package_config_file_path} "${PACKAGE_CMAKE_FILES_STAGING_DIR}/${PACKAGE}Config.cmake" PARENT_SCOPE)
endfunction(package_get_config_file_path PACKAGE OUT_package_config_file_path)


function(package_get_targets_export_name PACKAGE OUT_export_name)
    package_check_exists(${PACKAGE})
    set(${OUT_export_name} "${PACKAGE}Targets" PARENT_SCOPE)
endfunction(package_get_targets_export_name PACKAGE OUT_export_name)


function(package_get_targets_namespace PACKAGE OUT_package_targets_namespace)
    package_check_exists(${PACKAGE})
    set(${OUT_package_targets_namespace} "${PACKAGE}" PARENT_SCOPE)
endfunction(package_get_targets_namespace PACKAGE OUT_package_targets_namespace)





function(package_get_cmake_files_install_destination PACKAGE OUT_cmake_files_install_destination)
    package_check_exists(${PACKAGE})
    set(${OUT_cmake_files_install_destination} "${CMAKE_INSTALL_LIBDIR}/cmake/${PACKAGE}/" PARENT_SCOPE)
endfunction(package_get_cmake_files_install_destination PACKAGE OUT_cmake_files_install_destination)




function(package_add PACKAGE VERSION)
    package_get_exists(${PACKAGE} PACKAGE_EXISTS)
    if(PACKAGE_EXISTS)
        return()
    else()
        package_get_packages_listfile(PACKAGE_LISTFILE)
        file(APPEND ${PACKAGE_LISTFILE} "${PACKAGE}\n")
    endif(PACKAGE_EXISTS)
    
    package_get_version_file_path(${PACKAGE} PACKAGE_VERSION_FILE)
    write_basic_package_version_file(
        ${PACKAGE_VERSION_FILE} 
        VERSION ${VERSION} 
        COMPATIBILITY AnyNewerVersion
    )

    package_get_cmake_files_install_destination(${PACKAGE} PACKAGE_INSTALL_CMAKE_DIR)
    install(
        FILES ${PACKAGE_VERSION_FILE}
        PERMISSIONS
            OWNER_WRITE OWNER_READ
            GROUP_READ
            WORLD_READ
        DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
        COMPONENT cmake
    )

    package_get_config_file_path(${PACKAGE} PACKAGE_CONFIG_FILE)
    set(CONFIG_INPUT_FILE_CONTENT "@PACKAGE_INIT@\ninclude(CMakeFindDependencyMacro)\ninclude(\"\${CMAKE_CURRENT_LIST_DIR}/@PACKAGE_EXPORT_NAME@.cmake\")\ncheck_required_components(\"@PROJECT_NAME@\")\n")
    file(WRITE ${PACKAGE_CONFIG_FILE}.in "${CONFIG_INPUT_FILE_CONTENT}")
    configure_package_config_file(
        ${PACKAGE_CONFIG_FILE}.in
        ${PACKAGE_CONFIG_FILE}
        INSTALL_DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
    )
    file(REMOVE ${PACKAGE_CONFIG_FILE}.in)

    #[[
    install(
        FILES ${PACKAGE_CONFIG_FILE}
        PERMISSIONS
            OWNER_WRITE OWNER_READ
            GROUP_READ
            WORLD_READ        
        DESTINATION ${PACKAGE_CMAKE_FILES_INSTALL_DESTINATION}
        COMPONENT cmake
    )
    #]]

    #[[
    package_get_targets_export_name(${PACKAGE} PACKAGE_EXPORT_NAME)
    package_get_targets_namespace(${PACKAGE} PACKAGE_NAMESPACE)
    install(
        EXPORT ${PACKAGE_EXPORT_NAME}
        NAMESPACE ${PACKAGE_NAMESPACE}::
        DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
        COMPONENT cmake
    )
    #]]
endfunction(package_add PACKAGE VERSION)



# Usage:
#
# package_add_library(
#    PACKAGE package 
#    TARGET target_name 
#    TYPE [ OBJECT | STATIC | SHARED ]
# )
function(package_add_library)
    message(VERBOSE "${CMAKE_CURRENT_FUNCTION} args: ${ARGN}")
    set(OPTION_ARGS)
    set(SINGLE_VALUE_ARGS
        PACKAGE
        TARGET
        TARGET_TYPE
    )
    set(MULTI_VALUE_ARGS)

    # The naming is very specific. 
    # If we wanted to restrict values for a keyword FOO,
    # we would set a list called FOO-CHOICES
    set(TARGET_TYPE-CHOICES 
        OBJECT 
        STATIC 
        SHARED
    )

    cmake_parse_arguments(""
        "${OPTION_ARGS}"
        "${SINGLE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        "${ARGN}"
    )

    # Sanitize values for all required KWARGS
    list(LENGTH _KEYWORDS_MISSING_VALUES NUM_MISSING_KWARGS)
    if(NUM_MISSING_KWARGS GREATER 0)
        foreach(arg ${_KEYWORDS_MISSING_VALUES})
            message(WARNING "Keyword argument \"${arg}\" is missing a value.")
        endforeach(arg ${_KEYWORDS_MISSING_VALUES})
        message(FATAL_ERROR "One or more required keyword arguments are missing a value in call to ${CMAKE_CURRENT_FUNCTION}")
    endif(NUM_MISSING_KWARGS GREATER 0)

    # Ensure caller has provided required args
    foreach(arg ${SINGLE_VALUE_ARGS})
        set(ARG_VALUE ${_${arg}})
        if(NOT DEFINED ARG_VALUE)
            message(FATAL_ERROR "Keyword argument: \"${arg}\" not provided")
        else()
            if(DEFINED ${arg}-CHOICES)
                if(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                    message(FATAL_ERROR "Argument \"${arg}\" given invalid value: \"${ARG_VALUE}\". \n Choices: ${${arg}-CHOICES}.")
                endif(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
            endif(DEFINED ${arg}-CHOICES)
        endif(NOT DEFINED ARG_VALUE)
    endforeach(arg ${SINGLE_VALUE_ARGS})

    # Sanitize unknown args
    list(LENGTH _UNPARSED_ARGUMENTS NUM_UNPARSED_ARGS)
    if(NUM_UNPARSED_ARGS GREATER 0)
        foreach(arg ${_UNPARSED_ARGUMENTS})
            message(WARNING "Unknown argument: \"${arg}\" in call to ${CMAKE_CURRENT_FUNCTION}.")
        endforeach(arg ${_UNPARSED_ARGUMENTS})
        message(FATAL_ERROR "One or more unknown arguments in call to ${CMAKE_CURRENT_FUNCTION}")
    endif(NUM_UNPARSED_ARGS GREATER 0)

    # Make sure all required args are parsed.
    foreach(required_arg ${SINGLE_VALUE_ARGS})
        list(FIND _UNPARSED_ARGUMENTS ${required_arg} FOUND)
        if(NOT (FOUND STREQUAL "-1"))
            message(FATAL_ERROR "in ${CMAKE_CURRENT_FUNCTION}, \"${required_arg}\" is a required keyword argument.")
        endif(NOT (FOUND STREQUAL "-1"))
    endforeach(required_arg ${SINGLE_VALUE_ARGS})

    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    if(TARGET ${_TARGET})
        message(FATAL_ERROR "Target: \"${_TARGET}\" already exists.")
    endif(TARGET ${_TARGET})


    add_library(${_TARGET} ${_TARGET_TYPE})

    # After the target is installed, if another project or target imports it
    # the header directories will have to be searched for in the 
    # system install tree and not the current build tree
    target_include_directories(${_TARGET} 
        PUBLIC 
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${_PACKAGE}>
    )


    package_get_targets_export_name(${_PACKAGE} PACKAGE_TARGET_EXPORT_NAME)

    # Don't install object libraries
    if(_TARGET_TYPE STREQUAL OBJECT)
        message(STATUS "Target: \"${_TARGET}\" is type: \"${_TARGET_TYPE}\" and so will not be installed.")
    else()
        install(
            TARGETS ${_TARGET}
            EXPORT  ${PACKAGE_TARGET_EXPORT_NAME}
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/${_PACKAGE}
            COMPONENT lib
        )

        package_get_targets_export_name(${PACKAGE} PACKAGE_EXPORT_NAME)
        package_get_targets_namespace(${PACKAGE} PACKAGE_NAMESPACE)
        install(
            EXPORT ${PACKAGE_EXPORT_NAME}
            NAMESPACE ${PACKAGE_NAMESPACE}::
            DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
            COMPONENT cmake
        )
    endif(_TARGET_TYPE STREQUAL OBJECT)
    
endfunction(package_add_library)

