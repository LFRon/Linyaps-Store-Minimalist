// 返回首页推荐应用卡片具体对象

// 关闭VSCode非必要报错
// ignore_for_file: file_names, non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';

class MostDownloadAppGridItems {
  List<LinyapsPackageInfo> NewestAppsList;

  // 获取当前页面上下文对象
  BuildContext context;

  MostDownloadAppGridItems({
    required this.NewestAppsList,
    required this.context,
  });
  List <Widget> Items ()
    {
      List <Widget> returnItem = [];    // returnItem为最终返回的控件
      // 循环加入控件
      NewestAppsList.forEach((appinfo) {
        returnItem.add(
          Padding(
            // 用Padding是避开右侧的滚轮
            padding: EdgeInsets.only(right: 13.0),
            child: OpenContainer(
              openElevation: 0,
              closedElevation: 0,
              openColor: Theme.of(context).colorScheme.surface,
              closedColor: Theme.of(context).colorScheme.onPrimary,
              transitionDuration: Duration(milliseconds: 320),
              transitionType: ContainerTransitionType.fadeThrough,
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              openBuilder: (context, action) {
                return AppInfoPage(appId: appinfo.id);
              },
              closedBuilder: (context, action) {
                return Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            // 先显示图片
                            Hero(
                              tag: "NewestAppsGridItems_${appinfo.id}_${appinfo.version}",
                              child: CachedNetworkImage(
                                imageUrl: appinfo.Icon==null?"":appinfo.Icon!,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.grey.shade300,
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
                            SizedBox(height: 20,),    // 设置控件间间距
                            // 再显示应用名
                            Text(
                              appinfo.name,
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 20,),    // 设置控件间间距
                            Text(
                              appinfo.installCount==null
                              ? "下载量: 未知"
                              : "下载量: ${appinfo.installCount} 次",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
            ),
          ),
        );
      });
      return returnItem;
    }
}
