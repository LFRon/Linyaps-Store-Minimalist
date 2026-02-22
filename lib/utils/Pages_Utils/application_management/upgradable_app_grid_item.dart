// 可更新的应用列表单元设计

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/utils.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/GetSystemTheme/syscolor.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/application_management/buttons/upgrade_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:yaru/widgets.dart';

class UpgradableAppListItem extends StatefulWidget {

  // 获取必要的当前应用信息
  LinyapsPackageInfo cur_upgradable_app_info;

  // 通过回调函数进行升级操作
  Future <void> Function(LinyapsPackageInfo cur_upgradable_app_info) upgrade_cur_app;

  UpgradableAppListItem({
    super.key,
    required this.cur_upgradable_app_info,
    required this.upgrade_cur_app,
  });

  @override
  State<UpgradableAppListItem> createState() => _UpgradableAppListItemState();
}

class _UpgradableAppListItemState extends State<UpgradableAppListItem> {



  @override
  Widget build(BuildContext context) {

    // 从页面父类传入必要信息
    LinyapsPackageInfo cur_upgradable_app_info = widget.cur_upgradable_app_info;

    // 拿到我们当前的存储全局变量类的响应实例
    ApplicationState appState = Get.find<ApplicationState>();
    
    // 先判断应用是否已经在下载,如果是,用downloading_app用于存储当前下载中的应用对象
    LinyapsPackageInfo? downloading_app = appState.downloadingAppsQueue.firstWhereOrNull(
      (app) => cur_upgradable_app_info.id == app.id && cur_upgradable_app_info.version == app.version,
    );
    
    // 初始化升级按钮对象
    MyButton_Upgrade button_upgrade = MyButton_Upgrade(
      text: Text(
        "升级",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ), 
      // 如果应用正在升级,则直接设置按钮已被按下 (也就是提醒用户你已经正在升级)
      is_pressed: (downloading_app != null) ? ValueNotifier<bool>(true) : ValueNotifier<bool>(false), 
      indicator_width: 20, 
      onPressed: () async {
        // 将应用推入下载列表
        await widget.upgrade_cur_app(cur_upgradable_app_info);
      },
    );
    
    return Padding(   // 设置上下控件间间距
      padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 100),
                reverseDuration: const Duration(milliseconds: 130),
                child: AppInfoPage(
                  appId: cur_upgradable_app_info.id,
                ),
              ),
            );
          }, 
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Syscolor.isBlack(context)
                             ? Colors.grey.shade800
                             : Colors.grey.shade200,
              ),
            child: Padding(
              padding: EdgeInsets.only(top:8.0,bottom: 8.0,left: 25.0,right: 22.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 第一个Expanded放应用图标+名字
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CachedNetworkImage(
                          imageUrl: cur_upgradable_app_info.Icon ?? '',
                          placeholder: (context, url) => Center(
                            child: SizedBox(
                              height: 80,
                              width: 80,
                              child: YaruCircularProgressIndicator(
                                strokeWidth:2.5,     // 设置加载条宽度
                              ),  // 加载时显示进度条
                            ),
                          ),
                          // 如果图片无法加载就使用默认玲珑图标
                          errorWidget: (context, error, stackTrace) => Center(
                            child: Image(
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
                          cur_upgradable_app_info.name,
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
                    child: Row(
                      children: [
                        Icon(
                          size: 30,
                          color: Colors.lightGreen.withValues(alpha: 1.0),
                          Icons.cloud_upload_outlined,
                        ),
                        SizedBox(width: 20,),
                        SizedBox(
                          child: Text(
                            '版本升级信息: ${cur_upgradable_app_info.curOldVersion ?? "未知的旧版本"} -> ${cur_upgradable_app_info.version}',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: 90,
                    child: button_upgrade
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ); 
  }
}
