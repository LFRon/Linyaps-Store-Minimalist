// 返回首页顶栏应用卡片具体对象

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names, file_names, avoid_function_literals_in_foreach_calls

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';

class RecommendAppSliderItem extends StatefulWidget {

  // 传入当前应用信息
  LinyapsPackageInfo curAppInfo;

  // 获取当前屏幕长宽
  double height;
  double width;

  RecommendAppSliderItem({
    super.key,
    required this.curAppInfo,
    required this.height,
    required this.width,
  });

  @override
  State<RecommendAppSliderItem> createState() => _RecommendAppSliderItemState();
}

class _RecommendAppSliderItemState extends State<RecommendAppSliderItem> {
  @override
  Widget build(BuildContext context) {

    // 从页面父类中获取必需信息
    LinyapsPackageInfo app_info = widget.curAppInfo;
    double height = widget.height;
    double width = widget.width;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppInfoPage(
                appId: app_info.id,
              ),
            ),
          );
        },
        child: SizedBox(
          width: width*0.5,
          height: height*0.3,
          child: Column(
            children: [
              // 先显示图片
              CachedNetworkImage(
                imageUrl: app_info.Icon ?? '',
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
                  child: SizedBox(
                    width: width*0.05,
                    child: Icon(
                      Icons.error_rounded,
                      color: Colors.redAccent,
                    ),
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
                  fontSize: height*0.024,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
