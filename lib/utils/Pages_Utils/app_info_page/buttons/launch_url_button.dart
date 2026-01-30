// 点击访问链接用按钮

// 关闭VSCode非必要报错
// ignore_for_file: camel_case_types, must_be_immutable

import 'package:flutter/material.dart';

class MyButton_LaunchUrl extends StatelessWidget {

  // 声明需要传入的按下操作
  VoidCallback onPressed;

  // 声明需要传入的文本对象
  Text text;

  // 声明需要传入的Icon图标对象
  Icon icon;

  MyButton_LaunchUrl({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
  });


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8,),
          text,
        ],
      ),
    );
  }
}
