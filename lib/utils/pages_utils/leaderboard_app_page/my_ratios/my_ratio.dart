// 用于选择显示下载量还是新上架的复选框

// 关闭VSCode非必要报错
// ignore_for_file: camel_case_types, must_be_immutable, curly_braces_in_flow_control_structures, prefer_if_null_operators

import 'package:flutter/material.dart';

class MyRadio_SelectNewOrMost extends StatefulWidget {

  // 传入必须的窗口像素信息
  double height,width;

  // 传入与父页面必需的回调函数
  Function (int value) onChanged;

  MyRadio_SelectNewOrMost({
    super.key,
    required this.onChanged,
    required this.height,
    required this.width,
  });

  @override
  State<MyRadio_SelectNewOrMost> createState() => _MyRadio_SelectNewOrMostState();
}

// 声明Options类
enum Options { option1, option2 }

class _MyRadio_SelectNewOrMostState extends State<MyRadio_SelectNewOrMost> {

  // 声明默认选项选择对象
  Options _selectedOption = Options.option1;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<Options>(
      groupValue: _selectedOption,
      onChanged: (value) {
        if (mounted) {
          setState(() {
            _selectedOption = (value==null)?Options.option1:value;
          });
        }
        // 对不同的选项进行处理
        if (value == Options.option1) widget.onChanged(1);
        else if (value == Options.option2) widget.onChanged(2);
      },
      child: Row(
        children: [
          Radio<Options>(
            value: Options.option1,
            // 设置鼠标悬浮时半透明效果
            overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.blueAccent.withValues(alpha: 0.3);  // 蓝色半透明
              }
              return Colors.transparent;
            }),
            activeColor: Colors.blueAccent,
            focusColor: Colors.blueAccent,
          ),
          SizedBox(width: widget.width*0.005,),
          Text(
            "查看最近更新应用",
            style: TextStyle(
              fontSize: widget.height*0.024
            ),
          ),
          SizedBox(width: widget.width*0.04,),
          Radio<Options>(
            value: Options.option2,
            // 设置鼠标悬浮时半透明效果
            overlayColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.blueAccent.withValues(alpha: 0.3);  // 蓝色半透明
              }
              return Colors.transparent;
            }),
            activeColor: Colors.blueAccent,
            focusColor: Colors.blueAccent,
          ),
          SizedBox(width: widget.width*0.005,),
          Text(
            "查看下载最多应用",
            style: TextStyle(
              fontSize: widget.height*0.024
            ),
          ),
        ],
      ),
    );
  }
}
