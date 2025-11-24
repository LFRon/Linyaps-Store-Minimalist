// 主程序总线
// ignore_for_file: non_constant_identifier_names, must_be_immutable, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/main_pages/main_middle_page.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';
import 'package:provider/provider.dart';
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

  // 创建一个共享的ApplicationState实例
  ApplicationState appGlobalInfo = ApplicationState();

  runApp(
    ChangeNotifierProvider(
      create: (context) => appGlobalInfo,
      child: ToastificationWrapper(
        child: MyApp(),
      ),
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
