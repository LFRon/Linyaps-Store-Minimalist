// 用于在应用详情页显示

// 关闭VSCode非必要报错
// ignore_for_file: prefer_const_constructors_in_immutables, non_constant_identifier_names, must_be_immutable, prefer_if_null_operators, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:get/utils.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_CLI_Helper_API/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/install_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/launch_app_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/fatal_warning_button.dart';

class AppInfoListView extends StatefulWidget {

  // 声明需要当前应用信息
  LinyapsPackageInfo app_info;

  // 声明需要传入的下载应用列表
  List <LinyapsPackageInfo> downloadingAppsQueue;

  // 声明当前版本是否安装
  bool is_cur_version_installed;

  // 声明需要安装应用的回调函数
  // 之所以用回调是方便于父级页面让页面控件及时刷新
  Future <void> Function(LinyapsPackageInfo app_info,MyButton_Install button_install) install_app;

  // 声明需要安装应用的回调函数
  Future <void> Function(String appId,MyButton_FatalWarning button_uninstall) uninstall_app;

  AppInfoListView({
    super.key,
    required this.install_app,
    required this.uninstall_app,
    required this.app_info,
    required this.downloadingAppsQueue,
    required this.is_cur_version_installed,
  });

  @override
  State<AppInfoListView> createState() => AppInfoListViewState();
}

class AppInfoListViewState extends State<AppInfoListView> {

  // 声明卸载按钮对象
  late MyButton_FatalWarning button_uninstall;

  // 声明安装按钮对象
  late MyButton_Install button_install;

  // 声明启动应用按钮对象
  late MyButton_LaunchApp button_launchapp;

  // 该页面启动应用的方法
  void launch_app (String appId) async {
    // 设置按钮被按下
    button_launchapp.is_pressed.value = true;
    LinyapsCliHelper.launch_installed_app(appId);
    // 设置一定延迟后才允许用户继续按下, 以防用户突然一次按太多下打开过多实例
    await Future.delayed(Duration(milliseconds: 550));
    // 启动后设置按钮被释放
    button_launchapp.is_pressed.value = false;
  }

  // 覆写父类构造函数
  @override
  void initState () {
    super.initState();

    // 初始化卸载按钮对象
    button_uninstall = MyButton_FatalWarning(
      text: Text(
        "卸载",
        style: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
      ), 
      is_pressed: ValueNotifier<bool>(false),     // 初始化设置为按钮未被按下
      indicator_width: 16, 
      onPressed: () async {
        await widget.uninstall_app(
          widget.app_info.id,
          button_uninstall,
        );
      },
    );
      
  }

  @override
  Widget build(BuildContext context) {

    // 传入app_info对象
    LinyapsPackageInfo app_info = widget.app_info;

    // 从传入全局的下载列表
    List <LinyapsPackageInfo> downloadingAppsQueue = widget.downloadingAppsQueue;

    // 初始化安装按钮对象
    DownloadState state = DownloadState.none;

    // 先看看下载列表里有没有这个应用和对应版本
    if (downloadingAppsQueue.isNotEmpty) { 
      // 进行检查
      LinyapsPackageInfo? cur_downloading_app = downloadingAppsQueue.firstWhereOrNull(
        (app) => app.id == widget.app_info.id && app.version == widget.app_info.version,
      );
      // 如果找到了对应应用实例
      if (cur_downloading_app != null) state = cur_downloading_app.downloadState??DownloadState.none;
    } 

    // 初始化按钮
    button_install = MyButton_Install(
      text: Text(
        "安装",
        style: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
      ), 
      // 初始化按钮按下状态时检查其下载状态是不是1.在下载 2.在下载的路上,如果是,就设置按钮被按下,因为你这应用的确在安装的路上
      is_pressed: (state == DownloadState.waiting || state == DownloadState.downloading) ? ValueNotifier<bool>(true) : ValueNotifier<bool>(false),
      indicator_width: 16, 
      onPressed: () async {
        await widget.install_app(
          widget.app_info,
          button_install,
        );
      },
    );

    // 初始化启动应用按钮对象
    button_launchapp = MyButton_LaunchApp(
      text: Text(
        "启动",
        style: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
      ), 
      is_pressed: ValueNotifier<bool>(false),     // 初始化设置为按钮未被按下
      indicator_width: 16, 
      onPressed: () => launch_app(widget.app_info.id),
    );

    // 对ApplicationState实例进行实时监控
    return Padding(
      padding: const EdgeInsets.only(right: 11.0),     // 微操避开右侧滚轮
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top:8.0,bottom: 8.0,left: 8.0,right: 15.0),
          child: Row(
            children: [

              Expanded(
                flex: 1,
                child: Text(
                  "版本号: ${app_info.version}",
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),

              Expanded(
                flex: 1,
                child: widget.app_info.is_app_local_only != null
                ? widget.app_info.is_app_local_only! == true
                  ? Text(
                    "分发模式: 用户本地安装",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  )
                  : Text(
                    "分发模式: 未知",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  )
                : Row(
                  children: [
                    Text(
                      "分发模式: ${app_info.channel}",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 15,),
                    Text(
                      "下载量: ${app_info.installCount==null?'未知':app_info.installCount}",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
             
              FittedBox(
                child: SizedBox(width: 40,),
              ),

              // 如果应用安装了,则显示卸载与启动按钮
              Expanded(
                flex: 1,
                child: widget.is_cur_version_installed
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 30,
                        width: 80,
                        child: button_uninstall,
                      ),
                      SizedBox(
                        height: 30,
                        width: 80,
                        child: button_launchapp,
                      )
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 30,
                        width: 80,
                        child: button_install,
                      ),
                    ],
                  ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
