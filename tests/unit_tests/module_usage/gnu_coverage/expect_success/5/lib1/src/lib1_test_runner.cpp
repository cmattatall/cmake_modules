#include "lib1.hpp"
#include <iostream>

// We are testing if the test runner is successfully
// passed the arguments from the cmake build target
std::string argv_1_expect = "1";
std::string argv_2_expect = "2";

int main(int argc, char **argv) {
  std::cout << __FILE__ << ":" << __func__ << " called with " << argc
            << " arguments:" << std::endl;

  lib1_1();
  lib1_2();
  // lib13(); // intentionally commented out so there is 66% coverage for lib1
  return 0;
}