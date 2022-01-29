cmake_minimum_required(VERSION 3.21)
include(ProcessorCount)


function(CppCheckAnalysis_get_root_dir OUT_root_dir)
    set(${OUT_root_dir} "${CMAKE_BINARY_DIR}/cppcheck" PARENT_SCOPE)
endfunction(CppCheckAnalysis_get_root_dir OUT_root_dir)


function(CppCheckAnalysis_get_analysis_dir OUT_analysis_dir)
    CppCheckAnalysis_get_root_dir(CPPCHECK_ROOT_DIR)
    set(${OUT_analysis_dir} "${CPPCHECK_ROOT_DIR}/analysis" PARENT_SCOPE)
endfunction(CppCheckAnalysis_get_analysis_dir OUT_analysis_dir)


function(CppCheckAnalysis_get_target_dir TARGET OUT_target_dir)
    CppCheckAnalysis_get_analysis_dir(CPPCHECK_ANALYSIS_DIR)
    set(${OUT_target_dir} "${CPPCHECK_ANALYSIS_DIR}/${TARGET}" PARENT_SCOPE)
endfunction(CppCheckAnalysis_get_target_dir TARGET OUT_target_dir)


function(CppCheckAnalysis_get_target_output_file TARGET OUT_target_cppcheck_file)
    CppCheckAnalysis_get_target_dir(${TARGET} TARGET_CPPCHECK_DIR)
    set(${OUT_target_cppcheck_file} "${TARGET_CPPCHECK_DIR}/${TARGET}-cppcheck.output" PARENT_SCOPE)
endfunction(CppCheckAnalysis_get_target_output_file TARGET OUT_target_cppcheck_file)


function(CppCheckAnalysis_check_initialized)
    if(NOT CPPCHECK_EXECUTABLE)
        message(FATAL_ERROR "CPPCHECK_EXECUTABLE not set. Please call CppCheckAnalysis_init before other CppCheckAnalysis functions")
    endif(NOT CPPCHECK_EXECUTABLE)
endfunction(CppCheckAnalysis_check_initialized)

function(CppCheckAnalysis_get_analysis_target_name OUT_analysis_target_name)
    set(${OUT_analysis_target_name} cppcheck PARENT_SCOPE)
endfunction(CppCheckAnalysis_get_analysis_target_name OUT_analysis_target_name)


function(CppCheckAnalysis_get_processor_count OUT_processor_count)
    ProcessorCount(N)
    set(${OUT_processor_count} ${N} PARENT_SCOPE)
endfunction(CppCheckAnalysis_get_processor_count OUT_processor_count)


################################################################################
# @name: CppCheckAnalysis_init
#
# @brief
# Initialize the CppCheckAnalysis cmake module  
#
# @note
# - Requires cppcheck executable on disk
# - MUST be called before all other CppCheckAnalysis functions
#
# @usage 
# CppCheckAnalysis_init()
#
################################################################################
macro(CppCheckAnalysis_init)
    find_program(CPPCHECK_EXECUTABLE NAMES cppcheck)
    if(CPPCHECK_EXECUTABLE STREQUAL CPPCHECK_EXECUTABLE-NOTFOUND)
        message(WARNING "Could not find program clang-tidy on disk. ClangTidyAnalysis functions will fail.")
        set(CPPCHECK_EXECUTABLE "") # empty string
    endif(CPPCHECK_EXECUTABLE STREQUAL CPPCHECK_EXECUTABLE-NOTFOUND)

    CppCheckAnalysis_get_analysis_target_name(CPPCHECK_ANALYSIS_TARGET)
    if(NOT TARGET ${CPPCHECK_ANALYSIS_TARGET})
        add_custom_target(${CPPCHECK_ANALYSIS_TARGET})
    endif(NOT TARGET ${CPPCHECK_ANALYSIS_TARGET})

    CppCheckAnalysis_get_root_dir(CPPCHECK_ROOT_DIR)
    if(NOT (IS_DIRECTORY ${CPPCHECK_ROOT_DIR}))
        file(MAKE_DIRECTORY ${CPPCHECK_ROOT_DIR})
    endif(NOT (IS_DIRECTORY ${CPPCHECK_ROOT_DIR}))
    
endmacro(CppCheckAnalysis_init)


