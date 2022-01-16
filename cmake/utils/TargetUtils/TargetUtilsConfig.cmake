cmake_minimum_required(VERSION 3.21)


function(TargetUtils_get_child_targets output_var dir)
    set(targets)
    TargetUtils_get_all_targets_recursive(targets ${dir})
    set(${output_var} ${targets} PARENT_SCOPE)
endfunction(TargetUtils_get_child_targets output_var dir)


function(TargetUtils_get_all_targets output_var)
    set(targets)
    TargetUtils_get_child_targets(targets ${CMAKE_SOURCE_DIR})
    set(${output_var} ${targets} PARENT_SCOPE)
endfunction(TargetUtils_get_all_targets output_var)


macro(TargetUtils_get_all_targets_recursive targets dir)
    get_property(subdirectories DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)
    foreach(subdir ${subdirectories})
        TargetUtils_get_all_targets_recursive(${targets} ${subdir})
    endforeach(subdir ${subdirectories})
    get_property(current_targets DIRECTORY ${dir} PROPERTY BUILDSYSTEM_TARGETS)
    get_property(imported_targets DIRECTORY ${dir} PROPERTY IMPORTED_TARGETS)
    list(APPEND ${targets} ${current_targets})
    list(APPEND ${targets} ${imported_targets})
endmacro(TargetUtils_get_all_targets_recursive targets dir)


function(TargetUtils_get_child_tests output_var dir)
    set(tests)
    TargetUtils_get_all_tests_recursive(tests ${dir})
    set(${output_var} ${tests} PARENT_SCOPE)
endfunction(TargetUtils_get_child_tests output_var dir)


function(TargetUtils_get_all_tests output_var)
    set(tests)
    TargetUtils_get_child_tests(tests ${CMAKE_SOURCE_DIR})
    set(${output_var} ${tests} PARENT_SCOPE)
endfunction(TargetUtils_get_all_tests output_var)


macro(TargetUtils_get_all_tests_recursive tests cmake_dir)
    get_property(subdirectories DIRECTORY ${cmake_dir} PROPERTY SUBDIRECTORIES)
    foreach(subdir ${subdirectories})
        TargetUtils_get_all_tests_recursive(${tests} ${subdir})
    endforeach(subdir ${subdirectories})
    get_property(current_tests DIRECTORY ${cmake_dir} PROPERTY TESTS)
    list(APPEND ${tests} ${current_tests})
endmacro(TargetUtils_get_all_tests_recursive tests cmake_dir)


function(TargetUtils_print_all_targets)
    message("printing targets....")
    TargetUtils_get_all_targets(my_targets)
    foreach(target ${my_targets})
        # This is here because for some reason, 
        # Python::Interpreter is imported transitively by certain
        # third-party packages, but not EXPORTED from those libraries.
        # Thus, when indexing directory properties, we see a target exists 
        # called Python::Interpreter, but we cannot access it. This causes
        # an error when processing this function. 
        #
        # An elegant solution might be to recursively descend into the dirs in
        # question, hoist the target and export it using some crazy reflection
        # or something, but the usecase for this function will typically be
        # to sanity check your own (non-imported) targets when developing a 
        # build system with cmake. 
        # 
        # I have elected to go with the less elegant solution of just checking
        # if the target exists before trying to parse its properties.
        if(TARGET ${target}) 
            get_target_property(target_type ${target} TYPE)
            message("- ${target} (${target_type})")
        endif(TARGET ${target})
    endforeach(target ${my_targets})
    message("")
endfunction(TargetUtils_print_all_targets)