cmake_minimum_required(VERSION 3.10) 

macro(GraphvizDocugen_init)
    
endmacro(GraphvizDocugen_init)


################################################################################
# @name: GraphvizDocugen_make_target_Graph
#
# @brief
# Create an output png for the target dependency graph
#
# @note
# - Required "dot" executable installed on your system
#
# @usage 
# GraphvizDocugen_make_target_graph(
#   [ TARGET_PREFIX graphviz ] 
#   [ OUTPUT_PNG targets.png ] 
#   [ DOTFILE graph.dot ] 
# )
#
# @param       TARGET_PREFIX
# @type        VALUE
# @required    FALSE
# @description The prefix to use for graphviz targets to prevent target name collision. Default = graphviz
#
#
# @param       OUTPUT_PNG
# @type        VALUE
# @required    FALSE
# @description The name of the output png 
#
#
# @param       DOTFILE
# @type        VALUE
# @required    FALSE
# @description The name of the generated dot file
#
################################################################################
function(GraphvizDocugen_make_target_graph)

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
    )
    set(SINGLE_VALUE_ARGS-OPTIONAL
        # Add your argument keywords here
        TARGET_PREFIX
        OUTPUT_PNG
        DOTFILE
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
    set(TARGET_PREFIX-DEFAULT graphviz)
    set(OUTPUT_PNG-DEFAULT targets.png)
    set(DOTFILE-DEFAULT graph.dot)

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

    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], _OUTPUT_PNG:\"${_OUTPUT_PNG}\"")
    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], _DOTFILE:\"${_DOTFILE}\"")
    message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], _TARGET_PREFIX:\"${_TARGET_PREFIX}\"")

    if(NOT _OUTPUT_PNG)
        message(FATAL_ERROR "There is a logic error in ${CMAKE_CURRENT_FUNCTION}. _OUTPUT_PNG not defined. Please contact the library maintainer")
    endif(NOT _OUTPUT_PNG)

    if(NOT _DOTFILE)
        message(FATAL_ERROR "There is a logic error in ${CMAKE_CURRENT_FUNCTION}. _DOTFILE not defined. Please contact the library maintainer")
    endif(NOT _DOTFILE)

    if(NOT _TARGET_PREFIX)
        message(FATAL_ERROR "There is a logic error in ${CMAKE_CURRENT_FUNCTION}. _TARGET_PREFIX not defined. Please contact the library maintainer")
    endif(NOT _TARGET_PREFIX)

    foreach(UNKNOWN_ARG ${_UNPARSED_ARGUMENTS})
        message(FATAL_ERROR "\"${CMAKE_CURRENT_FUNCTION}\" invoked with unknown argument: \"${UNKNOWN_ARG}\".\nArgs: ${ARGN}")
    endforeach(UNKNOWN_ARG ${_UNPARSED_ARGUMENTS})


    set(GRAPHVIZ_WORKDIR "${CMAKE_BINARY_DIR}")
    if(${CMAKE_VERSION} VERSION_GREATER "3.21.0")
        find_program(DOT_EXECUTABLE NAMES dot)
        message(DEBUG "[ in ${CMAKE_CURRENT_FUNCTION} ], DOT_EXECUTABLE\":${DOT_EXECUTABLE}\"")
        if(DOT_EXECUTABLE STREQUAL DOT_EXECUTABLE-NOTFOUND)
            message(WARNING "Cannot create graphviz visualization of software architecture because executable: ${DOT_EXECUTABLE} not found")
            return()
        endif(DOT_EXECUTABLE STREQUAL DOT_EXECUTABLE-NOTFOUND)
        message(DEBUG "DOT_EXECUTABLE:\"${DOT_EXECUTABLE}\"")

        set(DOTFILES_TARGET ${_TARGET_PREFIX}-dotfiles)
        if(TARGET ${DOTFILES_TARGET})
            message(FATAL_ERROR "Target: \"${DOTFILES_TARGET}\" already exists.")
        endif(TARGET ${DOTFILES_TARGET})


        add_custom_target(${DOTFILES_TARGET}
            COMMENT "Generating dot files from cmake targets ... "
            COMMAND ${CMAKE_COMMAND} "--graphviz=${_DOTFILE}" .
            COMMAND ${CMAKE_COMMAND} -E echo "Done."
            WORKING_DIRECTORY "${GRAPHVIZ_WORKDIR}"
        )

        set(DEPGRAPH_PNG_TARGET ${_TARGET_PREFIX}-png)
        if(TARGET ${DEPGRAPH_PNG_TARGET})
            message(FATAL_ERROR "Target: \"${DEPGRAPH_PNG_TARGET}\" already exists.")
        endif(TARGET ${DEPGRAPH_PNG_TARGET})
        add_custom_target(${DEPGRAPH_PNG_TARGET} ALL
            DEPENDS ${DOTFILES_TARGET}
            COMMENT "Generating target visualization using \"${DOT_EXECUTABLE}\" ... "
            COMMAND ${DOT_EXECUTABLE} -Tpng ${_DOTFILE} -o ${_OUTPUT_PNG}
            COMMAND ${CMAKE_COMMAND} -E echo "Done."
            COMMAND ${CMAKE_COMMAND} -E echo "Produced target dependency graph: ${GRAPHVIZ_WORKDIR}/${_OUTPUT_PNG}."
            WORKING_DIRECTORY "${GRAPHVIZ_WORKDIR}"
        )
        
        
        set(GRAPHVIZ_POSTBUILD_SCRIPT "${GRAPHVIZ_WORKDIR}/${DEPGRAPH_PNG_TARGET}-postbuild.cmake")
        set(SCRIPT_CONTENT "\n")
        set(SCRIPT_CONTENT "${SCRIPT_CONTENT}cmake_minimum_required(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})\n")
        set(SCRIPT_CONTENT "${SCRIPT_CONTENT}file(GLOB DOT_FILES \"${GRAPHVIZ_WORKDIR}/${_DOTFILE}\\.*\")\n")
        set(SCRIPT_CONTENT "${SCRIPT_CONTENT}message(\"DOT_FILES:>\${DOT_FILES}<\")\n")
        set(SCRIPT_CONTENT "${SCRIPT_CONTENT}file(REMOVE \${DOT_FILES})\n")
        file(WRITE "${GRAPHVIZ_POSTBUILD_SCRIPT}" "${SCRIPT_CONTENT}")
        add_custom_command(
            TARGET ${DEPGRAPH_PNG_TARGET}
            POST_BUILD
            DEPENDS DEPENDS ${DOTFILES_TARGET}
            COMMENT "Cleaning up intermediate files produced by target: \"${DOTFILES_TARGET}\" ... "
            COMMAND ${CMAKE_COMMAND} -P "${GRAPHVIZ_POSTBUILD_SCRIPT}"
            COMMAND ${CMAKE_COMMAND} -E remove "${GRAPHVIZ_POSTBUILD_SCRIPT}"
            COMMAND ${CMAKE_COMMAND} -E remove "${_DOTFILE}"
            COMMAND ${CMAKE_COMMAND} -E echo "Done."
            WORKING_DIRECTORY "${GRAPHVIZ_WORKDIR}"
        )

    else()
        message(WARNING "Cannot create graphviz visualization of software architecture. Not supported in cmake version : ${CMAKE_VERSION}")
    endif()
endfunction(GraphvizDocugen_make_target_graph)
