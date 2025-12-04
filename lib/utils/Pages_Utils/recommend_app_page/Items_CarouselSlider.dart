// 返回首页顶栏应用卡片具体对象

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, file_names, avoid_function_literals_in_foreach_calls

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';

class RecommendAppSliderItems {

  List<LinyapsPackageInfo> RecommendAppsList;

  // 获取当前屏幕长宽
  double height;
  double width;

  // 获取必需的BuildContext
  BuildContext context;

  RecommendAppSliderItems ({
    required this.context,
    required this.RecommendAppsList,
    required this.height,
    required this.width,
  });

  List <Widget> Items () {
    List <Widget> returnItem = [];    // returnItem为最终返回的控件
    // 循环加入控件
    RecommendAppsList.forEach((app_info) {
      returnItem.add(
        // 给每个控件加入按钮
        ElevatedButton(
          onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return AppInfoPage(appId: app_info.id);
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            // 关掉所有按钮特效
            backgroundColor: Colors.transparent,
            overlayColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            splashFactory: NoSplash.splashFactory,
          ),
          child: Column(
            children: [
              // 先显示图片
              CachedNetworkImage(
                imageUrl: app_info.Icon==null?"":app_info.Icon!,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    height: height*0.06,
                    width: height*0.06,
                    child: CircularProgressIndicator(
                      color: Colors.grey.shade300,
                      strokeWidth: 4.8,
                    ),  // 加载时显示进度条
                  ),
                ),
                // 无法显示图片时显示错误
                errorWidget: (context, error, stackTrace) => Center(
                  child:Column(
                    children: [
                      SizedBox(
                        width: width*0.05,
                        child: Icon(
                          Icons.error_rounded,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                height: height*0.15,
                width: height*0.15,
              ),
              SizedBox(height:height*0.04,),
              // 再显示应用名
              Text(
                app_info.name,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: height*0.024,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
    return returnItem;
  }
}