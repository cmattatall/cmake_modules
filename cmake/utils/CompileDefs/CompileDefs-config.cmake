cmake_minimum_required(VERSION 3.21)

function(util_target_compile_definitions_COMMON target mode)
    target_compile_options(${target} ${mode} -Wall)
    target_compile_options(${target} ${mode} -Wextra)
    target_compile_options(${target} ${mode} -Wshadow)
endfunction(util_target_compile_definitions_COMMON target mode)


function(util_target_compile_definitions_CXX_CORE target mode)
    util_target_compile_definitions_COMMON(${target} ${mode})
    target_compile_options(${target} ${mode} -Wnon-virtual-dtor)
endfunction(util_target_compile_definitions_CXX_CORE target mode)


function(util_target_compile_definitions_C_CORE target mode)
    util_target_compile_definitions_COMMON(${target} ${mode})
endfunction(util_target_compile_definitions_C_CORE target mode)


function(util_target_compile_definitions_COVERAGE target mode)
    if(CMAKE_BUILD_TYPE STREQUAL Debug)
        if(CONFIGURE_TEST_COVERAGE)
            target_compile_options(${target} ${mode} -fprofile-arcs)
            target_compile_options(${target} ${mode} -ftest-coverage)
            target_compile_options(${target} ${mode} --coverage)
        else()
            message(STATUS "CONFIGURE_TEST_COVERAGE==OFF. Target ${target} will not have compile definitions added for code coverage profiling")
        endif(CONFIGURE_TEST_COVERAGE)
    else()
        message(WARNING "Not configuring target ${target} with compile definitions for code coverage. CMAKE_BUILD_TYPE is not \"Debug\"")
    endif(CMAKE_BUILD_TYPE STREQUAL Debug)
endfunction(util_target_compile_definitions_COVERAGE target)


function(util_target_compile_definitions_OPTIMIZE target mode)
    target_compile_options(${target} ${mode} -ffunction-sections)
    target_compile_options(${target} ${mode} -fdata-sections)

    
    # This actually causes a lot of link-stage failures. ESPECIALLY with PIC.
    # Enable and do the subsequent troubleshooting at your own will.
    # I will say that if your entire build is from-source, this can reduce your code 
    # size and execution time by as much as ~40% from the plain -O3 in certain cases.
    # 
    # Especially with -mtune=native - Carl
    #target_compile_options(${target} ${mode} -flto)
    #target_compile_options(${target} ${mode} -ffat-lto-objects)
    #target_compile_options(${target} ${mode} -fuse-linker-plugin)
endfunction(util_target_compile_definitions_OPTIMIZE target mode)