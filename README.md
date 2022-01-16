# Description

A collection of cmake modules used for C and C++ projects

# Testing

```sh
./scripts/build-and-test.sh
```


# Installation

```sh
cmake -S . -B build && \
cmake --build build && \
pushd build && \
    ctest -V && \
    cpack; \
popd; \
find build/packages/ -name "*\.deb" -exec sudo dpkg -i {} \;
```


# TODO LIST


- For some reason, TargetUtilsConfigVersion.cmake is being written to the binary directory of all the test suites at test time (when ctest runs and then calls the module unit tests using cmake)

- The output of the cmake configure and cmake build stages are not being printed to stdout as part of the test suites...

- We need to add unit tests for many of the module tests that involve a build stage (not just a configure stage) - this means an implicit DAG for the test runner hierarchy