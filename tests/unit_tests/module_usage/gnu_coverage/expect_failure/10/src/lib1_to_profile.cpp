#include <iostream>

int lib1_to_profile1() {
  std::cout << ">>> Executing function: " << __func__ << std::endl;
  return 5;
}

int lib1_to_profile2() {
  std::cout << ">>> Executing function: " << __func__ << std::endl;
  return 10;
}

int lib1_to_profile3() {
  std::cout << ">>> Executing function: " << __func__ << std::endl;
  return 15;
}

int lib1_to_profile4() {
  std::cout << ">>> Executing function: " << __func__ << std::endl;
  return 20;
}