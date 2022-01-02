cmake_minimum_required(VERSION 3.20)
project(package_api_positive_test_1)

include(package_api)


add_executable(${PROJECT_NAME} src/main.cpp)

find_package(my_package REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE my_package::my_library)