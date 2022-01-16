#include <iostream>
#include <json/json.h>

int bar() {
  Json::Value myJsonVal;
  myJsonVal["bar"] = "barval";
  std::cout << myJsonVal.toStyledString() << std::endl;
  return 0;
}