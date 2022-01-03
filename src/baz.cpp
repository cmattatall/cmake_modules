#include <iostream>
#include <json/json.h>

int foo() {
  Json::Value myJsonVal;
  myJsonVal["baz"] = "bazval";
  std::cout << myJsonVal.toStyledString() << std::endl;
  return 0;
}