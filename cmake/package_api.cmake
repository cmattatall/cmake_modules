################################################################################
# Package Api:
#
# Description:
# A cmake module that is meant to provide a modular interface for generating
# relocatable, installable packages from source modules using cmake. 
#
# Author:
# Carl Mattatall (cmattatall2@gmail.com)
#
################################################################################
# RESOURCES:
# https://fossies.org/linux/cmake/Tests/CPackComponentsForAll/CMakeLists.txt   
################################################################################
cmake_minimum_required(VERSION 3.21)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
include(packaging/cpack)


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
    set(PACKAGE_STAGING_DIR "${CMAKE_BINARY_DIR}/staging/${PACKAGE}")
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
    set(${OUT_package_version_file_path} "${PACKAGE_CMAKE_FILES_STAGING_DIR}/${PACKAGE}ConfigVersion.cmake" PARENT_SCOPE)
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


function(package_get_library_files_install_destination PACKAGE OUT_library_files_install_destination)
    package_check_exists(${PACKAGE})
    set(${OUT_library_files_install_destination} ${CMAKE_INSTALL_LIBDIR}/${PACKAGE} PARENT_SCOPE)
endfunction(package_get_library_files_install_destination PACKAGE OUT_library_files_install_destination)


function(package_get_header_files_install_destination PACKAGE OUT_header_files_install_destination)
    package_check_exists(${PACKAGE})
    set(${OUT_header_files_install_destination} ${CMAKE_INSTALL_INCLUDEDIR}/${PACKAGE} PARENT_SCOPE)
endfunction(package_get_header_files_install_destination PACKAGE OUT_header_files_install_destination)


function(package_get_header_component_name PACKAGE OUT_header_component_name)
    package_check_exists(${PACKAGE})
    set(${OUT_header_component_name} "${PACKAGE}Dev" PARENT_SCOPE)
endfunction(package_get_header_component_name PACKAGE OUT_header_component_name)


function(package_get_library_component_name PACKAGE OUT_library_component_name)
    package_check_exists(${PACKAGE})
    set(${OUT_library_component_name} "${PACKAGE}Lib" PARENT_SCOPE)
endfunction(package_get_library_component_name PACKAGE OUT_library_component_name)


function(package_get_cmake_component_name PACKAGE OUT_cmake_component_name)
    package_check_exists(${PACKAGE})
    set(${OUT_cmake_component_name} "${PACKAGE}Cmake" PARENT_SCOPE)
endfunction(package_get_cmake_component_name PACKAGE OUT_cmake_component_name)


function(package_get_executable_component_name PACKAGE OUT_executable_component_name)
    package_check_exists(${PACKAGE})
    set(${OUT_executable_component_name} "${PACKAGE}Bin" PARENT_SCOPE)
endfunction(package_get_executable_component_name PACKAGE OUT_executable_component_name)


function(package_get_version PACKAGE OUT_package_version)
    package_check_exists(${PACKAGE})
    package_get_version_file_path(${PACKAGE} PACKAGE_VERSION_FILE)
    if(NOT (EXISTS ${PACKAGE_VERSION_FILE}))
        message(FATAL_ERROR "Package version file: ${PACKAGE_VERSION_FILE} doesn't exist.")
    endif(NOT (EXISTS ${PACKAGE_VERSION_FILE}))
    include(${PACKAGE_VERSION_FILE})
    set(${OUT_package_version} ${PACKAGE_VERSION} PARENT_SCOPE)
endfunction(package_get_version PACKAGE OUT_package_version)


function(package_get_component_list PACKAGE OUT_components_list)
    package_check_exists(${PACKAGE})
    
    # Use internal API to get component names 
    package_get_header_component_name(${PACKAGE} HEADER_COMPONENT)
    package_get_library_component_name(${PACKAGE} LIBRARY_COMPONENT)
    package_get_cmake_component_name(${PACKAGE} CMAKE_COMPONENT)
    package_get_executable_component_name(${PACKAGE} EXECUTABLE_COMPONENT)


    set(PACKAGE_COMPONENT_LIST) # empty list
    list(APPEND PACKAGE_COMPONENT_LIST ${HEADER_COMPONENT})
    list(APPEND PACKAGE_COMPONENT_LIST ${LIBRARY_COMPONENT})
    list(APPEND PACKAGE_COMPONENT_LIST ${CMAKE_COMPONENT})
    list(APPEND PACKAGE_COMPONENT_LIST ${EXECUTABLE_COMPONENT})
    set(${OUT_components_list} ${PACKAGE_COMPONENT_LIST} PARENT_SCOPE)
