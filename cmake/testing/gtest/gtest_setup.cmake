cmake_minimum_required(VERSION 3.21)
################################################################################
# 
# CMake module file to import gtest + gmock and produce a 
# linkable target called "testing_framework" and a test discovery function called
# "testing_framework_discover_tests".
#
################################################################################
#   EXAMPLE USAGE:
#
#   # This example assumes that you have this file present 
#   # in your CMAKE_MODULE_PATH. If you do not, you should insert a call to 
#   # list(INSERT CMAKE_MODULE_PATH 0 ${PROJECT_SOURCE_DIR}/cmake)
#   # before any calls to include(...)
#   # In the above call to list(INSERT), this file would be called 
#   # "fetch-gtest.cmake" and would be located at
#   # ${PROJECT_SOURCE_DIR}/cmake/fetch-gtest.cmake
#   
#   cmake_minimum_required(VERSION 3.whatever)
#   project(example_gtest_cmake_module_usage)
#   include(fetch-gtest.cmake)
#   add_library(lib_to_test)
#   target_sources(lib_to_test 
#       PUBLIC 
#           lib_to_test_sourcefile2.cpp 
#           lib_to_test_sourcefile2.cpp
#       )
#   
#   add_executable(unit_tests)
#   target_sources(unit_tests PRIVATE unit_test_sourcefile1.cpp)
#   
#   include(fetch-gtest)
#   testing_framework_discover_tests(unit_tests)
#   
################################################################################
#   
# If gtest and gmock are not present on disk when this is invoked, they are 
# built from source. An unfortunate consequence of this is that the cmake
# targets from the package are not the same as those when the library is 
# built from source.
# 
# When built from source, we get targets:
#   - gtest_main
#   - gtest
#   - gmock
#
# When imported using find_package, we get targets:
#   - GTest::Main   
#   - GTest::GTest <--- this contains the gmock stuff
#
# Thus, this module file provides an interface target called testing_framework
# and a function testing_framework_discover_tests that is meant to be linked
# against using target_link_libraries as an alias target. 
#
################################################################################

add_library(testing_framework INTERFACE)

message(STATUS "Checking for package \"GTest\" ... ")
find_package(GTest)
include(GoogleTest)
if(NOT GTest_FOUND)
    message(STATUS "Package \"GTest\" not found on disk. Downloading and building from source now ... ")
    find_package(Git REQUIRED)
    include(FetchContent)
    set(FETCHCONTENT_QUIET OFF)

    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG        2f80c2ba71c0e8922a03b9b855e5b019ad1f7064 # release-1.10.0
    )
    FetchContent_MakeAvailable(googletest)


    target_link_libraries(testing_framework 
        INTERFACE 
            gtest_main 
            gtest
            gmock
    )

    # Disable linting and static analysis on third-party library sources.
    set_target_properties(testing_framework PROPERTIES CXX_CLANG_TIDY "")

else()
    message(STATUS "Ok.")
    message(STATUS "") # stdout formatting

    target_link_libraries(testing_framework 
        INTERFACE 
            GTest::Main 
            GTest::GTest
    )
endif(NOT GTest_FOUND)


function(testing_framework_discover_tests test_runner_target)
    gtest_discover_tests(${test_runner_target})
endfunction(testing_framework_discover_tests test_runner_target)
