// 可更新的应用列表单元设计

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/global_variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/pages_utils/my_buttons/upgrade_button.dart';
import 'package:provider/provider.dart';

class UpgradableAppListItems {

  // 获取必要的当前应用信息
  List <LinyapsPackageInfo> upgradable_apps_info;

  // 获取必要的父页面构建上下文
  BuildContext context;

  // 通过回调函数将"升级"按钮传递给父页面进行控制
  Function (MyButton_Upgrade button_upgrade) exposeUpgradeButton;

  // 通过回调函数传递给父页面进行升级操作
  // Future <void> Function (MyButton_Upgrade button_upgrade,LinyapsPackageInfo cur_app_info) AppUpgrade;

  UpgradableAppListItems({
    required this.upgradable_apps_info,
    required this.context,
    // required this.AppUpgrade,
    required this.exposeUpgradeButton,
  });

  // 返回所有控件
  List <Widget> items () 
    {
      // 拿到我们当前的存储全局变量类的响应实例
      ApplicationState appState = context.watch<ApplicationState>();
      
      // 初始化要返回的控件列表
      List <Widget> returnItems = [];
      LinyapsPackageInfo i;
      for (i in upgradable_apps_info)
        {
          // 先判断应用是否已经在下载,如果是,用downloading_app用于存储当前下载中的应用对象
          final downloading_app = appState.downloadingAppsQueue.firstWhere(
            (app) => i.id == app.id && i.version == app.version,
            orElse: () => LinyapsPackageInfo(id: '', name: '', version: '', description: '', arch: ''), 
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
            is_pressed: (downloading_app.id != '') ? ValueNotifier<bool>(true) : ValueNotifier<bool>(false), 
            indicator_width: 20, 
            onPressed: () async {
              // await widget.exposeUpgradeButton(button_upgrade);
              // await widget.AppUpgrade(button_upgrade,widget.cur_app_info);
            },
          );
          // 对外暴露升级按钮
          exposeUpgradeButton(button_upgrade);
          returnItems.add(
            Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.onPrimary,
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
                              imageUrl: i.Icon??"",
                              placeholder: (context, url) => Center(
                                child: SizedBox(
                                  height: 80,
                                  width: 80,
                                  child: SizedBox(
                                    height: 16,width: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.grey.shade300,
                                      strokeWidth:2.5,     // 设置加载条宽度
                                    ),
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
                              i.name,
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
                            Text(
                              '版本升级信息: ${i.current_old_version??'未知的旧版本'} -> ${i.version}',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
          );
        }
      return returnItems;
    }
}

