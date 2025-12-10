// 所有应用中每个网络的应用信息显示

// 关闭VSCode的非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';

class AppGridItem {

  // 获取当前应用信息
  LinyapsPackageInfo cur_app;

  // 获取页面必须的上下文
  BuildContext context;

  AppGridItem({
    required this.cur_app,
    required this.context,
  });

  Widget item () {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AppInfoPage(appId: cur_app.id);
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
        child: Padding(
          padding: EdgeInsets.only(top: 30,bottom: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 先显示图片
              Hero(
                tag: "NewestAppsGridItems_${cur_app.id}",
                child: CachedNetworkImage(
                  imageUrl: cur_app.Icon==null?"":cur_app.Icon!,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        color: Colors.grey.shade300,
                      ),  // 加载时显示进度条
                    ),
                  ),
                  // 无法显示图片时显示错误
                  errorWidget: (context, error, stackTrace) => Center(
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image(
                        image: AssetImage(
                          'assets/images/linyaps-generic-app.png',
                        ),
                      ),
                    ),
                  ),
                  height: 80,
                  width: 80,
                ),
              ),
              // SizedBox(height:height*0.03,),    // 设置控件间间距
              // 再显示应用名
              Text(
                cur_app.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                // 设置最多只能显示1行
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // SizedBox(height:height*0.025,),    // 设置控件间间距
              Text(
                "版本号: ${cur_app.version}",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
