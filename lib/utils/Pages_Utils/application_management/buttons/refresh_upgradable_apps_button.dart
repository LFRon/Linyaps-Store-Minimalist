// 刷新待升级应用的按钮设计

// 关闭VSCode非必要报错
// ignore_for_file: camel_case_types, must_be_immutable

import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class MyButton_RefreshUpgradableApps extends StatelessWidget {

  // 声明需要传入的按下操作
  VoidCallback onPressed;

  // 声明需要传入的文本对象
  Text text;

  MyButton_RefreshUpgradableApps({
    super.key,
    required this.onPressed,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      color: YaruColors.adwaitaBlue,
      elevation: 0,   // 设置不显示边缘阴影
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
