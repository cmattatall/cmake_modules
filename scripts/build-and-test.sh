#!/bin/bash
# Bash script to configure and test the project
ABORT_ON_FAILURE="ON" # change this to continue running even when a test fails
POST_TEST_CLEANUP="ON" # Set to "ON" to remove the build directory of tests
DEBUG_TESTS="OFF"       # Set to "ON" to enable a very verbose cmake configure and build output 

WORKDIR=$(pwd)
THIS_SCRIPT=$0
[ ! -d "${WORKDIR}/.git" ] && echo "$THIS_SCRIPT invoked from wrong working directory: $WORKDIR. Please invoke from the project root." && exit -1

# we use libjsoncpp as a an example transient dependency 
#(just printing a hello-world json) in some of the tests
set +e
dpkg --list | grep libjsoncpp-dev
if [ "$?" -ne "0" ]; then
    echo "libjsoncpp is not installed. It is required for the transient dependency tests."
    echo -e "Please install it with \$sudo apt-get update && sudo apt-get install -y libjsoncpp-dev"
    exit 0
fi

set -e

FAILED_POSITIVE_TESTS=()
FAILED_NEGATIVE_TESTS=()
FAILURE_COUNT=0

function run_test () {
    local TEST_CMAKE_SOURCE_DIR=${1:?"Error, no argument provided for TEST_CMAKE_SOURCE_DIR"}
    local TEST_CMAKE_BUILD_DIR=${2:?"Error, no argument provided for TEST_CMAKE_BUILD_DIR"}
    local TEST_LOGS_DIR=${3:?"Error, no argument provided for TEST_LOGS_DIR"}
    local EXPECT_RETURN_CODE=${4:?"Error, no argument provided for EXPECT_RETURN_CODE"} # if we pass ANY argument to this we should treat it as a negative test

    [ -d "${TEST_CMAKE_BUILD_DIR}" ] && rm -r "${TEST_CMAKE_BUILD_DIR}"
    local TEST_NAME=$(echo $(realpath ${TESTCASE_CMAKE_SOURCE_DIR} --relative-to=${WORKDIR}/tests) | sed 's/\//_/g')
    local TEST_LOGFILE="${TEST_LOGS_DIR}/${TEST_NAME}.log"
    [ -f "${TEST_LOGFILE}" ] && rm "${TEST_LOGFILE}"
    touch "${TEST_LOGFILE}"

    echo "" # formatting
    echo "Running test: ${TEST_NAME}"
    echo "TEST_CMAKE_SOURCE_DIR: ${TEST_CMAKE_SOURCE_DIR}"
    echo "TEST_CMAKE_BUILD_DIR: ${TEST_CMAKE_BUILD_DIR}"
    echo "TEST_LOGS_DIR: ${TEST_LOGS_DIR}"
    echo "EXPECT_RETURN_CODE:${EXPECT_RETURN_CODE}"
    echo "" # formatting

    local CMAKE_TEST_LOG_LEVEL="notice"
    if [ "${DEBUG_TESTS}" == "ON" ]; then
        CMAKE_TEST_LOG_LEVEL="debug"
    fi

    set -o pipefail # If you don't do this, tee will "succeed" despite the command being piped to it failing
    cmake \
        -S "${TESTCASE_CMAKE_SOURCE_DIR}" \
        -B "${TESTCASE_CMAKE_BUILD_DIR}" \
        -DCMAKE_PREFIX_PATH="${TEST_SUITE_PROJECT_CMAKE_MODULE_PATH}" \
        -DSOURCE_CODE_DIR_ABSOLUTE=$(realpath ${WORKDIR}/tests/src) \
        -DHEADER_FILE_DIR_ABSOLUTE=$(realpath ${WORKDIR}/tests/include) \
        -DTESTS_ROOT_DIR_ABSOLUTE=$(realpath ${WORKDIR}/tests) \
        --no-warn-unused-cli \
        --log-level=${CMAKE_TEST_LOG_LEVEL} \
        | tee --append "${TEST_LOGFILE}" \
    && \
    cmake \
        --build "${TESTCASE_CMAKE_BUILD_DIR}" \
        | tee --append "${TEST_LOGFILE}"
    local TEST_RESULT="$?"
    set +o pipefail

    if [ "${EXPECT_RETURN_CODE}" == "0" ]; then
        # Positive test should return 0
        if [ "$TEST_RESULT" != "0" ]; then 
            echo "Test: ${TEST_NAME} failed. Expected a 0 return code, but got ${TEST_RESULT}. See "${TEST_LOGFILE}" for details."
            FAILED_POSITIVE_TESTS[${#FAILED_POSITIVE_TESTS[@]}]="${TEST_NAME}"
            ((FAILURE_COUNT=FAILURE_COUNT+1))
            if [ "$ABORT_ON_FAILURE" == "ON" ]; then
                exit -1
            fi
        else

            # Some of the tests may want us to try cpack after they build.
            # Even if the configure and build steps succeed, we may need to try cpack.
            #
            # An easy way to check for this is if there is a CPackConfig.cmake in the build tree
            if [ -f "${TEST_CMAKE_BUILD_DIR}/CPackConfig.cmake" ]; then

                mkdir tmp
                set -o pipefail
                cpack --config "${TEST_CMAKE_BUILD_DIR}/CPackConfig.cmake" -B tmp | tee --append "${TEST_LOGFILE}"
                TEST_CPACK_RESULT="$?"
                set +o pipefail
                rm -r tmp

                # Sadly, there is no --binary-dir option for cpack so we have to do our own cleanup :/
                if [ -d _CPack_Packages ]; then
                    rm -r _CPack_Packages
                fi

                if [ "$TEST_CPACK_RESULT" != "0" ]; then
                    echo "Post-build packaging for test: ${TEST_NAME} failed. Expected a 0 return code, but got ${TEST_CPACK_RESULT}. See "${TEST_LOGFILE}" for details."
                    FAILED_POSITIVE_TESTS[${#FAILED_POSITIVE_TESTS[@]}]="${TEST_NAME}"
                    ((FAILURE_COUNT=FAILURE_COUNT+1))
                    if [ "$ABORT_ON_FAILURE" == "ON" ]; then
                        exit -1
                    fi
                fi
            fi

        fi
    else 
        # Negative test should return ANYTHING but 0
        if [ "$TEST_RESULT" == "0" ]; then
            echo "Test: ${TEST_NAME} failed. Expected a NON-zero return code, but got ${TEST_RESULT}. See "${TEST_LOGFILE}" for details."
            FAILED_NEGATIVE_TESTS[${#FAILED_NEGATIVE_TESTS[@]}]="${TEST_NAME}"
            ((FAILURE_COUNT=FAILURE_COUNT+1))
            if [ "$ABORT_ON_FAILURE" == "ON" ]; then
                exit -1
            fi
        else

            # Some of the tests may want us to try cpack after they build.
            # Even if the configure and build steps succeed, we may need to try cpack.
            #
            # An easy way to check for this is if there is a CPackConfig.cmake in the build tree
            if [ -f "${TEST_CMAKE_BUILD_DIR}/CPackConfig.cmake" ]; then

                mkdir tmp
                set -o pipefail
                TEST_CPACK_RESULT=$(cpack --config "${TEST_CMAKE_BUILD_DIR}/CPackConfig.cmake" -B tmp | tee --append "${TEST_LOGFILE}")
                set +o pipefail
                rm -r tmp

                # Sadly, there is no --binary-dir option for cpack so we have to do our own cleanup :/
                if [ -d _CPack_Packages ]; then
                    rm -r _CPack_Packages
                fi

                if [ "$TEST_CPACK_RESULT" == "0" ]; then
                    echo "Post-build packaging for test: ${TEST_NAME} failed. Expected NON-zero return code, but got ${TEST_CPACK_RESULT}. See "${TEST_LOGFILE}" for details."
                    FAILED_POSITIVE_TESTS[${#FAILED_POSITIVE_TESTS[@]}]="${TEST_NAME}"
                    ((FAILURE_COUNT=FAILURE_COUNT+1))
                    if [ "$ABORT_ON_FAILURE" == "ON" ]; then
                        exit -1
                    fi
                fi
            fi

        fi
    fi            

    if [ "${POST_TEST_CLEANUP}" == "ON" ]; then
        echo "Performing post-test cleanup for ${TEST_NAME} ..."
        [ -f "${TEST_LOGFILE}" ] && rm "${TEST_LOGFILE}"
        [ -d "${TESTCASE_CMAKE_BUILD_DIR}" ] && rm -rf "${TESTCASE_CMAKE_BUILD_DIR}"
    fi
    
}



function run_tests () {

    local TEST_SUITE_PROJECT_CMAKE_MODULE_PATH=${1:?"Error: no argument provided for TEST_SUITE_PROJECT_CMAKE_MODULE_PATH"}
    echo "Using TEST_SUITE_PROJECT_CMAKE_MODULE_PATH: ${TEST_SUITE_PROJECT_CMAKE_MODULE_PATH}"

    local TEST_LOGGING_DIR="${WORKDIR}/tests/unit_tests/logs"
    [ ! -d "${TEST_LOGGING_DIR}" ] && mkdir -p "${TEST_LOGGING_DIR}"

    set +e
    for cmakelists in $(find tests -name "*CMakeLists\.txt"); do
    
        local TESTCASE_CMAKE_SOURCE_DIR=$(dirname ${cmakelists})
        local TESTCASE_CMAKE_BUILD_DIR="${TESTCASE_CMAKE_SOURCE_DIR}/build"

        local TEST_TYPE=$(echo $(basename $(dirname ${TESTCASE_CMAKE_SOURCE_DIR})) | sed 's/\//_/')
        if [ "${TEST_TYPE}" == "expect_success" ]; then
            run_test \
                "${TESTCASE_CMAKE_SOURCE_DIR}"  \
                "${TESTCASE_CMAKE_BUILD_DIR}"   \
                "${TEST_LOGGING_DIR}"           \
                0   

        elif [ "${TEST_TYPE}" == "expect_failure" ]; then
            run_test \
                "${TESTCASE_CMAKE_SOURCE_DIR}"  \
                "${TESTCASE_CMAKE_BUILD_DIR}"   \
                "${TEST_LOGGING_DIR}"           \
                -1
        else
            echo "Could not determine test type. Grandparent directory of ${cmakelists} must be \"expect_failure\" or \"expect_success\"."
        fi
    done
    set -e

    if [ ${FAILURE_COUNT} -gt 0 ]; then
        echo "The following tests failed:"
        for FAILED_POSITIVE_TEST in ${FAILED_POSITIVE_TEST[@]}; do
            echo " - ${FAILED_POSITIVE_TEST} (expected success, got failure)"
        done
        for FAILED_NEGATIVE_TEST in ${FAILED_NEGATIVE_TEST[@]}; do
            echo " - ${FAILED_NEGATIVE_TEST} (expected failure, got success)"
        done
        exit $FAILURE_COUNT
    else
        echo "All tests succeeded!"
    fi
}

function main () {
    cmake -S . -B build
    cmake --build build

    local LOCAL_CMAKE_MODULE_PATH=""
    for cmake_module_configfile in $(find cmake -name "*Config\.cmake"); do
        cmake_module_dir=$(dirname ${cmake_module_configfile})
        cmake_module_dir_abs=$(realpath ${cmake_module_dir})
        LOCAL_CMAKE_MODULE_PATH="${LOCAL_CMAKE_MODULE_PATH};${cmake_module_dir_abs};"
    done

    run_tests "${LOCAL_CMAKE_MODULE_PATH}"

    pushd build
        cpack
    popd
}

main