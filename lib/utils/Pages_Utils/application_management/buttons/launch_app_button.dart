// 卸载动态按钮绘制

// 忽略VSCode报错
// ignore_for_file: camel_case_types, non_constant_identifier_names, must_be_immutable

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class MyButton_AppManage_LaunchApp extends StatefulWidget {

  double indicator_width;      // 声明加载动画图标大小
  ValueNotifier <bool> is_pressed;   // is_press开关用于调整按钮是否被按下
  VoidCallback onPressed;

  MyButton_AppManage_LaunchApp({
    super.key,
    required this.is_pressed,
    required this.indicator_width,
    required this.onPressed,    // 调整声明顺序使按钮声明更清晰
  });

  @override
  State<MyButton_AppManage_LaunchApp> createState() => _MyButton_AppManage_LaunchAppState();
}

class _MyButton_AppManage_LaunchAppState extends State<MyButton_AppManage_LaunchApp> {
  @override
  Widget build(BuildContext context) {
    // 返回变量监听层
    return ValueListenableBuilder <bool> (
      valueListenable: widget.is_pressed,
      builder: (context,value,child) {
        return MaterialButton(
          color: YaruColors.adwaitaBlue,
          // 设置不显示边缘阴影
          focusElevation: 0,
          highlightElevation: 0,
          elevation: 0,   
          hoverElevation: 0,
          padding: EdgeInsets.all(0),
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
              child: YaruCircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3.5,     // 设置加载条宽度
              ),
            ),
          )
          : Center(
            child: Icon(
              Icons.launch,
              size: 25,
              color: Colors.white,
            ),
          ),
        );
      }
    );
  }
}
