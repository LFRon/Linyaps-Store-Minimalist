// 返回首页推荐应用卡片具体对象

// 关闭VSCode非必要报错
// ignore_for_file: file_names, non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';

class NewestAppGridItems {
  List<LinyapsPackageInfo> NewestAppsList;

  // 获取当前屏幕长宽
  double height;
  double width;

  // 获取当前页面上下文对象
  BuildContext context;

  NewestAppGridItems({
    required this.NewestAppsList,
    required this.context,
    required this.height,
    required this.width,
  });
  List <Widget> Items ()
    {
      List <Widget> returnItem = [];    // returnItem为最终返回的控件
      // 循环加入控件
      NewestAppsList.forEach((appinfo)
        {
          returnItem.add(
            Padding(     // 用Padding是避开右侧的滚轮
              padding: EdgeInsets.only(right: 13.0),
              child: Container(
                height: height*0.01,
                width: width*0.01,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            tag: "NewestAppsGridItems_${appinfo.id}",
                            child: FastCachedImage(
                              url: appinfo.Icon==null?"":appinfo.Icon!,
                              loadingBuilder: (context, url) => Center(
                                child: SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: CircularProgressIndicator(
                                    color: Colors.grey.shade300,
                                  ),  // 加载时显示进度条
                                ),
                              ),
                              // 无法显示图片时显示错误
                              errorBuilder: (context, error, stackTrace) => Center(
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
                          SizedBox(height:height*0.03,),    // 设置控件间间距
                          // 再显示应用名
                          Text(
                            appinfo.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            // 设置最多只能显示1行
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height:height*0.025,),    // 设置控件间间距
                          Text(
                            "更新时间: ${appinfo.createTime==null?"未知":appinfo.createTime?.substring(0,10)}",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      return returnItem;
    }
}
