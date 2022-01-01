cmake_minimum_required(VERSION 3.21)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

function(package_get_targets_export_name PACKAGE OUT_export_name)
    set(OUT_export_name "${PACKAGE}Targets" PARENT_SCOPE)
endfunction(package_get_targets_export_name PACKAGE OUT_export_name)


function(package_get_targets_namespace PACKAGE OUT_package_targets_namespace)
    set(OUT_package_targets_namespace "${PACKAGE}" PARENT_SCOPE)
endfunction(package_get_targets_namespace PACKAGE OUT_package_targets_namespace)


function(package_get_config_file_path PACKAGE OUT_package_config_file_path)
    set(OUT_package_config_file_path "${CMAKE_BINARY_DIR}/${PACKAGE}Config.cmake" PARENT_SCOPE)
endfunction(package_get_config_file_path PACKAGE OUT_package_config_file_path)


function(package_get_version_file_path PACKAGE OUT_package_version_file_path)
    set(OUT_package_version_file_path "${CMAKE_BINARY_DIR}/${PACKAGE}Version.cmake" PARENT_SCOPE)
endfunction(package_get_version_file_path PACKAGE OUT_package_version_file_path)


function(package_get_cmake_files_install_destination PACKAGE OUT_cmake_files_install_destination)
    set(OUT_cmake_files_install_destination "${CMAKE_INSTALL_LIBDIR}/cmake/${PACKAGE}/")
endfunction(package_get_cmake_files_install_destination PACKAGE OUT_cmake_files_install_destination)


function(package_get_metadata_file_location PACKAGE OUT_package_metadata_file_location)
    set(OUT_package_metadata_file_location "${CMAKE_BINARY_DIR}/packages/${PACKAGE}.cmake")
endfunction(package_get_metadata_file_location PACKAGE OUT_package_metadata_file_location)


function(package_write_metadata_file PACKAGE VERSION)
    package_get_metadata_file_location(${PACKAGE} PACKAGE_META_FILE)
    get_filename_component(PACKAGE_METADATA_FILE_DIR ${PACKAGE_META_FILE} DIRECTORY)
    if(NOT EXISTS ${PACKAGE_METADATA_FILE_DIR})
        file(MAKE_DIRECTORY ${PACKAGE_METADATA_FILE_DIR})
    endif(NOT EXISTS ${PACKAGE_METADATA_FILE_DIR})
    file(WRITE 
        ${PACKAGE_META_FILE}
        "set(PACKAGE_VERSION \${PACKAGE_VERSION})\n"
    )
endfunction(package_write_metadata_file PACKAGE VERSION)




function(package_add PACKAGE VERSION)
    package_write_metadata_file(${PACKAGE} ${VERSION})
    package_get_cmake_files_install_destination(${PACKAGE} PACKAGE_INSTALL_CMAKE_DIR)
    package_get_version_file_path(${PACKAGE} PACKAGE_VERSION_FILE)

    write_basic_package_version_file(
        ${PACKAGE_VERSION_FILE} 
        VERSION ${VERSION} 
        COMPATIBILITY AnyNewerVersion
    )
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
    install(
        FILES ${PACKAGE_CONFIG_FILE}
        PERMISSIONS
            OWNER_WRITE OWNER_READ
            GROUP_READ
            WORLD_READ        
        DESTINATION ${PACKAGE_CMAKE_FILES_INSTALL_DESTINATION}
        COMPONENT cmake
    )

    package_get_targets_export_name(${PACKAGE} PACKAGE_EXPORT_NAME)
    package_get_targets_namespace(${PACKAGE} PACKAGE_NAMESPACE)
    install(
        EXPORT ${PACKAGE_EXPORT_NAME}
        NAMESPACE ${PACKAGE_NAMESPACE}::
        DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
        COMPONENT cmake
    )
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
        message("ARG_VALUE:${ARG_VALUE}")
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
    endif(_TARGET_TYPE STREQUAL OBJECT)
    
endfunction(package_add_library)

