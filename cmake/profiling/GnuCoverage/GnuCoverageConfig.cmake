################################################################################
# License:                                                                     #
# -----------------------------------------------------------------------------#
# Copyright (c) - 2021, Carl Mattatall                                         #
# All rights reserved.                                                         #
#                                                                              #
# Redistribution and use in source and binary forms, with or without           #
# modification, are permitted provided that the following conditions are met:  #
#                                                                              #
# 1. Redistributions of source code must retain the above copyright notice,    #
#    this list of conditions and the following disclaimer.                     #
#                                                                              #
# 2. Redistributions in binary form must reproduce the above copyright notice, #
#    this list of conditions and the following disclaimer in the documentation #
#    and/or other materials provided with the distribution.                    #
#                                                                              #
# 3. Neither the name of the copyright holder nor the names of its             #
#    contributors may be used to endorse or promote products derived from this #
#    software without specific prior written permission.                       #
#                                                                              #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  #
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    #
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   #
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE    #
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR          #
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF         #
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS     #
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN      #
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)      #
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE   #
# POSSIBILITY OF SUCH DAMAGE.                                                  #
#                                                                              #
################################################################################
# Acknowledgements:                                                            #
# -----------------------------------------------------------------------------#
# Based on Lars Bilke and Joakim Soderberg's LCOV cmake integration - 2012     #
#                                                                              #
################################################################################
# Usage:                                                                       #
# -----------------------------------------------------------------------------#
# 0. (Mac only) If you use Xcode 5.1 make sure to patch geninfo as             #
#    described here: http://stackoverflow.com/a/22404544/80480                 #
#                                                                              #
# 1. Add this file into your cmake modules path. It must be discoverable by    #    
#    find_package()                                                            #
#                                                                              #
# 2. Add the following line to your CMakeLists.txt:                            #
#    find_package(GnuCoverage)                                                 #
#                                                                              #
# 3. Initialize the module:                                                    #
#    GnuCoverage_init()                                                        #
#                                                                              #
# 4. Create a library or target to test:                                       #
#    e.g.                                                                      #
#    add_library(my_lib_to_test)                                               #
#    target_sources(my_lib_to_test PRIVATE lib_src1.cpp lib_src2.cpp)          #
#                                                                              #
# 5. Configure the library target for coverage profiling:                      #
#    GnuCoverage_target_add_coverage_definitions(                              #
#       TARGET my_lib_to_test                                                  #
#    )                                                                         #
#                                                                              #
# 6. Add a test runner executable:                                             #
#    e.g.                                                                      #
#    add_executable(unit_tests)                                                #
#    target_sources(unit_tests PRIVATE test_main.cpp test1.cpp test2.cpp)      #
#    target_link_libraries(unit_tests PRIVATE my_lib_to_test)                  #
#                                                                              #
# 7. Create a build target to generate the code coverage report:               #
#    GnuCoverage_add_report_target(                                            #
#        COVERAGE_TARGET     coverage                                          #
#        TEST_RUNNER         unit_tests                                        #
#        COVERAGE_FILENAME   coverage-report                                   #
#        [ POST_BUILD ]                                                        #
#    )                                                                         #
#                                                                              #
# 8. Build your cmake project like normal                                      #
#    $ cmake -B build -S . -DCMAKE_BUILD_TYPE=Debug && cmake --build build     #
#                                                                              #
# 9. Make the coverage report. Not required if POST_BUILD is specified.        #
#    $cd build                                                                 #
#    $ make coverage                                                           #
#                                                                              #
################################################################################



