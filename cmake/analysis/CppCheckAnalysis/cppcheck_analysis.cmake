cmake_minimum_required(VERSION 3.21)

# Mandatory preample
find_program(CPPCHECK_BIN NAMES cppcheck)
if(CPPCHECK_BIN STREQUAL CPPCHECK_BIN-NOTFOUND)
    message(WARNING "Cannot configure cppcheck integration because cppcheck not found on disk.")
    return()
endif(CPPCHECK_BIN STREQUAL CPPCHECK_BIN-NOTFOUND)

execute_process(COMMAND ${CPPCHECK_BIN} --version
    OUTPUT_VARIABLE CPPCHECK_VERSION
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

include(ProcessorCount)
ProcessorCount(N)
set(CPPCHECK_THREADS_ARG "-j${N}" CACHE STRING "The number of threads to use")


set(CPPCHECK_ERROR_EXITCODE_ARG "--error-exitcode=1" CACHE STRING "The exitcode to use if an error is found")
set(CPPCHECK_CHECKS_ARGS "--enable=warning" CACHE STRING "Arguments for the checks to run")

# Don't show these errors
if(EXISTS "${PROJECT_SOURCE_DIR}/.cppcheck_suppressions")
    set(CPPCHECK_SUPPRESSIONS_FILES "--suppressions-list=${PROJECT_SOURCE_DIR}/.cppcheck_suppressions" CACHE STRING "The suppressions file to use")
else()
    set(CPPCHECK_SUPPRESSIONS_FILES "" CACHE STRING "The suppressions file to use")
endif()

# Show these errors but don't fail the build
# These are mainly going to be from the "warning" category that is enabled by default later
if(EXISTS "${PROJECT_SOURCE_DIR}/.cppcheck_exitcode_suppressions")
    set(CPPCHECK_EXITCODE_SUPPRESSIONS "--exitcode-suppressions=${PROJECT_SOURCE_DIR}/.cppcheck_exitcode_suppressions" CACHE STRING "The exitcode suppressions file to use")
else()
    set(CPPCHECK_EXITCODE_SUPPRESSIONS "" CACHE STRING "The exitcode suppressions file to use")
endif()


function(cppcheck_configure_analysis target)
    if(NOT CONFIGURE_CPPCHECK)
        message(STATUS "Not configuring Target: ${target} for cppcheck")
        return()
    endif(NOT CONFIGURE_CPPCHECK)

    get_target_property(TARGET_SOURCES ${target} SOURCES)
    get_target_property(TARGET_INCLUDE_DIRS ${target} INCLUDE_DIRECTORIES)
    get_target_property(TARGET_CMAKE_SOURCE_DIR ${target} SOURCE_DIR)

    set(CPPCHECK_TARGET_SOURCES_ARG)
    foreach(source ${TARGET_SOURCES})
        list(APPEND CPPCHECK_TARGET_SOURCES_ARG "${TARGET_CMAKE_SOURCE_DIR}/${source}")
    endforeach(source ${TARGET_SOURCES})
    
    # we could get super fancy with generator expressions .... 
    # e.g. "-I$<JOIN:$<TARGET_PROPERTY:foo,INCLUDE_DIRECTORIES>,;-I>"
    #
    # Or... we could just do it the sane way and manually append so that a 
    # future reader will actually understand what is happening here...
    set(CPPCHECK_INCLUDE_DIRS_ARG "") 
    foreach(IDIR ${TARGET_INCLUDE_DIRS})
        set(CPPCHECK_INCLUDE_DIRS_ARG "${CPPCHECK_INCLUDE_DIRS_ARG} -I${IDIR}")
    endforeach(IDIR ${TARGET_INCLUDE_DIRS})

    set(CPPCHECK_OPTION_ARGS 
        ${CPPCHECK_CHECKS_ARGS}
        ${CPPCHECK_THREADS_ARG}
        ${CPPCHECK_ERROR_EXITCODE_ARG}
        ${CPPCHECK_SUPPRESSIONS_FILES}
        ${CPPCHECK_EXITCODE_SUPPRESSIONS}
    )
    
    set(TARGET_CPPCHECK_XML_OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/reports/${target}.xml)
    get_filename_component(TARGET_CPPCHECK_REPORT_OUTPUT_DIR ${TARGET_CPPCHECK_XML_OUTPUT} DIRECTORY)
    if(NOT EXISTS ${TARGET_CPPCHECK_REPORT_OUTPUT_DIR})
        file(MAKE_DIRECTORY ${TARGET_CPPCHECK_REPORT_OUTPUT_DIR})
    endif(NOT EXISTS ${TARGET_CPPCHECK_REPORT_OUTPUT_DIR})

    set(CPPCHECK_COMMAND 
        ${CPPCHECK_BIN}
        ${CPPCHECK_OPTION_ARGS}
        ${CPPCHECK_TARGET_SOURCES_ARG}
        --xml 
        --xml-version=2
        2> ${TARGET_CPPCHECK_XML_OUTPUT}
    )

    list(LENGTH TARGET_SOURCES TARGET_SOURCES_LENGTH)
    if(NOT TARGET_SOURCES_LENGTH STREQUAL 0)
        add_custom_target(${target}-cppcheck 
            ALL # this needs to be here. putting ALL bundles this target into the default build group. Without doing this, we would have 
            COMMENT "Performing cppcheck static analysis on sources for target: ${target}"
            COMMAND ${CPPCHECK_COMMAND}
            DEPENDS ${target}
        )

        # DON'T DO THE HTML REPORT GENERATION. IT SEEMS THAT CPPCHECK-HTML-REPORT IS STILL IN A VERY UNSTABLE DEVELOPMENT PHASE
        #[[
        # We can also convert the xml file into an html report so that it can be viewed in the browswer
        set(CPPCHECK_HTML_REPORT_SOURCE_DIR ${TARGET_CMAKE_SOURCE_DIR})
        set(CPPCHECK_HTML_REPORT_TITLE "${target} cppcheck report")
        set(CPPCHECK_HTML_REPORT_XML_INPUT ${TARGET_CPPCHECK_XML_OUTPUT})
        set(CPPCHECK_HTML_REPORT_OUTPUT_DIR ${TARGET_CPPCHECK_REPORT_OUTPUT_DIR})
        cppcheck_generate_html_report(
            ${target} 
            ${CPPCHECK_HTML_REPORT_XML_INPUT} 
            ${CPPCHECK_HTML_REPORT_SOURCE_DIR}
            ${CPPCHECK_HTML_REPORT_OUTPUT_DIR}
            ${CPPCHECK_HTML_REPORT_TITLE}
        )
        #]]

        endif(NOT TARGET_SOURCES_LENGTH STREQUAL 0)
endfunction(cppcheck_configure_analysis target)



function(cppcheck_generate_html_report target cppcheck_xml_file source_code_dir report_output_dir report_title)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} is not currently working. The formatting of the output html file is broken in several browsers.")

    if(NOT TARGET ${target}-cppcheck)
        message(WARNING "Cannot configure cppcheck html report for target: ${target}. Reason: target:${target} does not exist as a cmake target.")
        return()
    endif(NOT TARGET ${target}-cppcheck)

    find_program(CPPCHECK_HTML_REPORT_BIN NAMES cppcheck-htmlreport)
    if(CPPCHECK_HTML_REPORT_BIN STREQUAL CPPCHECK_HTML_REPORT_BIN-NOTFOUND)
        message(WARNING "Cannot configure cppcheck-htmlreport with the existing cppcheck integration because cppcheck-htmlreport not found on disk.")
        return()
    endif(CPPCHECK_HTML_REPORT_BIN STREQUAL CPPCHECK_HTML_REPORT_BIN-NOTFOUND)
    
    set(CPPCHECK_HTML_REPORT_COMMAND
        ${CPPCHECK_HTML_REPORT_BIN}
        --source-dir=${source_code_dir}
        --title=${report_title}
        --file=${cppcheck_xml_file}
        --report-dir=${report_output_dir}
    )

    add_custom_target(${target}-cppcheck-html-report
        ALL 
        COMMENT "Generating cppcheck html report for target: ${target}"
        COMMAND ${CPPCHECK_HTML_REPORT_COMMAND}
        WORKING_DIRECTORY ${}
        DEPENDS ${target}-cppcheck
    )
    
endfunction(cppcheck_generate_html_report target cppcheck_xml_file source_code_dir report_output_dir report_title)
