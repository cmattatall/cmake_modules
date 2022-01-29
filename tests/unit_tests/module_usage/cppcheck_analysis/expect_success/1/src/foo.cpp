int function_with_ub(int *arg) {
  // UB because + is not a sequence point
  int undefined_result = *arg = *arg++ + ++(*arg);
  return undefined_result;
}