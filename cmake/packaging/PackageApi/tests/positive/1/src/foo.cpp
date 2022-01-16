#include <iostream>
#include <json/json.h>

int foo() {
  Json::Value myJsonVal;
  myJsonVal["foo"] = "fooval";
  std::cout << myJsonVal.toStyledString() << std::endl;
  return 0;
}