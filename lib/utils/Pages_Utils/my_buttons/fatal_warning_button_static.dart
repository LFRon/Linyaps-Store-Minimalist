// 卸载动态按钮绘制

// 忽略VSCode报错
// ignore_for_file: camel_case_types, non_constant_identifier_names, must_be_immutable

import 'package:flutter/material.dart';

class MyStaticButton_FatalWarning extends StatefulWidget {

  // 声明需要传入的按下操作
  VoidCallback onPressed;

  Text text;     // 声明显示的文本

  MyStaticButton_FatalWarning({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  State<MyStaticButton_FatalWarning> createState() => _MyStaticButton_FatalWarningState();
}

class _MyStaticButton_FatalWarningState extends State<MyStaticButton_FatalWarning> {
  @override
  Widget build(BuildContext context) {
    // 返回变量监听层
    return MaterialButton(
      onPressed: widget.onPressed,
      color: Colors.redAccent,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.text,
        ],
      ),
    );
  }
}
