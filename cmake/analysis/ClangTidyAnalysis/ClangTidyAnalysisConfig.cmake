cmake_minimum_required(VERSION 3.21)

function(ClangTidyAnalysis_check_initialized)
    if(NOT CLANG_TIDY_EXECUTABLE)
        message(FATAL_ERROR "CLANG_TIDY_EXECUTABLE not set. Please call ClangTidyAnalysis_init before other ClangTidyAnalysis functions")
    endif(NOT CLANG_TIDY_EXECUTABLE)
endfunction(ClangTidyAnalysis_check_initialized)


################################################################################
# @name: ClangTidyAnalysis_init
#
# @brief
# Initialize the ClangTidyAnalysis cmake module
#
# @note
# - Requires clang-tidy executable on disk
# - MUST be called before all other ClangTidyAnalysis functions
#
# @usage 
# ClangTidyAnalysis_init()
#
################################################################################
macro(ClangTidyAnalysis_init)
    find_program(CLANG_TIDY_EXECUTABLE NAMES clang-tidy)
    if(CLANG_TIDY_EXECUTABLE STREQUAL CLANG_TIDY_EXECUTABLE-NOTFOUND)
        message(WARNING "Could not find program clang-tidy on disk. ClangTidyAnalysis functions will fail.")
        set(CLANG_TIDY_EXECUTABLE "") # empty string
    endif(CLANG_TIDY_EXECUTABLE STREQUAL CLANG_TIDY_EXECUTABLE-NOTFOUND)
endmacro(ClangTidyAnalysis_init)




