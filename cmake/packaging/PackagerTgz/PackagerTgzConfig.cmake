cmake_minimum_required(VERSION 3.21)

macro(PackagerTgz_configure)
    
    list(APPEND CPACK_GENERATOR "TGZ")
    if(CPACK_COMPONENT_INSTALL)
        set(CPACK_TGZ_COMPONENT_INSTALL ${CPACK_COMPONENT_INSTALL})
    endif(CPACK_COMPONENT_INSTALL)
    
endmacro(PackagerTgz_configure)

