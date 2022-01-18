cmake_minimum_required(VERSION 3.21)

add_subdirectory(utils)
add_subdirectory(packaging)
add_subdirectory(testing)
add_subdirectory(docugen)
add_subdirectory(codegen)
add_subdirectory(profiling)

message(WARNING "[ in ${CMAKE_CURRENT_LIST_FILE} ], add_subdirectory(analysis) is commented out because it is still a work in progress")
#add_subdirectory(analysis)