endfunction(package_get_component_list PACKAGE OUT_components_list)


# Usage:
# package_add( 
#   PACKAGE my_package    
#   [VERSION 0.9.1 ] 
# )
# 
# Notes: 
#   - Currently we don't validate if the version string is valid for semver
function(package_add)
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : ARGN=${ARGN}")
    ############################################################################
    # Developer configures these                                               #
    ############################################################################

    set(OPTION_ARGS
        # ADD YOUR OPTIONAL ARGUMENTS
    )

    ##########################
    # SET UP MONOVALUE ARGS  #
    ##########################
    set(SINGLE_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
        PACKAGE
        VERSION
    )
    set(SINGLE_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
    )

    ##########################
    # SET UP MULTIVALUE ARGS #
    ##########################
    set(MULTI_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
    )
    set(MULTI_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
    )

    ##########################
    # CONFIGURE CHOICES FOR  #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # The naming is very specific. 
    # If we wanted to restrict values 
    # for a keyword FOO, we would set a 
    # list called FOO-CHOICES
    # set(FOO-CHOICES FOO1 FOO2 FOO3)

    ##########################
    # CONFIGURE DEFAULTS FOR #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # The naming is very specific. 
    # If we wanted to provide a default value for a keyword BAR,
    # we would set BAR-DEFAULT.
    # set(BAR-DEFAULT MY_DEFAULT_BAR_VALUE)


    ############################################################################
    # Perform the argument parsing                                             #
    ############################################################################
    set(SINGLE_VALUE_ARGS)
    list(APPEND SINGLE_VALUE_ARGS ${SINGLE_VALUE_ARGS-REQUIRED} ${SINGLE_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES SINGLE_VALUE_ARGS)

    set(MULTI_VALUE_ARGS)
    list(APPEND MULTI_VALUE_ARGS ${MULTI_VALUE_ARGS-REQUIRED} ${MULTI_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES MULTI_VALUE_ARGS)

    cmake_parse_arguments(""
        "${OPTION_ARGS}"
        "${SINGLE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        "${ARGN}"
    )
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : _KEYWORDS_MISSING_VALUES=${_KEYWORDS_MISSING_VALUES}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : _UNPARSED_ARGUMENTS=${_UNPARSED_ARGUMENTS}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : SINGLE_VALUE_ARGS=${SINGLE_VALUE_ARGS}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : MULTI_VALUE_ARGS=${MULTI_VALUE_ARGS}")


    # Sanitize values for all required KWARGS
    list(LENGTH _KEYWORDS_MISSING_VALUES NUM_MISSING_KWARGS)
    if(NUM_MISSING_KWARGS GREATER 0)
        foreach(arg ${_KEYWORDS_MISSING_VALUES})
            message(WARNING "Keyword argument \"${arg}\" is missing a value.")
        endforeach(arg ${_KEYWORDS_MISSING_VALUES})
        message(FATAL_ERROR "One or more required keyword arguments are missing a value in call to ${CMAKE_CURRENT_FUNCTION}")
    endif(NUM_MISSING_KWARGS GREATER 0)

    # Ensure caller has provided required args
    foreach(arglist "SINGLE_VALUE_ARGS;MULTI_VALUE_ARGS")
        foreach(arg ${${arglist}})
            set(ARG_VALUE ${_${arg}})
            if(NOT DEFINED ARG_VALUE)
                if(DEFINED ${arg}-DEFAULT)
                    message(WARNING "keyword argument: \"${arg}\" not provided. Using default value of ${${arg}-DEFAULT}")
                    set(_${arg} ${${arg}-DEFAULT})
                else()
                    if(${arg} IN_LIST ${arglist}-REQUIRED)
                        message(FATAL_ERROR "Required keyword argument: \"${arg}\" not provided")
                    endif(${arg} IN_LIST ${arglist}-REQUIRED)
                endif(DEFINED ${arg}-DEFAULT)
            else()
                if(DEFINED ${arg}-CHOICES)
                    if(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                        message(FATAL_ERROR "Keyword argument \"${arg}\" given invalid value: \"${ARG_VALUE}\". \n Choices: ${${arg}-CHOICES}.")
                    endif(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                endif(DEFINED ${arg}-CHOICES)
            endif(NOT DEFINED ARG_VALUE)
        endforeach(arg ${${arglist}})
    endforeach(arglist "SINGLE_VALUE_ARGS;MULTI_VALUE_ARGS")

    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    list(LENGTH _UNPARSED_ARGUMENTS NUM_UNPARSED_ARGS)
    if(NUM_UNPARSED_ARGS GREATER 0)
        message(FATAL_ERROR "Unknown arguments: \"${_UNPARSED_ARGUMENTS}\" given to ${CMAKE_CURRENT_FUNCTION}")
    endif(NUM_UNPARSED_ARGS GREATER 0)

    package_get_exists(${_PACKAGE} PACKAGE_EXISTS)
    if(PACKAGE_EXISTS)
        return()
    else()
        package_get_packages_listfile(PACKAGE_LISTFILE)
        file(APPEND ${PACKAGE_LISTFILE} "${_PACKAGE}\n")
    endif(PACKAGE_EXISTS)

    set(VALID_VERSION_REGEX "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$")
    message(VERBOSE "Validating VERSION: ${_VERSION} against ${VALID_VERSION_REGEX}")
    string(REGEX MATCH ${VALID_VERSION_REGEX} VALID_VERSION ${_VERSION})

    if(NOT VALID_VERSION)
        message(VERBOSE "[in ${CMAKE_CURRENT_FUNCTION}] Argument VERSION does not match regex ${VALID_VERSION_REGEX}.")
        message(FATAL_ERROR "[in ${CMAKE_CURRENT_FUNCTION}] : VERSION argument given invalid value ${_VERSION}.")
    endif(NOT VALID_VERSION)
    
    package_get_version_file_path(${_PACKAGE} PACKAGE_VERSION_FILE)
    write_basic_package_version_file(
        ${PACKAGE_VERSION_FILE} 
        VERSION ${VALID_VERSION} 
        COMPATIBILITY AnyNewerVersion
    )

    package_get_cmake_component_name(${_PACKAGE} PACKAGE_CMAKE_COMPONENT)
    package_get_cmake_files_install_destination(${_PACKAGE} PACKAGE_INSTALL_CMAKE_DIR)
    install(
        FILES ${PACKAGE_VERSION_FILE}
        PERMISSIONS
            OWNER_WRITE OWNER_READ
            GROUP_READ
            WORLD_READ
        DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
        COMPONENT ${PACKAGE_CMAKE_COMPONENT}
    )

    package_get_targets_export_name(${_PACKAGE} PACKAGE_EXPORT_NAME)
    package_get_config_file_path(${_PACKAGE} PACKAGE_CONFIG_FILE)
    
    file(WRITE ${PACKAGE_CONFIG_FILE}.in "@PACKAGE_INIT@\ninclude(CMakeFindDependencyMacro)\n")
    file(APPEND ${PACKAGE_CONFIG_FILE}.in "include(\"\${CMAKE_CURRENT_LIST_DIR}/@PACKAGE_EXPORT_NAME@.cmake\")\n")
    file(APPEND ${PACKAGE_CONFIG_FILE}.in "check_required_components(\"@PROJECT_NAME@\")\n")

    configure_package_config_file(
        ${PACKAGE_CONFIG_FILE}.in
        ${PACKAGE_CONFIG_FILE}
        INSTALL_DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
    )
    file(REMOVE ${PACKAGE_CONFIG_FILE}.in)
    package_get_cmake_files_install_destination(${_PACKAGE} PACKAGE_INSTALL_CMAKE_DIR)
    install(
        FILES ${PACKAGE_CONFIG_FILE}
        PERMISSIONS
            OWNER_WRITE OWNER_READ
            GROUP_READ
            WORLD_READ        
        DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
        COMPONENT ${PACKAGE_CMAKE_COMPONENT}
    )

    # Get component names
    package_get_header_component_name(${_PACKAGE} PACKAGE_HEADER_COMPONENT)
    package_get_library_component_name(${_PACKAGE} PACKAGE_LIBRARY_COMPONENT)
    package_get_cmake_component_name(${_PACKAGE} PACKAGE_CMAKE_COMPONENT)
    package_get_executable_component_name(${_PACKAGE} PACKAGE_EXECUTABLE_COMPONENT)

    # Add components to the package
    package_add_component(${_PACKAGE} ${PACKAGE_LIBRARY_COMPONENT})
    package_add_component(${_PACKAGE} ${PACKAGE_EXECUTABLE_COMPONENT})

    package_add_component(${_PACKAGE} ${PACKAGE_HEADER_COMPONENT})
    package_add_component_dependency(${PACKAGE_HEADER_COMPONENT} ${PACKAGE_LIBRARY_COMPONENT})

    package_add_component(${_PACKAGE} ${PACKAGE_CMAKE_COMPONENT})
    package_add_component_dependency(${PACKAGE_CMAKE_COMPONENT} ${PACKAGE_LIBRARY_COMPONENT})
    package_add_component_dependency(${PACKAGE_CMAKE_COMPONENT} ${PACKAGE_EXECUTABLE_COMPONENT})

    packager_configure_deb(${_PACKAGE})
endfunction(package_add)



# Usage:
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

    ##########################
    # SET UP MONOVALUE ARGS  #
    ##########################
    set(SINGLE_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
        PACKAGE
        TARGET
        TARGET_TYPE
    )
    set(SINGLE_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
    )

    ##########################
    # SET UP MULTIVALUE ARGS #
    ##########################
    set(MULTI_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
    )
    set(MULTI_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
    )

    ##########################
    # CONFIGURE CHOICES FOR  #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # The naming is very specific. 
    # If we wanted to restrict values 
    # for a keyword FOO, we would set a 
    # list called FOO-CHOICES
    # set(FOO-CHOICES FOO1 FOO2 FOO3)
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
    # set(BAR-DEFAULT MY_DEFAULT_BAR_VALUE)
    set(TARGET_TYPE-DEFAULT SHARED)

    ############################################################################
    # Perform the argument parsing                                             #
    ############################################################################
    set(SINGLE_VALUE_ARGS)
    list(APPEND SINGLE_VALUE_ARGS ${SINGLE_VALUE_ARGS-REQUIRED} ${SINGLE_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES SINGLE_VALUE_ARGS)

    set(MULTI_VALUE_ARGS)
    list(APPEND MULTI_VALUE_ARGS ${MULTI_VALUE_ARGS-REQUIRED} ${MULTI_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES MULTI_VALUE_ARGS)

    cmake_parse_arguments(""
        "${OPTION_ARGS}"
        "${SINGLE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        "${ARGN}"
    )
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : _KEYWORDS_MISSING_VALUES=${_KEYWORDS_MISSING_VALUES}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : _UNPARSED_ARGUMENTS=${_UNPARSED_ARGUMENTS}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : SINGLE_VALUE_ARGS=${SINGLE_VALUE_ARGS}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : MULTI_VALUE_ARGS=${MULTI_VALUE_ARGS}")

    # Sanitize values for all required KWARGS
    list(LENGTH _KEYWORDS_MISSING_VALUES NUM_MISSING_KWARGS)
    if(NUM_MISSING_KWARGS GREATER 0)
        foreach(arg ${_KEYWORDS_MISSING_VALUES})
            message(WARNING "Keyword argument \"${arg}\" is missing a value.")
        endforeach(arg ${_KEYWORDS_MISSING_VALUES})
        message(FATAL_ERROR "One or more required keyword arguments are missing a value in call to ${CMAKE_CURRENT_FUNCTION}")
    endif(NUM_MISSING_KWARGS GREATER 0)

    # Ensure caller has provided required args
    foreach(arglist "SINGLE_VALUE_ARGS;MULTI_VALUE_ARGS")
        foreach(arg ${${arglist}})
            set(ARG_VALUE ${_${arg}})
            if(NOT DEFINED ARG_VALUE)
                if(DEFINED ${arg}-DEFAULT)
                    message(WARNING "keyword argument: \"${arg}\" not provided. Using default value of ${${arg}-DEFAULT}")
                    set(_${arg} ${${arg}-DEFAULT})
                else()
                    if(${arg} IN_LIST ${arglist}-REQUIRED)
                        message(FATAL_ERROR "Required keyword argument: \"${arg}\" not provided")
                    endif(${arg} IN_LIST ${arglist}-REQUIRED)
                endif(DEFINED ${arg}-DEFAULT)
            else()
                if(DEFINED ${arg}-CHOICES)
                    if(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                        message(FATAL_ERROR "Keyword argument \"${arg}\" given invalid value: \"${ARG_VALUE}\". \n Choices: ${${arg}-CHOICES}.")
                    endif(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                endif(DEFINED ${arg}-CHOICES)
            endif(NOT DEFINED ARG_VALUE)
        endforeach(arg ${${arglist}})
    endforeach(arglist "SINGLE_VALUE_ARGS;MULTI_VALUE_ARGS")

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

    package_get_version(${_PACKAGE} PACKAGE_VERSION)
    set_target_properties(${_TARGET} PROPERTIES VERSION "${PACKAGE_VERSION}")
    if(_TARGET_TYPE STREQUAL SHARED)
        set_target_properties(${_TARGET} PROPERTIES SOVERSION "${PACKAGE_VERSION}")    
    endif(_TARGET_TYPE STREQUAL SHARED)

    package_get_cmake_component_name(${_PACKAGE} PACKAGE_CMAKE_COMPONENT)
    package_get_library_component_name(${_PACKAGE} PACKAGE_LIB_COMPONENT)

    package_get_library_files_install_destination(${_PACKAGE} PACKAGE_LIB_INSTALL_DIR)
    package_get_cmake_files_install_destination(${_PACKAGE} PACKAGE_INSTALL_CMAKE_DIR)
    package_get_header_files_install_destination(${_PACKAGE} PACKAGE_HEADER_INSTALL_DIR)
    
    package_get_targets_export_name(${_PACKAGE} PACKAGE_EXPORT_NAME)
    package_get_targets_namespace(${_PACKAGE} PACKAGE_NAMESPACE)

    # Don't install object or interface libraries
    if((_TARGET_TYPE STREQUAL OBJECT) OR (_TARGET_TYPE STREQUAL INTERFACE))
        message(VERBOSE "Target: \"${_TARGET}\" is type: \"${_TARGET_TYPE}\" and so will not be installed.")
    else()

        # After the target is installed, if another project or target imports it
        # the header directories will have to be searched for in the 
        # system install tree and not the current build tree
        target_include_directories(${_TARGET} 
            PUBLIC
                $<INSTALL_INTERFACE:${PACKAGE_HEADER_INSTALL_DIR}>
        )
        
        install(
            TARGETS ${_TARGET}
            EXPORT  ${PACKAGE_TARGET_EXPORT_NAME}
            DESTINATION ${PACKAGE_LIB_INSTALL_DIR}
            COMPONENT ${PACKAGE_LIB_COMPONENT}
        )

        install(
            EXPORT ${PACKAGE_EXPORT_NAME}
            NAMESPACE ${PACKAGE_NAMESPACE}::
            DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
            COMPONENT ${PACKAGE_CMAKE_COMPONENT}
        )

    endif()
    
endfunction(package_add_library)


# Usage:
# package_create_libraries(
#   PACKAGE my_package_name
#   TARGET  my_target_name
#   SOURCES { src1.cpp src2.cpp } 
#   [PUBLIC_INCLUDE_DIRECTORIES] { dir1 dir2 ... }
#   [PRIVATE_INCLUDE_DIRECTORIES] { dir1 dir2 ... }
# )
function(package_create_libraries)
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : ARGN=${ARGN}")
    ############################################################################
    # Developer configures these                                               #
    ############################################################################
    
    set(OPTION_ARGS
        # Add optional (boolean) arguments here
    )

    ##########################
    # SET UP MONOVALUE ARGS  #
    ##########################
    set(SINGLE_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
        PACKAGE
        TARGET
    )
    set(SINGLE_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
    )
    
    ##########################
    # SET UP MULTIVALUE ARGS #
    ##########################
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
    # set(FOO-CHOICES FOO1 FOO2 FOO3)

    ##########################
    # CONFIGURE DEFAULTS FOR #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # The naming is very specific. 
    # If we wanted to provide a default value for a keyword BAR,
    # we would set BAR-DEFAULT.
    # set(BAR-DEFAULT MY_DEFAULT_BAR_VALUE)

    ############################################################################
    # Perform the argument parsing                                             #
    ############################################################################
    set(SINGLE_VALUE_ARGS)
    list(APPEND SINGLE_VALUE_ARGS ${SINGLE_VALUE_ARGS-REQUIRED} ${SINGLE_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES SINGLE_VALUE_ARGS)

    set(MULTI_VALUE_ARGS)
    list(APPEND MULTI_VALUE_ARGS ${MULTI_VALUE_ARGS-REQUIRED} ${MULTI_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES MULTI_VALUE_ARGS)

    cmake_parse_arguments(""
        "${OPTION_ARGS}"
        "${SINGLE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        "${ARGN}"
    )
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : _KEYWORDS_MISSING_VALUES=${_KEYWORDS_MISSING_VALUES}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : _UNPARSED_ARGUMENTS=${_UNPARSED_ARGUMENTS}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : SINGLE_VALUE_ARGS=${SINGLE_VALUE_ARGS}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : MULTI_VALUE_ARGS=${MULTI_VALUE_ARGS}")

    # Sanitize values for all required KWARGS
    list(LENGTH _KEYWORDS_MISSING_VALUES NUM_MISSING_KWARGS)
    if(NUM_MISSING_KWARGS GREATER 0)
        foreach(arg ${_KEYWORDS_MISSING_VALUES})
            message(WARNING "Keyword argument \"${arg}\" is missing a value.")
        endforeach(arg ${_KEYWORDS_MISSING_VALUES})
        message(FATAL_ERROR "One or more required keyword arguments are missing a value in call to ${CMAKE_CURRENT_FUNCTION}")
    endif(NUM_MISSING_KWARGS GREATER 0)

    # Ensure caller has provided required args
    foreach(arglist "SINGLE_VALUE_ARGS;MULTI_VALUE_ARGS")
        foreach(arg ${${arglist}})
            set(ARG_VALUE ${_${arg}})
            if(NOT DEFINED ARG_VALUE)
                if(DEFINED ${arg}-DEFAULT)
                    message(WARNING "keyword argument: \"${arg}\" not provided. Using default value of ${${arg}-DEFAULT}")
                    set(_${arg} ${${arg}-DEFAULT})
                else()
                    if(${arg} IN_LIST ${arglist}-REQUIRED)
                        message(FATAL_ERROR "Required keyword argument: \"${arg}\" not provided")
                    endif(${arg} IN_LIST ${arglist}-REQUIRED)
                endif(DEFINED ${arg}-DEFAULT)
            else()
                if(DEFINED ${arg}-CHOICES)
                    if(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                        message(FATAL_ERROR "Keyword argument \"${arg}\" given invalid value: \"${ARG_VALUE}\". \n Choices: ${${arg}-CHOICES}.")
                    endif(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                endif(DEFINED ${arg}-CHOICES)
            endif(NOT DEFINED ARG_VALUE)
        endforeach(arg ${${arglist}})
    endforeach(arglist "SINGLE_VALUE_ARGS;MULTI_VALUE_ARGS")

    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    set(OBJECT_LIBRARY_TARGET_NAME ${_TARGET}-objects)
    set(STATIC_LIBRARY_TARGET_NAME ${_TARGET}-static)
    set(SHARED_LIBRARY_TARGET_NAME ${_TARGET}-shared)

    package_add_library(
        PACKAGE ${_PACKAGE}
        TARGET ${OBJECT_LIBRARY_TARGET_NAME}
        TARGET_TYPE OBJECT
    )
    target_sources(${OBJECT_LIBRARY_TARGET_NAME} PRIVATE ${_SOURCES})


    package_add_library(
        PACKAGE ${_PACKAGE}
        TARGET ${SHARED_LIBRARY_TARGET_NAME}
        TARGET_TYPE SHARED
        $<TARGET_OBJECTS:${OBJECT_LIBRARY_TARGET_NAME}>
    )

    package_add_library(
        PACKAGE ${_PACKAGE}
        TARGET ${STATIC_LIBRARY_TARGET_NAME}
        TARGET_TYPE SHARED
        $<TARGET_OBJECTS:${OBJECT_LIBRARY_TARGET_NAME}>
    )

    if(DEFINED _PUBLIC_INCLUDE_DIRECTORIES)
        target_include_directories(${STATIC_LIBRARY_TARGET_NAME} PUBLIC ${_PUBLIC_INCLUDE_DIRECTORIES} )
        target_include_directories(${SHARED_LIBRARY_TARGET_NAME} PUBLIC ${_PUBLIC_INCLUDE_DIRECTORIES} )
    endif(DEFINED _PUBLIC_INCLUDE_DIRECTORIES)


    if(DEFINED _PRIVATE_INCLUDE_DIRECTORIES)
        target_include_directories(${STATIC_LIBRARY_TARGET_NAME} PRIVATE ${_PRIVATE_INCLUDE_DIRECTORIES} )
        target_include_directories(${SHARED_LIBRARY_TARGET_NAME} PRIVATE ${_PRIVATE_INCLUDE_DIRECTORIES} )
    endif(DEFINED _PRIVATE_INCLUDE_DIRECTORIES)

endfunction(package_create_libraries)



# Usage:
# package_install_headers(
#   PACKAGE <MY_PACKAGE>
#   FILES { file1.hpp file1.h file3.hpp }
# )
function(package_install_headers)
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : ARGN=${ARGN}")
    ############################################################################
    # Developer configures these                                               #
    ############################################################################
    
    set(OPTION_ARGS
        # Add optional (boolean) arguments here
    )

    ##########################
    # SET UP MONOVALUE ARGS  #
    ##########################
    set(SINGLE_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
        PACKAGE
    )
    set(SINGLE_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
    )
    
    ##########################
    # SET UP MULTIVALUE ARGS #
    ##########################
    set(MULTI_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
        FILES
    )
    set(MULTI_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
    )


    ##########################
    # CONFIGURE CHOICES FOR  #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # The naming is very specific. 
    # If we wanted to restrict values 
    # for a keyword FOO, we would set a 
    # list called FOO-CHOICES
    # set(FOO-CHOICES FOO1 FOO2 FOO3)

    ##########################
    # CONFIGURE DEFAULTS FOR #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # The naming is very specific. 
    # If we wanted to provide a default value for a keyword BAR,
    # we would set BAR-DEFAULT.
    # set(BAR-DEFAULT MY_DEFAULT_BAR_VALUE)

    ############################################################################
    # Perform the argument parsing                                             #
    ############################################################################
    set(SINGLE_VALUE_ARGS)
    list(APPEND SINGLE_VALUE_ARGS ${SINGLE_VALUE_ARGS-REQUIRED} ${SINGLE_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES SINGLE_VALUE_ARGS)

    set(MULTI_VALUE_ARGS)
    list(APPEND MULTI_VALUE_ARGS ${MULTI_VALUE_ARGS-REQUIRED} ${MULTI_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES MULTI_VALUE_ARGS)

    cmake_parse_arguments(""
        "${OPTION_ARGS}"
        "${SINGLE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        "${ARGN}"
    )
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : _KEYWORDS_MISSING_VALUES=${_KEYWORDS_MISSING_VALUES}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : _UNPARSED_ARGUMENTS=${_UNPARSED_ARGUMENTS}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : SINGLE_VALUE_ARGS=${SINGLE_VALUE_ARGS}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : MULTI_VALUE_ARGS=${MULTI_VALUE_ARGS}")

    # Sanitize values for all required KWARGS
    list(LENGTH _KEYWORDS_MISSING_VALUES NUM_MISSING_KWARGS)
    if(NUM_MISSING_KWARGS GREATER 0)
        foreach(arg ${_KEYWORDS_MISSING_VALUES})
            message(WARNING "Keyword argument \"${arg}\" is missing a value.")
        endforeach(arg ${_KEYWORDS_MISSING_VALUES})
        message(FATAL_ERROR "One or more required keyword arguments are missing a value in call to ${CMAKE_CURRENT_FUNCTION}")
    endif(NUM_MISSING_KWARGS GREATER 0)

    # Ensure caller has provided required args
    foreach(arglist "SINGLE_VALUE_ARGS;MULTI_VALUE_ARGS")
        foreach(arg ${${arglist}})
            set(ARG_VALUE ${_${arg}})
            if(NOT DEFINED ARG_VALUE)
                if(DEFINED ${arg}-DEFAULT)
                    message(WARNING "keyword argument: \"${arg}\" not provided. Using default value of ${${arg}-DEFAULT}")
                    set(_${arg} ${${arg}-DEFAULT})
                else()
                    if(${arg} IN_LIST ${arglist}-REQUIRED)
                        message(FATAL_ERROR "Required keyword argument: \"${arg}\" not provided")
                    endif(${arg} IN_LIST ${arglist}-REQUIRED)
                endif(DEFINED ${arg}-DEFAULT)
            else()
                if(DEFINED ${arg}-CHOICES)
                    if(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                        message(FATAL_ERROR "Keyword argument \"${arg}\" given invalid value: \"${ARG_VALUE}\". \n Choices: ${${arg}-CHOICES}.")
                    endif(NOT (${ARG_VALUE} IN_LIST ${arg}-CHOICES))
                endif(DEFINED ${arg}-CHOICES)
            endif(NOT DEFINED ARG_VALUE)
        endforeach(arg ${${arglist}})
    endforeach(arglist "SINGLE_VALUE_ARGS;MULTI_VALUE_ARGS")


    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    package_get_header_files_install_destination(${_PACKAGE} PACKAGE_HEADER_FILE_INSTALL_DIR)
    package_get_header_component_name(${_PACKAGE} PACKAGE_HEADER_COMPONENT)

    foreach(file ${_FILES})
        install(
            FILES ${file}
            DESTINATION ${PACKAGE_HEADER_FILE_INSTALL_DIR}
            COMPONENT ${PACKAGE_HEADER_COMPONENT}
        )
    endforeach(file ${_FILES})


endfunction(package_install_headers)


function(package_add_component PACKAGE COMPONENT_NAME)
    string(TOUPPER ${COMPONENT_NAME} COMPONENT_NAME_UPPER)
    set(CPACK_COMPONENT_${COMPONENT_NAME_UPPER}_GROUP ${PACKAGE} CACHE INTERNAL "")
endfunction(package_add_component PACKAGE COMPONENT_NAME)


function(package_add_component_dependency COMPONENT_NAME COMPONENT_DEPENDENCY_NAME)
    string(TOUPPER ${COMPONENT_NAME} COMPONENT_NAME_UPPER)
    set(CPACK_COMPONENT_${COMPONENT_NAME_UPPER}_DEPENDS ${COMPONENT_DEPENDENCY_NAME} CACHE INTERNAL "")
endfunction(package_add_component_dependency COMPONENT_NAME COMPONENT_DEPENDENCY_NAME)


macro(packager_finalize_config)
    include(CPack)
endmacro(packager_finalize_config)
