// 显示每个下载中的应用功能实现

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';

class DownloadingAppListItem extends StatelessWidget {

  // 获取当前应用下载信息
  LinyapsPackageInfo cur_app_info;

  DownloadingAppListItem({
    super.key,
    required this.cur_app_info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Padding(
        padding: EdgeInsets.only(top:8.0,bottom: 8.0,left: 30.0,right: 35.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                FastCachedImage(
                  url: cur_app_info.Icon??"",
                  loadingBuilder: (context, url) => Center(
                    child: SizedBox(
                      height: 70,
                      width: 70,
                      child: CircularProgressIndicator(
                        color: Colors.grey.shade300,
                        strokeWidth:2.5,     // 设置加载条宽度
                      ),  // 加载时显示进度条
                    ),
                  ),
                  // 如果图片无法加载就使用默认玲珑图标
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Image(
                      height: 70,
                      width: 70,
                      image: AssetImage(
                        'assets/images/linyaps-generic-app.png',
                      ),
                    ),
                  ),
                  height: 70,
                  width: 70,
                ),
                SizedBox(width: 30,),  // 设置应用图标和名称的横向间距
                Text(
                  cur_app_info.name,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            SizedBox(width: 30,),  // 设置应用图标和名称的横向间距
            cur_app_info.downloadState == DownloadState.downloading
              ? Row(
                children: [
                  SizedBox(
                    height: 35,
                    width: 35,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(width: 30,),
                  Text(
                    '正在下载',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              )
              : cur_app_info.downloadState == DownloadState.waiting
                ? Text(
                  '正在等待下载',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
