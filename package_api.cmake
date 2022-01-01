# Usage:
#
# package_add_library(
#    PACKAGE package 
#    TARGET target_name 
#    TYPE [ OBJECT | STATIC | SHARED ]
# )
function(package_add_library)
    set(OPTION_ARGS)
    set(SINGLE_VALUE_ARGS
        PACKAGE
        TARGET
        TYPE
    )
    set(MULTI_VALUE_ARGS)
    cmake_parse_arguments(args
        "${OPTION_ARGS}"
        "${SINGLE_VALUE_ARGS}"
        "${MULTI_VALUE_ARGS}"
        "${ARGN}"
    )
    message(DEBUG "In ${CMAKE_CURRENT_FUNCTION}, following arguments not parsed:")
    foreach(arg ${${args_UNPARSED_ARGUMENTS}})
        message("- ${arg}")
    endforeach(arg ${${args_UNPARSED_ARGUMENTS}})

    message(DEBUG "In ${CMAKE_CURRENT_FUNCTION}, following arguments are missing keywords:")
    foreach(arg ${${args_KEYWORDS_MISSING_VALUES}})
        message("- ${arg}")
    endforeach(arg ${${args_KEYWORDS_MISSING_VALUES}})

    message("TARGET=${arg_TARGET}")
    message("PACKAGE=${arg_PACKAGE}")
    message("TYPE=${arg_TYPE}")

    
endfunction(package_add_library)

