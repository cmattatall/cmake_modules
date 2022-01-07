cmake_minimum_required(VERSION 3.21)

include(${CMAKE_CURRENT_LIST_DIR}/gtest/gtest_setup.cmake)


function(testing_discover_tests test_runner_target)
    gtest_discover_tests(${test_runner_target})
endfunction(testing_discover_tests test_runner_target)
