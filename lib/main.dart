// 主程序总线
// ignore_for_file: non_constant_identifier_names, must_be_immutable, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/utils.dart';
import 'package:linglong_store_flutter/pages/main_pages/main_middle_page.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  // 启动时检测操作系统环境与架构

  WidgetsFlutterBinding.ensureInitialized();   // 确保程序主窗口已加载
  if (!kIsWasm && !kIsWeb)
    {
      // 设置窗口参数
      await WindowManager.instance.setTitle("玲珑应用商店");
      // 设置窗口最小大小
      await WindowManager.instance.setMinimumSize(const Size(1200,600));
    }

  // 创建GetX管理共享的ApplicationState实例
  Get.put(ApplicationState());
  ApplicationState appGlobalInfo = Get.find<ApplicationState>();

  // 启动时更新系统架构信息
  await appGlobalInfo.getUnameArch();
  await appGlobalInfo.getLinyapsStoreApiArch();

  // 启动应用及控制器
  runApp(
    GetMaterialApp(
      home: ToastificationWrapper(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {

  // 在这里声明当前应用版本号
  static String cur_version = '1.0.4';

  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState () {
    super.initState();
    // 检测操作系统是不是Linux,不是的话赶紧跑路
    if (!Platform.isLinux) exit(0);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "HarmonyOS Sans",
        fontFamilyFallback: [
          'Noto Color Emoji',
        ],
        colorScheme: ColorScheme.light(
          surface: Colors.grey.shade200,
          primary: Colors.black,
          onPrimary: Colors.grey.shade300,
          secondary: Colors.white,
        ),
      ),
      home: MainMiddlePage(),
    );
  }
}
