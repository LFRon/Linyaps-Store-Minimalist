// 返回首页推荐应用卡片具体对象

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, file_names, non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/GetSystemTheme/syscolor.dart';
import 'package:page_transition/page_transition.dart';
import 'package:yaru/widgets.dart';

class NewestAppGridItem extends StatefulWidget {

  LinyapsPackageInfo curAppInfo;

  NewestAppGridItem({
    super.key,
    required this.curAppInfo,
  });

  @override
  State<NewestAppGridItem> createState() => _NewestAppGridItemState();
}

class _NewestAppGridItemState extends State<NewestAppGridItem> {
  @override
  Widget build(BuildContext context) {

    // 从页面父类传入必须信息
    LinyapsPackageInfo appinfo = widget.curAppInfo;

    return Padding(     // 用Padding是避开右侧的滚轮
      padding: EdgeInsets.only(right: 13.0),
      child: Container(
        height: 150,
        width: 150,
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
              PageTransition(
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 100),
                reverseDuration: const Duration(milliseconds: 130),
                child: AppInfoPage(
                  appId: appinfo.id,
                ),
              ),
            );
          },
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
                  SizedBox(height: 20,),    // 设置控件间间距
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
                  SizedBox(height: 20,),    // 设置控件间间距
                  Text(
                    "更新时间: ${appinfo.createTime==null?"未知":appinfo.createTime?.substring(0,10)}",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
