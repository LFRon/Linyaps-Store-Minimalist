// 显示应用截图的控件
// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yaru/widgets.dart';

class AppInfo_SCapList {

  // 获取需要传入的当前应用截图
  List <String> SCapList;

  AppInfo_SCapList({
    required this.SCapList,
  });

  List <Widget> widgets () {
    // 预备返回的控件列表
    List <Widget> returnItems = [];
    for (var i in SCapList) {
      returnItems.add(
        CachedNetworkImage(
          height: 130,
          width: 130,
          imageUrl: i,
          placeholder: (context, url) => Center(
            child: YaruCircularProgressIndicator(
              strokeWidth:2.5, // 设置加载条宽度
            ),
          ),
          // 无法显示图片时显示错误
          errorWidget:(
            context,
            error,
            stackTrace,
          ) => Center(
            child: Image(
              image: AssetImage(
                'assets/images/linyaps-generic-app.png',
              ),
            ),
          ),
        ),
      );
    }
    return returnItems;
  }
}
