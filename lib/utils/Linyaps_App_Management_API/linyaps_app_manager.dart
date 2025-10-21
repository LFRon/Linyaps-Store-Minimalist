// 用于对接应用管理页面的中间件
// 该中间件用于与商店API功能对接实现具体应用管理

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_CLI_Helper/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_store_api_service.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/version_compare/version_compare.dart';
import 'package:linglong_store_flutter/utils/global_variables/global_application_state.dart';

class LinyapsAppManagerApi {

  // 单开返回本地应用图标的函数,同步进行减少应用加载时间
  Future <String> getAppIcon (String appId) async 
    {
      List <LinyapsPackageInfo> app_info = await LinyapsStoreApiService().get_app_details(appId);
      String iconUrl = "";
      // 尝试获取应用的图标
      try {
        iconUrl = app_info[0].Icon ?? "";
      }
      catch (e) {
        iconUrl = "";
      }
      return iconUrl;
    }
  
  // 将待安装应用推送到安装队列里函数,而非直接安装
  Future <void> install_app (LinyapsPackageInfo newApp,BuildContext context) async 
    {
      // 将需要安装的应用统一推送
      await ApplicationState().addDownloadingApp(newApp,context);
      return;
    }

  // 返回已经安装的应用抽象类列表
  // 需要加入already_get_list是让重新扫描已安装应用时先获取当前已经安装的应用信息
  // 然后没有的再往里加
  Future <List<LinyapsPackageInfo>> get_installed_apps (List <LinyapsPackageInfo> already_get_list) async
    {
      // 先异步获取玲珑本地信息
      dynamic linyapsLocalInfo = await LinyapsCliHelper().get_linyaps_all_local_info();
      // 处理异常(比如没有安装玲珑或者没安装应用等情况)
      if (linyapsLocalInfo == null) return [];
      // 通过迭代器对遍历本地已经安装的玲珑组件包信息
      dynamic i;
      // 初始化待返回临时对象
      List<LinyapsPackageInfo> returnItems = [];
      // 开始遍历本地的应用安装信息
      for (i in linyapsLocalInfo['layers'])
        {
          String IconUrl = "";
          // 先检查已知的应用列表是否为空省去不必要的循环
          if (already_get_list.isEmpty)
            {
              returnItems.add(
                LinyapsPackageInfo(
                  id: i['info']['id'], 
                  name: i['info']['name'], 
                  version: i['info']['version'], 
                  description: i['info']['description'], 
                  arch: i['info']['arch'][0],
                  Icon: IconUrl,     // 此时图标链接为空
                  IconUpdated: 0,     // 设置图标未更新
                ),
              );
            }
          // 如果已安装应用列表已初始化过则对比版本号是否发生变化
          else    
            {
              // 先检查应用是否存在
              dynamic existingApp = already_get_list.firstWhere(
                (app) => app.id == i['info']['id'],
                orElse: () => LinyapsPackageInfo(
                  id: '',     // 找不到就返回空对象,下面检测也用这个空id作为识别
                  name: '', 
                  version: '', 
                  description: '', 
                  arch: '',
                )
              );
              // 如果应用没有录入就进行录入
              if (existingApp.id == '')
                {
                  returnItems.add(
                    LinyapsPackageInfo(
                      id: i['info']['id'], 
                      name: i['info']['name'], 
                      version: i['info']['version'], 
                      description: i['info']['description'], 
                      arch: i['info']['arch'][0],
                      Icon: IconUrl,     // 此时图标链接为空
                      IconUpdated: 0,     // 设置图标未更新
                    ),
                  );
                }
              // 如果发现录入了,就检查版本是否一致,不一致就更新版本
              else
                {
                  if (existingApp.version != i['info']['version'])
                    {
                      returnItems.add(
                        LinyapsPackageInfo(
                          id: i['info']['id'], 
                          name: i['info']['name'], 
                          version: existingApp.version, 
                          description: i['info']['description'], 
                          arch: i['info']['arch'][0],
                          Icon: existingApp.Icon,     // 此时图标链接为空
                          IconUpdated: 1,     // 设置图标未更新
                        ),
                      );
                    }
                  else
                    {
                      returnItems.add(
                        LinyapsPackageInfo(
                          id: i['info']['id'], 
                          name: i['info']['name'], 
                          version: existingApp.version, 
                          description: i['info']['description'], 
                          arch: i['info']['arch'][0],
                          Icon: existingApp.Icon,     // 此时图标链接为空
                          IconUpdated: 1,     // 设置图标未更新
                        ),
                      );
                    }
                }
            }
        }
      return returnItems;
    }

  // 返回应用可更新列表
  Future <List<LinyapsPackageInfo>> get_upgradable_apps () async 
    {
      // 先获取已安装应用
      List <LinyapsPackageInfo> installed_apps = await get_installed_apps([]);

      // 初始化待返回应用抽象类列表
      List <LinyapsPackageInfo> upgradable_apps = [];

      // 遍历已安装的应用
      LinyapsPackageInfo i;   // 先初始化遍历用迭代器
      for (i in installed_apps)
        {
          // 先尝试从商店获取当前应用信息
          List <LinyapsPackageInfo> app_info_from_store = await LinyapsStoreApiService().get_app_details(i.id);
          // 如果找不到对应应用直接跳过
          if (app_info_from_store.isEmpty) continue;
          // 如果发现有更高版本
          if (
            VersionCompare(
              ver1: app_info_from_store[app_info_from_store.length-1].version,
              ver2: i.version,
            ).isFirstGreaterThanSec()
          ) {
            // 存储最新版本应用的信息
            upgradable_apps.add(
              LinyapsPackageInfo(
                id: i.id, 
                name: i.name, 
                version: app_info_from_store[app_info_from_store.length-1].version, 
                current_old_version: i.version,
                description: i.description, 
                arch: i.arch,
                Icon: app_info_from_store[app_info_from_store.length-1].Icon,
              ),
            );
          }
        }
      return upgradable_apps;
    }
}
