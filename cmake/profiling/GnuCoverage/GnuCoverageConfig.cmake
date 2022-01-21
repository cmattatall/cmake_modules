# Copyright (c) 2012 - 2015, Lars Bilke
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
#
# 2012-01-31, Lars Bilke
# - Enable Code Coverage
#
# 2013-09-17, Joakim S�derberg
# - Added support for Clang.
# - Some additional usage instructions.
#
# USAGE:

# 0. (Mac only) If you use Xcode 5.1 make sure to patch geninfo as described here:
#      http://stackoverflow.com/a/22404544/80480
#
# 1. Copy this file into your cmake modules path.
#
# 2. Add the following line to your CMakeLists.txt:
#      INCLUDE(CodeCoverage)
#
# 3. Set compiler flags to turn off optimization and enable coverage:
#    set(CMAKE_CXX_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
#	 set(CMAKE_C_FLAGS "-g -O0 -fprofile-arcs -ftest-coverage")
#
# 3. Use the function setup_executable_for_coverage to create a custom make target
#    which runs your test executable and produces a lcov code coverage report:
#    Example:
#	 setup_executable_for_coverage(
#				my_coverage_target  # Name for custom target.
#				test_driver         # Name of the test driver executable that runs the tests.
#									# NOTE! This should always have a ZERO as exit code
#									# otherwise the coverage generation will not complete.
#				coverage            # Name of output directory.
#				)
#
# 4. Build a Debug build:
#	 cmake -DCMAKE_BUILD_TYPE=Debug ..
#	 make
#	 make my_coverage_target
#
#

macro(GnuCoverage_setup)
    
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
endmacro(GnuCoverage_setup)


# Param _targetname     The name of new the custom make target
# Param _testrunner     The name of the target which runs the tests.
#						MUST return ZERO always, even on errors.
#						If not, no coverage report will be created!
# Param _outputname     lcov output is generated as _outputname.info
#                       HTML report is generated in _outputname/index.html
# Optional fourth parameter is passed as arguments to _testrunner
# Pass them in list form, e.g.: "-j;2" for -j 2

macro(GnuCoverage_remove_by_pattern pattern)
    set(LCOV_REMOVE "${LCOV_REMOVE};${pattern}")
endmacro(GnuCoverage_remove_by_pattern pattern)

function(GnuCoverage_setup_executable_for_coverage _targetname _testrunner _outputname)

    target_link_libraries(${_targetname} PRIVATE gcov)

	if(NOT LCOV_EXE_PATH)
		message(FATAL_ERROR "lcov not found! Aborting...")
	endif(NOT LCOV_EXE_PATH) 

	if(NOT GENHTML_EXE_PATH)
		message(FATAL_ERROR "genhtml not found! Aborting...")
	endif(NOT GENHTML_EXE_PATH)
    
	set(COVERAGE_INFO_FILE "${PROJECT_BINARY_DIR}/${_outputname}.info")
	set(COVERAGE_INFO_FILE_CLEANED "${COVERAGE_INFO_FILE}.cleaned")
  
	separate_arguments(test_command UNIX_COMMAND "${_testrunner}")

    if(IS_DIRECTORY ${PROJECT_BINARY_DIR}/_deps)
        list(APPEND LCOV_REMOVE ${PROJECT_BINARY_DIR}/_deps)
        list(APPEND LCOV_REMOVE ${PROJECT_BINARY_DIR}/_deps/*)
    endif(IS_DIRECTORY ${PROJECT_BINARY_DIR}/_deps)

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

    # Setup target
	add_custom_target(
        ${_targetname} ${LCOV_EXE_PATH} --directory ${PROJECT_BINARY_DIR} --zerocounters # Cleanup lcov
		COMMAND ${test_command} ${ARGV3} # Run tests

		# Capturing lcov counters and generating report
		COMMAND ${LCOV_EXE_PATH} --directory ${PROJECT_BINARY_DIR} --capture --output-file ${COVERAGE_INFO_FILE}  --exclude "\"${PROJECT_BINARY_DIR}/*\""
		COMMAND ${LCOV_EXE_PATH} --remove ${COVERAGE_INFO_FILE} ${LCOV_REMOVE}  '/usr/*' '${PROJECT_SOURCE_DIR}/tests/*' --output-file ${COVERAGE_INFO_FILE_CLEANED}
		COMMAND ${GENHTML_EXE_PATH} -o ${_outputname} ${COVERAGE_INFO_FILE_CLEANED}
		WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
		COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report.\nOpen ${PROJECT_BINARY_DIR}/${_outputname}/coverage_report.html in your browser to view the coverage report."
        USES_TERMINAL
	)

    set(REPORT_SUMMARY_FILE ${PROJECT_BINARY_DIR}/${_outputname}/coverage_summary.txt)
    set(COVERAGE_REPORT_FILE ${PROJECT_BINARY_DIR}/${_outputname}/lcov_coverage_report.html) 
    add_custom_command(
        TARGET ${_targetname}
        POST_BUILD

        # TODO: 
        # This is terrible because i/o redirection doesnt work on many platforms (e.g. Windows)
        #                                                                |
        #                                                                |
        #                                                                v
        COMMAND ${LCOV_EXE_PATH} --summary ${COVERAGE_INFO_FILE_CLEANED} > ${REPORT_SUMMARY_FILE}
        COMMAND ${CMAKE_COMMAND} -E rename ${PROJECT_BINARY_DIR}/${_outputname}/index.html ${COVERAGE_REPORT_FILE}
        COMMAND ${CMAKE_COMMAND} -E remove ${COVERAGE_INFO_FILE} ${COVERAGE_INFO_FILE_CLEANED}
        MAIN_DEPENDENCY ${COVERAGE_INFO_FILE_CLEANED}
        DEPENDS ${COVERAGE_INFO_FILE_CLEANED} ${COVERAGE_INFO_FILE}
        BYPRODUCTS ${REPORT_SUMMARY_FILE} ${COVERAGE_REPORT_FILE}
		WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        COMMENT "Performing post-build tasks for target \"${_targetname}\""
        USES_TERMINAL
    )
endfunction(GnuCoverage_setup_executable_for_coverage _targetname _testrunner _outputname) # setup_executable_for_coverage