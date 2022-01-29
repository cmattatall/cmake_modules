#include "lib_to_profile.hpp"
#include <iostream>

// We are testing if the test runner is successfully
// passed the arguments from the cmake build target
std::string argv_1_expect = "1";
std::string argv_2_expect = "2";

int main(int argc, char **argv) {
  std::cout << __FILE__ << ":" << __func__ << " called with " << argc
            << " arguments:" << std::endl;

  lib_to_profile1();
  lib_to_profile2();
  // lib_to_profile3(); // intentionally commented out
  return 0;
}