cmake_minimum_required(VERSION 3.21)

include(${CMAKE_CURRENT_LIST_DIR}/cppcheck_analysis)
function(analyze_target_sources target)
    cppcheck_configure_analysis(${target})
endfunction(analyze_target_sources target)