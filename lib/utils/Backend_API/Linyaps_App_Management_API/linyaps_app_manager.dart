// 用于对接应用管理页面的中间件
// 该中间件用于与商店API功能对接实现具体应用管理

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'package:get/get.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_CLI_Helper_API/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';

class LinyapsAppManagerApi {
  
  // 将待安装应用推送到安装队列里函数,而非直接安装
  static Future <void> install_app (LinyapsPackageInfo newApp) async {
    // 将需要安装的应用统一推送
    Get.find<ApplicationState>().addDownloadingApp(newApp);
    return;
  }

  // 返回已经安装的应用抽象类列表
  // 返回值:
  // 第0项为列表本体, 第1项为列表是否被更新
  // 需要加入already_get_list是让重新扫描已安装应用时先获取当前已经安装的应用信息
  // 然后没有的再往里加
  static  Future <List<dynamic>> get_installed_apps (List <LinyapsPackageInfo> already_get_list) async {
    
    // 先异步获取玲珑本地信息
    dynamic linyapsLocalInfo = await LinyapsCliHelper.get_linyaps_all_local_info();
    
    // 遇到没有安装玲珑或者没安装应用等情况,直接返回空列表
    if (linyapsLocalInfo == null) return [];
    
    // 初始化待返回已安装应用的临时对象
    List<LinyapsPackageInfo> installedItems = [];

    // 检查应用列表是否被更新, 默认为假
    bool is_installed_apps_updated = false;
    
    // 提前检查列表是否为空, 为空必然进行了更新, 故直接设置为true
    if (already_get_list.isEmpty) is_installed_apps_updated = true;

    // 开始遍历本地的应用安装信息
    for (dynamic i in linyapsLocalInfo['layers']) {
      // 检测到玲珑base/runtime直接跳过
      if (
        i['info']['id'] == 'org.deepin.base' ||
        i['info']['id'] == 'org.deepin.foundation' ||
        i['info']['id'] == 'org.deepin.Runtime' || 
        i['info']['id'] == 'org.deepin.runtime.dtk' ||
        i['info']['id'] == 'org.deepin.runtime.gtk4' ||
        i['info']['id'] == 'org.deepin.base.flatpak.freedesktop' ||
        i['info']['id'] == 'org.deepin.base.flatpak.kde'  ||
        i['info']['id'] == 'org.deepin.base.flatpak.gnome'   ||
        i['info']['id'] == 'org.deepin.base.wine'   ||
        i['info']['id'] == 'org.deepin.runtime.wine'   ||
        i['info']['id'] == 'org.deepin.runtime.qt5'   ||
        i['info']['id'] == 'org.deepin.runtime.webengine'
      ) continue;
      // 先检查已知的应用列表是否为空省去不必要的循环
      if (already_get_list.isEmpty) {
        installedItems.add(
          LinyapsPackageInfo(
            id: i['info']['id'], 
            name: i['info']['name'], 
            version: i['info']['version'], 
            description: i['info']['description'], 
            arch: i['info']['arch'][0],
            Icon: '',     // 此时图标链接为空
          ),
        );
      }
      // 如果已安装应用列表已初始化过则对比版本号是否发生变化
      else {
        // 先检查应用是否存在
        LinyapsPackageInfo? existingApp = already_get_list.firstWhereOrNull(
          (app) => app.id == i['info']['id'],
        );
        // 如果应用没有录入就进行录入
        if (existingApp == null) {
          installedItems.add(
            LinyapsPackageInfo(
              id: i['info']['id'], 
              name: i['info']['name'], 
              version: i['info']['version'], 
              description: i['info']['description'], 
              arch: i['info']['arch'][0],
              Icon: '',     // 此时未获取图标链接, 故为空
            ),
          );
          is_installed_apps_updated = true;
        }
        // 如果发现录入了,就检查版本是否一致,不一致就更新版本
        else {
          if (existingApp.version != i['info']['version']) {
            installedItems.add(
              LinyapsPackageInfo(
                id: i['info']['id'], 
                name: i['info']['name'], 
                version: i['info']['version'], 
                description: i['info']['description'], 
                arch: i['info']['arch'][0],
                Icon: existingApp.Icon,    
              ),
            );
            is_installed_apps_updated = true;
          } else {
            installedItems.add(
              LinyapsPackageInfo(
                id: i['info']['id'], 
                name: i['info']['name'], 
                version: existingApp.version, 
                description: i['info']['description'], 
                arch: i['info']['arch'][0],
                Icon: existingApp.Icon,   
              ),
            );
          }
        }
      }
    }
    List<dynamic> returnItems = [];
    // 由于玲珑在刚安装完应用的瞬间会创建两个应用版本对象, 而导致应用安装信息里出现两个一模一样的应用
    // 但是安装完之后JSON列表里又会变成一个应用对象
    // 因此在下一次检查时要比对加好的列表(installedItems)与现有列表长度, 如果不一样就意味着列表必然进行了更新
    // 因此要额外进行长度比对
    if (installedItems.length!=already_get_list.length) is_installed_apps_updated = true;
    
    if (is_installed_apps_updated) returnItems.add(installedItems);
    else returnItems.add(already_get_list);

    returnItems.add(is_installed_apps_updated);
    return returnItems;
  }

  // 获取当前应用安装信息的函数
  // 若当前没有安装则返回空 (NULL)
  static Future <LinyapsPackageInfo?> get_cur_installed_app_info (String appId) async {
    // 先调用该静态类方法
    List <dynamic> installed_apps_info_get = await get_installed_apps([]);
    // 然后拿取其第0位获取安装信息
    List <LinyapsPackageInfo> installed_apps_info = installed_apps_info_get[0];
    LinyapsPackageInfo? cur_app_info_local = installed_apps_info.firstWhereOrNull(
      (app) => app.id == appId,
    );
    return cur_app_info_local;
  }

}
