// 所有应用中每个网络的应用信息显示

// 关闭VSCode的非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/GetSystemTheme/syscolor.dart';
import 'package:yaru/widgets.dart';

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
    return OpenContainer(
      openElevation: 0,
      closedElevation: 0,
      transitionDuration: Duration(milliseconds: 320),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder:(context, action) {
        // 先获取当前页面主题
        ThemeData curThemeData = Theme.of(this.context);
        return AppInfoPage(
          appId: cur_app.id,
          curThemeData: curThemeData,
        );
      },
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      closedBuilder:(context, action) {
        return Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            color: Syscolor.isBlack(context)
                   ? Colors.grey.shade800
                   : Colors.grey.shade200,
          ),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
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
                          child: YaruCircularProgressIndicator(
                            strokeWidth: 2.5,
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
      }, 
    );
    
    
    
  }
}
