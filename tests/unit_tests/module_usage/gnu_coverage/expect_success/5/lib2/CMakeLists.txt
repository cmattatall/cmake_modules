project(
    ${TEST_PROJECT_NAME}-lib2
    VERSION 0.1.2
    LANGUAGES C CXX
)

add_library(lib2)
target_sources(lib2 PRIVATE src/lib2.cpp)
target_include_directories(lib2 PUBLIC include)

GnuCoverage_target_add_coverage_definitions(
    TARGET lib2
)

add_executable(lib2_test_runner src/lib2_test_runner.cpp)
target_link_libraries(lib2_test_runner PRIVATE lib2)

GnuCoverage_add_report_target(                                            
    COVERAGE_TARGET     lib2_test_runner-coverage                                          
    TEST_RUNNER         lib2_test_runner
    POST_BUILD
    MIN_LINE_PERCENT 33 # This test is explicitly checking if we are properly measuring the coverage percentages for sub-modules
    MIN_FUNC_PERCENT 33 # This test is explicitly checking if we are properly measuring the coverage percentages for sub-modules                                  
)