################################################################################
# @name: GnuCoverage_init
#
# @brief
# Initialize the GnuCoverage cmake module
#
# @note
# - CALL THIS FIRST BEFORE ANY OTHER GnuCoverage functions
#
# @usage 
# GnuCoverage_init()
#
################################################################################
macro(GnuCoverage_init)
    
    # Check prereqs
    find_program( GCOV_EXE_PATH    gcov)
    find_program( LCOV_EXE_PATH    lcov)
    find_program( GENHTML_EXE_PATH genhtml)
    find_program( GCOVR_EXE_PATH   gcovr PATHS ${CMAKE_CURRENT_SOURCE_DIR}/tests)


    # TODO:
    #
    # Plan was to use the demangling tricks similar to 
    # https://github.com/edwincarlson/cmake-gtest-gcov-project-template/blob/master/cmake/CodeCoverage.cmake
    # 
    # Sadly, really haven't had time to get around to it yet
    # - ctm
    find_program( CPPFILT_EXE_PATH NAMES c++filt) 



    if(NOT GCOV_EXE_PATH)
        message(FATAL_ERROR "gcov not found! Aborting...")
    endif() # NOT GCOV_EXE_PATH

    if(NOT CMAKE_COMPILER_IS_GNUCXX)
        # Clang version 3.0.0 and greater now supports gcov as well.
        message(WARNING "Compiler is not GNU gcc! Clang Version 3.0.0 and greater supports gcov as well, but older versions don't.")

        if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            message(FATAL_ERROR "Compiler is not GNU gcc! Aborting...")
        endif()
    endif() # NOT CMAKE_COMPILER_IS_GNUCXX

    set(CMAKE_CXX_FLAGS_COVERAGE
        "-g -O0 --coverage -fprofile-arcs -ftest-coverage"
        CACHE STRING "Flags used by the C++ compiler during coverage builds."
        FORCE 
    )

    set(CMAKE_C_FLAGS_COVERAGE
        "-g -O0 --coverage -fprofile-arcs -ftest-coverage"
        CACHE STRING "Flags used by the C compiler during coverage builds."
        FORCE 
    )

    set(CMAKE_EXE_LINKER_FLAGS_COVERAGE
        ""
        CACHE STRING "Flags used for linking binaries during coverage builds."
        FORCE 
    )

    set(CMAKE_SHARED_LINKER_FLAGS_COVERAGE
        ""
        CACHE STRING "Flags used by the shared libraries linker during coverage builds."
        FORCE 
    )

    mark_as_advanced(
        CMAKE_CXX_FLAGS_COVERAGE
        CMAKE_C_FLAGS_COVERAGE
        CMAKE_EXE_LINKER_FLAGS_COVERAGE
        CMAKE_SHARED_LINKER_FLAGS_COVERAGE 
    )

    if ( NOT (CMAKE_BUILD_TYPE STREQUAL "Debug"))
        message( WARNING "Code coverage results with an optimized (non-Debug) build may be misleading" )
    endif() # NOT CMAKE_BUILD_TYPE STREQUAL "Debug"
endmacro(GnuCoverage_init)



################################################################################
# @name: GnuCoverage_remove_by_pattern
#
# @brief
# Exclude a specific filepath pattern from the code coverage profiling
#
# @note
# Uses cmake regex
#
# @usage 
# GnuCoverage_remove_by_pattern( "/usr/include/*\.hpp" )
#
################################################################################
macro(GnuCoverage_remove_by_pattern pattern)
    set(LCOV_REMOVE "${LCOV_REMOVE};${pattern}")
endmacro(GnuCoverage_remove_by_pattern pattern)



################################################################################
# @name: GnuCoverage_target_add_coverage_definitions
#
# @brief
# Add the necessary compile definitions to target TARGET so it can be profiled
# using code coverage tools
#
#
# @usage 
# GnuCoverage_target_add_coverage_definitions(
#    TARGET my_target_with_sources
# )
#
# @param       TARGET
# @type        VALUE
# @required    TRUE
# @description The target to add the coverage compile definitions
#
################################################################################
function(GnuCoverage_target_add_coverage_definitions)
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

    if(NOT TARGET ${_TARGET})
        message(FATAL_ERROR "Target: ${_TARGET} does not exist!")    
    endif(NOT TARGET ${_TARGET})

    if(NOT CMAKE_BUILD_TYPE)
        message(WARNING "CMAKE_BUILD_TYPE not set.")
    else()
        if((CMAKE_BUILD_TYPE STREQUAL Release) OR (CMAKE_BUILD_TYPE STREQUAL MinSizeRel))
            message(WARNING "CMAKE_BUILD_TYPE == ${CMAKE_BUILD_TYPE}, coverage results may be misleading due to compiler optimization!")
        endif((CMAKE_BUILD_TYPE STREQUAL Release) OR (CMAKE_BUILD_TYPE STREQUAL MinSizeRel))
    endif(NOT CMAKE_BUILD_TYPE)

    target_compile_options(${_TARGET} PRIVATE  -fprofile-arcs -ftest-coverage)

endfunction(GnuCoverage_target_add_coverage_definitions)



