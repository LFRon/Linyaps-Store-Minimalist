// 返回首页推荐应用卡片具体对象

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, file_names, non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/GetSystemTheme/syscolor.dart';
import 'package:yaru/yaru.dart';

class WelcomeAppGridItems extends StatefulWidget {

  // 获取当前应用信息
  LinyapsPackageInfo curAppInfo;

  // 获取当前屏幕长宽
  double height;
  double width;

  WelcomeAppGridItems({
    super.key,
    required this.curAppInfo,
    required this.height,
    required this.width,
  });

  @override
  State<WelcomeAppGridItems> createState() => _WelcomeAppGridItemsState();
}

class _WelcomeAppGridItemsState extends State<WelcomeAppGridItems> {
  @override
  Widget build(BuildContext context) {

    // 从页面父类获取当前应用信息
    LinyapsPackageInfo appinfo = widget.curAppInfo;
    double height = widget.height;
    double width = widget.width;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Syscolor.isBlack(context)
               ? Colors.grey.shade800
               : Colors.grey.shade200,
      ),
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AppInfoPage(
                  appId: appinfo.id,
                );
              },
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                          color: YaruColors.adwaitaRed,
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
                color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                fontSize: height*0.025,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
