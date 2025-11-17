// 用于对接应用管理页面的中间件
// 该中间件用于与商店API功能对接实现具体应用管理

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_CLI_Helper/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';
import 'package:provider/provider.dart';

class LinyapsAppManagerApi {
  
  // 将待安装应用推送到安装队列里函数,而非直接安装
  Future <void> install_app (LinyapsPackageInfo newApp,BuildContext context) async {
    // 将需要安装的应用统一推送
    await Provider.of<ApplicationState>(context, listen: false).addDownloadingApp(newApp,context);
    return;
  }

  // 返回已经安装的应用抽象类列表
  // 需要加入already_get_list是让重新扫描已安装应用时先获取当前已经安装的应用信息
  // 然后没有的再往里加
  Future <List<LinyapsPackageInfo>> get_installed_apps (List <LinyapsPackageInfo> already_get_list) async {
    // 先异步获取玲珑本地信息
    dynamic linyapsLocalInfo = await LinyapsCliHelper().get_linyaps_all_local_info();
    // 再获取
    // 处理异常(比如没有安装玲珑或者没安装应用等情况)
    if (linyapsLocalInfo == null) return [];
    // 初始化待返回临时对象
    List<LinyapsPackageInfo> returnItems = [];
    // 开始遍历本地的应用安装信息
    dynamic i;
    for (i in linyapsLocalInfo['layers']) {
      String IconUrl = "";
      // 先检查已知的应用列表是否为空省去不必要的循环
      if (already_get_list.isEmpty) {
        returnItems.add(
          LinyapsPackageInfo(
            id: i['info']['id'], 
            name: i['info']['name'], 
            version: i['info']['version'], 
            description: i['info']['description'], 
            arch: i['info']['arch'][0],
            Icon: IconUrl,     // 此时图标链接为空
          ),
        );
      }
      // 如果已安装应用列表已初始化过则对比版本号是否发生变化
      else {
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
        if (existingApp.id == '') {
          returnItems.add(
            LinyapsPackageInfo(
              id: i['info']['id'], 
              name: i['info']['name'], 
              version: i['info']['version'], 
              description: i['info']['description'], 
              arch: i['info']['arch'][0],
              Icon: IconUrl,     // 此时图标链接为空
            ),
          );
        }
        // 如果发现录入了,就检查版本是否一致,不一致就更新版本
        else {
          if (existingApp.version != i['info']['version']) {
            returnItems.add(
              LinyapsPackageInfo(
                id: i['info']['id'], 
                name: i['info']['name'], 
                version: i['info']['version'], 
                description: i['info']['description'], 
                arch: i['info']['arch'][0],
                Icon: existingApp.Icon,     // 此时图标链接为空
              ),
            );
          } else {
            returnItems.add(
              LinyapsPackageInfo(
                id: i['info']['id'], 
                name: i['info']['name'], 
                version: existingApp.version, 
                description: i['info']['description'], 
                arch: i['info']['arch'][0],
                Icon: existingApp.Icon,     // 此时图标链接为空
              ),
            );
          }
        }
      }
    }
    return returnItems;
  }
}
