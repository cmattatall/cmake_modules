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
#    $ cd build                                                                #
#    $ make coverage-report                                                    #
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
    find_program(GCOV_EXECUTABLE    gcov    REQUIRED)
    find_program(LCOV_EXECUTABLE    lcov    REQUIRED)
    find_program(GENHTML_EXECUTABLE genhtml REQUIRED)
    find_program(GCOVR_EXECUTABLE   gcovr   REQUIRED)
    find_program(PYTHON_EXECUTABLE  python3 REQUIRED) 

    # TODO:
    #
    # Plan was to use the demangling tricks similar to 
    # https://github.com/edwincarlson/cmake-gtest-gcov-project-template/blob/master/cmake/CodeCoverage.cmake
    # 
    # Sadly, really haven't had time to get around to it yet
    # - ctm
    find_program( CPPFILT_EXECUTABLE NAMES c++filt) 

    if(NOT CMAKE_COMPILER_IS_GNUCXX)
        # Clang version 3.0.0 and greater now supports gcov as well.
        message(WARNING "Compiler is not GNU gcc! Clang Version 3.0.0 and greater supports gcov as well, but older versions don't.")

        if(NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
            message(FATAL_ERROR "Compiler is not GNU gcc! Aborting...")
        endif()
    endif() # NOT CMAKE_COMPILER_IS_GNUCXX

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

    # For more information, see link below:
    # https://gcc.gnu.org/onlinedocs/gcc-9.3.0/gcc/Instrumentation-Options.html
    target_compile_options(${_TARGET} PRIVATE -fprofile-arcs)
    target_compile_options(${_TARGET} PRIVATE -ftest-coverage)
    target_compile_options(${_TARGET} PRIVATE -fprofile-abs-path)
    target_compile_options(${_TARGET} PRIVATE --coverage)
    target_link_libraries(${_TARGET} PUBLIC gcov)

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
# @param:  _COVERAGE_FILENAME (@type VALUE) (@required true)
#          lcov output is generated as _COVERAGE_FILENAME.info
#          HTML report is generated in _COVERAGE_FILENAME/index.html
#
################################################################################
function(GnuCoverage_setup_executable_for_coverage _targetname _testrunner _COVERAGE_FILENAME)
    message(WARNING "${CMAKE_CURRENT_FUNCTION} is deprecated. Use GnuCoverage_add_report_target")
    GnuCoverage_add_report_target(
        COVERAGE_TARGET ${_targetname}
        TEST_RUNNER ${_testrunner} 
        COVERAGE_FILENAME ${_COVERAGE_FILENAME} 
        ${ARGN}
    )
endfunction(GnuCoverage_setup_executable_for_coverage _targetname _testrunner _COVERAGE_FILENAME)


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
#   [ MIN_LINE_PERCENT 50 ]
#   [ MIN_FUNC_PERCENT 67 ]
#   [ RUNNER_ARGS "--logging verbose --logfile foobar.log.txt" ] <-- important part is that the entire thing is quoted
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
# @param       RUNNER_ARGS
# @type        LIST
# @required    FALSE
# @description A quoted, internally-whitespace-delimited list of arguments 
#              to pass to the test runner
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
# @param       MINIMUM_LINE_PERCENT
# @type        VALUE
# @required    FALSE
# @description The minimum acceptable coverage percentage by line that will 
#              pass the build
#
# @param       MINUMUM_FUNCTION_PERCENT
# @type        VALUE
# @required    FALSE
# @description The minimum acceptable coverage percentage by function that will
#              pass the build
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
        MIN_LINE_PERCENT
        MIN_FUNC_PERCENT
    )

    ##########################
    # SET UP MULTIVALUE ARGS #
    ##########################
    set(MULTI_VALUE_ARGS-REQUIRED
        # Add your argument keywords here
    )
    set(MULTI_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
        RUNNER_ARGS
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
    set(COVERAGE_DIR-DEFAULT "${CMAKE_CURRENT_BINARY_DIR}/coverage")
    set(MIN_LINE_PERCENT-DEFAULT 50)
    set(MIN_FUNC_PERCENT-DEFAULT 50)

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

    target_link_libraries(${_TEST_RUNNER} PRIVATE gcov)


    if(NOT DEFINED _COVERAGE_DIR)
        message(FATAL_ERROR "_COVERAGE_DIR not defined (\${_COVERAGE_DIR}:\"{_COVERAGE_DIR}\"")
        return()
    endif(NOT DEFINED _COVERAGE_DIR)
    if(NOT IS_DIRECTORY ${_COVERAGE_DIR})
        file(MAKE_DIRECTORY ${_COVERAGE_DIR})
    endif(NOT IS_DIRECTORY ${_COVERAGE_DIR})


    # Get the full path to the test runner executable so we don't have 
    # to deal with working directory shenanigans in the custom targets.
    get_target_property(TEST_RUNNER_OUTPUT_DIR ${_TEST_RUNNER} BINARY_DIR )
    if(${TEST_RUNNER_OUTPUT_DIR} STREQUAL TEST_RUNNER_OUTPUT_DIR-NOTFOUND)
        message(FATAL_ERROR "Could not determine binary directory for target: ${_TEST_RUNNER}. Cannot determine an absolute path for the test runner executable ... Exiting!")
        return() # Explicit return just in case.
    endif(${TEST_RUNNER_OUTPUT_DIR} STREQUAL TEST_RUNNER_OUTPUT_DIR-NOTFOUND)

    get_target_property(TEST_RUNNER_OUTPUT_NAME ${_TEST_RUNNER} OUTPUT_NAME)
    if(TEST_RUNNER_OUTPUT_NAME STREQUAL TEST_RUNNER_OUTPUT_NAME-NOTFOUND)
        # If it doesn't have the property, its output name will just be the target name.
        set(TEST_RUNNER_OUTPUT_NAME ${_TEST_RUNNER}) 
    endif(TEST_RUNNER_OUTPUT_NAME STREQUAL TEST_RUNNER_OUTPUT_NAME-NOTFOUND)
    set(TEST_RUNNER_ABSPATH "${TEST_RUNNER_OUTPUT_DIR}/${TEST_RUNNER_OUTPUT_NAME}")

    # We can at least warn non-UNIX callers
    if(NOT UNIX)
        message(WARNING "Parsing test runner args : ${_RUNNER_ARGS} as a unix command. Parsing may fail due to your platform")
    endif(NOT UNIX)
    separate_arguments(PARSED_RUNNER_ARG_LIST UNIX_COMMAND "${_RUNNER_ARGS}")

    set(COVERAGE_INFO_FILE "${_COVERAGE_DIR}/${_COVERAGE_FILENAME}.info")
    set(COVERAGE_INFO_FILE_CLEANED "${COVERAGE_INFO_FILE}.cleaned")

    if(IS_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/_deps)
        list(APPEND LCOV_REMOVE ${CMAKE_CURRENT_BINARY_DIR}/_deps)
        list(APPEND LCOV_REMOVE ${CMAKE_CURRENT_BINARY_DIR}/_deps/*)
    endif(IS_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/_deps)

    if(FETCHCONTENT_BASE_DIR)
        if(EXISTS ${FETCHCONTENT_BASE_DIR})
            if(IS_DIRECTORY ${FETCHCONTENT_BASE_DIR})
                list(APPEND LCOV_REMOVE ${FETCHCONTENT_BASE_DIR}/*)                
            endif(IS_DIRECTORY ${FETCHCONTENT_BASE_DIR})
        endif(EXISTS ${FETCHCONTENT_BASE_DIR})
    endif(FETCHCONTENT_BASE_DIR)
    
    if(IS_DIRECTORY ${_COVERAGE_DIR}/codegen)
        list(APPEND LCOV_REMOVE ${_COVERAGE_DIR}/codegen)
        list(APPEND LCOV_REMOVE ${_COVERAGE_DIR}/codegen/*)
    endif(IS_DIRECTORY ${_COVERAGE_DIR}/codegen)


    set(COVERAGE_SUMMARY_FILE ${_COVERAGE_DIR}/coverage_summary.txt)
    set(COVERAGE_REPORT_FILE ${_COVERAGE_DIR}/report/coverage_report.html)
    message(DEBUG "COVERAGE_SUMMARY_FILE:${COVERAGE_SUMMARY_FILE}")
    message(DEBUG "COVERAGE_REPORT_FILE:${COVERAGE_REPORT_FILE}")

    set(COVERAGE_CREATION_COMMENT "\n")
    set(COVERAGE_CREATION_COMMENT "${COVERAGE_CREATION_COMMENT}- Resetting code coverage counters to zero ...\n- Done.\n")
    set(COVERAGE_CREATION_COMMENT "${COVERAGE_CREATION_COMMENT}- Processing code coverage counters and generating report...\n- Done.\n")
    set(COVERAGE_CREATION_COMMENT "${COVERAGE_CREATION_COMMENT}- To view the code coverage report in your browser, open ${COVERAGE_REPORT_FILE}.")
    
    add_custom_target(${_COVERAGE_TARGET}-reset
        ${LCOV_EXECUTABLE}  --directory ${_COVERAGE_DIR} --zerocounters # Cleanup lcov
        COMMENT "Resetting code coverage execution counters ..."
        WORKING_DIRECTORY ${_COVERAGE_DIR}
        USES_TERMINAL
    )

    add_custom_target(${_COVERAGE_TARGET}-execute
        COMMAND ${TEST_RUNNER_ABSPATH} ${PARSED_RUNNER_ARG_LIST}
        DEPENDS ${_TEST_RUNNER} ${_COVERAGE_TARGET}-reset
        COMMENT "Launching test runner(s) ..."
        WORKING_DIRECTORY ${_COVERAGE_DIR}
        USES_TERMINAL
    )

    # If we can find a way to index the .gcda files using cmake itself, 
    # then we don't have to constantly maintain multi-platform search support
    #
    # Note:
    # - We explicitly do not use CMAKE_CURRENT_BINARY_DIR when searching
    #       - it doesnt work in many cases depending on where the targets 
    #         that TEST_RUNNER has been linked against are defined/declared
    set(GCDA_SCRIPT "\n")
    set(GCDA_SCRIPT "${GCDA_SCRIPT}cmake_minimum_required(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})\n")
    set(GCDA_SCRIPT "${GCDA_SCRIPT}file(GLOB_RECURSE GCDA_FILES \"${CMAKE_BINARY_DIR}/*\.gcda\")\n") 
    set(GCDA_SCRIPT "${GCDA_SCRIPT}foreach(GCDA_FILE \${GCDA_FILES})\n")
    set(GCDA_SCRIPT "${GCDA_SCRIPT}\tget_filename_component(GCDA_FILENAME \${GCDA_FILE} NAME)\n")
    set(GCDA_SCRIPT "${GCDA_SCRIPT}\tfile(COPY_FILE \${GCDA_FILE} ${_COVERAGE_DIR}/\${GCDA_FILENAME})\n")
    set(GCDA_SCRIPT "${GCDA_SCRIPT}endforeach(GCDA_FILE \${GCDA_FILES})\n")
    set(GCDA_SCRIPT "${GCDA_SCRIPT}file(GLOB_RECURSE GCNO_FILES \"${CMAKE_BINARY_DIR}/*\.gcno\")\n")
    set(GCDA_SCRIPT "${GCDA_SCRIPT}foreach(GCNO_FILE \${GCNO_FILES})\n")
    set(GCDA_SCRIPT "${GCDA_SCRIPT}\tget_filename_component(GCNO_FILENAME \${GCNO_FILE} NAME)\n")
    set(GCDA_SCRIPT "${GCDA_SCRIPT}\tfile(COPY_FILE \${GCNO_FILE} ${_COVERAGE_DIR}/\${GCNO_FILENAME})\n")
    set(GCDA_SCRIPT "${GCDA_SCRIPT}endforeach(GCNO_FILE \${GCNO_FILES})\n")
    file(WRITE ${_COVERAGE_DIR}/gcda.cmake ${GCDA_SCRIPT})
    add_custom_command(
        TARGET ${_COVERAGE_TARGET}-execute
        POST_BUILD
        COMMAND ${CMAKE_COMMAND} -P ${_COVERAGE_DIR}/gcda.cmake
    )

    add_custom_target(${_COVERAGE_TARGET}-capture
        COMMAND ${LCOV_EXECUTABLE} --directory ${_COVERAGE_DIR} --capture --output-file ${COVERAGE_INFO_FILE} --exclude ${PROJECT_BINARY_DIR}/*
        DEPENDS ${_COVERAGE_TARGET}-execute
        COMMENT "Recording code paths traversed during execution of test runner ..."
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        USES_TERMINAL
    )

    add_custom_target(${_COVERAGE_TARGET}-clean
        COMMAND ${LCOV_EXECUTABLE} --remove ${COVERAGE_INFO_FILE} ${LCOV_REMOVE}  '/usr/*' '${PROJECT_SOURCE_DIR}/tests/*'  --output-file ${COVERAGE_INFO_FILE_CLEANED}
        DEPENDS ${_COVERAGE_TARGET}-capture
        COMMENT "Removing excluded filepaths from the coverage report ..."
        BYPRODUCTS ${COVERAGE_INFO_FILE_CLEANED}
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        USES_TERMINAL
    )

    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION} ], GENHTML_EXECUTABLE:${GENHTML_EXECUTABLE}")
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION} ], _COVERAGE_DIR:${_COVERAGE_DIR}" )
    message(DEBUG "[in ${CMAKE_CURRENT_FUNCTION} ], COVERAGE_INFO_FILE_CLEANED:${COVERAGE_INFO_FILE_CLEANED}" )

    set(REPORT_BUILD_GROUP) # empty var
    if(_POST_BUILD)
        set(REPORT_BUILD_GROUP ALL)
    endif(_POST_BUILD)


    get_filename_component(COVERAGE_REPORT_FILE_DIR ${COVERAGE_REPORT_FILE} DIRECTORY)
    add_custom_target(${_COVERAGE_TARGET}-report ${REPORT_BUILD_GROUP} # <--- This allows us to do the report generation at build time
        COMMAND ${GENHTML_EXECUTABLE} -o ${COVERAGE_REPORT_FILE_DIR} ${COVERAGE_INFO_FILE_CLEANED}
        COMMAND ${CMAKE_COMMAND} -E rename ${COVERAGE_REPORT_FILE_DIR}/index.html ${COVERAGE_REPORT_FILE}
        COMMENT "Generating html code coverage report ..."
        DEPENDS ${_COVERAGE_TARGET}-clean
        WORKING_DIRECTORY ${_COVERAGE_DIR}
        BYPRODUCTS ${COVERAGE_REPORT_FILE}
        USES_TERMINAL
    )

    # Enforce coverage checks
    if(UNIX)
        if(NOT APPLE)

            # TODO: FIX MEEE - this is suuuper disgusting and hacky
            # We want to leverage something in cmake but it's REALLY hard to get cmake to execute arbitrary cmake code AFTER the configure stage...
            find_program(GREP grep REQUIRED)
            find_program(AWK  awk  REQUIRED)
            find_program(CAT  cat  REQUIRED)
            find_program(BASH bash REQUIRED)
            find_program(SED  sed  REQUIRED)
            set(COVERAGE_SUMMARY_FILE_ABSPATH ${COVERAGE_SUMMARY_FILE})

            math(EXPR MIN_LINE_PERCENT_EVALUATED ${_MIN_LINE_PERCENT})
            set(LINE_COVERAGE_CHECK_SCRIPT_ABSPATH "${_COVERAGE_DIR}/line_coverage_check.sh")
            set(LINE_COVERAGE_CHECK_SCRIPT_CONTENT "#!/bin/bash\nMINIMUM_COVERAGE_PERCENT=\$(echo \"${MIN_LINE_PERCENT_EVALUATED}\" | ${SED} \'s/%//\'| ${AWK} \'BEGIN { FS=\".\" } { print \$1 }\')\nCOVERAGE_PERCENT=\$(${CAT} \"${COVERAGE_SUMMARY_FILE_ABSPATH}\" | ${GREP} \"%\" | ${GREP} lines | ${GREP} -o \".*%\" | ${AWK} \'{ print \$2}\' | ${SED} \'s/%//\' | ${AWK} \'BEGIN { FS=\".\" } { print \$1 }\')\nif [ \${MINIMUM_COVERAGE_PERCENT} -gt \${COVERAGE_PERCENT} ]\; then\n\techo \"Code coverage check failed! At least \${MINIMUM_COVERAGE_PERCENT}% of lines must be covered by execution of ${TEST_RUNNER_ABSPATH} to pass (Currently \${COVERAGE_PERCENT}%)\"\n\texit -1\nfi\necho \"Code coverage check passed (Currently \${COVERAGE_PERCENT}% lines covered by execution of ${TEST_RUNNER_ABSPATH})!\"\nexit 0")
            file(WRITE ${LINE_COVERAGE_CHECK_SCRIPT_ABSPATH} ${LINE_COVERAGE_CHECK_SCRIPT_CONTENT})
            file(CHMOD ${LINE_COVERAGE_CHECK_SCRIPT_ABSPATH} 
                PERMISSIONS 
                    OWNER_EXECUTE OWNER_WRITE OWNER_READ
                    GROUP_EXECUTE GROUP_WRITE GROUP_READ
                    WORLD_READ        
            )

            math(EXPR MIN_FUNC_PERCENT_EVALUATED ${_MIN_FUNC_PERCENT})
            set(FUNCTION_COVERAGE_CHECK_SCRIPT_ABSPATH "${_COVERAGE_DIR}/function_coverage_check.sh")
            set(FUNCTION_COVERAGE_CHECK_SCRIPT_CONTENT "#!/bin/bash\nMINIMUM_COVERAGE_PERCENT=\$(echo \"${MIN_FUNC_PERCENT_EVALUATED}\" | ${SED} \'s/%//\'| ${AWK} \'BEGIN { FS=\".\" } { print \$1 }\')\nCOVERAGE_PERCENT=\$(${CAT} \"${COVERAGE_SUMMARY_FILE_ABSPATH}\" | ${GREP} \"%\" | ${GREP} functions | ${GREP} -o \".*%\" | ${AWK} \'{ print \$2}\' | ${SED} \'s/%//\' | ${AWK} \'BEGIN { FS=\".\" } { print \$1 }\')\nif [ \${MINIMUM_COVERAGE_PERCENT} -gt \${COVERAGE_PERCENT} ]\; then\n\techo \"Code coverage check failed! At least \${MINIMUM_COVERAGE_PERCENT}% of functions must be covered by execution of ${TEST_RUNNER_ABSPATH} to pass (Currently \${COVERAGE_PERCENT}%)\"\n\texit -1\nfi\necho \"Code coverage check passed (Currently \${COVERAGE_PERCENT}% functions covered by execution of ${TEST_RUNNER_ABSPATH})!\"\nexit 0")
            file(WRITE ${FUNCTION_COVERAGE_CHECK_SCRIPT_ABSPATH} ${FUNCTION_COVERAGE_CHECK_SCRIPT_CONTENT})
            file(CHMOD ${FUNCTION_COVERAGE_CHECK_SCRIPT_ABSPATH} 
                PERMISSIONS 
                    OWNER_EXECUTE OWNER_WRITE OWNER_READ
                    GROUP_EXECUTE GROUP_WRITE GROUP_READ
                    WORLD_READ        
            )

            add_custom_target(${_COVERAGE_TARGET}-check ALL
                COMMAND ${LCOV_EXECUTABLE} --summary ${COVERAGE_INFO_FILE_CLEANED} > ${COVERAGE_SUMMARY_FILE_ABSPATH}
                COMMAND ${LINE_COVERAGE_CHECK_SCRIPT_ABSPATH}
                COMMAND ${FUNCTION_COVERAGE_CHECK_SCRIPT_ABSPATH}
                COMMAND ${CMAKE_COMMAND} -E remove ${COVERAGE_INFO_FILE} ${COVERAGE_INFO_FILE_CLEANED}
                DEPENDS ${_COVERAGE_TARGET}-clean
                COMMENT "Generating code coverage summary file and checking code coverage requirements ..."
                BYPRODUCTS ${COVERAGE_SUMMARY_FILE_ABSPATH}
                WORKING_DIRECTORY ${_COVERAGE_DIR}
                USES_TERMINAL
            )

            # Technically, not a dependency 
            # - BUT since we could be executing in a post-build context, the coverage check
            #   target can fail the build. This means that we must ensure the report gets 
            #   built BEFORE the coverage check is performed. 
            # 
            #   The easiest way to do that is with a direct dependency.
            add_dependencies(${_COVERAGE_TARGET}-check ${_COVERAGE_TARGET}-report)


        else()
            message(WARNING "${CMAKE_CURRENT_FUNCTION} currently does not support Apple systems. Code coverage will not be enforced.")
            return()
        endif(NOT APPLE)
    else()
        message(WARNING "${CMAKE_CURRENT_FUNCTION} currently does not support non-UNIX systems. Code coverage will not be enforced.")
        return()
    endif(UNIX)
    
endfunction(GnuCoverage_add_report_target) 
