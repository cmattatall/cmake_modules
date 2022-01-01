# Usage:
#
# package_add_library(
#    PACKAGE package 
#    TARGET target_name 
#    TYPE [ OBJECT | STATIC | SHARED ]
# )



function(package_add)
    set(OPTION_ARGS)
    set(SINGLE_VALUE_ARGS
        PACKAGE
        TARGET
        TYPE
    ) 
endfunction(package_add)




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
    
endfunction(package_add_library)