################################################################################
# @name: GnuCoverage_setup_executable_for_coverage
#
# @brief:
# Create a build target _targetname that generates a code coverage report
#
# @note
#  - DEPRECATED. USE GnuCoverage_add_report_target instead
#  - Optional fourth parameter is passed as arguments to _testrunner
#    Pass them in list form, e.g.: "-j;2" for -j 2
#
# @usage: 
# GnuCoverage_setup_executable_for_coverage(
#   coverage-report-target
#   test-runner-exe
#   report_name
# )
#
# @param:  _targetname (@paramtype VALUE) (@required true)
#
#
# @param:  _testrunner (@type VALUE) (@required true)
#          The name of the target which runs the tests.
#          MUST return ZERO always, even on errors.
#          If not, no coverage report will be created!
#
# @param:  _coverage_filename (@type VALUE) (@required true)
#          lcov output is generated as _coverage_filename.info
#          HTML report is generated in _coverage_filename/index.html
#
################################################################################
function(GnuCoverage_setup_executable_for_coverage _targetname _testrunner _coverage_filename)
    message(WARNING "${CMAKE_CURRENT_FUNCTION} is deprecated. Use GnuCoverage_add_report_target")
    GnuCoverage_setup_coverage_build_target(${_targetname} ${_testrunner} ${_coverage_filename} ${ARGN})
endfunction(GnuCoverage_setup_executable_for_coverage _targetname _testrunner _coverage_filename)



