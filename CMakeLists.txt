cmake_minimum_required(VERSION 3.20)

project(foo)


set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH};${CMAKE_CURRENT_SOURCE_DIR}")

include(package_api)


package_add_library(PACKAGE my_package TARGET my_target TARGET_TYPE OBJECT_FOO)
