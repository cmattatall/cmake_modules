#include <iostream>
#include "package_api_pkg_include_directories_test/lib.hpp"

int lib(){
    std::cout << "Executing " << __func__ << std::endl;
    return 0;
}