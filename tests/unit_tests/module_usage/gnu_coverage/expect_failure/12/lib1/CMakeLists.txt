project(
    ${TEST_PROJECT_NAME}-lib1
    VERSION 0.1.2
    LANGUAGES C CXX
)


add_library(lib1)
target_sources(lib1 PRIVATE src/lib1.cpp)
target_include_directories(lib1 PUBLIC include)


set(EXPECTED_COVERAGE 66) # We expect this to pass (but lib2 to fail because it has 33% coverage and the min is set at 36)
add_executable(lib1_test_runner src/lib1_test_runner.cpp)
GnuCoverage_add_report_target(                                            
    COVERAGE_TARGET     lib1_test_runner-coverage                                          
    TEST_RUNNER         lib1_test_runner
    TARGETS             lib1
    POST_BUILD           
    MIN_LINE_PERCENT ${EXPECTED_COVERAGE}
    MIN_FUNC_PERCENT ${EXPECTED_COVERAGE}
)

configure_file(check-lib1-coverage.in.sh ${CMAKE_CURRENT_BINARY_DIR}/check-lib1-coverage.sh @ONLY)
file(CHMOD ${CMAKE_CURRENT_BINARY_DIR}/check-lib1-coverage.sh 
    PERMISSIONS
        OWNER_EXECUTE OWNER_WRITE OWNER_READ
        GROUP_EXECUTE GROUP_WRITE GROUP_READ
        WORLD_EXECUTE WORLD_WRITE WORLD_READ
)
add_custom_target(lib1-test-coverage ALL)
add_custom_command(TARGET lib1-test-coverage
    POST_BUILD
    COMMAND ./check-lib1-coverage.sh
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
add_dependencies(lib1-test-coverage GnuCoverage)