################################################################################
# @name: CppCheckAnalysis_configure_target
#
# @brief
# Configure a target TARGET to have cppcheck perform static analysis on its sources
#
# @note
# - Target must exist
# - CppCheckAnalysis_init must have been already called
#
# @usage 
# CppCheckAnalysis_configure_target(
#   TARGET my_target_name
#   [ VERBOSE ]
# )
#
#
# @param       TARGET
# @type        VALUE
# @required    TRUE
# @description The name of the target to perform the cppcheck analysis on
#
#
# @param       VERBOSE
# @type        OPTION
# @required    FALSE
# @description Option to enable verbose output during the static analysis
#
#
# @param       POST_BUILD
# @type        OPTION
# @required    FALSE
# @description Option to enable post-build static analysis for target: TARGET. 
#              If not selected, static analysis can be done manually by building
#              target <TARGET_NAME>-cppcheck or cppcheck. Note that Building 
#              target cppcheck will build ALL static analysis targets, not just
#              target: TARGET.
#
################################################################################
# TODOLIST:
# 
# - allow arguments (and with a default value) for a .suppressions file
# 
################################################################################
function(CppCheckAnalysis_configure_target)

    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : ARGN=${ARGN}")
    ############################################################################
    # Developer configures these                                               #
    ############################################################################

    set(OPTION_ARGS
        VERBOSE
        POST_BUILD
        # ADD YOUR OPTIONAL ARGUMENTS
    )

    ##########################
    # SET UP MONOVALUE ARGS  #
    ##########################
    set(SINGLE_VALUE_ARGS-REQUIRED
        TARGET
        # Add your argument keywords here
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

    if(NOT TARGET ${_TARGET})
        message(FATAL_ERROR "Target: \"${_TARGET}\" does not exist!")
    endif(NOT TARGET ${_TARGET})
    
    set(TARGET_SOURCE_ANALYSIS_TARGET_NAME ${_TARGET}-cppcheck-analysis)

    CppCheckAnalysis_get_target_dir(${_TARGET} TARGET_CPPCHECK_DIR)
    if(NOT (IS_DIRECTORY ${TARGET_CPPCHECK_DIR}))
        file(MAKE_DIRECTORY ${TARGET_CPPCHECK_DIR})
    endif(NOT (IS_DIRECTORY ${TARGET_CPPCHECK_DIR}))

    # Set up the actual targets and cppcheck command
    set(CPPCHECK_COMMAND 
        ${CPPCHECK_EXECUTABLE}
        --enable=all  
    )
    if(FETCHCONTENT_BASE_DIR AND (IS_DIRECTORY FETCHCONTENT_BASE_DIR))
        # Exclude third-party sources from the check
        list(APPEND CPPCHECK_COMMAND -i ${FETCHCONTENT_BASE_DIR}) 
    endif(FETCHCONTENT_BASE_DIR AND (IS_DIRECTORY FETCHCONTENT_BASE_DIR))
    

    if(_VERBOSE)
        list(APPEND CPPCHECK_COMMAND "--verbose")
        list(APPEND CPPCHECK_COMMAND "--report-progress")
    endif(_VERBOSE)

    # Add the source files for 
    get_target_property(TARGET_SOURCE_FILES ${_TARGET} SOURCES)
    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], TARGET_SOURCE_FILES:${TARGET_SOURCE_FILES}")
    if(TARGET_SOURCE_FILES STREQUAL TARGET_SOURCE_FILES-NOTFOUND)
        message(WARNING "Target: \"${_TARGET}\" contains no source files. Cannot configure it for cppcheck analysis")
        return()
    endif(TARGET_SOURCE_FILES STREQUAL TARGET_SOURCE_FILES-NOTFOUND)

    # Convert all the sources to absolute paths to prevent weird bugs
    get_target_property(TARGET_SOURCE_DIR ${_TARGET} SOURCE_DIR)
    set(TARGET_SOURCE_FILES_ABSPATH "")
    foreach(SOURCE_FILE ${TARGET_SOURCE_FILES})
        if(IS_ABSOLUTE ${SOURCE_FILE})
            set(SOURCE_FILE_ABSPATH ${SOURCE_FILE})
        else()
            set(SOURCE_FILE_ABSPATH "${TARGET_SOURCE_DIR}/${SOURCE_FILE}")
        endif(IS_ABSOLUTE ${SOURCE_FILE})
        list(APPEND TARGET_SOURCE_FILES_ABSPATH ${SOURCE_FILE_ABSPATH})
    endforeach(SOURCE_FILE ${TARGET_SOURCE_FILES})
    message(DEBUG "TARGET_SOURCE_FILES_ABSPATH:${TARGET_SOURCE_FILES_ABSPATH}")


    get_target_property(TARGET_TYPE ${_TARGET} TYPE)
    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], TARGET_TYPE:${TARGET_TYPE}")
    if(NOT (TARGET_TYPE) OR (TARGET_TYPE STREQUAL TARGET_TYPE-NOTFOUND))
        message(FATAL_ERROR "Target:\"${_TARGET}\" does not have property: \"TYPE\".")
    endif(NOT (TARGET_TYPE) OR (TARGET_TYPE STREQUAL TARGET_TYPE-NOTFOUND))

    # Configure target-type-specific suppressions.
    # e.g. We don't care about unused functions for libraries
    if(TARGET_TYPE STREQUAL EXECUTABLE)
    elseif((TARGET_TYPE STREQUAL STATIC_LIBRARY) OR (TARGET_TYPE STREQUAL SHARED_LIBRARY) OR (TARGET_TYPE STREQUAL OBJECT_LIBRARY))
        list(APPEND CPPCHECK_COMMAND "--suppress=unusedFunction")
    else()
        message(FATAL_ERROR "Function ${CMAKE_CURRENT_FUNCTION} does not know how to handle target (\"${_TARGET}\") with type:\"${TARGET_TYPE}\".")
    endif()


    CppCheckAnalysis_get_target_output_file(${_TARGET} TARGET_CPPCHECK_OUTPUT_FILE)
    if(_POST_BUILD)
        set(BUILD_GROUP_ALL ALL)
    endif(_POST_BUILD)
    add_custom_target(${TARGET_SOURCE_ANALYSIS_TARGET_NAME}
        ${BUILD_GROUP_ALL}
        COMMENT "Performing cppcheck static analysis on sources for target: \"${_TARGET}\""
        COMMAND ${CPPCHECK_COMMAND} --output-file=${TARGET_CPPCHECK_OUTPUT_FILE} ${TARGET_SOURCE_FILES_ABSPATH}
        DEPENDS ${_TARGET}
    )

    # Add the current target as a dependency of the top-level cppcheck analysis target
    CppCheckAnalysis_get_analysis_target_name(CPPCHECK_ANALYSIS_TARGET)
    add_dependencies(${CPPCHECK_ANALYSIS_TARGET} ${TARGET_SOURCE_ANALYSIS_TARGET_NAME})

endfunction(CppCheckAnalysis_configure_target)

