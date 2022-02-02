project(
    ${TEST_PROJECT_NAME}-lib2
    VERSION 0.1.2
    LANGUAGES C CXX
)

add_library(lib2)
target_sources(lib2 PRIVATE src/lib2.cpp)
target_include_directories(lib2 PUBLIC include)


add_executable(lib2_test_runner src/lib2_test_runner.cpp)

# If you look at the source code for the test 
# runner, less than 50% of lines and functions are covered. 
# This test should fail because the default minimum coverage is 50% 
# when arguments MIN_LINE_PERCENT and MIN_FUNC_PERCENT are unspecified.
GnuCoverage_add_report_target(                                            
    COVERAGE_TARGET     lib2_test_runner-coverage                                          
    TEST_RUNNER         lib2_test_runner
    TARGETS             lib2
    POST_BUILD                                        
)