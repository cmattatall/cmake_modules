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
    if(NOT PACKAGE_EXISTS)
        message(FATAL_ERROR "Cannot invoke ${CMAKE_CURRENT_FUNCTION} with arguments: ${ARGN}. Reason: package: \"${PACKAGE}\" does not exist.")
    endif(NOT PACKAGE_EXISTS)
endfunction(package_check_exists PACKAGE)


function(package_get_staging_dir PACKAGE OUT_package_staging_dir)
    package_check_exists(${PACKAGE})
    set(PACKAGE_STAGING_DIR "${CMAKE_BINARY_DIR}/staging/${PACKAGE}/")
    get_filename_component(PARENT_PACKAGE_STAGING_DIR ${PACKAGE_STAGING_DIR} DIRECTORY)
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
    message(VERBOSE "${CMAKE_CURRENT_FUNCTION} args: ${ARGN}")
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
#    TYPE [ OBJECT | STATIC | SHARED | INTERFACE ]
# )
function(package_add_library)
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : ARGN=${ARGN}")
    ############################################################################
    # Developer configures these                                               #
    ############################################################################

    set(OPTION_ARGS
        # ADD YOUR OPTIONAL ARGUMENTS
    )

    set(SINGLE_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
        PACKAGE
        TARGET
        TARGET_TYPE
    )
    set(SINGLE_VALUE_ARGS-OPTIONAL
        VERSION
        # Add your argument keywords here
    )


    set(MULTI_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
        SOURCES
    )
    set(MULTI_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
        PUBLIC_INCLUDE_DIRECTORIES
        PRIVATE_INCLUDE_DIRECTORIES
    )

    ##########################
    # CONFIGURE CHOICES FOR  #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # The naming is very specific. 
    # If we wanted to restrict values 
    # for a keyword FOO, we would set a 
    # list called FOO-CHOICES
    set(TARGET_TYPE-CHOICES 
        OBJECT 
        STATIC 
        SHARED
        INTERFACE
    )

    ##########################
    # CONFIGURE DEFAULTS FOR #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # The naming is very specific. 
    # If we wanted to provide a default value for a keyword BAR,
    # we would set BAR-DEFAULT.
    set(TARGET_TYPE-DEFAULT SHARED)

    if(DEFINED PROJECT_VERSION)
        set(VERSION-DEFAULT ${PROJECT_VERSION})
    endif(DEFINED PROJECT_VERSION)

    ############################################################################
    # Perform the argument parsing                                             #
    ############################################################################
    set(SINGLE_VALUE_ARGS)
    list(APPEND SINGLE_VALUE_ARGS ${SINGLE_VALUE_ARGS-REQUIRED} ${SINGLE_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES SINGLE_VALUE_ARGS)
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : SINGLE_VALUE_ARGS=${SINGLE_VALUE_ARGS}")

    set(MULTI_VALUE_ARGS)
    list(APPEND MULTI_VALUE_ARGS ${MULTI_VALUE_ARGS-REQUIRED} ${MULTI_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES MULTI_VALUE_ARGS)
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : MULTI_VALUE_ARGS=${MULTI_VALUE_ARGS}")


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
            if(DEFINED ${arg}-DEFAULT)
                message(WARNING "keyword argument: \"${arg}\" not provided. Using default value of ${${arg}-DEFAULT}")
                set(_${arg} ${${arg}-DEFAULT})
            else()
                if(${arg} IN_LIST SINGLE_VALUE_ARGS-REQUIRED)
                    message(FATAL_ERROR "Required keyword argument: \"${arg}\" not provided")
                endif(${arg} IN_LIST SINGLE_VALUE_ARGS-REQUIRED)
            endif(DEFINED ${arg}-DEFAULT)
        else()
            if(DEFINED ${arg}-CHOICES)
                if(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                    message(FATAL_ERROR "Keyword argument \"${arg}\" given invalid value: \"${ARG_VALUE}\". \n Choices: ${${arg}-CHOICES}.")
                endif(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
            endif(DEFINED ${arg}-CHOICES)
        endif(NOT DEFINED ARG_VALUE)
    endforeach(arg ${SINGLE_VALUE_ARGS})

    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    if(TARGET ${_TARGET})
        message(FATAL_ERROR "Target: \"${_TARGET}\" already exists.")
    endif(TARGET ${_TARGET})

                                        
    add_library(
        ${_TARGET} 
        ${_TARGET_TYPE} 
        ${_UNPARSED_ARGUMENTS} 
        # PROPAGATE OTHER ARGS TO add_library call
        # e.g. 
        #    - $<TARGET_OBJECTS:SOME_OTHER_TARGET>
        #    - source1.cpp source2.cpp,
        #    - EXCLUDE_FROM_ALL               
    )

    set_target_properties(${_TARGET} 
        PROPERTIES 
            POSITION_INDEPENDENT_CODE ON
    )

    package_get_targets_export_name(${_PACKAGE} PACKAGE_TARGET_EXPORT_NAME)

    if(DEFINED _VERSION)
        set_target_properties(${_TARGET} PROPERTIES VERSION "${_VERSION}")
        if(_TARGET_TYPE STREQUAL SHARED)
            set_target_properties(${_TARGET} PROPERTIES SOVERSION "${_VERSION}")    
        endif(_TARGET_TYPE STREQUAL SHARED)
    endif(DEFINED _VERSION)

    # Don't install object or interface libraries
    if((_TARGET_TYPE STREQUAL OBJECT) OR (_TARGET_TYPE STREQUAL INTERFACE))
        message(STATUS "Target: \"${_TARGET}\" is type: \"${_TARGET_TYPE}\" and so will not be installed.")
    else()

        # After the target is installed, if another project or target imports it
        # the header directories will have to be searched for in the 
        # system install tree and not the current build tree
        target_include_directories(${_TARGET} 
        PUBLIC 
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${_PACKAGE}>
        )

        install(
            TARGETS ${_TARGET}
            EXPORT  ${PACKAGE_TARGET_EXPORT_NAME}
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/${_PACKAGE}
            COMPONENT lib
        )

        package_get_cmake_files_install_destination(${_PACKAGE} PACKAGE_INSTALL_CMAKE_DIR)
        package_get_targets_export_name(${_PACKAGE} PACKAGE_EXPORT_NAME)
        package_get_targets_namespace(${_PACKAGE} PACKAGE_NAMESPACE)
        install(
            EXPORT ${PACKAGE_EXPORT_NAME}
            NAMESPACE ${PACKAGE_NAMESPACE}::
            DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
            COMPONENT cmake
        )
    endif()
    
endfunction(package_add_library)




function(package_create_libraries)
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : ARGN=${ARGN}")
    ############################################################################
    # Developer configures these                                               #
    ############################################################################
    
    set(OPTION_ARGS
        # Add optional (boolean) arguments here
    )

    set(SINGLE_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
        PACKAGE
        TARGET
    )
    set(SINGLE_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
    )
    
    set(MULTI_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
        SOURCES
    )

    set(MULTI_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
        PUBLIC_INCLUDE_DIRECTORIES
        PRIVATE_INCLUDE_DIRECTORIES
    )


    ##########################
    # CONFIGURE CHOICES FOR  #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # The naming is very specific. 
    # If we wanted to restrict values 
    # for a keyword FOO, we would set a 
    # list called FOO-CHOICES

    ##########################
    # CONFIGURE DEFAULTS FOR #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # The naming is very specific. 
    # If we wanted to provide a default value for a keyword BAR,
    # we would set BAR-DEFAULT.

    ############################################################################
    # Perform the argument parsing                                             #
    ############################################################################
    set(SINGLE_VALUE_ARGS)
    list(APPEND SINGLE_VALUE_ARGS ${SINGLE_VALUE_ARGS-REQUIRED} ${SINGLE_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES SINGLE_VALUE_ARGS)
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : SINGLE_VALUE_ARGS=${SINGLE_VALUE_ARGS}")

    set(MULTI_VALUE_ARGS)
    list(APPEND MULTI_VALUE_ARGS ${MULTI_VALUE_ARGS-REQUIRED} ${MULTI_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES MULTI_VALUE_ARGS)
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : MULTI_VALUE_ARGS=${MULTI_VALUE_ARGS}")

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
            if(DEFINED ${arg}-DEFAULT)
                message(WARNING "keyword argument: \"${arg}\" not provided. Using default value of ${${arg}-DEFAULT}")
                set(_${arg} ${${arg}-DEFAULT})
            else()
                if(${arg} IN_LIST SINGLE_VALUE_ARGS-REQUIRED)
                message(FATAL_ERROR "Required keyword argument: \"${arg}\" not provided")
            endif(${arg} IN_LIST SINGLE_VALUE_ARGS-REQUIRED)
            endif(DEFINED ${arg}-DEFAULT)
        else()
            if(DEFINED ${arg}-CHOICES)
                if(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                    message(FATAL_ERROR "Argument \"${arg}\" given invalid value: \"${ARG_VALUE}\". \n Choices: ${${arg}-CHOICES}.")
                endif(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
            endif(DEFINED ${arg}-CHOICES)
        endif(NOT DEFINED ARG_VALUE)
    endforeach(arg ${SINGLE_VALUE_ARGS})

    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    set(OBJECT_LIBRARY_TARGET_NAME ${_TARGET}-objects)
    set(STATIC_LIBRARY_TARGET_NAME ${_TARGET}-static)
    set(SHARED_LIBRARY_TARGET_NAME ${_TARGET}-shared)

    package_add_library(
        PACKAGE ${PACKAGE}
        TARGET ${OBJECT_LIBRARY_TARGET_NAME}
        TARGET_TYPE OBJECT
    )
    target_sources(${OBJECT_LIBRARY_TARGET_NAME} PRIVATE ${_SOURCES})


    package_add_library(
        PACKAGE ${PACKAGE}
        TARGET ${SHARED_LIBRARY_TARGET_NAME}
        TARGET_TYPE SHARED
        $<TARGET_OBJECTS:${OBJECT_LIBRARY_TARGET_NAME}>
    )

    package_add_library(
        PACKAGE ${PACKAGE}
        TARGET ${STATIC_LIBRARY_TARGET_NAME}
        TARGET_TYPE SHARED
        $<TARGET_OBJECTS:${OBJECT_LIBRARY_TARGET_NAME}>
    )

endfunction(package_create_libraries)
