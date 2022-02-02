#!/bin/bash
# Bash script to confirm that the execution coverage numbers for lib2 as
# profiled by GnuCoverage cmake module are accurate
EXPECTED_COVERAGE=@EXPECTED_COVERAGE@
LINE_COVERAGE_PERCENT=$(/usr/bin/cat ./coverage/coverage_summary.txt | /usr/bin/grep "%" | /usr/bin/grep lines | /usr/bin/grep -o ".*%" | /usr/bin/awk '{ print $2}' | /usr/bin/sed 's/%//' | /usr/bin/awk 'BEGIN { FS="." } { print $1 }')
echo "LINE_COVERAGE_PERCENT:${LINE_COVERAGE_PERCENT}"
echo "EXPECTED_COVERAGE:${EXPECTED_COVERAGE}"
if [ "${EXPECTED_COVERAGE}" != "${LINE_COVERAGE_PERCENT}" ]; then
    echo "ERROR - There is likely a bug in the GnuCoverage cmake module. EXPECTED_COVERAGE != LINE_COVERAGE_PERCENT (\"${EXPECTED_COVERAGE}\" != \"${LINE_COVERAGE_PERCENT}\")"
    exit -1
fi