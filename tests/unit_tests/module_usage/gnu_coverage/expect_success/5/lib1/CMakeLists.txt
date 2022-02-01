project(
    ${TEST_PROJECT_NAME}-lib1
    VERSION 0.1.2
    LANGUAGES C CXX
)


add_library(lib1)
target_sources(lib1 PRIVATE src/lib1.cpp)
target_include_directories(lib1 PUBLIC include)

GnuCoverage_target_add_coverage_definitions(
    TARGET lib1
)



add_executable(lib1_test_runner src/lib1_test_runner.cpp)
target_link_libraries(lib1_test_runner PRIVATE lib1)

GnuCoverage_add_report_target(                                            
    COVERAGE_TARGET     lib1_test_runner-coverage                                          
    TEST_RUNNER         lib1_test_runner
    POST_BUILD           
    MIN_LINE_PERCENT 66 # This test is explicitly checking if we are properly measuring the coverage percentages for sub-modules
    MIN_FUNC_PERCENT 66 # This test is explicitly checking if we are properly measuring the coverage percentages for sub-modules                                
)
