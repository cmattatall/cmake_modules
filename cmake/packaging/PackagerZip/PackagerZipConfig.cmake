cmake_minimum_required(VERSION 3.21)

macro(PackagerZip_init)
    list(APPEND CPACK_GENERATOR "ZIP")
    if(CPACK_COMPONENT_INSTALL)
        set(CPACK_ZIP_COMPONENT_INSTALL ${CPACK_COMPONENT_INSTALL})
    endif(CPACK_COMPONENT_INSTALL)
endmacro(PackagerZip_init)


function(PackagerZip_configure_package PKG)
    message(WARNING "Not implemented yet")
endfunction(PackagerZip_configure_package PKG)

