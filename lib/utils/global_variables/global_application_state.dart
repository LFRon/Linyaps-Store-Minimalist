// 用于管理全局存储的应用变量(安装的应用与可更新变量)

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_App_Management_API/linyaps_app_manager.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';

class ApplicationState extends ChangeNotifier {

  List<LinyapsPackageInfo> _upgradableAppsList = [];
  List<LinyapsPackageInfo> _installedAppsList = [];

  List<LinyapsPackageInfo> get upgradable_apps_list => _upgradableAppsList;
  List<LinyapsPackageInfo> get installed_apps_list => _installedAppsList;

  // 在线更新应用更新状况
  // 更新待更新应用列表方法
  Future <void> updateUpgradableAppsList_Online () async 
    {
      List <LinyapsPackageInfo> get_upgradable_apps = await LinyapsAppManagerApi().get_upgradable_apps();
      // 更新对应变量并触发页面重构
      _upgradableAppsList = get_upgradable_apps;
      notifyListeners();
      return;
    }

  // 更新本地应用安装详情方法
  Future <void> updateInstalledAppsList_Online () async 
    {
      List <LinyapsPackageInfo> get_installed_apps = await LinyapsAppManagerApi().get_installed_apps();
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

  void updateInstalledAppsList(List <LinyapsPackageInfo> newList) {
    _installedAppsList = newList;
    notifyListeners();
  }
}
