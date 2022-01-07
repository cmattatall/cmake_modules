cmake_minimum_required(VERSION 3.21)

find_program(CLANG_TIDY_BIN NAMES clang-tidy)
if(CLANG_TIDY_BIN STREQUAL CLANG_TIDY_BIN-NOTFOUND)
    message(WARNING "Cannot configure clang-tidy integration because clang-tidy executable not found on disk.")
else()  
    set(CLANG_TIDY_EXE ${CLANG_TIDY_BIN})
    set(CLANG_TIDY_CHECKS "--checks=*")
    set(CLANG_TIDY_WARNINGS_AS_ERRORS "") # empty list for now. Add as needed

    set(CLANG_TIDY_COMMAND
        ${CLANG_TIDY_EXE}
        ${CLANG_TIDY_CHECKS}
    
    ) # empty list
    set(CMAKE_CXX_CLANG_TIDY ${CLANG_TIDY_COMMAND} CACHE STRING "" FORCE)
endif(CLANG_TIDY_BIN STREQUAL CLANG_TIDY_BIN-NOTFOUND)
