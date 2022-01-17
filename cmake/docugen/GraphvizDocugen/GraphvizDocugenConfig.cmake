
# Just use modern cmake here. 
# We will warn if graphviz not supported
cmake_minimum_required(VERSION 3.10) 

function(GraphvizDocugen_make_target_graph)
    if(${CMAKE_VERSION} VERSION_GREATER "3.21.0")
        set(DOT_EXECUTABLE dot)
        find_program(DOT_EXE_PATH "${DOT_EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX}")
        if(${DOT_EXE_PATH} STREQUAL DOT_EXE_PATH-NOTFOUND)
            message(WARNING "Cannot create graphviz visualization of software architecture because executable: ${DOT_EXECUTABLE} not found")
        else()
            set(GRAPHVIZ_IMAGE_TARGET graphviz)
            if(NOT TARGET ${GRAPHVIZ_IMAGE_TARGET})
                add_custom_target(${GRAPHVIZ_IMAGE_TARGET} ALL
                    COMMAND ${CMAKE_COMMAND} "--graphviz=graph.dot" .
                    COMMAND ${DOT_EXECUTABLE} -Tpng graph.dot -o targets.png
                    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}" # top level of entire build tree
                )
            else()
                message(WARNING "Target: \"${GRAPHVIZ_IMAGE_TARGET}\" already exists.")
            endif(NOT TARGET ${GRAPHVIZ_IMAGE_TARGET})
        endif(${DOT_EXE_PATH} STREQUAL DOT_EXE_PATH-NOTFOUND)
    else()
        message(WARNING "Cannot create graphviz visualization of software architecture. Not supported in cmake version : ${CMAKE_VERSION}")
    endif()
endfunction(GraphvizDocugen_make_target_graph)
