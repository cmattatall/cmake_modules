cmake_minimum_required(VERSION 3.21)

macro(PackagerRpm_configure)

    list(APPEND CPACK_GENERATOR "RPM")
    if(CPACK_COMPONENT_INSTALL)
        set(CPACK_RPM_COMPONENT_INSTALL ${CPACK_COMPONENT_INSTALL})
    endif(CPACK_COMPONENT_INSTALL)
    
endmacro(PackagerRpm_configure)

