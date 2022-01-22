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

- Ctest is being invoked for some reason even though the test suite is not being run with ctest anymore... This doesn't cause the builds or tests to fail though. THIS SEEMS TO HAPPEN A TON WHEN `cmake --build` is invoked (but it still seems to happen at least once during the configure stage)

- Add find_package and cmake module support for the clang-tidy static analysis module

- Add find_package and cmake module support for the cppcheck static analysis module

- Factor out common logic for propagation of `$<TARGET_OBJECTS: ... >` in PackagerApi_add_library and PackagerApi_add_executable
