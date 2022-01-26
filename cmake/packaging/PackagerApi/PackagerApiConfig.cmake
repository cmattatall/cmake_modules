################################################################################
# Package Api:                                                                 #
#                                                                              #
# Description:                                                                 #
# A cmake module that is meant to provide a modular interface for generating   #
# relocatable, installable packages from source modules using cmake.           #
#                                                                              #
# Author:                                                                      #   
# Carl Mattatall (cmattatall2@gmail.com)                                       #
#                                                                              #
################################################################################
cmake_minimum_required(VERSION 3.21)

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

find_package(PkgConfig REQUIRED)

find_package(Packager REQUIRED)
find_package(PackagerDeb REQUIRED)
find_package(PackagerRpm REQUIRED)
find_package(PackagerTgz REQUIRED)
find_package(PackagerZip REQUIRED)




macro(PackagerApi_init)
    # This does nothing for now, but we will put this here in the future
endmacro(PackagerApi_init)



function(PackagerApi_get_packages_listfile OUT_packages_listfile)
    set(${OUT_packages_listfile} "${CMAKE_BINARY_DIR}/package-list.txt" PARENT_SCOPE) # top level of build tree
endfunction(PackagerApi_get_packages_listfile OUT_packages_listfile)


function(PackagerApi_get_listed_packages OUT_PackagerApi_list)
    PackagerApi_get_packages_listfile(PACKAGE_LISTFILE)
    set(LISTED_PACKAGES "") # empty list
    if(NOT EXISTS ${PACKAGE_LISTFILE})
        message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ] - PACKAGE_LISTFILE:\"${PACKAGE_LISTFILE}\" did not exist. Creating now...")
        file(TOUCH ${PACKAGE_LISTFILE}) # Create the empty file
    else()
        file(STRINGS ${PACKAGE_LISTFILE} LISTED_PACKAGES)
    endif(NOT EXISTS ${PACKAGE_LISTFILE})

    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ] - LISTED_PACKAGES=\"${LISTED_PACKAGES}\"")
    set(${OUT_PackagerApi_list} ${LISTED_PACKAGES} PARENT_SCOPE)
endfunction(PackagerApi_get_listed_packages OUT_PackagerApi_list)


function(PackagerApi_get_exists PACKAGE OUT_PackagerApi_exists)
    PackagerApi_get_listed_packages(PACKAGE_LIST)
    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ] - PACKAGE_LIST=\"${PACKAGE_LIST}\"")
    if(${PACKAGE} IN_LIST PACKAGE_LIST)
        set(${OUT_PackagerApi_exists} 1 PARENT_SCOPE)
    else()
        set(${OUT_PackagerApi_exists} 0 PARENT_SCOPE)
    endif(${PACKAGE} IN_LIST PACKAGE_LIST)
endfunction(PackagerApi_get_exists PACKAGE OUT_PackagerApi_exists)


function(PackagerApi_add_to_list PACKAGE)
    PackagerApi_get_packages_listfile(PACKAGE_LISTFILE)
    PackagerApi_get_listed_packages(PACKAGE_LIST)
    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION}] - PACKAGE_LIST=\"${PACKAGE_LIST}\"")
    if(NOT (${PACKAGE} IN_LIST PACKAGE_LIST))
        message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION}] - Appending package ${PACKAGE} to ${PACKAGE_LISTFILE}")
        file(APPEND ${PACKAGE_LISTFILE} "${PACKAGE}\n")

        PackagerApi_get_listed_packages(UPDATED_PACKAGE_LIST)
        message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION}] - After adding package ${PACKAGE}, UPDATED_PACKAGE_LIST:\"${UPDATED_PACKAGE_LIST}\"")

    else()
        message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION}] - FOUND PACKAGE ${PACKAGE} IN PACKAGE_LIST:\"${PACKAGE_LIST}\". Package will not be appended to the package list.")
    endif(NOT (${PACKAGE} IN_LIST PACKAGE_LIST))
endfunction(PackagerApi_add_to_list PACKAGE)

function(PackagerApi_check_exists PACKAGE)
    PackagerApi_get_exists(${PACKAGE} PACKAGE_EXISTS)
    if(NOT ${PACKAGE_EXISTS})
        message(FATAL_ERROR "Cannot invoke ${CMAKE_CURRENT_FUNCTION} with arguments: ${ARGV}. Reason: package: \"${PACKAGE}\" does not exist.")
    endif(NOT ${PACKAGE_EXISTS})
endfunction(PackagerApi_check_exists PACKAGE)


function(PackagerApi_get_version_file_path PACKAGE OUT_PackagerApi_version_file_path)
    PackagerApi_get_cmake_files_staging_dir(${PACKAGE} PACKAGE_CMAKE_FILES_STAGING_DIR)
    set(${OUT_PackagerApi_version_file_path} "${PACKAGE_CMAKE_FILES_STAGING_DIR}/${PACKAGE}ConfigVersion.cmake" PARENT_SCOPE)
endfunction(PackagerApi_get_version_file_path PACKAGE OUT_PackagerApi_version_file_path)


function(PackagerApi_get_config_file_path PACKAGE OUT_PackagerApi_config_file_path)
    PackagerApi_check_exists(${PACKAGE})
    PackagerApi_get_cmake_files_staging_dir(${PACKAGE} PACKAGE_CMAKE_FILES_STAGING_DIR)
    set(${OUT_PackagerApi_config_file_path} "${PACKAGE_CMAKE_FILES_STAGING_DIR}/${PACKAGE}Config.cmake" PARENT_SCOPE)
endfunction(PackagerApi_get_config_file_path PACKAGE OUT_PackagerApi_config_file_path)


function(PackagerApi_get_targets_export_name PACKAGE OUT_export_name)
    PackagerApi_check_exists(${PACKAGE})
    set(${OUT_export_name} "${PACKAGE}Targets" PARENT_SCOPE)
endfunction(PackagerApi_get_targets_export_name PACKAGE OUT_export_name)


function(PackagerApi_get_targets_namespace PACKAGE OUT_PackagerApi_targets_namespace)
    PackagerApi_check_exists(${PACKAGE})
    set(${OUT_PackagerApi_targets_namespace} "${PACKAGE}" PARENT_SCOPE)
endfunction(PackagerApi_get_targets_namespace PACKAGE OUT_PackagerApi_targets_namespace)


function(PackagerApi_get_reldir_suffix PACKAGE OUT_reldir_suffix)
    PackagerApi_check_exists(${PACKAGE})
    set(${OUT_reldir_suffix} ${PACKAGE} PARENT_SCOPE)
endfunction(PackagerApi_get_reldir_suffix PACKAGE OUT_reldir_suffix)


function(PackagerApi_get_library_files_install_reldir PACKAGE OUT_library_files_install_reldir)
    PackagerApi_check_exists(${PACKAGE})
    PackagerApi_get_reldir_suffix(${PACKAGE} INSTALL_RELDIR_SUFFIX)
    set(${OUT_library_files_install_reldir} ${CMAKE_INSTALL_LIBDIR}/${INSTALL_RELDIR_SUFFIX} PARENT_SCOPE)
endfunction(PackagerApi_get_library_files_install_reldir PACKAGE OUT_library_files_install_reldir)


function(PackagerApi_get_header_files_install_reldir PACKAGE OUT_header_files_install_reldir)
    PackagerApi_check_exists(${PACKAGE})
    PackagerApi_get_reldir_suffix(${PACKAGE} INSTALL_RELDIR_SUFFIX)
    set(${OUT_header_files_install_reldir} ${CMAKE_INSTALL_INCLUDEDIR}/${INSTALL_RELDIR_SUFFIX} PARENT_SCOPE)
endfunction(PackagerApi_get_header_files_install_reldir PACKAGE OUT_header_files_install_reldir)


function(PackagerApi_get_header_files_install_include_reldir PACKAGE OUT_header_files_install_includedir)
    PackagerApi_check_exists(${PACKAGE})
    PackagerApi_get_reldir_suffix(${PACKAGE} INSTALL_RELDIR_SUFFIX)
    PackagerApi_get_header_files_install_reldir(${PACKAGE} HEADER_FILES_INSTALL_RELDIR)
    get_filename_component(HEADER_FILES_INSTALL_RELDIR_DIR ${HEADER_FILES_INSTALL_RELDIR} DIRECTORY)
    set(${OUT_header_files_install_includedir} ${HEADER_FILES_INSTALL_RELDIR_DIR} PARENT_SCOPE)
endfunction(PackagerApi_get_header_files_install_include_reldir PACKAGE OUT_header_files_install_includedir)


function(PackagerApi_get_cmake_files_install_reldir PACKAGE OUT_cmake_files_install_reldir)
    PackagerApi_check_exists(${PACKAGE})
    set(${OUT_cmake_files_install_reldir} "${CMAKE_INSTALL_LIBDIR}/cmake/${PACKAGE}/" PARENT_SCOPE)
endfunction(PackagerApi_get_cmake_files_install_reldir PACKAGE OUT_cmake_files_install_reldir)


function(PackagerApi_get_executable_files_install_reldir PACKAGE OUT_executable_files_install_reldir)
    PackagerApi_check_exists(${PACKAGE})
    set(${OUT_executable_files_install_reldir} ${CMAKE_INSTALL_BINDIR}/${PACKAGE} PARENT_SCOPE)
endfunction(PackagerApi_get_executable_files_install_reldir PACKAGE OUT_executable_files_install_reldir)


function(PackagerApi_get_staging_dir PACKAGE OUT_PackagerApi_staging_dir)
    PackagerApi_check_exists(${PACKAGE})
    set(PACKAGE_STAGING_DIR "${CMAKE_BINARY_DIR}/staging/${PACKAGE}")
    get_filename_component(PARENT_PACKAGE_STAGING_DIR ${PACKAGE_STAGING_DIR} DIRECTORY)
    if(NOT EXISTS ${PARENT_PACKAGE_STAGING_DIR})
        file(MAKE_DIRECTORY ${PARENT_PACKAGE_STAGING_DIR})
    endif(NOT EXISTS ${PARENT_PACKAGE_STAGING_DIR})
    set(${OUT_PackagerApi_staging_dir} ${PACKAGE_STAGING_DIR} PARENT_SCOPE)
