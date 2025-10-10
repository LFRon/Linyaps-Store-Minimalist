// 主程序总线
// ignore_for_file: non_constant_identifier_names, must_be_immutable

import 'dart:io';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/main_pages/main_middle_page.dart';
import 'package:linglong_store_flutter/utils/Check_Connection_Status/check_connection_status.dart';
import 'package:linglong_store_flutter/utils/global_variables/global_application_state.dart';
import 'package:provider/provider.dart';
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
      // 初始化FastCachedImage
      await FastCachedImageConfig.init();
    }

   // 创建一个共享的ApplicationState实例
  ApplicationState appGlobalInfo = ApplicationState();

  // 初始化统计应用安装信息
  await appGlobalInfo.updateInstalledAppsList_Online();

  // 如果网络连接正常就后台加载应用可更新信息
  Future.delayed(Duration.zero).then((_) async {
    if (await CheckInternetConnectionStatus().staus_is_good())
      {
        await appGlobalInfo.updateInstalledAppsList_Online();
      }
  });

  // 再加载应用升级信息
  Future.delayed(Duration.zero).then((_) async {
    if (await CheckInternetConnectionStatus().staus_is_good())
      {
        await appGlobalInfo.updateUpgradableAppsList_Online();
      }
  });

  runApp(
    ChangeNotifierProvider(
      create: (context) => appGlobalInfo,
      child: MyApp(),
    )
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState ()
    {
      super.initState();
      // 检测操作系统不是Linux赶紧跑路
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
      // home: MainMiddlePage(),    等调试完成再去实现
      home: MainMiddlePage(),
    );
  }
}
