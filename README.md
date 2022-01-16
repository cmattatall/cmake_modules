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
find build -name "*\.deb" -exec sudo dpkg -i {} \;
```
