// 卸载动态按钮绘制

// 忽略VSCode报错
// ignore_for_file: camel_case_types, non_constant_identifier_names, must_be_immutable

import 'package:flutter/material.dart';

class MyButton_Upgrade extends StatefulWidget {

  Text text;     // 声明显示的文本
  double indicator_width;      // 声明加载动画图标大小
  ValueNotifier <bool> is_pressed;   // is_press开关用于调整按钮是否被按下
  VoidCallback onPressed;

  MyButton_Upgrade({
    super.key,
    required this.text,
    required this.is_pressed,
    required this.indicator_width,
    required this.onPressed,    // 调整声明顺序使按钮声明更清晰
  });

  @override
  State<MyButton_Upgrade> createState() => _MyButton_UpgradeState();
}

class _MyButton_UpgradeState extends State<MyButton_Upgrade> {
  @override
  Widget build(BuildContext context) {
    // 返回变量监听层
    return ValueListenableBuilder <bool> (
      valueListenable: widget.is_pressed,
      builder: (context,value,child) {
        return MaterialButton(
          color: Colors.green.withValues(alpha: 0.7),
          elevation: 0,   // 设置不显示边缘阴影
          shape: RoundedRectangleBorder(  // 设置圆角
              borderRadius: BorderRadius.circular(12),
          ),
          onPressed: () async {    // 设置按下之后触发的函数(方法)   
            // 防止用户多次同时按下按钮,所以只允许按钮在is_pressed为假时才可以触发执行函数
            if (!value) {
              widget.onPressed();
            }
          },  
          child: value     // 判断是否按钮被按下
          ? Center(
            child: SizedBox(
              height: widget.indicator_width,
              width: widget.indicator_width,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth:2.5,     // 设置加载条宽度
              ),
            ),
          )
          :widget.text,
        );
      }
    );
  }
}
