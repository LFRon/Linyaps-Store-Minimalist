// 所有应用中每个网络的应用信息显示

// 关闭VSCode的非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_CLI_Helper_API/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_store_api_service.dart';
import 'package:linglong_store_flutter/utils/GetSystemTheme/syscolor.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/application_management/buttons/launch_app_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/application_management/buttons/uninstall_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:yaru/widgets.dart';

class InstalledAppsGridItems extends StatefulWidget {

  // 获取窗口当前的像素宽高
  double height,width;

  // 获取当前安装的应用信息
  LinyapsPackageInfo cur_app_info;

  InstalledAppsGridItems({
    super.key,
    required this.height,
    required this.width,
    required this.cur_app_info,
  });

  @override
  State<InstalledAppsGridItems> createState() => _InstalledAppsGridItemsState();
}

class _InstalledAppsGridItemsState extends State <InstalledAppsGridItems> {

  // 声明启动应用按钮
  late MyButton_AppManage_LaunchApp button_launch_app;

  // 声明卸载按钮
  late MyButton_AppManage_Uninstall button_uninstall;

  // 用于检查本地的应用是否在商店里
  Future <bool> isAppExistInStore (String appId) async {
    List <LinyapsPackageInfo>? app_info_get = await LinyapsStoreApiService.get_app_details_list(appId);
    // 检查列表是否为空
    if (app_info_get == null) return false;
    else return true;
  }

  // 用户按下卸载按钮, 卸载对应应用
  Future <void> uninstallApp (String appId, MyButton_AppManage_Uninstall button_uninstall) async {
    // 设置卸载按钮为按下状态
    button_uninstall.is_pressed.value = true;
    // 调用卸载函数
    await LinyapsCliHelper.uninstall_app(appId);
    // 重置卸载按钮为按下状态
    button_uninstall.is_pressed.value = false;
  }

  // 用户按下启动按钮, 启动对应应用
  Future <void> launchApp (String appId, MyButton_AppManage_LaunchApp button_launch) async {
    // 设置按钮被按下
    button_launch.is_pressed.value = true;
    LinyapsCliHelper.launch_installed_app(appId);   // 以非await异步方式启动应用
    // 设置一定延迟后才允许用户继续按下, 以防用户突然一次按太多下打开过多实例
    await Future.delayed(Duration(milliseconds: 550));
    // 启动后设置按钮被释放
    button_launch.is_pressed.value = false;
    return;
  }

  @override
  void initState () {
    super.initState();
    // 初始化卸载按钮
    button_uninstall = MyButton_AppManage_Uninstall(
      is_pressed: ValueNotifier<bool>(false), 
      indicator_width: 22, 
      onPressed: () async {
        await uninstallApp(
          widget.cur_app_info.id, 
          button_uninstall,
        );
      }
    );
    // 初始化启动按钮
    button_launch_app = MyButton_AppManage_LaunchApp(
      is_pressed: ValueNotifier<bool>(false), 
      indicator_width: 22, 
      onPressed: () async {
        await launchApp(widget.cur_app_info.id, button_launch_app);
      }
    );
  }

  @override
  Widget build(BuildContext context) {

    // 从父控件传入当前应用信息
    LinyapsPackageInfo cur_app_info = widget.cur_app_info;

    return Container(
      height: 120,
      width: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Syscolor.isBlack(context)
                ? Colors.grey.shade800
                : Colors.grey.shade200,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageTransition(
                type: PageTransitionType.fade,
                duration: const Duration(milliseconds: 100),
                reverseDuration: const Duration(milliseconds: 130),
                child: AppInfoPage(
                  appId: cur_app_info.id,
                ),
              ),
            );
          }, 
          child: Padding(
            padding: EdgeInsets.only(top: 15,bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 先显示图片
                CachedNetworkImage(
                  imageUrl: cur_app_info.Icon ?? '',
                  key: ValueKey(cur_app_info.name),
                  height: 80,width: 80,
                  placeholder: (context, loadingProgress) {
                    return Center(
                      child: SizedBox(
                        height: 80,
                        width: 80,
                        child: YaruCircularProgressIndicator(
                          strokeWidth: 3.0,
                        ),  // 加载时显示进度条
                      ),
                    );
                  },
                  errorWidget: (context, error, stackTrace) => Center(
                    child: Image(
                      image: AssetImage(
                        'assets/images/linyaps-generic-app.png',
                      ),
                    ),
                  ),
                ),
                // SizedBox(height:height*0.03,),    // 设置控件间间距
                // 再显示应用名
                Text(
                  cur_app_info.name,
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
                  "版本号: ${cur_app_info.version}",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: button_launch_app,
                    ),
                    const SizedBox(width: 20,),
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: button_uninstall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
