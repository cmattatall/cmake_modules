cmake_minimum_required(VERSION 3.20)
project(package_api_positive_test_1)

add_executable(${PROJECT_NAME} src/main.cpp)

find_package(foo REQUIRED)
target_link_libraries(${PROJECT_NAME} PRIVATE foo::foo_target)