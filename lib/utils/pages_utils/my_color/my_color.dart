import 'package:flutter/material.dart';

class MyColor {
  
  // 返回二级颜色
  Color secondary (BuildContext context)
    {
      return Theme.of(context).colorScheme.secondary;
    }

}