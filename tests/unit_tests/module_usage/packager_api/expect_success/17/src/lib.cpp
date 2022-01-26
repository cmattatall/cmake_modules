#include "lib.hpp"
#include <iostream>

int lib() {
  std::cout << "Executing " << __func__ << std::endl;
  return 0;
}