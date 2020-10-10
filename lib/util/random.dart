part of askr;

math.Random _random = new math.Random();

// 随机

// 返回 0.0 到 1.0 的随机浮点数
double randomDouble() {
  return _random.nextDouble();
}

/// 返回 -1.0 到 1.0 的随机浮点数
double randomSignedDouble() {
  return _random.nextDouble() * 2.0 - 1.0;
}

/// 返回 0 到 [max]-1 的随机整数
int randomInt(int max) {
  return _random.nextInt(max);
}

/// 以最随机的方式返回 [true] 或 [false]
bool randomBool() {
  return _random.nextDouble() < 0.5;
}
