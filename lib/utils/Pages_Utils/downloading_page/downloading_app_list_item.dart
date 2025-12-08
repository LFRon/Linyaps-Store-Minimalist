// 显示每个下载中的应用功能实现

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/fatal_warning_button_static.dart';

class DownloadingAppListItem extends StatelessWidget {

  // 获取当前应用下载信息
  LinyapsPackageInfo cur_app_info;

  // 获取到全局应用实例
  ApplicationState globalAppState = Get.find<ApplicationState>();

  DownloadingAppListItem({
    super.key,
    required this.cur_app_info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      margin: EdgeInsets.symmetric(vertical: 6.0),    // 设置ListView.builder子控件间的间距
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      child: Padding(
        padding: EdgeInsets.only(top:8.0,bottom: 8.0,left: 30.0,right: 35.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CachedNetworkImage(
                    imageUrl: cur_app_info.Icon ?? '',
                    placeholder: (context, url) => Center(
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
                    errorWidget: (context, error, stackTrace) => Center(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 1,
              child: Text(
                '版本: ${cur_app_info.version}',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            
            Expanded(
              flex: 2,
              child: cur_app_info.downloadState == DownloadState.downloading
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 3.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 20,),
                    Text(
                      '正在下载',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    cur_app_info.downloadState == DownloadState.waiting
                      ? Row(
                        children: [
                          Text(
                            '正在等待下载',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 40,),
                          SizedBox(
                            width: 100,
                            height: 40,
                            child: MyStaticButton_FatalWarning(
                              onPressed: () {
                                globalAppState.downloadingAppsQueue.cast<LinyapsPackageInfo>().removeWhere(
                                  (app) => app.id == cur_app_info.id && app.version == cur_app_info.version
                                );
                              }, 
                              text: Text(
                                '取消',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                      : SizedBox(),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
