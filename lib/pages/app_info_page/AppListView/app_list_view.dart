// 用于在应用详情页显示

// 关闭VSCode非必要报错
// ignore_for_file: prefer_const_constructors_in_immutables, non_constant_identifier_names, must_be_immutable, prefer_if_null_operators

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_CLI_Helper/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/global_variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/pages_utils/my_buttons/install_button.dart';
import 'package:linglong_store_flutter/utils/pages_utils/my_buttons/launch_app_button.dart';
import 'package:linglong_store_flutter/utils/pages_utils/my_buttons/fatal_warning_button.dart';
import 'package:provider/provider.dart';

class AppInfoView extends StatefulWidget {

  // 声明需要当前应用信息
  LinyapsPackageInfo app_info;

  // 声明需要当前应用已经安装的版本
  String? cur_installed_app_version;

  // 声明判定当前版本是否安装的对象
  bool is_cur_version_installed;

  // 声明需要安装应用的回调函数
  // 之所以用回调是方便于父级页面让页面控件及时刷新
  Future <void> Function(LinyapsPackageInfo app_info,MyButton_Install button_install) install_app;

  // 声明需要安装应用的回调函数
  Future <void> Function(String appId,MyButton_FatalWarning button_uninstall) uninstall_app;

  AppInfoView({
    super.key,
    required this.is_cur_version_installed,
    required this.install_app,
    required this.uninstall_app,
    required this.app_info,
    this.cur_installed_app_version,
  });

  @override
  State<AppInfoView> createState() => AppInfoViewState();
}

class AppInfoViewState extends State<AppInfoView> {

  // 声明卸载按钮对象
  late MyButton_FatalWarning button_uninstall;

  // 声明安装按钮对象
  late MyButton_Install button_install;

  // 声明启动应用按钮对象
  late MyButton_LaunchApp button_launchapp;

  // 得到正在安装的应用列表
  // List <LinyapsPackageInfo>  get downloading_apps_queue => Provider.of<ApplicationState>(context,listen: false).downloadingAppsQueue;

  // 该页面启动应用的方法
  void launch_app (String appId) {
    // 设置按钮被按下
    button_launchapp.is_pressed.value = true;
    LinyapsCliHelper().launch_installed_app(appId);
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

    // 传入当前版本是否安装对象
    bool is_cur_version_installed = widget.is_cur_version_installed;

    // 对ApplicationState实例进行实时监控
    return Consumer<ApplicationState> (
      builder: (context, appState, child) {
        // 初始化安装按钮对象
      DownloadState state = DownloadState.none;

      // 先看看下载列表里有没有这个应用和对应版本
      if (appState.downloadingAppsQueue.isNotEmpty) { 
        // 进行检查
        LinyapsPackageInfo cur_downloading_app = appState.downloadingAppsQueue.firstWhere(
          (app) => app.id == widget.app_info.id && app.version == widget.app_info.version,
          // 没有就返回空对象
          orElse: () => LinyapsPackageInfo(
            id: '', 
            name: '', 
            version: '', 
            description: '',
              arch: '',
          )
        );
        // 如果找到了对应应用实例
        if (cur_downloading_app.id != '') state = cur_downloading_app.downloadState??DownloadState.none;
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "版本号: ${app_info.version}",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  Text("分发模式: ${app_info.channel}"),
                  Text("下载量: ${app_info.installCount==null?'未知':app_info.installCount}"),
                  is_cur_version_installed
                    ? SizedBox(
                      height: 30,
                      width: 80,
                      child: button_uninstall,
                    )
                    : SizedBox(
                      height: 30,
                      width: 80,
                    ),
                  is_cur_version_installed
                    ? SizedBox(
                      height: 30,
                      width: 80,
                      child: button_launchapp,
                    )
                    : SizedBox(
                      height: 30,
                      width: 80,
                      child: button_install,
                    ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}
