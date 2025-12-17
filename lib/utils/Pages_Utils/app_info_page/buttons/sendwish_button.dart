// 发送心愿单按钮设计

// 关闭VSCode非必要报错
// ignore_for_file: camel_case_types, must_be_immutable

import 'package:flutter/material.dart';

class MyButton_SendWish extends StatelessWidget {

  // 声明需要传入的按下操作
  VoidCallback onPressed;

  // 声明需要传入的文本对象
  Text text;

  MyButton_SendWish({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      color: Colors.transparent,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            size: 30,
            Icons.navigate_next_outlined,
          ),
          SizedBox(width: 5,),
          text,
        ],
      ),
    );
  }
}
