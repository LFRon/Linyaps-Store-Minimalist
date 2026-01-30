// 返回按钮设计

// 关闭VSCode非必要报错
// ignore_for_file: camel_case_types, must_be_immutable

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/GetSystemTheme/syscolor.dart';

class MyButton_Confirm extends StatelessWidget {

  // 声明需要传入的按下操作
  VoidCallback onPressed;

  // 声明需要传入的文本对象
  Text text;

  MyButton_Confirm({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      elevation: 0,
      highlightElevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      color: Syscolor.isBlack(context)
             ? Colors.grey.shade600
             : Colors.grey.shade300,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          text,
        ],
      ),
    );
  }
}
