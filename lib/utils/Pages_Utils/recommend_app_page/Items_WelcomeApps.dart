// 返回首页推荐应用卡片具体对象

// 关闭VSCode非必要报错
// ignore_for_file: file_names, non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';

class WelcomeAppGridItems {
  List<LinyapsPackageInfo> WelcomeAppsList;

  // 获取当前屏幕长宽
  double height;
  double width;
  // 获取当前页面上下文对象
  BuildContext context;

  WelcomeAppGridItems({
    required this.WelcomeAppsList,
    required this.context,
    required this.height,
    required this.width,
  });
  List <Widget> Items () {
    List <Widget> returnItem = [];    // returnItem为最终返回的控件
    // 循环加入控件
    WelcomeAppsList.forEach((appinfo) {
      returnItem.add(
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AppInfoPage(appId: appinfo.id);
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
                    Hero(
                      tag: "WelcomeAppGridItems_${appinfo.id}",
                      child: CachedNetworkImage(
                        imageUrl: appinfo.Icon==null?"":appinfo.Icon!,
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
                        height: height*0.1,
                        width: height*0.1,
                      ),
                    ),
                    SizedBox(height:height*0.025,),
                    // 再显示应用名
                    Text(
                      appinfo.name,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: height*0.02,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