endfunction(PackagerApi_get_staging_dir PACKAGE OUT_PackagerApi_staging_dir)


function(PackagerApi_get_header_files_staging_dir PACKAGE OUT_header_files_staging_dir)
    PackagerApi_get_staging_dir(${PACKAGE} PACKAGE_STAGING_PREFIX)
    PackagerApi_get_header_files_install_reldir(${PACKAGE} HEADER_FILES_INSTALL_RELDIR)
    set(${OUT_header_files_staging_dir} "${PACKAGE_STAGING_PREFIX}/${HEADER_FILES_INSTALL_RELDIR}" PARENT_SCOPE)
endfunction(PackagerApi_get_header_files_staging_dir PACKAGE OUT_header_files_staging_dir)


function(PackagerApi_get_header_files_staging_include_dir PACKAGE OUT_header_files_staging_dir)
    PackagerApi_get_header_files_staging_dir(${PACKAGE} HEADER_FILES_STAGING_DIR)
    get_filename_component(HEADER_FILES_STAGING_INCLUDEDIR ${HEADER_FILES_STAGING_DIR} DIRECTORY)
    set(${OUT_header_files_staging_dir} "${HEADER_FILES_STAGING_INCLUDEDIR}" PARENT_SCOPE)
endfunction(PackagerApi_get_header_files_staging_include_dir PACKAGE OUT_header_files_staging_dir)


function(PackagerApi_get_cmake_files_staging_dir PACKAGE OUT_PackagerApi_cmake_files_staging_dir)
    PackagerApi_get_staging_dir(${PACKAGE} PACKAGE_STAGING_PREFIX)
    PackagerApi_get_cmake_files_install_reldir(${PACKAGE} CMAKE_FILES_INSTALL_RELDIR)
    set(${OUT_PackagerApi_cmake_files_staging_dir} "${PACKAGE_STAGING_PREFIX}/${CMAKE_FILES_INSTALL_RELDIR}" PARENT_SCOPE)
endfunction(PackagerApi_get_cmake_files_staging_dir PACKAGE OUT_PackagerApi_cmake_files_staging_dir)


function(PackagerApi_get_runtime_config_staging_dir PACKAGE OUT_PackagerApi_runtime_config_staging_dir)
    PackagerApi_get_staging_dir(${PACKAGE} PACKAGE_STAGING_PREFIX)
    PackagerApi_get_executable_files_install_reldir(${PACKAGE} EXECUTABLE_FILES_INSTALL_RELDIR)
    set(${OUT_PackagerApi_runtime_config_staging_dir} "${PACKAGE_STAGING_PREFIX}/${EXECUTABLE_FILES_INSTALL_RELDIR}" PARENT_SCOPE)
endfunction(PackagerApi_get_runtime_config_staging_dir PACKAGE OUT_PackagerApi_runtime_config_staging_dir)



function(PackagerApi_get_library_component_name PACKAGE OUT_library_component_name)
    PackagerApi_check_exists(${PACKAGE})
    set(${OUT_library_component_name} "${PACKAGE}Lib" PARENT_SCOPE)
endfunction(PackagerApi_get_library_component_name PACKAGE OUT_library_component_name)


function(PackagerApi_get_header_component_name PACKAGE OUT_header_component_name)
    PackagerApi_check_exists(${PACKAGE})
    set(${OUT_header_component_name} "${PACKAGE}Dev" PARENT_SCOPE)
endfunction(PackagerApi_get_header_component_name PACKAGE OUT_header_component_name)


function(PackagerApi_get_cmake_component_name PACKAGE OUT_cmake_component_name)
    PackagerApi_check_exists(${PACKAGE})
    set(${OUT_cmake_component_name} "${PACKAGE}Cmake" PARENT_SCOPE)
endfunction(PackagerApi_get_cmake_component_name PACKAGE OUT_cmake_component_name)


function(PackagerApi_get_executable_component_name PACKAGE OUT_executable_component_name)
    PackagerApi_check_exists(${PACKAGE})
    set(${OUT_executable_component_name} "${PACKAGE}Bin" PARENT_SCOPE)
endfunction(PackagerApi_get_executable_component_name PACKAGE OUT_executable_component_name)


function(PackagerApi_get_ldconfig_file_path PACKAGE OUT_PackagerApi_ldconfig_filepath)
    PackagerApi_check_exists(${PACKAGE})
    PackagerApi_get_runtime_config_staging_dir(${PACKAGE} PACKAGE_RUNTIME_STAGING_DIR)
    set(${OUT_PackagerApi_ldconfig_filepath} "${PACKAGE_RUNTIME_STAGING_DIR}/${PACKAGE}.conf" PARENT_SCOPE)
endfunction(PackagerApi_get_ldconfig_file_path PACKAGE OUT_PackagerApi_ldconfig_filepath)


function(PackagerApi_get_ldconfig_install_absdir PACKAGE OUT_ldconfig_install_absdir)
    PackagerApi_check_exists(${PACKAGE})
    if(APPLE OR (NOT UNIX)) # mac OS doesn't use ldconfig
        message(FATAL_ERROR "Invocation of ${CMAKE_CURRENT_FUNCTION} is meaningless on the current platform. ldconfig is not used.")
    endif()
    set(LDCONFIG_INSTALL_DIR "/etc/ld.so.conf.d/${PACKAGE}/")
    set(${OUT_ldconfig_install_absdir} ${LDCONFIG_INSTALL_DIR} PARENT_SCOPE)
endfunction(PackagerApi_get_ldconfig_install_absdir PACKAGE OUT_ldconfig_install_absdir)


function(PackagerApi_get_postinst_component_name PACKAGE OUT_postinst_component_name)
    PackagerApi_check_exists(${PACKAGE})
    PackagerApi_get_library_component_name(${PACKAGE} PKG_LIBRARY_COMPONENT_NAME)
    set(${OUT_postinst_component_name} ${PKG_LIBRARY_COMPONENT_NAME} PARENT_SCOPE)
endfunction(PackagerApi_get_postinst_component_name PACKAGE OUT_postinst_component_name)


function(PackagerApi_get_version PACKAGE OUT_PackagerApi_version)
    PackagerApi_check_exists(${PACKAGE})
    PackagerApi_get_version_file_path(${PACKAGE} PACKAGE_VERSION_FILE)
    if(NOT (EXISTS ${PACKAGE_VERSION_FILE}))
        message(FATAL_ERROR "Package version file: ${PACKAGE_VERSION_FILE} doesn't exist.")
    endif(NOT (EXISTS ${PACKAGE_VERSION_FILE}))
    include(${PACKAGE_VERSION_FILE})
    set(${OUT_PackagerApi_version} ${PACKAGE_VERSION} PARENT_SCOPE)
endfunction(PackagerApi_get_version PACKAGE OUT_PackagerApi_version)


function(PackagerApi_get_component_list PACKAGE OUT_components_list)
    PackagerApi_check_exists(${PACKAGE})
    
    # Use internal API to get component names 
    PackagerApi_get_header_component_name(${PACKAGE} HEADER_COMPONENT)
    PackagerApi_get_library_component_name(${PACKAGE} LIBRARY_COMPONENT)
    PackagerApi_get_cmake_component_name(${PACKAGE} CMAKE_COMPONENT)
    PackagerApi_get_executable_component_name(${PACKAGE} EXECUTABLE_COMPONENT)


    set(PACKAGE_COMPONENT_LIST) # empty list
    list(APPEND PACKAGE_COMPONENT_LIST ${HEADER_COMPONENT})
    list(APPEND PACKAGE_COMPONENT_LIST ${LIBRARY_COMPONENT})
    list(APPEND PACKAGE_COMPONENT_LIST ${CMAKE_COMPONENT})
    list(APPEND PACKAGE_COMPONENT_LIST ${EXECUTABLE_COMPONENT})
    set(${OUT_components_list} ${PACKAGE_COMPONENT_LIST} PARENT_SCOPE)
endfunction(PackagerApi_get_component_list PACKAGE OUT_components_list)


function(PackagerApi_add_component PACKAGE COMPONENT_NAME)
    PackagerApi_check_exists(${PACKAGE})
    string(TOUPPER ${COMPONENT_NAME} COMPONENT_NAME_UPPER)
    set(CPACK_COMPONENT_${COMPONENT_NAME_UPPER}_GROUP ${PACKAGE} CACHE INTERNAL "")
endfunction(PackagerApi_add_component PACKAGE COMPONENT_NAME)


function(PackagerApi_add_component_dependency COMPONENT_NAME COMPONENT_DEPENDENCY_NAME)
    string(TOUPPER ${COMPONENT_NAME} COMPONENT_NAME_UPPER)
    set(CPACK_COMPONENT_${COMPONENT_NAME_UPPER}_DEPENDS ${COMPONENT_DEPENDENCY_NAME} CACHE INTERNAL "")
endfunction(PackagerApi_add_component_dependency COMPONENT_NAME COMPONENT_DEPENDENCY_NAME)



function(PackagerApi_target_include_directories)
    target_include_directories(${ARGN})
endfunction(PackagerApi_target_include_directories)


function(PackagerApi_target_sources)
    target_sources(${ARGN})
endfunction(PackagerApi_target_sources)


function(PackageApi_target_link_libraries)
    target_link_libraries(${ARGN})
endfunction(PackageApi_target_link_libraries)


################################################################################
# THIS MUST BE CALLED LAST IN THE TOP-LEVEL CMAKELISTS.TXT                     #
################################################################################
# AS IT FINALIZES THE SETTIGNS FOR ALL THE VARIABLES                           #
# CONFIGURED USING THIS MODULE'S API FUNCTIONS AND GENERATES THE CPACK CONFIG. #
################################################################################


