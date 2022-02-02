project(
    ${TEST_PROJECT_NAME}-lib1
    VERSION 0.1.2
    LANGUAGES C CXX
)


add_library(lib1)
target_sources(lib1 PRIVATE src/lib1.cpp)
target_include_directories(lib1 PUBLIC include)



# If you look at the source code for the test 
# runner, less than 50% of lines and functions are covered. 
# This test should fail because the default minimum coverage is 50% 
# when arguments MIN_LINE_PERCENT and MIN_FUNC_PERCENT are unspecified.
add_executable(lib1_test_runner src/lib1_test_runner.cpp)

GnuCoverage_add_report_target(                                            
    COVERAGE_TARGET     lib1_test_runner-coverage                                          
    TEST_RUNNER         lib1_test_runner
    TARGETS             lib1
    POST_BUILD                                        
)
