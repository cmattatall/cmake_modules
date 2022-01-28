
# Just use modern cmake here. 
# We will warn if graphviz not supported
cmake_minimum_required(VERSION 3.10) 

function(GraphvizDocugen_make_target_graph)
    if(${CMAKE_VERSION} VERSION_GREATER "3.21.0")
        set(GRAPHVIZ_WORKDIR ${CMAKE_BINARY_DIR})
        set(DOT_EXECUTABLE dot)
        find_program(DOT_EXE_PATH "${DOT_EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX}")
        if(DOT_EXE_PATH STREQUAL DOT_EXE_PATH-NOTFOUND)
            message(WARNING "Cannot create graphviz visualization of software architecture because executable: ${DOT_EXECUTABLE} not found")
            return()
        endif(DOT_EXE_PATH STREQUAL DOT_EXE_PATH-NOTFOUND)
        message(DEBUG "DOT_EXE_PATH:\"${DOT_EXE_PATH}\"")

        set(GRAPHVIZ_IMAGE_TARGET graphviz)
        if(TARGET ${GRAPHVIZ_IMAGE_TARGET})
            message(WARNING "Target: \"${GRAPHVIZ_IMAGE_TARGET}\" already exists.")
            return()
        endif(TARGET ${GRAPHVIZ_IMAGE_TARGET})
        
        add_custom_target(${GRAPHVIZ_IMAGE_TARGET} ALL
            COMMAND ${CMAKE_COMMAND} "--graphviz=graph.dot" .
            COMMAND ${DOT_EXECUTABLE} -Tpng graph.dot -o targets.png
            WORKING_DIRECTORY "${GRAPHVIZ_WORKDIR}"
        )

        set(GRAPHVIZ_CLEANUP_SCRIPT "${GRAPHVIZ_WORKDIR}/graphviz_cleanup.cmake")
        file(WRITE "${GRAPHVIZ_CLEANUP_SCRIPT}" "cmake_minimum_required(VERSION ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION})\nfile(GLOB DOT_FILES \"${GRAPHVIZ_WORKDIR}/graph\\.dot\\.*\")\nmessage(DEBUG \"DOT_FILES:\${DOT_FILES}\")\nfile(REMOVE \${DOT_FILES})")
        add_custom_command(
            TARGET ${GRAPHVIZ_IMAGE_TARGET}
            POST_BUILD
            COMMENT "Cleaning up the dot files produced during build of ${GRAPHVIZ_IMAGE_TARGET} ... "
            COMMAND ${CMAKE_COMMAND} -P "${GRAPHVIZ_WORKDIR}/graphviz_cleanup.cmake"
            COMMAND ${CMAKE_COMMAND} -E remove "${GRAPHVIZ_CLEANUP_SCRIPT}"
            COMMAND ${CMAKE_COMMAND} -E echo "Done."
            WORKING_DIRECTORY "${GRAPHVIZ_WORKDIR}"
        )
    else()
        message(WARNING "Cannot create graphviz visualization of software architecture. Not supported in cmake version : ${CMAKE_VERSION}")
    endif()
endfunction(GraphvizDocugen_make_target_graph)