################################################################################
# @name: PackagerApi_finalize_config
#
# @brief
# Finalize the PackagerApi configuration for all targets and packages
#
# @note
# ** MUST BE CALLED LAST IN THE PARENT SCOPE **
#
# @usage 
# PackagerApi_finalize_config()
#
################################################################################
macro(PackagerApi_finalize_config)
    Packager_finalize_config()
endmacro(PackagerApi_finalize_config)


################################################################################
# @name: PackagerApi_add_package
#
# @brief
# Add a package: PACKAGE for use with PackagerApi functions
#
#
# @usage 
# PackagerApi_add_package(
#   PACKAGE my_package
#   VERSION 0.2.3
# )
#
# @param       PACKAGE
# @type        VALUE
# @required    TRUE
# @description The name of the package
#
#
# @param       VERSION
# @type        VALUE
# @required    TRUE
# @description The package version. Must be a valid SEMVER string
#
#
################################################################################
function(PackagerApi_add_package)
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
    # Note: Default values are not supported for members of OPTION_ARGS 
    # (since not providing an option is FALSE)
    #
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

    # SINGLE_VALUE_ARGS LOGIC-CONSISTENCY CHECK
    message(VERBOSE "Performing self-consistency logic check for SINGLE_VALUE_ARGS ... ")
    foreach(ARG ${SINGLE_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(DEFINED ${ARG}-DEFAULT)
                if(NOT (${${ARG}-DEFAULT} IN_LIST ${ARG}-CHOICES))
                    message(FATAL_ERROR "The argument choices and defaults configured for ${CMAKE_CURRENT_FUNCTION} are inconsistent. This is a development error. Please contact the maintainer.")
                endif(NOT (${${ARG}-DEFAULT} IN_LIST ${ARG}-CHOICES))
            endif(DEFINED ${ARG}-DEFAULT)
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${SINGLE_VALUE_ARGS})
    message(VERBOSE "Ok.")
    
    # MULTI_VALUE_ARGS LOGIC-CONSISTENCY CHECK
    message(VERBOSE "Performing self-consistency logic check for MULTI_VALUE_ARGS ... ")
    foreach(ARG ${MULTI_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(DEFINED ${ARG}-DEFAULT)
                foreach(LIST_ELEMENT ${${ARG}-DEFAULT})
                    if(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                        message(FATAL_ERROR "The argument choices and defaults configured for ${CMAKE_CURRENT_FUNCTION} are inconsistent. This is a development error. Please contact the maintainer.")
                    endif(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                endforeach(LIST_ELEMENT ${${ARG}-DEFAULT})
            endif(DEFINED ${ARG}-DEFAULT)
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${MULTI_VALUE_ARGS})
    message(VERBOSE "Ok.")

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

    # Sanitize keywords for all required KWARGS
    list(LENGTH _KEYWORDS_MISSING_VALUES NUM_MISSING_KWARGS)
    if(NUM_MISSING_KWARGS GREATER 0)
        foreach(arg ${_KEYWORDS_MISSING_VALUES})
            message(WARNING "Keyword argument \"${arg}\" is missing a value.")
        endforeach(arg ${_KEYWORDS_MISSING_VALUES})
        message(FATAL_ERROR "One or more required keyword arguments are missing their values.")
    endif(NUM_MISSING_KWARGS GREATER 0)

    # Process required single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS-REQUIRED})
        if(NOT DEFINED _${ARG})
            message(FATAL_ERROR "Required keyword argument: ${ARG} not provided.")
            return()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${SINGLE_VALUE_ARGS-REQUIRED})

    # Process optional single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS-OPTIONAL})
        if(NOT DEFINED _${ARG})
            if(DEFINED ${ARG}-DEFAULT)
                set(_${ARG} ${${ARG}-DEFAULT})
                message(VERBOSE "Value for keyword argument: ${ARG} not given. Used default value of ${_${ARG}}")
            endif(DEFINED ${ARG}-DEFAULT)
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${SINGLE_VALUE_ARGS-OPTIONAL})

    # Validate choices for single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(NOT (${_${ARG}} IN_LIST ${ARG}-CHOICES))
                message(FATAL_ERROR "Keyword argument \"${ARG}\" given invalid value: \"${_${ARG}}\". \n Choices: ${${ARG}-CHOICES}.")
            endif(NOT (${_${ARG}} IN_LIST ${ARG}-CHOICES))
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${SINGLE_VALUE_ARGS})
    
    # Process required multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS-REQUIRED})
        if(NOT DEFINED _${ARG})
            message(FATAL_ERROR "Required keyword argument: ${ARG} not provided.")
            return()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${MULTI_VALUE_ARGS-REQUIRED})
    
    # Process optional multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS-OPTIONAL})
        if(NOT DEFINED _${ARG})
            if(DEFINED ${ARG}-DEFAULT)
                set(_${ARG} ${${ARG}-DEFAULT})
                message(VERBOSE "Value for keyword argument: ${ARG} not given. Used default value of ${_${ARG}}")
            endif(DEFINED ${ARG}-DEFAULT)
        else()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${MULTI_VALUE_ARGS-OPTIONAL})

    # Validate choices for multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            foreach(LIST_ELEMENT ${_${ARG}})
                if(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                    message(FATAL_ERROR "Keyword argument \"${ARG}\" given an invalid value: \"${LIST_ELEMENT}\". \n Choices: ${${ARG}-CHOICES}.")
                endif(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
            endforeach(LIST_ELEMENT ${_${ARG}})
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${MULTI_VALUE_ARGS})

    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    list(LENGTH _UNPARSED_ARGUMENTS NUM_UNPARSED_ARGS)
    if(NUM_UNPARSED_ARGS GREATER 0)
        message(FATAL_ERROR "Unknown arguments: \"${_UNPARSED_ARGUMENTS}\" given to ${CMAKE_CURRENT_FUNCTION}")
    endif(NUM_UNPARSED_ARGS GREATER 0)

    PackagerApi_get_exists(${_PACKAGE} PACKAGE_EXISTS)
    message(DEBUG "After call to PackagerApi_get_exists for package : ${_PACKAGE}, PACKAGE_EXISTS=${PACKAGE_EXISTS}")
    if(PACKAGE_EXISTS)
        message(STATUS "PACKAGE: \"${_PACKAGE}\" already exists. Not adding to package list.")
    else()
        message(DEBUG "Adding package: ${_PACKAGE} to package list.")
        PackagerApi_add_to_list(${_PACKAGE})
    endif(PACKAGE_EXISTS)
    
    util_is_version_valid(${_VERSION} VALID_VERSION)
    if(NOT VALID_VERSION)
        message(FATAL_ERROR "[in ${CMAKE_CURRENT_FUNCTION}] : VERSION argument given invalid value ${_VERSION}.")
    else()
        message(VERBOSE "Package \"${_PACKAGE}\" version \"${_VERSION}\" is valid.")
    endif(NOT VALID_VERSION)
    
    PackagerApi_get_version_file_path(${_PACKAGE} PACKAGE_VERSION_FILE)
    write_basic_package_version_file(
        ${PACKAGE_VERSION_FILE} 
        VERSION ${_VERSION} 
        COMPATIBILITY AnyNewerVersion
    )

    PackagerApi_get_cmake_component_name(${_PACKAGE} PACKAGE_CMAKE_COMPONENT)
    PackagerApi_get_cmake_files_install_reldir(${_PACKAGE} PACKAGE_INSTALL_CMAKE_DIR)

    install(
        FILES ${PACKAGE_VERSION_FILE}
        PERMISSIONS
            OWNER_WRITE OWNER_READ
            GROUP_READ
            WORLD_READ
        DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
        COMPONENT ${PACKAGE_CMAKE_COMPONENT}
    )

    PackagerApi_get_targets_export_name(${_PACKAGE} PACKAGE_EXPORT_NAME)
    PackagerApi_get_config_file_path(${_PACKAGE} PACKAGE_CONFIG_FILE)
    
    file(WRITE ${PACKAGE_CONFIG_FILE}.in "@PACKAGE_INIT@\ninclude(CMakeFindDependencyMacro)\n")
    file(APPEND ${PACKAGE_CONFIG_FILE}.in "include(\"\${CMAKE_CURRENT_LIST_DIR}/@PACKAGE_EXPORT_NAME@.cmake\")\n")
    file(APPEND ${PACKAGE_CONFIG_FILE}.in "check_required_components(\"@_PACKAGE@\")\n")

    configure_package_config_file(
        ${PACKAGE_CONFIG_FILE}.in
        ${PACKAGE_CONFIG_FILE}
        INSTALL_DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
    )
    file(REMOVE ${PACKAGE_CONFIG_FILE}.in)
    PackagerApi_get_cmake_files_install_reldir(${_PACKAGE} PACKAGE_INSTALL_CMAKE_DIR)
    install(
        FILES ${PACKAGE_CONFIG_FILE}
        PERMISSIONS
            OWNER_WRITE OWNER_READ
            GROUP_READ
            WORLD_READ        
                WORLD_READ        
            WORLD_READ        
        DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
        COMPONENT ${PACKAGE_CMAKE_COMPONENT}
    )


    # Get component names
    PackagerApi_get_header_component_name(${_PACKAGE} PACKAGE_HEADER_COMPONENT)
    PackagerApi_get_library_component_name(${_PACKAGE} PACKAGE_LIBRARY_COMPONENT)
    PackagerApi_get_cmake_component_name(${_PACKAGE} PACKAGE_CMAKE_COMPONENT)
    PackagerApi_get_executable_component_name(${_PACKAGE} PACKAGE_EXECUTABLE_COMPONENT)

    # Add components to the package
    PackagerApi_add_component(${_PACKAGE} ${PACKAGE_LIBRARY_COMPONENT})
    PackagerApi_add_component(${_PACKAGE} ${PACKAGE_EXECUTABLE_COMPONENT})

    PackagerApi_add_component(${_PACKAGE} ${PACKAGE_HEADER_COMPONENT})
    PackagerApi_add_component_dependency(${PACKAGE_HEADER_COMPONENT} ${PACKAGE_LIBRARY_COMPONENT})

    PackagerApi_add_component(${_PACKAGE} ${PACKAGE_CMAKE_COMPONENT})
    PackagerApi_add_component_dependency(${PACKAGE_CMAKE_COMPONENT} ${PACKAGE_LIBRARY_COMPONENT})
    PackagerApi_add_component_dependency(${PACKAGE_CMAKE_COMPONENT} ${PACKAGE_EXECUTABLE_COMPONENT})

endfunction(PackagerApi_add_package)



################################################################################
# @name: PackagerApi_add_library
#
# @brief
# Add a library target: TARGET to package: PACKAGE
#
# @note
# Usage is conformant to add_library()
#
# @usage 
# PackagerApi_add_library(
#   PACKAGE my_package
#   TARGET my_target
#   TARGET_TYPE SHARED | STATIC | INTERFACE | OBJECT
#   ...
# )
#
# @param       PACKAGE
# @type        VALUE
# @required    TRUE
# @description The name of the package
#
# @param       TARGET
# @type        VALUE
# @required    TRUE
# @description The name of the library target
#
# @param       TARGET_TYPE
# @type        VALUE
# @required    TRUE
# @description The type of target. 
# @choices     SHARED | STATIC | INTERFACE | OBJECT
#
################################################################################
function(PackagerApi_add_library)
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
    )
    set(SINGLE_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
        TARGET_TYPE
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
    # Note: Default values are not supported for members of OPTION_ARGS 
    # (since not providing an option is FALSE)
    #
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

    # SINGLE_VALUE_ARGS LOGIC-CONSISTENCY CHECK
    message(VERBOSE "Performing self-consistency logic check for SINGLE_VALUE_ARGS ... ")
    foreach(ARG ${SINGLE_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(DEFINED ${ARG}-DEFAULT)
                if(NOT (${${ARG}-DEFAULT} IN_LIST ${ARG}-CHOICES))
                    message(FATAL_ERROR "The argument choices and defaults configured for ${CMAKE_CURRENT_FUNCTION} are inconsistent. This is a development error. Please contact the maintainer.")
                endif(NOT (${${ARG}-DEFAULT} IN_LIST ${ARG}-CHOICES))
            endif(DEFINED ${ARG}-DEFAULT)
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${SINGLE_VALUE_ARGS})
    message(VERBOSE "Ok.")
    
    # MULTI_VALUE_ARGS LOGIC-CONSISTENCY CHECK
    message(VERBOSE "Performing self-consistency logic check for MULTI_VALUE_ARGS ... ")
    foreach(ARG ${MULTI_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(DEFINED ${ARG}-DEFAULT)
                foreach(LIST_ELEMENT ${${ARG}-DEFAULT})
                    if(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                        message(FATAL_ERROR "The argument choices and defaults configured for ${CMAKE_CURRENT_FUNCTION} are inconsistent. This is a development error. Please contact the maintainer.")
                    endif(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                endforeach(LIST_ELEMENT ${${ARG}-DEFAULT})
            endif(DEFINED ${ARG}-DEFAULT)
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${MULTI_VALUE_ARGS})
    message(VERBOSE "Ok.")

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

    # Sanitize keywords for all required KWARGS
    list(LENGTH _KEYWORDS_MISSING_VALUES NUM_MISSING_KWARGS)
    if(NUM_MISSING_KWARGS GREATER 0)
        foreach(arg ${_KEYWORDS_MISSING_VALUES})
            message(WARNING "Keyword argument \"${arg}\" is missing a value.")
        endforeach(arg ${_KEYWORDS_MISSING_VALUES})
        message(FATAL_ERROR "One or more required keyword arguments are missing their values.")
    endif(NUM_MISSING_KWARGS GREATER 0)

    # Process required single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS-REQUIRED})
        if(NOT DEFINED _${ARG})
            message(FATAL_ERROR "Required keyword argument: ${ARG} not provided.")
            return()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${SINGLE_VALUE_ARGS-REQUIRED})

    # Process optional single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS-OPTIONAL})
        if(NOT DEFINED _${ARG})
            if(DEFINED ${ARG}-DEFAULT)
                set(_${ARG} ${${ARG}-DEFAULT})
                message(VERBOSE "Value for keyword argument: ${ARG} not given. Used default value of ${_${ARG}}")
            endif(DEFINED ${ARG}-DEFAULT)
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${SINGLE_VALUE_ARGS-OPTIONAL})

    # Validate choices for single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(NOT (${_${ARG}} IN_LIST ${ARG}-CHOICES))
                message(FATAL_ERROR "Keyword argument \"${ARG}\" given invalid value: \"${_${ARG}}\". \n Choices: ${${ARG}-CHOICES}.")
            endif(NOT (${_${ARG}} IN_LIST ${ARG}-CHOICES))
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${SINGLE_VALUE_ARGS})
    
    # Process required multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS-REQUIRED})
        if(NOT DEFINED _${ARG})
            message(FATAL_ERROR "Required keyword argument: ${ARG} not provided.")
            return()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${MULTI_VALUE_ARGS-REQUIRED})
    
    # Process optional multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS-OPTIONAL})
        if(NOT DEFINED _${ARG})
            if(DEFINED ${ARG}-DEFAULT)
                set(_${ARG} ${${ARG}-DEFAULT})
                message(VERBOSE "Value for keyword argument: ${ARG} not given. Used default value of ${_${ARG}}")
            endif(DEFINED ${ARG}-DEFAULT)
        else()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${MULTI_VALUE_ARGS-OPTIONAL})

    # Validate choices for multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            foreach(LIST_ELEMENT ${_${ARG}})
                if(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                    message(FATAL_ERROR "Keyword argument \"${ARG}\" given an invalid value: \"${LIST_ELEMENT}\". \n Choices: ${${ARG}-CHOICES}.")
                endif(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
            endforeach(LIST_ELEMENT ${_${ARG}})
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${MULTI_VALUE_ARGS})

    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    PackagerApi_check_exists(${_PACKAGE})

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

    # Inherit link libraries and include directories from target objects.
    # This because we do not install target objects and so without doing this
    # transient dependencies will not be propagated into the install package.
    foreach(arg ${_UNPARSED_ARGUMENTS})

        # The behaviour of string(REGEX <mode>) is INCREDIBLY undocumented.
        # Sometimes it is even plain wrong.
        # string(REGEX MATCH) stores captured subexpressions in CMAKE_MATCH_1 ... CMAKE_MATCH_9
        # (where CMAKE_MATCH_0 == the complete matched expression - not subexpression).
        #
        # However, Despite the claims of the documentation, CMAKE_MATCH_x (where x > 1)
        # is not set for string(REGEX REPLACE) ... which is sad because there is a large
        # usecase subset where one would want to parse a subexpression from within a string.
        set(TARGET_OBJECTS_REGEX "\\$<TARGET_OBJECTS:(.+)>")
        string(REGEX MATCH ${TARGET_OBJECTS_REGEX} MATCHED ${arg})
        if(MATCHED)
            string(REGEX REPLACE ${TARGET_OBJECTS_REGEX} ${CMAKE_MATCH_1} OBJECT_TARGET_NAME ${arg})
            message(DEBUG "Parsed target:${OBJECT_TARGET_NAME} from ${arg} as TARGET_OBJECT library dependency for target: ${_TARGET} in ${CMAKE_CURRENT_FUNCTION}")
            if(TARGET ${OBJECT_TARGET_NAME})
                get_target_property(OBJECT_TARGET_TYPE ${OBJECT_TARGET_NAME} TYPE)
                if(OBJECT_TARGET_TYPE)
                    if(OBJECT_TARGET_TYPE STREQUAL OBJECT_LIBRARY)

                        # PASS interface link libraries and interface include directories on from $<TARGET_OBJECTS: ... >

                        get_target_property(INHERITED_INTERFACE_INCLUDE_DIRECTORIES ${OBJECT_TARGET_NAME} INTERFACE_INCLUDE_DIRECTORIES)
                        message(VERBOSE "[ in ${CMAKE_CURRENT_FUNCTION} ], TARGET: ${_TARGET} INHERITED_INTERFACE_INCLUDE_DIRECTORIES:${INHERITED_INTERFACE_INCLUDE_DIRECTORIES} from target ${OBJECT_TARGET_NAME}")
                        if(NOT (INHERITED_INTERFACE_INCLUDE_DIRECTORIES STREQUAL "INHERITED_INTERFACE_INCLUDE_DIRECTORIES-NOTFOUND"))
                            PackagerApi_target_include_directories(${_TARGET} PUBLIC ${INHERITED_INTERFACE_INCLUDE_DIRECTORIES})
                        else()
                            message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], target: ${OBJECT_TARGET_NAME} does not have property INTERFACE_INCLUDE_DIRECTORIES")
                        endif(NOT (INHERITED_INTERFACE_INCLUDE_DIRECTORIES STREQUAL "INHERITED_INTERFACE_INCLUDE_DIRECTORIES-NOTFOUND"))

                        get_target_property(INHERITED_INTERFACE_LINK_LIBRARIES ${OBJECT_TARGET_NAME} INTERFACE_LINK_LIBRARIES)
                        message(VERBOSE "[ in ${CMAKE_CURRENT_FUNCTION} ], TARGET: ${_TARGET} INHERITED_INTERFACE_LINK_LIBRARIES:${INHERITED_INTERFACE_LINK_LIBRARIES} from target ${OBJECT_TARGET_NAME}")                        
                        if(NOT (INHERITED_INTERFACE_LINK_LIBRARIES STREQUAL "INHERITED_INTERFACE_LINK_LIBRARIES-NOTFOUND"))
                            PackagerApi_target_link_libraries(${_TARGET} PUBLIC ${INHERITED_INTERFACE_LINK_LIBRARIES})
                        else()
                            message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], target: ${OBJECT_TARGET_NAME} does not have property INTERFACE_LINK_LIBRARIES")
                        endif(NOT (INHERITED_INTERFACE_LINK_LIBRARIES STREQUAL "INHERITED_INTERFACE_LINK_LIBRARIES-NOTFOUND"))

                    else()
                        message(WARNING "Target:${OBJECT_TARGET_NAME} exists but does not have type:OBJECT_LIBRARY. There is a likely bug around in ${CMAKE_CURRENT_LIST_LINE} in ${CMAKE_CURRENT_LIST_FILE}.")
                    endif(OBJECT_TARGET_TYPE STREQUAL OBJECT_LIBRARY)
                endif(OBJECT_TARGET_TYPE)
            else()
                message(WARNING "Target:${OBJECT_TARGET_NAME} does not exist. There is a likely bug around in ${CMAKE_CURRENT_LIST_LINE} in ${CMAKE_CURRENT_LIST_FILE}.")
            endif(TARGET ${OBJECT_TARGET_NAME})
            
        endif(MATCHED)
    endforeach(arg ${_UNPARSED_ARGUMENTS})

    set_target_properties(${_TARGET} 
        PROPERTIES 
            POSITION_INDEPENDENT_CODE ON
    )

    PackagerApi_get_targets_export_name(${_PACKAGE} PACKAGE_TARGET_EXPORT_NAME)

    PackagerApi_get_version(${_PACKAGE} PACKAGE_VERSION)
    set_target_properties(${_TARGET} PROPERTIES VERSION "${PACKAGE_VERSION}")
    if(_TARGET_TYPE STREQUAL SHARED)
        set_target_properties(${_TARGET} PROPERTIES SOVERSION "${PACKAGE_VERSION}")    
    endif(_TARGET_TYPE STREQUAL SHARED)

    PackagerApi_get_cmake_component_name(${_PACKAGE} PACKAGE_CMAKE_COMPONENT)
    PackagerApi_get_library_component_name(${_PACKAGE} PACKAGE_LIB_COMPONENT)

    PackagerApi_get_library_files_install_reldir(${_PACKAGE} PACKAGE_LIB_INSTALL_DIR)
    PackagerApi_get_cmake_files_install_reldir(${_PACKAGE} PACKAGE_INSTALL_CMAKE_DIR)
    PackagerApi_get_header_files_install_reldir(${_PACKAGE} PACKAGE_HEADER_INSTALL_DIR)
    
    PackagerApi_get_targets_export_name(${_PACKAGE} PACKAGE_EXPORT_NAME)
    PackagerApi_get_targets_namespace(${_PACKAGE} PACKAGE_NAMESPACE)

    # Don't install object or interface libraries
    if((_TARGET_TYPE STREQUAL OBJECT) OR (_TARGET_TYPE STREQUAL INTERFACE))
        message(VERBOSE "Target: \"${_TARGET}\" is type: \"${_TARGET_TYPE}\" and so will not be installed.")
    else()

        # After the target is installed, if another project or target imports it
        # the header directories will have to be searched for in the 
        # system install tree and not the current build tree
        PackagerApi_target_include_directories(${_TARGET} 
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
    
endfunction(PackagerApi_add_library)


################################################################################
# @name: PackagerApi_add_cmake_package
#
# @brief
# See documentation for PackagerApi_cmake_add_package
#
# @usage 
# See documentation for PackagerApi_cmake_add_package
#
################################################################################
function(PackagerApi_add_cmake_package)
    message(WARNING "${CMAKE_CURRENT_FUNCTION} is deprecated. Prefer usage of PackagerApi_cmake_add_package instead.")
    PackagerApi_cmake_add_package(${ARGN})
endfunction(PackagerApi_add_cmake_package)


################################################################################
# @name: PackagerApi_cmake_add_package
#
# @brief
# Create a PackagerApi package specifically meant for use with find_package. 
# The name of the package to later use with find_package() will be based on the config file name.
# e.g. a value of CONFIG_FILE: MyPackageConfig.cmake corresponds to a package name of "MyPackage"
#
# @note
#  - Value for CONFIG_FILE must be compliant with find_package. 
#    Eg <LOWERCASE_PACKAGE_NAME>-config.cmake or <PACKAGE_NAME>Config.cmake.
#  
#  - Value for VERSION must be a value SEMVER string.
#
# @usage 
# PackagerApi_cmake_add_package(
#   CONFIG_FILE  /path/to/myMyCmakePackageConfig.cmake
#   VERSION 9.1.2
# )
#
# @param       CONFIG_FILE
# @type        VALUE
# @required    TRUE
# @description The path to the config file.
# @note        The name of the config file MUST be compliant with find_package. Eg <LOWERCASE_PACKAGE_NAME>-config.cmake or <PACKAGE_NAME>Config.cmake
#
#
# @param       VERSION
# @type        VALUE
# @required    TRUE
# @description The package version
# @note        Value must be compliant with SEMVER string
#
################################################################################
function(PackagerApi_cmake_add_package)
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
        CONFIG_FILE
        VERSION
    )
    set(SINGLE_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
        PKG_TYPE
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
    set(PKG_TYPE-CHOICES
        DEB
        TGZ
        ZIP
        RPM
    )

    ##########################
    # CONFIGURE DEFAULTS FOR #
    # SINGLE VALUE ARGUMENTS #
    ##########################
    # Note: Default values are not supported for members of OPTION_ARGS 
    # (since not providing an option is FALSE)
    #
    # The naming is very specific. 
    # If we wanted to provide a default value for a keyword BAR,
    # we would set BAR-DEFAULT.
    # set(BAR-DEFAULT MY_DEFAULT_BAR_VALUE)
    set(PKG_TYPE-DEFAULT DEB)
    

    ############################################################################
    # Perform the argument parsing                                             #
    ############################################################################
    set(SINGLE_VALUE_ARGS)
    list(APPEND SINGLE_VALUE_ARGS ${SINGLE_VALUE_ARGS-REQUIRED} ${SINGLE_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES SINGLE_VALUE_ARGS)

    set(MULTI_VALUE_ARGS)
    list(APPEND MULTI_VALUE_ARGS ${MULTI_VALUE_ARGS-REQUIRED} ${MULTI_VALUE_ARGS-OPTIONAL})
    list(REMOVE_DUPLICATES MULTI_VALUE_ARGS)

    # SINGLE_VALUE_ARGS LOGIC-CONSISTENCY CHECK
    message(VERBOSE "Performing self-consistency logic check for SINGLE_VALUE_ARGS ... ")
    foreach(ARG ${SINGLE_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(DEFINED ${ARG}-DEFAULT)
                if(NOT (${${ARG}-DEFAULT} IN_LIST ${ARG}-CHOICES))
                    message(FATAL_ERROR "The argument choices and defaults configured for ${CMAKE_CURRENT_FUNCTION} are inconsistent. This is a development error. Please contact the maintainer.")
                endif(NOT (${${ARG}-DEFAULT} IN_LIST ${ARG}-CHOICES))
            endif(DEFINED ${ARG}-DEFAULT)
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${SINGLE_VALUE_ARGS})
    message(VERBOSE "Ok.")
    
    # MULTI_VALUE_ARGS LOGIC-CONSISTENCY CHECK
    message(VERBOSE "Performing self-consistency logic check for MULTI_VALUE_ARGS ... ")
    foreach(ARG ${MULTI_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(DEFINED ${ARG}-DEFAULT)
                foreach(LIST_ELEMENT ${${ARG}-DEFAULT})
                    if(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                        message(FATAL_ERROR "The argument choices and defaults configured for ${CMAKE_CURRENT_FUNCTION} are inconsistent. This is a development error. Please contact the maintainer.")
                    endif(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                endforeach(LIST_ELEMENT ${${ARG}-DEFAULT})
            endif(DEFINED ${ARG}-DEFAULT)
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${MULTI_VALUE_ARGS})
    message(VERBOSE "Ok.")

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

    # Sanitize keywords for all required KWARGS
    list(LENGTH _KEYWORDS_MISSING_VALUES NUM_MISSING_KWARGS)
    if(NUM_MISSING_KWARGS GREATER 0)
        foreach(arg ${_KEYWORDS_MISSING_VALUES})
            message(WARNING "Keyword argument \"${arg}\" is missing a value.")
        endforeach(arg ${_KEYWORDS_MISSING_VALUES})
        message(FATAL_ERROR "One or more required keyword arguments are missing their values.")
    endif(NUM_MISSING_KWARGS GREATER 0)

    # Process required single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS-REQUIRED})
        if(NOT DEFINED _${ARG})
            message(FATAL_ERROR "Required keyword argument: ${ARG} not provided.")
            return()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${SINGLE_VALUE_ARGS-REQUIRED})

    # Process optional single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS-OPTIONAL})
        if(NOT DEFINED _${ARG})
            if(DEFINED ${ARG}-DEFAULT)
                set(_${ARG} ${${ARG}-DEFAULT})
                message(VERBOSE "Value for keyword argument: ${ARG} not given. Used default value of ${_${ARG}}")
            endif(DEFINED ${ARG}-DEFAULT)
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${SINGLE_VALUE_ARGS-OPTIONAL})

    # Validate choices for single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(NOT (${_${ARG}} IN_LIST ${ARG}-CHOICES))
                message(FATAL_ERROR "Keyword argument \"${ARG}\" given invalid value: \"${_${ARG}}\". \n Choices: ${${ARG}-CHOICES}.")
            endif(NOT (${_${ARG}} IN_LIST ${ARG}-CHOICES))
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${SINGLE_VALUE_ARGS})
    
    # Process required multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS-REQUIRED})
        if(NOT DEFINED _${ARG})
            message(FATAL_ERROR "Required keyword argument: ${ARG} not provided.")
            return()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${MULTI_VALUE_ARGS-REQUIRED})
    
    # Process optional multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS-OPTIONAL})
        if(NOT DEFINED _${ARG})
            if(DEFINED ${ARG}-DEFAULT)
                set(_${ARG} ${${ARG}-DEFAULT})
                message(VERBOSE "Value for keyword argument: ${ARG} not given. Used default value of ${_${ARG}}")
            endif(DEFINED ${ARG}-DEFAULT)
        else()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${MULTI_VALUE_ARGS-OPTIONAL})

    # Validate choices for multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            foreach(LIST_ELEMENT ${_${ARG}})
                if(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                    message(FATAL_ERROR "Keyword argument \"${ARG}\" given an invalid value: \"${LIST_ELEMENT}\". \n Choices: ${${ARG}-CHOICES}.")
                endif(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
            endforeach(LIST_ELEMENT ${_${ARG}})
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${MULTI_VALUE_ARGS})

    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    if(NOT EXISTS ${_CONFIG_FILE})
        message(FATAL_ERROR "[ in ${CMAKE_CURRENT_FUNCTION}, value for CONFIG_FILE : ${_CONFIG_FILE} invalid. File does not exist")
    endif(NOT EXISTS ${_CONFIG_FILE})

    get_filename_component(CONFIG_FILE_NAME ${_CONFIG_FILE} NAME)
    string(REGEX MATCH "^.*Config\.cmake$" VALID_CONFIG_FILE_NAME ${CONFIG_FILE_NAME})
    message(DEBUG "VALID_CONFIG_FILE_NAME:${VALID_CONFIG_FILE_NAME}")

    if(NOT VALID_CONFIG_FILE_NAME)
        message(FATAL_ERROR "Value for CONFIG_FILE : \"${_CONFIG_FILE}\" is not a valid cmake config file name")
    endif(NOT VALID_CONFIG_FILE_NAME)
    string(REGEX REPLACE "Config\.cmake$" "" MODULE_NAME ${VALID_CONFIG_FILE_NAME})

    util_is_version_valid(${_VERSION} MODULE_VERSION_IS_VALID)
    if(NOT MODULE_VERSION_IS_VALID)
        message(FATAL_ERROR "[in ${CMAKE_CURRENT_FUNCTION}] : cmake package module: \"${MODULE_NAME}\" argument given invalid VERSION value ${_VERSION}.")
    else()
        message(VERBOSE "Package version for cmake package module : \"${MODULE_NAME}\" version \"${_VERSION}\" is valid.")
    endif(NOT MODULE_VERSION_IS_VALID)

    set(CMAKE_PACKAGE ${MODULE_NAME})
    PackagerApi_add_package(
        PACKAGE ${CMAKE_PACKAGE}
        VERSION ${_VERSION}
    )

    set(MODULE_CONFIG_FILE ${CONFIG_FILE})

    PackagerApi_get_version_file_path(${CMAKE_PACKAGE} MODULE_VERSION_FILE)
    PackagerApi_get_cmake_files_install_reldir(${CMAKE_PACKAGE} PACKAGE_CMAKE_FILES_INSTALL_RELDIR)
    PackagerApi_get_cmake_component_name(${CMAKE_PACKAGE} PACKAGE_CMAKE_COMPONENT_NAME)

    write_basic_package_version_file(
        ${MODULE_VERSION_FILE}
        VERSION ${_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    install(
        FILES 
            ${MODULE_CONFIG_FILE}
            ${MODULE_VERSION_FILE}
        COMPONENT ${PACKAGE_CMAKE_COMPONENT_NAME}
        DESTINATION "${PACKAGE_CMAKE_FILES_INSTALL_RELDIR}"
    )

    if(_PKG_TYPE STREQUAL DEB)
        PackagerDeb_init()
        PackagerDeb_configure_package(${CMAKE_PACKAGE})
    elseif(_PKG_TYPE STREQUAL RPM)
        PackagerRpm_init()
        PackagerRpm_configure_package(${CMAKE_PACKAGE})
    elseif(_PKG_TYPE STREQUAL TGZ)
        PackagerTgz_init()
        PackagerTgz_configure_package(${CMAKE_PACKAGE})
    elseif(_PKG_TYPE STREQUAL ZIP)
        PackagerZip_init()
        PackagerZip_configure_package(${CMAKE_PACKAGE})
    else()
        message(FATAL_ERROR "Unknown value : \"${_PKG_TYPE} for PKG_TYPE\"")
    endif()
    

endfunction(PackagerApi_cmake_add_package)


################################################################################
# @name: PackagerApi_add_executable
#
# @brief
# Add an executable: TARGET as part of package: PACKAGE
#
# @note
#  # ADD NOTES HERE # 
#
# @usage 
# PackagerApi_add_executable(
#   PACKAGE my_package
#   TARGET my_target
#   [ { source1.cpp ./rel/path/to/CMAKE_CURRENT_SOURCE_DIR/source2.cpp /abs/path/source3.cpp}
#   [ EXCLUDE_FROM_ALL ]
# )
#
# @param       PACKAGE
# @type        VALUE
# @required    true
# @description The name of the package that target: TARGET will be added to
#
#
# @param       TARGET
# @type        VALUE
# @required    true
# @description The name of the executable target
#
#
################################################################################
function(PackagerApi_add_executable)
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
    # Note: Default values are not supported for members of OPTION_ARGS 
    # (since not providing an option is FALSE)
    #
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

    # SINGLE_VALUE_ARGS LOGIC-CONSISTENCY CHECK
    message(VERBOSE "Performing self-consistency logic check for SINGLE_VALUE_ARGS ... ")
    foreach(ARG ${SINGLE_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(DEFINED ${ARG}-DEFAULT)
                if(NOT (${${ARG}-DEFAULT} IN_LIST ${ARG}-CHOICES))
                    message(FATAL_ERROR "The argument choices and defaults configured for ${CMAKE_CURRENT_FUNCTION} are inconsistent. This is a development error. Please contact the maintainer.")
                endif(NOT (${${ARG}-DEFAULT} IN_LIST ${ARG}-CHOICES))
            endif(DEFINED ${ARG}-DEFAULT)
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${SINGLE_VALUE_ARGS})
    message(VERBOSE "Ok.")
    
    # MULTI_VALUE_ARGS LOGIC-CONSISTENCY CHECK
    message(VERBOSE "Performing self-consistency logic check for MULTI_VALUE_ARGS ... ")
    foreach(ARG ${MULTI_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(DEFINED ${ARG}-DEFAULT)
                foreach(LIST_ELEMENT ${${ARG}-DEFAULT})
                    if(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                        message(FATAL_ERROR "The argument choices and defaults configured for ${CMAKE_CURRENT_FUNCTION} are inconsistent. This is a development error. Please contact the maintainer.")
                    endif(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                endforeach(LIST_ELEMENT ${${ARG}-DEFAULT})
            endif(DEFINED ${ARG}-DEFAULT)
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${MULTI_VALUE_ARGS})
    message(VERBOSE "Ok.")

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

    # Sanitize keywords for all required KWARGS
    list(LENGTH _KEYWORDS_MISSING_VALUES NUM_MISSING_KWARGS)
    if(NUM_MISSING_KWARGS GREATER 0)
        foreach(arg ${_KEYWORDS_MISSING_VALUES})
            message(WARNING "Keyword argument \"${arg}\" is missing a value.")
        endforeach(arg ${_KEYWORDS_MISSING_VALUES})
        message(FATAL_ERROR "One or more required keyword arguments are missing their values.")
    endif(NUM_MISSING_KWARGS GREATER 0)

    # Process required single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS-REQUIRED})
        if(NOT DEFINED _${ARG})
            message(FATAL_ERROR "Required keyword argument: ${ARG} not provided.")
            return()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${SINGLE_VALUE_ARGS-REQUIRED})

    # Process optional single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS-OPTIONAL})
        if(NOT DEFINED _${ARG})
            if(DEFINED ${ARG}-DEFAULT)
                set(_${ARG} ${${ARG}-DEFAULT})
                message(VERBOSE "Value for keyword argument: ${ARG} not given. Used default value of ${_${ARG}}")
            endif(DEFINED ${ARG}-DEFAULT)
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${SINGLE_VALUE_ARGS-OPTIONAL})

    # Validate choices for single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(NOT (${_${ARG}} IN_LIST ${ARG}-CHOICES))
                message(FATAL_ERROR "Keyword argument \"${ARG}\" given invalid value: \"${_${ARG}}\". \n Choices: ${${ARG}-CHOICES}.")
            endif(NOT (${_${ARG}} IN_LIST ${ARG}-CHOICES))
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${SINGLE_VALUE_ARGS})
    
    # Process required multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS-REQUIRED})
        if(NOT DEFINED _${ARG})
            message(FATAL_ERROR "Required keyword argument: ${ARG} not provided.")
            return()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${MULTI_VALUE_ARGS-REQUIRED})
    
    # Process optional multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS-OPTIONAL})
        if(NOT DEFINED _${ARG})
            if(DEFINED ${ARG}-DEFAULT)
                set(_${ARG} ${${ARG}-DEFAULT})
                message(VERBOSE "Value for keyword argument: ${ARG} not given. Used default value of ${_${ARG}}")
            endif(DEFINED ${ARG}-DEFAULT)
        else()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${MULTI_VALUE_ARGS-OPTIONAL})

    # Validate choices for multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            foreach(LIST_ELEMENT ${_${ARG}})
                if(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                    message(FATAL_ERROR "Keyword argument \"${ARG}\" given an invalid value: \"${LIST_ELEMENT}\". \n Choices: ${${ARG}-CHOICES}.")
                endif(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
            endforeach(LIST_ELEMENT ${_${ARG}})
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${MULTI_VALUE_ARGS})

    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    PackagerApi_check_exists(${_PACKAGE})

    if(TARGET ${_TARGET})
        message(FATAL_ERROR "Target: \"${_TARGET}\" already exists.")
    endif(TARGET ${_TARGET})

                                        
    add_executable(
        ${_TARGET} 
        ${_UNPARSED_ARGUMENTS} 
        # PROPAGATE OTHER ARGS TO add_library call
        # e.g. 
        #    - $<TARGET_OBJECTS:SOME_OTHER_TARGET>
        #    - source1.cpp source2.cpp,
        #    - EXCLUDE_FROM_ALL               
    )

    # Inherit link libraries and include directories from target objects.
    # This because we do not install target objects and so without doing this
    # transient dependencies will not be propagated into the install package.
    foreach(arg ${_UNPARSED_ARGUMENTS})

        # The behaviour of string(REGEX <mode>) is INCREDIBLY undocumented.
        # Sometimes it is even plain wrong.
        # string(REGEX MATCH) stores captured subexpressions in CMAKE_MATCH_1 ... CMAKE_MATCH_9
        # (where CMAKE_MATCH_0 == the complete matched expression - not subexpression).
        #
        # However, Despite the claims of the documentation, CMAKE_MATCH_x (where x > 1)
        # is not set for string(REGEX REPLACE) ... which is sad because there is a large
        # usecase subset where one would want to parse a subexpression from within a string.
        set(TARGET_OBJECTS_REGEX "\\$<TARGET_OBJECTS:(.+)>")
        string(REGEX MATCH ${TARGET_OBJECTS_REGEX} MATCHED ${arg})
        if(MATCHED)
            string(REGEX REPLACE ${TARGET_OBJECTS_REGEX} ${CMAKE_MATCH_1} OBJECT_TARGET_NAME ${arg})
            message(DEBUG "Parsed target:${OBJECT_TARGET_NAME} from ${arg} as TARGET_OBJECT library dependency for target: ${_TARGET} in ${CMAKE_CURRENT_FUNCTION}")
            if(TARGET ${OBJECT_TARGET_NAME})
                get_target_property(OBJECT_TARGET_TYPE ${OBJECT_TARGET_NAME} TYPE)
                if(OBJECT_TARGET_TYPE)
                    if(OBJECT_TARGET_TYPE STREQUAL OBJECT_LIBRARY)

                        # PASS interface link libraries and interface include directories on from $<TARGET_OBJECTS: ... >

                        get_target_property(INHERITED_INTERFACE_INCLUDE_DIRECTORIES ${OBJECT_TARGET_NAME} INTERFACE_INCLUDE_DIRECTORIES)
                        message(VERBOSE "[ in ${CMAKE_CURRENT_FUNCTION} ], TARGET: ${_TARGET} INHERITED_INTERFACE_INCLUDE_DIRECTORIES:${INHERITED_INTERFACE_INCLUDE_DIRECTORIES} from target ${OBJECT_TARGET_NAME}")
                        if(NOT (INHERITED_INTERFACE_INCLUDE_DIRECTORIES STREQUAL "INHERITED_INTERFACE_INCLUDE_DIRECTORIES-NOTFOUND"))
                            PackagerApi_target_include_directories(${_TARGET} PUBLIC ${INHERITED_INTERFACE_INCLUDE_DIRECTORIES})
                        else()
                            message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], target: ${OBJECT_TARGET_NAME} does not have property INTERFACE_INCLUDE_DIRECTORIES")
                        endif(NOT (INHERITED_INTERFACE_INCLUDE_DIRECTORIES STREQUAL "INHERITED_INTERFACE_INCLUDE_DIRECTORIES-NOTFOUND"))

                        get_target_property(INHERITED_INTERFACE_LINK_LIBRARIES ${OBJECT_TARGET_NAME} INTERFACE_LINK_LIBRARIES)
                        message(VERBOSE "[ in ${CMAKE_CURRENT_FUNCTION} ], TARGET: ${_TARGET} INHERITED_INTERFACE_LINK_LIBRARIES:${INHERITED_INTERFACE_LINK_LIBRARIES} from target ${OBJECT_TARGET_NAME}")                        
                        if(NOT (INHERITED_INTERFACE_LINK_LIBRARIES STREQUAL "INHERITED_INTERFACE_LINK_LIBRARIES-NOTFOUND"))
                            PackagerApi_target_link_libraries(${_TARGET} PUBLIC ${INHERITED_INTERFACE_LINK_LIBRARIES})
                        else()
                            message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], target: ${OBJECT_TARGET_NAME} does not have property INTERFACE_LINK_LIBRARIES")
                        endif(NOT (INHERITED_INTERFACE_LINK_LIBRARIES STREQUAL "INHERITED_INTERFACE_LINK_LIBRARIES-NOTFOUND"))

                    else()
                        message(WARNING "Target:${OBJECT_TARGET_NAME} exists but does not have type:OBJECT_LIBRARY. There is a likely bug around in ${CMAKE_CURRENT_LIST_LINE} in ${CMAKE_CURRENT_LIST_FILE}.")
                    endif(OBJECT_TARGET_TYPE STREQUAL OBJECT_LIBRARY)
                endif(OBJECT_TARGET_TYPE)
            else()
                message(WARNING "Target:${OBJECT_TARGET_NAME} does not exist. There is a likely bug around in ${CMAKE_CURRENT_LIST_LINE} in ${CMAKE_CURRENT_LIST_FILE}.")
            endif(TARGET ${OBJECT_TARGET_NAME})
            
        endif(MATCHED)
    endforeach(arg ${_UNPARSED_ARGUMENTS})

    set_target_properties(${_TARGET} 
        PROPERTIES 
            POSITION_INDEPENDENT_CODE ON
    )

    PackagerApi_get_targets_export_name(${_PACKAGE} PACKAGE_TARGET_EXPORT_NAME)

    PackagerApi_get_version(${_PACKAGE} PACKAGE_VERSION)
    set_target_properties(${_TARGET} PROPERTIES VERSION "${PACKAGE_VERSION}")

    PackagerApi_get_cmake_component_name(${_PACKAGE} PACKAGE_CMAKE_COMPONENT)
    PackagerApi_get_executable_component_name(${_PACKAGE} PACKAGE_BIN_COMPONENT)

    PackagerApi_get_executable_files_install_reldir(${_PACKAGE} PACKAGE_BIN_INSTALL_DIR)
    PackagerApi_get_cmake_files_install_reldir(${_PACKAGE} PACKAGE_INSTALL_CMAKE_DIR)
    
    PackagerApi_get_targets_export_name(${_PACKAGE} PACKAGE_EXPORT_NAME)
    PackagerApi_get_targets_namespace(${_PACKAGE} PACKAGE_NAMESPACE)

    install(
        TARGETS ${_TARGET}
        EXPORT  ${PACKAGE_TARGET_EXPORT_NAME}
        DESTINATION ${PACKAGE_BIN_INSTALL_DIR}
        COMPONENT ${PACKAGE_BIN_COMPONENT}
    )

    install(
        EXPORT ${PACKAGE_EXPORT_NAME}
        NAMESPACE ${PACKAGE_NAMESPACE}::
        DESTINATION ${PACKAGE_INSTALL_CMAKE_DIR}
        COMPONENT ${PACKAGE_CMAKE_COMPONENT}
    )

    
endfunction(PackagerApi_add_executable)


################################################################################
# @name: PackagerApi_install_headers
#
# @brief
# Install header files for target: TARGET as part of package: PACKAGE
#
# @note
# ** DEPRECATED ** 
# Use PackagerApi_target_headers instead
#
# @usage 
# See documentation for PackagerApi_target_headers
#
################################################################################
function(PackagerApi_install_headers)
    PackagerApi_target_headers(${ARGN})
endfunction(PackagerApi_install_headers)


################################################################################
# @name: PackagerApi_target_headers
#
# @brief
# Add headers to target: TARGET as part of package: PACKAGE.
#
# @note
# No filtering is done by file extension. This can technically be used to 
# install any arbitrary files and update the include directories for 
# $<INSTALL_INTERFACE> and $<BUILD_INTERFACE> of target: TARGET
#
# @param        PACKAGE
# @type        VALUE
# @required    true
# @description The package name
#
# @param       TARGET
# @type        VALUE
# @required    TRUE
# @description The target for which to add the header files
#
# @param       HEADERS
# @type        LIST
# @required    TRUE
# @description CMake (i.e. semicolon-delimited) list of header files to install
# and include the directories to target: TARGET
#
#
# @usage 
# PackagerApi_target_headers(
#   PACKAGE my_package
#   TARGET my_target
#   HEADERS header1.hpp header2.hpp /abs/path/to/header3.h ./rel/path/to/header4.h ...
# )
#
################################################################################
function(PackagerApi_target_headers)
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
        HEADERS
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
    # Note: Default values are not supported for members of OPTION_ARGS 
    # (since not providing an option is FALSE)
    #
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

    # SINGLE_VALUE_ARGS LOGIC-CONSISTENCY CHECK
    message(VERBOSE "Performing self-consistency logic check for SINGLE_VALUE_ARGS ... ")
    foreach(ARG ${SINGLE_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(DEFINED ${ARG}-DEFAULT)
                if(NOT (${${ARG}-DEFAULT} IN_LIST ${ARG}-CHOICES))
                    message(FATAL_ERROR "The argument choices and defaults configured for ${CMAKE_CURRENT_FUNCTION} are inconsistent. This is a development error. Please contact the maintainer.")
                endif(NOT (${${ARG}-DEFAULT} IN_LIST ${ARG}-CHOICES))
            endif(DEFINED ${ARG}-DEFAULT)
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${SINGLE_VALUE_ARGS})
    message(VERBOSE "Ok.")
    
    # MULTI_VALUE_ARGS LOGIC-CONSISTENCY CHECK
    message(VERBOSE "Performing self-consistency logic check for MULTI_VALUE_ARGS ... ")
    foreach(ARG ${MULTI_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(DEFINED ${ARG}-DEFAULT)
                foreach(LIST_ELEMENT ${${ARG}-DEFAULT})
                    if(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                        message(FATAL_ERROR "The argument choices and defaults configured for ${CMAKE_CURRENT_FUNCTION} are inconsistent. This is a development error. Please contact the maintainer.")
                    endif(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                endforeach(LIST_ELEMENT ${${ARG}-DEFAULT})
            endif(DEFINED ${ARG}-DEFAULT)
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${MULTI_VALUE_ARGS})
    message(VERBOSE "Ok.")

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

    # Sanitize keywords for all required KWARGS
    list(LENGTH _KEYWORDS_MISSING_VALUES NUM_MISSING_KWARGS)
    if(NUM_MISSING_KWARGS GREATER 0)
        foreach(arg ${_KEYWORDS_MISSING_VALUES})
            message(WARNING "Keyword argument \"${arg}\" is missing a value.")
        endforeach(arg ${_KEYWORDS_MISSING_VALUES})
        message(FATAL_ERROR "One or more required keyword arguments are missing their values.")
    endif(NUM_MISSING_KWARGS GREATER 0)

    # Process required single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS-REQUIRED})
        if(NOT DEFINED _${ARG})
            message(FATAL_ERROR "Required keyword argument: ${ARG} not provided.")
            return()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${SINGLE_VALUE_ARGS-REQUIRED})

    # Process optional single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS-OPTIONAL})
        if(NOT DEFINED _${ARG})
            if(DEFINED ${ARG}-DEFAULT)
                set(_${ARG} ${${ARG}-DEFAULT})
                message(VERBOSE "Value for keyword argument: ${ARG} not given. Used default value of ${_${ARG}}")
            endif(DEFINED ${ARG}-DEFAULT)
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${SINGLE_VALUE_ARGS-OPTIONAL})

    # Validate choices for single-value keyword arguments
    foreach(ARG ${SINGLE_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            if(NOT (${_${ARG}} IN_LIST ${ARG}-CHOICES))
                message(FATAL_ERROR "Keyword argument \"${ARG}\" given invalid value: \"${_${ARG}}\". \n Choices: ${${ARG}-CHOICES}.")
            endif(NOT (${_${ARG}} IN_LIST ${ARG}-CHOICES))
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${SINGLE_VALUE_ARGS})
    
    # Process required multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS-REQUIRED})
        if(NOT DEFINED _${ARG})
            message(FATAL_ERROR "Required keyword argument: ${ARG} not provided.")
            return()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${MULTI_VALUE_ARGS-REQUIRED})
    
    # Process optional multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS-OPTIONAL})
        if(NOT DEFINED _${ARG})
            if(DEFINED ${ARG}-DEFAULT)
                set(_${ARG} ${${ARG}-DEFAULT})
                message(VERBOSE "Value for keyword argument: ${ARG} not given. Used default value of ${_${ARG}}")
            endif(DEFINED ${ARG}-DEFAULT)
        else()
        endif(NOT DEFINED _${ARG})
    endforeach(ARG ${MULTI_VALUE_ARGS-OPTIONAL})

    # Validate choices for multi-value keyword arguments
    foreach(ARG ${MULTI_VALUE_ARGS})
        if(DEFINED ${ARG}-CHOICES)
            foreach(LIST_ELEMENT ${_${ARG}})
                if(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
                    message(FATAL_ERROR "Keyword argument \"${ARG}\" given an invalid value: \"${LIST_ELEMENT}\". \n Choices: ${${ARG}-CHOICES}.")
                endif(NOT (${LIST_ELEMENT} IN_LIST ${ARG}-CHOICES))
            endforeach(LIST_ELEMENT ${_${ARG}})
        endif(DEFINED ${ARG}-CHOICES)
    endforeach(ARG ${MULTI_VALUE_ARGS})

    ##########################################
    # NOW THE FUNCTION LOGIC SPECIFICS BEGIN #
    ##########################################

    PackagerApi_check_exists(${_PACKAGE})

    if(NOT TARGET ${_TARGET})
        message(FATAL_ERROR "Target:${_TARGET} does not exist.")
    endif(NOT TARGET ${_TARGET})
    

    PackagerApi_get_header_files_install_reldir(${_PACKAGE} PACKAGE_HEADER_FILE_INSTALL_DIR)
    PackagerApi_get_header_files_install_include_reldir(${_PACKAGE} PACKAGE_HEADER_FILE_INSTALL_INCLUDEDIR)
    PackagerApi_get_header_component_name(${_PACKAGE} PACKAGE_HEADER_COMPONENT)
    PackagerApi_get_header_files_staging_dir(${_PACKAGE} PACKAGE_HEADER_FILES_STAGING_DIR)
    PackagerApi_get_header_files_staging_include_dir(${_PACKAGE} PACKAGE_HEADER_FILES_STAGING_INCLUDE_DIR)

    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], PACKAGE_HEADER_FILE_INSTALL_DIR:${PACKAGE_HEADER_FILE_INSTALL_DIR}")
    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], PACKAGE_HEADER_FILE_INSTALL_INCLUDEDIR:${PACKAGE_HEADER_FILE_INSTALL_INCLUDEDIR}")
    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], PACKAGE_HEADER_COMPONENT:${PACKAGE_HEADER_COMPONENT}")
    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], PACKAGE_HEADER_FILES_STAGING_DIR:${PACKAGE_HEADER_FILES_STAGING_DIR}")
    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], PACKAGE_HEADER_FILES_STAGING_INCLUDE_DIR:${PACKAGE_HEADER_FILES_STAGING_INCLUDE_DIR}")

    if(NOT EXISTS ${PACKAGE_HEADER_FILES_STAGING_DIR})
        file(MAKE_DIRECTORY ${PACKAGE_HEADER_FILES_STAGING_DIR})
    endif(NOT EXISTS ${PACKAGE_HEADER_FILES_STAGING_DIR})

    set(BUILD_INTERFACE_INCLUDEDIRS)
    foreach(HEADER_FILE ${_HEADERS})

        if(NOT (IS_ABSOLUTE ${HEADER_FILE}))
            set(HEADER_FILE ${CMAKE_CURRENT_SOURCE_DIR}/${HEADER_FILE})
        endif(NOT (IS_ABSOLUTE ${HEADER_FILE}))

        if(NOT EXISTS ${HEADER_FILE})
            message(FATAL_ERROR "File: \"${HEADER_FILE}\" does not exist.")
        endif(NOT EXISTS ${HEADER_FILE})

        get_filename_component(HEADER_BUILD_DIR ${HEADER_FILE} DIRECTORY)
        get_filename_component(HEADER_BUILD_DIR_NAME ${HEADER_BUILD_DIR} NAME)
        get_filename_component(HEADER_INSTALL_DIR_NAME ${PACKAGE_HEADER_FILE_INSTALL_DIR} NAME)
        
        message(DEBUG "HEADER_BUILD_DIR:${HEADER_BUILD_DIR}")
        message(DEBUG "HEADER_BUILD_DIR_NAME:${HEADER_BUILD_DIR_NAME}")
        message(DEBUG "HEADER_INSTALL_DIR_NAME:${HEADER_INSTALL_DIR_NAME}")

        if(NOT (HEADER_BUILD_DIR_NAME STREQUAL HEADER_INSTALL_DIR_NAME))
        # This handles the case wherein the headers are in a directory such as 
        # ${CMAKE_CURRENT_SOURCE_DIR}/include/lib.hpp and the source files have
        # #include directives that reference the __ HEADER INSTALL LOCATION __
        # e.g. 
        # #include "package_name/lib.hpp"

            file(COPY ${HEADER_FILE} DESTINATION ${PACKAGE_HEADER_FILES_STAGING_DIR})
            PackagerApi_target_include_directories(${_TARGET} 
                PRIVATE
                    $<BUILD_INTERFACE:${PACKAGE_HEADER_FILES_STAGING_INCLUDE_DIR}>
            )

        else()

        # This handles the case wherein the headers are in a directory such as
        # ${CMAKE_CURRENT_SOURCE_DIR}/include/package_name/lib.hpp and the 
        # source files have 
        # #include directives that reference the __ HEADER BUILD LOCATION __
        # e.g. 
        # #include "lib.hpp"

            PackagerApi_target_include_directories(${_TARGET} 
                PRIVATE
                    $<BUILD_INTERFACE:${HEADER_BUILD_DIR}>
            )
        endif(NOT (HEADER_BUILD_DIR_NAME STREQUAL HEADER_INSTALL_DIR_NAME))

        if(IS_ABSOLUTE ${HEADER_BUILD_DIR})
            set(BUILD_INTERFACE_HEADER_DIR "${HEADER_BUILD_DIR}")
        else()
            set(BUILD_INTERFACE_HEADER_DIR "${CMAKE_CURRENT_SOURCE_DIR}/${HEADER_BUILD_DIR}")
        endif(IS_ABSOLUTE ${HEADER_BUILD_DIR})
        
        PackagerApi_target_include_directories(${_TARGET} 
            PUBLIC 
                $<INSTALL_INTERFACE:${PACKAGE_HEADER_FILE_INSTALL_INCLUDEDIR}>
        )

        install(
            FILES ${HEADER_FILE}
            DESTINATION ${PACKAGE_HEADER_FILE_INSTALL_DIR}
            COMPONENT ${PACKAGE_HEADER_COMPONENT}
        )
    endforeach(HEADER_FILE ${_HEADERS})

    list(REMOVE_DUPLICATES BUILD_INTERFACE_INCLUDEDIRS)

    foreach(INCLUDEDIR ${BUILD_INTERFACE_INCLUDEDIRS})
        PackagerApi_target_include_directories(${_TARGET} 
            PUBLIC 
                $<BUILD_INTERFACE:${INCLUDEDIR}>
        )
    endforeach(INCLUDEDIR ${BUILD_INTERFACE_INCLUDEDIRS})

endfunction(PackagerApi_target_headers)





################################################################################
# Utility functions - TODO: factor into a different module
################################################################################

function(util_is_version_valid VERSION OUT_version_is_valid)
    set(VALID_VERSION_REGEX "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$")
    message(VERBOSE "Validating VERSION: ${VERSION} against ${VALID_VERSION_REGEX}")
    string(REGEX MATCH ${VALID_VERSION_REGEX} VALID_VERSION ${VERSION})
    if(VALID_VERSION)
        set(${OUT_version_is_valid} 1 PARENT_SCOPE)
    else()
        set(${OUT_version_is_valid} 0 PARENT_SCOPE)
    endif(VALID_VERSION)
endfunction(util_is_version_valid VERSION OUT_version_is_valid)
