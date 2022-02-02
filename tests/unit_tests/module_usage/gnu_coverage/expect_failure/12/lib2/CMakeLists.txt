project(
    ${TEST_PROJECT_NAME}-lib2
    VERSION 0.1.2
    LANGUAGES C CXX
)

add_library(lib2)
target_sources(lib2 PRIVATE src/lib2.cpp)
target_include_directories(lib2 PUBLIC include)


add_executable(lib2_test_runner src/lib2_test_runner.cpp)
target_link_libraries(lib2_test_runner PRIVATE lib2)

set(EXPECTED_COVERAGE 36) # There is 33% coverage in lib2 so we expect this test to fail
GnuCoverage_add_report_target(                                            
    COVERAGE_TARGET     lib2_test_runner-coverage                                          
    TEST_RUNNER         lib2_test_runner
    TARGETS             lib2
    POST_BUILD
    MIN_LINE_PERCENT ${EXPECTED_COVERAGE} 
    MIN_FUNC_PERCENT ${EXPECTED_COVERAGE}
)


configure_file(check-lib2-coverage.in.sh ${CMAKE_CURRENT_BINARY_DIR}/check-lib2-coverage.sh @ONLY)
file(CHMOD ${CMAKE_CURRENT_BINARY_DIR}/check-lib2-coverage.sh 
    PERMISSIONS
        OWNER_EXECUTE OWNER_WRITE OWNER_READ
        GROUP_EXECUTE GROUP_WRITE GROUP_READ
        WORLD_EXECUTE WORLD_WRITE WORLD_READ
)
add_custom_target(lib2-test-coverage ALL)
add_custom_command(TARGET lib2-test-coverage
    POST_BUILD
    COMMAND ./check-lib2-coverage.sh
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)
add_dependencies(lib2-test-coverage GnuCoverage)