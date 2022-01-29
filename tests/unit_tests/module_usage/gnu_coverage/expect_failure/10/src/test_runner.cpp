#include "lib1_to_profile.hpp"
#include "lib2_to_profile.hpp"
#include <iostream>

// 33% coverage is less than 50 and so should fail the build
int main(int argc, char **argv) {
  lib1_to_profile1();
  lib2_to_profile1();

  // intentionally commented out so we don't cover these functions
  // lib_to_profile2();

  // intentionally commented out so we don't cover these functions
  // lib_to_profile3();
  return 0;
}