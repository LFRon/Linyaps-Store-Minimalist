// 用于通过命令读取用户的安装信息

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, unnecessary_string_interpolations, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:toastification/toastification.dart';

class LinyapsCliHelper {

  // 用于判断是否安装了玲珑
  Future <bool> is_installed_linyaps () async {
    try {
      await Process.run('ll-cli', ['--version']);
      return true;
    }
    catch (e) {
      return false;
    }
  }

  // 用于返回玲珑所有安装信息的方法
  Future <dynamic> get_linyaps_all_local_info () async {
    // 指定玲珑的states.json路径
    String linyaps_states_path = '/var/lib/linglong/states.json';
    File file = File(linyaps_states_path);
    if (await file.exists())
      {
        // 以字符串的形式读取states.json
        String get_states_content = await file.readAsString();
        // 将字符串对象转成列表字典
        Map<String, dynamic> jsonData = jsonDecode(get_states_content) as Map<String, dynamic>;
        return jsonData;
      }
    else return null;
  }
  
  // 用于返回应用安装的版本方法
  Future <dynamic> get_app_installed_info (String appId) async {
    // 先获取玲珑读取的信息
    dynamic linyaps_info = await get_linyaps_all_local_info();
    // 如果用户未安装玲珑则直接跟没有安装一样返回
    if (linyaps_info == null) return "";
    LinyapsPackageInfo installed_app;
    int i=0;  // 用于下方循环查找应用
    for (i=0;i<linyaps_info['layers'].length;i++) {
      // 如果找到了应用,且显示未被删除则确认这是唯一安装的应用
      if (linyaps_info['layers'][i]['info']['id']==appId && linyaps_info['layers'][i]['deleted']==null) {
        installed_app = LinyapsPackageInfo(
          id: linyaps_info['layers'][i]['info']['id'], 
          name: linyaps_info['layers'][i]['info']['name'], 
          repoName: linyaps_info['layers'][i]['repo'],
          arch: linyaps_info['layers'][i]['info']['arch'][0],
          version: linyaps_info['layers'][i]['info']['version'], 
          description: linyaps_info['layers'][i]['info']['description'],
        );
        return installed_app;
      }
    }
    return "";
  }

  // 启动玲珑应用的方法
  void launch_installed_app (String appId) {
    // 进行启动
    Process.run('ll-cli', ['run',appId]);
    return;
  }
  
  // 安装玲珑应用的方法,version_last代表这个应用在进行安装前在本地的版本
  // 这里需要控件上下文,是为了显示应用安装成功亦或者失败的通知
  Future <int> install_app (String appId,String appName,String version,String? version_last,BuildContext context) async {
    // 显示全局通知开始安装
    toastification.show(
      context: context,
      applyBlurEffect: true,
      title: Text(
        '$appName开始安装',
        style: TextStyle(
          fontSize: 20,
        ),
      ),
      style: ToastificationStyle.flat,
      type: ToastificationType.info,
      autoCloseDuration: const Duration(seconds: 3),
    );
    ProcessResult result;
    result = await Process.run('pkexec',['ll-cli','install','$appId/$version','--force','-y']); 
    if (result.exitCode == 0) {
      // 显示全局通知安装成功
      toastification.show(
        context: context,
        applyBlurEffect: true,
        title: Text(
          '$appName安装成功',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        style: ToastificationStyle.flat,
        type: ToastificationType.success,
        autoCloseDuration: const Duration(seconds: 3),
      );
    } else {
      // 显示全局通知安装失败
      toastification.show(
        context: context,
        applyBlurEffect: true,
        title: Text(
          '$appName安装失败',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        style: ToastificationStyle.flat,
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
    }
    // 返回命令退出码
    return result.exitCode;    
  }

  // 卸载玲珑应用的方法,代表这个应用在进行安装前在本地的版本
  Future <int> uninstall_app (String appId) async {
    ProcessResult result;
    // 卸载前先杀死容器进程
    await Process.run('ll-cli', ['kill',appId]);
    // 进行应用强制安装
    result = await Process.run('pkexec',['ll-cli','uninstall','$appId']);
    // 返回命令退出码
    return result.exitCode;    
  }
}
