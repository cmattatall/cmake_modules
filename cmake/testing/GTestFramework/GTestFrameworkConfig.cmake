cmake_minimum_required(VERSION 3.21)
################################################################################
# 
# CMake module file to import gtest + gmock and produce an INTERFACE target
# called "gtest_framework"
#
################################################################################
#   EXAMPLE USAGE:
#   
#   cmake_minimum_required(VERSION 3.whatever)
#   project(example_gtest_framework_usage)
#   find_package(GTestFramework REQUIRED)
#   GTestFramework_init()
#
#   add_library(lib_to_test)
#   target_sources(lib_to_test 
#       PUBLIC 
#           src_under_test1.cpp 
#           src_under_test2.cpp
#       )
#   
#   add_executable(unit_tests)
#   target_sources(unit_tests PRIVATE my_test_main.cpp)
#   target_link_libraries(unit_tests PRIVATE lib_to_test)
#
#   GTestFramework_discover_tests(unit_tests)
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
################################################################################


function(GTestFramework_init)
    if(NOT TARGET GTestFramework)
        add_library(GTestFramework INTERFACE)
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


            target_link_libraries(GTestFramework 
                INTERFACE 
                    gtest_main 
                    gtest
                    gmock
            )

            # Disable linting and static analysis on third-party library sources.
            set_target_properties(GTestFramework PROPERTIES CXX_CLANG_TIDY "")

        else()
            message(STATUS "Ok.")
            message(STATUS "") # stdout formatting

            target_link_libraries(GTestFramework 
                INTERFACE 
                    GTest::Main 
                    GTest::GTest
            )
        endif(NOT GTest_FOUND)

    endif(NOT TARGET GTestFramework)
endfunction(GTestFramework_init)



function(GTestFramework_discover_tests test_runner_executable)
    target_link_libraries(${test_runner_executable} PRIVATE GTestFramework)

    get_target_property(TEST_SOURCES ${test_runner_executable} SOURCES)
    message(DEBUG "TEST_SOURCES:${TEST_SOURCES}")
    if(NOT (TEST_SOURCES STREQUAL "TEST_SOURCES-NOTFOUND"))
        gtest_add_tests(
            TARGET ${test_runner_executable}
            SOURCES ${TEST_SOURCES}
        )
    endif(NOT (TEST_SOURCES STREQUAL "TEST_SOURCES-NOTFOUND"))

    get_target_property(INTERFACE_TEST_SOURCES ${test_runner_executable} INTERFACE_SOURCES)
    message(DEBUG "INTERFACE_TEST_SOURCES:${INTERFACE_TEST_SOURCES}")
    if(NOT (INTERFACE_TEST_SOURCES STREQUAL "INTERFACE_TEST_SOURCES-NOTFOUND"))
        gtest_add_tests(
            TARGET ${test_runner_executable}
            SOURCES ${INTERFACE_TEST_SOURCES}
        )
    endif(NOT (INTERFACE_TEST_SOURCES STREQUAL "INTERFACE_TEST_SOURCES-NOTFOUND"))

endfunction(GTestFramework_discover_tests test_runner_executable)
