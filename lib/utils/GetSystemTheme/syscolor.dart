// 返回系统当前主题颜色的功能
// 是黑色则返回true,否则为false
import 'package:flutter/material.dart';

class Syscolor {
  static bool isBlack(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }
}