################################################################################
# @name: GnuCoverage_add_report_target
#
# @brief
# Create a build target that generates a code coverage report
#
# @usage 
# GnuCoverage_add_report_target(
#   COVERAGE_TARGET     coverage
#   TEST_RUNNER         my-test-runner
#   COVERAGE_FILENAME   coverage-report
#   [ COVERAGE_DIR ] /my/coverage/directory/can/be/relative/or/absolute
#   [ POST_BUILD ]
# )
#
# @param       COVERAGE_TARGET
# @type        value
# @required    TRUE
# @description The name for the target that will make the code coverage report
#
# @param       TEST_RUNNER
# @type        VALUE
# @required    TRUE
# @description The name of the executable cmake target that runs the tests
#
# @param       COVERAGE_FILENAME
# @type        VALUE
# @required    TRUE
# @description The name (without extension) of the coverage report output file
#
# @param       COVERAGE_DIR
# @type        VALUE
# @required    FALSE
# @description The directory in which to generate the code coverage reports
#
# @param       POST_BUILD
# @type        OPTION
# @required    FALSE
# @description Option to automatically generate the coverage report post-build
#       
################################################################################
function(GnuCoverage_add_report_target)

    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION}] : ARGN=${ARGN}")
    ############################################################################
    # Developer configures these                                               #
    ############################################################################

    set(OPTION_ARGS
        # ADD YOUR OPTIONAL ARGUMENTS
        POST_BUILD
    )

    ##########################
    # SET UP MONOVALUE ARGS  #
    ##########################
    set(SINGLE_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
        COVERAGE_TARGET
        TEST_RUNNER
        COVERAGE_FILENAME
    )
    set(SINGLE_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
        COVERAGE_DIR
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
    if(PROJECT_BINARY_DIR)
        set(COVERAGE_DIR-DEFAULT ${PROJECT_BINARY_DIR})
    else()
        set(COVERAGE_DIR-DEFAULT ${CMAKE_CURRENT_BINARY_DIR})
    endif()

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

    if(NOT TARGET ${_TEST_RUNNER} )
        message(FATAL_ERROR "Target: ${_TEST_RUNNER} does not exist!")
    endif(NOT TARGET ${_TEST_RUNNER} )

    if(NOT DEFINED _COVERAGE_DIR)
        message(FATAL_ERROR "_COVERAGE_DIR not defined (\${_COVERAGE_DIR} == ${_COVERAGE_DIR}")
    endif(NOT DEFINED _COVERAGE_DIR)
    
    target_link_libraries(${_TEST_RUNNER} PRIVATE gcov)
    

    if(NOT LCOV_EXE_PATH)
        message(FATAL_ERROR "lcov not found! Aborting...")
    endif(NOT LCOV_EXE_PATH) 

    if(NOT GENHTML_EXE_PATH)
        message(FATAL_ERROR "genhtml not found! Aborting...")
    endif(NOT GENHTML_EXE_PATH)

    set(COVERAGE_INFO_FILE "${PROJECT_BINARY_DIR}/${_COVERAGE_FILENAME}.info")
    set(COVERAGE_INFO_FILE_CLEANED "${COVERAGE_INFO_FILE}.cleaned")

    separate_arguments(test_command UNIX_COMMAND "${_TEST_RUNNER}")

    if(IS_DIRECTORY ${PROJECT_BINARY_DIR}/_deps)
        list(APPEND LCOV_REMOVE ${PROJECT_BINARY_DIR}/_deps)
        list(APPEND LCOV_REMOVE ${PROJECT_BINARY_DIR}/_deps/*)
    endif(IS_DIRECTORY ${PROJECT_BINARY_DIR}/_deps)

    if(FETCHCONTENT_BASE_DIR)
        if(EXISTS ${FETCHCONTENT_BASE_DIR})
            if(IS_DIRECTORY ${FETCHCONTENT_BASE_DIR})
                list(APPEND LCOV_REMOVE ${FETCHCONTENT_BASE_DIR}/*)                
            endif(IS_DIRECTORY ${FETCHCONTENT_BASE_DIR})
        endif(EXISTS ${FETCHCONTENT_BASE_DIR})
    endif(FETCHCONTENT_BASE_DIR)
    

    if(IS_DIRECTORY ${PROJECT_BINARY_DIR}/codegen)
        list(APPEND LCOV_REMOVE ${PROJECT_BINARY_DIR}/codegen)
        list(APPEND LCOV_REMOVE ${PROJECT_BINARY_DIR}/codegen/*)
    endif(IS_DIRECTORY ${PROJECT_BINARY_DIR}/codegen)


    find_program(PYTHON_EXECUTABLE NAMES python3)
    if(NOT PYTHON_EXECUTABLE)
        message(FATAL_ERROR "Python not found! Aborting...")
    endif(NOT PYTHON_EXECUTABLE) 

    if(NOT GCOVR_EXE_PATH)
        message(FATAL_ERROR "gcovr not found! Aborting...")
    endif(NOT GCOVR_EXE_PATH)

    set(REPORT_SUMMARY_FILE ${PROJECT_BINARY_DIR}/${_coverage_filename}/coverage_summary.txt)
    set(COVERAGE_REPORT_FILE ${PROJECT_BINARY_DIR}/${_coverage_filename}/coverage_report.html)

    set(COVERAGE_CREATION_COMMENT "Resetting code coverage counters to zero.\n")
    set(COVERAGE_CREATION_COMMENT "${COVERAGE_CREATION_COMMENT}Processing code coverage counters and generating report.\n")
    set(COVERAGE_CREATION_COMMENT "${COVERAGE_CREATION_COMMENT}Open ${COVERAGE_REPORT_FILE} in your browser to view the coverage report.")
    
    # Setup target
    add_custom_target(
        ${_COVERAGE_TARGET} ${LCOV_EXE_PATH} --directory ${PROJECT_BINARY_DIR} --zerocounters # Cleanup lcov
        COMMAND ${test_command} ${ARGV3} # Run tests

        # Capturing lcov counters and generating report
        COMMAND ${LCOV_EXE_PATH} --directory ${PROJECT_BINARY_DIR} --capture --output-file ${COVERAGE_INFO_FILE}  --exclude "\"${PROJECT_BINARY_DIR}/*\""
        COMMAND ${LCOV_EXE_PATH} --remove ${COVERAGE_INFO_FILE} ${LCOV_REMOVE}  '/usr/*' '${PROJECT_SOURCE_DIR}/tests/*' --output-file ${COVERAGE_INFO_FILE_CLEANED}
        COMMAND ${GENHTML_EXE_PATH} -o ${_coverage_filename} ${COVERAGE_INFO_FILE_CLEANED}
        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        COMMENT ${COVERAGE_CREATION_COMMENT}
        USES_TERMINAL
    )

    if(_POST_BUILD)
        add_custom_command(
            TARGET ${_COVERAGE_TARGET}
            POST_BUILD

            # TODO: FIXME
            # This is terrible because i/o redirection doesnt work on many platforms (e.g. Windows)
            #                                                                |
            #                                                                |
            #                                                                v
            COMMAND ${LCOV_EXE_PATH} --summary ${COVERAGE_INFO_FILE_CLEANED} > ${REPORT_SUMMARY_FILE}
            COMMAND ${CMAKE_COMMAND} -E rename ${PROJECT_BINARY_DIR}/${_coverage_filename}/index.html ${COVERAGE_REPORT_FILE}
            COMMAND ${CMAKE_COMMAND} -E remove ${COVERAGE_INFO_FILE} ${COVERAGE_INFO_FILE_CLEANED}
            MAIN_DEPENDENCY ${COVERAGE_INFO_FILE_CLEANED}
            DEPENDS ${COVERAGE_INFO_FILE_CLEANED} ${COVERAGE_INFO_FILE}
            BYPRODUCTS ${REPORT_SUMMARY_FILE} ${COVERAGE_REPORT_FILE}
            WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
            COMMENT "Performing post-build tasks for target \"${_COVERAGE_TARGET}\""
            USES_TERMINAL
        )
    endif(_POST_BUILD)
    
endfunction(GnuCoverage_add_report_target) 