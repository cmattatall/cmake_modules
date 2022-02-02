# Description

A collection of cmake modules used for C and C++ projects


# Modules

This section contains a list of modules along with a brief description. 
For specifics, usage examples, and more information, see the 
`cmake/<MODULE>/README.md` subdirectory of a specific module.


- TargetUtils - A collection of cmake functions for manipulating and printing targets
- Packager    - The base module for the rest of the packaging modules - 
- PackagerApi - The core module for creating multiple build packages in a single project
- PackagerDeb - Used for creating debian packages from PackageApi packages
- PackagerRpm - Used for creating rpm packages from PackageApi packages
- PackagerTgz - Used for creating tarball + gunzip packages from PackageApi packages
- PackagerZip - Used for creating zip packages from PackageApi packages
- GnuCoverage - A framework for profiling, code coverage, and enforcing coverage requirements
- GTestFramework - An enhanced and more user-friendly extension of the GoogleTest cmake module
- GraphvizDocugen - A module 
- GitMetadata - Used for embedding git and build metadata into sources

- CppcheckAnalysis - WORK IN PROGRESS
- ClangTidyAnalysis - WORK IN PROGRESS






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


# Usage

- See the `tests/unit_tests/module_usage` subdirectories for API usage examples. <br>
- There should also be cmake function API documentation in many of the cmake modules e.g.: <br>
```sh
# Usage:
# PackagerApi_add_library(
#    PACKAGE package 
#    TARGET target_name 
#    TARGET_TYPE [ OBJECT | STATIC | SHARED | INTERFACE ]
# )
```

# TODO LIST

- Add support for inter-package depenedencies. SPECIFICALLY - add implementations that use: <br>
    - CPACK_DEBIAN_PACKAGE_DEPENDS 
    - CPACK_DEBIAN_>COMPONENT< PACKAGE_DEPENDS

- Add tests for adding transient dependencies and SHDEPLIBS_PACKAGE_DEPENDS to PackagerApi

- Fix code coverage report generation using stdout redirection (see GnuCoverageConfig.cmake::GnuCoverage_setup_coverage_build_target). This will not work on windows platforms


- Add support for $< TARGET_OBJECTS:... > generator expression to GnuCoverage_add_report_target


LOOK INTO:
https://cmake.org/cmake/help/v3.21/cpack_gen/deb.html#cpack_gen:CPack%20DEB%20Generator