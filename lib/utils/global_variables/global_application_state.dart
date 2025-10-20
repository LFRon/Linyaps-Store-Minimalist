// 用于管理全局存储的应用变量(安装的应用与可更新变量)

// 目前用于存储:
// 1. 已安装应用 2. 可更新应用 3. 正在下载安装的应用


// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_App_Management_API/linyaps_app_manager.dart';
import 'package:linglong_store_flutter/utils/Linyaps_CLI_Helper/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';

class ApplicationState extends ChangeNotifier {

  // 初始化私有可更新应用列表
  List <LinyapsPackageInfo> _upgradableAppsList = [];

  // 初始化私有已安装应用列表
  List <LinyapsPackageInfo> _installedAppsList = [];

  // 初始化正在下载的应用列表
  List <LinyapsPackageInfo> _downloadingAppsQueue = [];
  bool isProcessingQueue = false;   // 用于标记是否正在处理下载队列


  List <LinyapsPackageInfo> get upgradable_apps_list => _upgradableAppsList;
  List <LinyapsPackageInfo> get installed_apps_list => _installedAppsList;
  List <LinyapsPackageInfo>  get downloading_apps_queue => _downloadingAppsQueue;

  // 在线更新应用更新状况方法
  Future <void> updateUpgradableAppsList_Online () async 
    {
      List <LinyapsPackageInfo> get_upgradable_apps = await LinyapsAppManagerApi().get_upgradable_apps();
      // 更新对应变量并触发页面重构
      _upgradableAppsList = get_upgradable_apps;
      notifyListeners();
      return;
    }

  //// 对本地应用变量更改
  // 更新本地应用安装详情方法
  Future <void> updateInstalledAppsList_Online (List <LinyapsPackageInfo> already_get_list) async 
    {
      List <LinyapsPackageInfo> get_installed_apps = await LinyapsAppManagerApi().get_installed_apps(already_get_list);
      // 更新对应变量并触发页面重构
      _installedAppsList = get_installed_apps;
      notifyListeners();
      return;
    }

  // 这个离线方法需要传入新列表手动刷新
  void updateUpgradableAppsList(List <LinyapsPackageInfo> newList) {
    _upgradableAppsList = newList;
    notifyListeners();
  }

  // 这个离线方法需要手动传入新列表刷新本地已安装应用
  void updateInstalledAppsList(List <LinyapsPackageInfo> newList) {
    _installedAppsList = newList;
    notifyListeners();
  }
  ////

  //// 对下载列表的更改
  // 更新正在下载的应用列表
  void addDownloadingApp(LinyapsPackageInfo newApp) {
    newApp.downloadState = DownloadState.waiting;
    _downloadingAppsQueue.add(newApp);
    notifyListeners();
  }

  // 从正在下载的应用列表中移除应用
  void removeDownloadingApp(LinyapsPackageInfo app) {
    _downloadingAppsQueue.remove(app);
    notifyListeners();  
  }

  // 处理下载队列方法
  void processDownloadingQueue() async {
    isProcessingQueue = true;

    // 拿到队列头部元素
    LinyapsPackageInfo? currentApp = _downloadingAppsQueue.first;

    // 进行应用安装并判断状态
    if (
      await LinyapsCliHelper().install_app(
        currentApp.id, 
        currentApp.version, 
        currentApp.current_old_version,
      ) == 0
    ) {
      // 安装成功
      currentApp.downloadState = DownloadState.completed;
      // 将其从列表中移除
      _downloadingAppsQueue.remove(currentApp);
    } else {
      // 安装失败
      currentApp.downloadState = DownloadState.failed;
    }

    // 更新监听者
    notifyListeners();
    return;
  }
  ////

}
