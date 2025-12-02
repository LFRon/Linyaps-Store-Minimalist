// 用于管理全局存储的应用变量 (安装的应用与可更新变量)

// 目前用于存储:
// 1. 已安装应用 2. 可更新应用 3. 正在下载安装的应用


// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, avoid_print, curly_braces_in_flow_control_structures

import 'dart:io';
import 'package:get/get.dart';
import 'package:linglong_store_flutter/utils/Linyaps_App_Management_API/linyaps_app_manager.dart';
import 'package:linglong_store_flutter/utils/Linyaps_CLI_Helper/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_store_api_service.dart';

class ApplicationState extends GetxController {

  // 初始化系统架构和商店返回的架构信息
  RxString os_arch = ''.obs;
  RxString repo_arch = ''.obs;

  // 初始化私有可更新应用列表
  RxList upgradableAppsList = RxList<LinyapsPackageInfo>();

  // 初始化私有已安装应用列表
  RxList installedAppsList = RxList<LinyapsPackageInfo>();

  // 初始化正在下载的应用列表
  RxList downloadingAppsQueue = RxList<LinyapsPackageInfo>();
  RxBool isProcessingQueue = false.obs;   // 用于标记是否正在处理下载队列

  // 用于返回按照"uname -m"标准命令输出的架构信息
  Future <void> getUnameArch () async {
    ProcessResult arch_result;
    arch_result = await Process.run('uname', ['-m']);
    // 更新操作系统架构信息
    String get_arch = arch_result.stdout.toString().trim();
    os_arch.value = get_arch;
    update();
    return;
  }

  // 用于返回按照玲珑商店架构要求的架构信息
  Future <void> getLinyapsStoreApiArch () async {
    ProcessResult arch_result;
    arch_result = await Process.run('uname', ['-m']);
    // 更新操作系统架构信息
    String os_arch = arch_result.stdout.toString().trim();
    String get_arch = "";
    if (os_arch == 'aarch64') get_arch = 'arm64';
    else get_arch = os_arch;
    // 更新变量信息
    repo_arch.value = get_arch;
    update();
    return;
  }

  // 在线更新应用更新状况方法
  Future <void> updateUpgradableAppsList_Online () async {
    List <LinyapsPackageInfo> get_upgradable_apps = await LinyapsStoreApiService.get_upgradable_apps();
    // 更新对应变量并触发页面重构
    upgradableAppsList.assignAll(get_upgradable_apps);
    update();
    return;
  }

  //// 对本地应用变量更改
  // 走后端应用管理API, 进行全局实例变量的更新
  // 返回值是否更新, true为更新了, false为没有
  Future <bool> updateInstalledAppsList_Online () async {
    List <dynamic> get_installed_info = await LinyapsAppManagerApi.get_installed_apps(installedAppsList.cast<LinyapsPackageInfo>());
    List <LinyapsPackageInfo> get_installed_apps = get_installed_info[0];
    // 更新对应变量并触发页面重构
    installedAppsList.assignAll(get_installed_apps);
    update();
    return get_installed_info[1];
  }

  // 这个离线方法需要传入新列表手动刷新
  void updateUpgradableAppsList(List <LinyapsPackageInfo> newList) {
    upgradableAppsList.assignAll(newList);
    update();
  }

  // 这个离线方法需要手动传入新列表刷新本地已安装应用
  void updateInstalledAppsList(List <LinyapsPackageInfo> newList) {
    installedAppsList.assignAll(newList);
    update();
  }
  ////

  //// 对下载列表的更改
  // 更新正在下载的应用列表
  Future <void> addDownloadingApp(LinyapsPackageInfo newApp) async {
    // 设置新加入应用的下载状态为正在下载
    newApp.downloadState = DownloadState.waiting;

    // 创建新列表实例以确保触发更新
    downloadingAppsQueue.add(newApp);

    // 通知监听者变化
    update();
    
    // 如果流水线没有更新就进行启动更新流水线
    if (!isProcessingQueue.value) processDownloadingQueue();
  }

  // 从正在下载的应用列表中移除应用
  Future <void> removeDownloadingApp(LinyapsPackageInfo app) async {
    try {
      downloadingAppsQueue.remove(app);
    } catch (_) {
      print('移除下载列表应用: ${app.id} 时出现故障');
    }
  }

  // 处理下载队列方法
  Future <void> processDownloadingQueue() async {
    isProcessingQueue.value = true;
    print('当前下载列表: $downloadingAppsQueue');
    // 进行应用安装并判断状态
    while (downloadingAppsQueue.isNotEmpty) {
      LinyapsPackageInfo currentApp = downloadingAppsQueue.first;
      // 更新下载状态
      currentApp.downloadState = DownloadState.downloading;
      update();
      if (
        await LinyapsCliHelper.install_app(
          currentApp.id, 
          currentApp.name,
          currentApp.version, 
          currentApp.current_old_version,
        ) == 0
      ) {
        // 安装成功
        currentApp.downloadState = DownloadState.completed;
        // 将其从列表中移除
        downloadingAppsQueue.remove(currentApp);
        // 再检查其是否在待升级列表中, 如果在则移除
        LinyapsPackageInfo? app_exist_in_upgradable_list = upgradableAppsList.cast<LinyapsPackageInfo>().firstWhereOrNull(
          (app) => app.id == currentApp.id && app.version == currentApp.version,
        );
        if (app_exist_in_upgradable_list != null) upgradableAppsList.remove(app_exist_in_upgradable_list);
        update();
        print('当前下载列表: $downloadingAppsQueue');
      } else {
        // 安装失败
        currentApp.downloadState = DownloadState.failed;
        downloadingAppsQueue.remove(currentApp);
        update();
        print('当前下载列表: $downloadingAppsQueue');
      }
    }
    isProcessingQueue.value = false;
    return;
  }
  ////

}
