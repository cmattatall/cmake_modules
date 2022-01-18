#include "gtest/gtest.h"
#include <iostream>

TEST(DUMMY_TEST_1, TEST_SUITE1_NAME) {
  EXPECT_FALSE(0 == 1);
  EXPECT_TRUE(1 == 1);
}