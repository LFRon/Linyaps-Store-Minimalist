// 返回按钮设计

// 关闭VSCode非必要报错
// ignore_for_file: camel_case_types, must_be_immutable

import 'package:flutter/material.dart';

class MyButton_Back extends StatelessWidget {

  // 声明需要传入的按下操作
  VoidCallback onPressed;

  // 声明需要传入的宽度以便于控制图标大小
  double size;

  MyButton_Back({
    super.key,
    required this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            size: size,
            Icons.arrow_back_ios,
          ),
          Text(
            "返回",
            style: TextStyle(
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
