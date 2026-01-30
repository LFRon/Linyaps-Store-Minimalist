// 应用详情设计页面

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_print, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/app_info_page/ListView/app_info_list_view.dart';
import 'package:linglong_store_flutter/utils/Check_Connection_Status/check_connection_status.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_App_Management_API/linyaps_app_manager.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_CLI_Helper_API/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_store_api_service.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/app_info_page/ListView/screenshot_list.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/app_info_page/buttons/install_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/app_info_page/buttons/launch_app_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/app_info_page/buttons/uninstall_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/application_management/dialog_app_not_exist_in_store.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/app_info_page/buttons/back_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/app_info_page/buttons/app_listview/install_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/generic_buttons/fatal_warning_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/settings.dart';
import 'package:yaru/widgets.dart';

class AppInfoPage extends StatefulWidget {

  // 声明必须获取的应用ID
  String appId;

  AppInfoPage({
    super.key, 
    required this.appId,
  });

  @override
  State<AppInfoPage> createState() => AppInfoPageState();
}

class AppInfoPageState extends State<AppInfoPage> with WidgetsBindingObserver {

  // 声明当前页面的安装按钮
  late MyButton_AppInfoPage_Install install_button;

  // 声明当前页面卸载按钮
  late MyButton_AppInfoPage_Uninstall uninstall_button;

  // 声明当前页面启动按钮
  late MyButton_AppInfoPage_LaunchApp launch_app_button;

  // 启用页面监视定时器
  Timer? checkTimer;

  // 声明网络连接的状态对象,默认状态为假
  bool is_connection_good = false;

  // 声明页面加载状态,默认为没加载完
  bool is_page_loaded = false;

  // 声明本地应用信息加载状态,默认状态为假
  bool is_app_local_info_loading = false;

  // 声明存储当前应用在商店的信息列表
  late List<LinyapsPackageInfo>? cur_app_info_list;

  // 声明读取全局应用变量实例类
  late ApplicationState appState;

  // 声明存储当前应用安装的第几个版本,默认为字符串为空代表没有安装
  String? cur_installed_version;

  // 访问deepin论坛玲珑专版跳转链接
  Future <void> visitLinyapsBBS() async {
    Uri linyaps_bbs_uri = Uri.parse(
      'https://bbs.deepin.org.cn/module/detail/230',
    );
    await launchUrl(linyaps_bbs_uri);
  }

  // 获取当前网络具体状况函数
  Future <void> get_connection_status() async {
    bool is_connection_good_get =
        await CheckInternetConnectionStatus.staus_is_good();
    // 更新页面具体变量信息
    if (mounted)
      setState(() {
        is_connection_good = is_connection_good_get;
      });
    return;
  }

  // 设置本地应用信息正在更新的开关方法
  Future <void> setAppLocalInfoLoading() async {
    if (mounted) setState(() {
      is_app_local_info_loading = true;
    });
    return;
  }

  // 设置本地应用信息没有更新/更新完成的开关方法
  Future <void> setAppLocalInfoLoaded() async {
    if (mounted) setState(() {
      is_app_local_info_loading = false;
    });
    return;
  }

  // 获取应用具体信息函数,返回的值为"是否在商店中找到这个应用"
  Future <bool> getAppDetails(String appId) async {
    // 从玲珑后端API中获得玲珑应用数据
    List <LinyapsPackageInfo>? get_app_info = await LinyapsStoreApiService.get_app_details_list(appId);

    // 检查应用是否存在,不存在直接调商店没有此应用的对话框
    if (get_app_info == null) {
      await showDialog(
        // 这里用异步是直接阻断页面继续加载
        context: context,
        barrierDismissible: false, // 禁止用户按别的地方关闭
        builder: (context) {
          return MyDialog_AppNotExistInStore();
        },
      );
      Navigator.of(context).popUntil((route) {
        return route.isFirst;
      });
      return false;
    }

    // 进行赋值
    if (mounted) {
      setState(() {
        cur_app_info_list = get_app_info;
      });
    }
    return true;
  }

  // 获取应用具体安装信息的函数
  Future <void> update_app_installed_info(String appId) async {
    // 如果应用存在,则通过应用管理拿到本地应用安装对象信息
    LinyapsPackageInfo? app_local_info = await LinyapsAppManagerApi.get_cur_installed_app_info(appId);
    // 先判断其是否在本地
    // 如果在本地则再检查应用是否在商店返回信息中
    // 若不在,则认定为是用户本地安装的非商店版本
    // 并在加入至应用信息列表时开启本地安装标识
    if (app_local_info != null) {
      LinyapsPackageInfo? is_app_local_info_in_store = cur_app_info_list!
                                                       .firstWhereOrNull(
                                                        (app) => app.id == appId && 
                                                        app.version == app_local_info.version,
                                                       );
      if (is_app_local_info_in_store == null) {
        app_local_info.is_app_local_only = true;
        cur_app_info_list!.insert(0, app_local_info);
      }
    }
    // 如果应用存在
    if (app_local_info != null) {
      // 立刻通知页面重构获取安装的应用的版本
      if (mounted) setState(() {
        cur_installed_version = app_local_info.version;
      });
    } else {
      // 如果应用不存在则恢复Null值
      cur_installed_version = null;
    }
    return;
  }

  // 设置页面响应已完成的函数
  Future <void> set_page_loaded() async {
    if (mounted) setState(() {
      is_page_loaded = true;
    });
  }

  // 设置安装函数实现,用于被ListView.builder里的控件当回调函数调用
  // 该页面安装应用的方法,version代表当前安装的目标版本,cur_app_version代表如果有的本地安装版本
  Future <void> install_app(
    LinyapsPackageInfo appInfo,
    MyButton_Install? button_install,   // 这个是应用列表中的安装按钮(如果传入)
    MyButton_AppInfoPage_Install? button_install_this,  // 这个是本页面中的安装按钮(如果传入)
  ) async {
    // 设置按钮被按下
    // 设置安装按钮被按下
    if (button_install != null) {
      button_install.is_pressed.value = true;
    }
    if (button_install_this != null) {
      button_install_this.is_pressed.value = true;
    }
    await LinyapsAppManagerApi.install_app(appInfo);
    if (mounted) setState(() {});
    return;
  }

  // 设置卸载函数实现,用于被ListView.builder里的控件当回调函数用
  Future <void> uninstall_app(
    String appId,
    MyButton_FatalWarning? button_uninstall,  // 这个是应用列表中的卸载按钮(如果传入)
    MyButton_AppInfoPage_Uninstall? button_uninstall_this,  // 这个是本页面中的卸载按钮(如果传入)
  ) async {
    // 设置卸载按钮被按下
    int excute_result = 0;

    // 如果是子ListView应用列表页面按下卸载按钮
    if (button_uninstall != null) {
      button_uninstall.is_pressed.value = true;
      excute_result = await LinyapsCliHelper.uninstall_app(appId);
      // 设置安装按钮被释放
      button_uninstall.is_pressed.value = false;
      // 如果启动失败设置启动按钮文字为"失败"提醒用户
      if (excute_result != 0) {
        button_uninstall.text = Text(
          "失败",
          style: TextStyle(
            fontSize: 18, 
            color: Colors.white
          ),
        );
      // 如果成功则触发重构
      } else {
        print('Uninstalled version from $cur_installed_version');
        if (mounted) setState(() {
          cur_installed_version = null;
        });
      }
    }
    
    // 如果是当前应用页面按下卸载按钮
    else if (button_uninstall_this != null) {
      button_uninstall_this.is_pressed.value = true;
      excute_result = await LinyapsCliHelper.uninstall_app(appId);
      // 设置安装按钮被释放
      button_uninstall_this.is_pressed.value = false;
      // 如果启动失败设置启动按钮文字为"失败"提醒用户
      if (excute_result != 0) {
        button_uninstall_this.text = Text(
          "失败",
          style: TextStyle(
            fontSize: 18, 
            color: Colors.white
          ),
        );
      // 如果成功则触发重构
      } else {
        print('Uninstalled version from $cur_installed_version');
        if (mounted) setState(() {
          cur_installed_version = null;
        });
      }
    }

    return;
    
  }

  // 当前页面启动应用的函数
  // 该页面启动应用的方法
  Future <void> launch_app (String appId, MyButton_AppInfoPage_LaunchApp button_launchapp) async {
    // 设置按钮被按下
    button_launchapp.is_pressed.value = true;
    LinyapsCliHelper.launch_installed_app(appId);
    // 设置一定延迟后才允许用户继续按下, 以防用户突然一次按太多下打开过多实例
    await Future.delayed(Duration(milliseconds: 550));
    // 启动后设置按钮被释放
    button_launchapp.is_pressed.value = false;
  }

  @override
  void initState() {
    super.initState();
    // 增加应用/页面状态观察者
    WidgetsBinding.instance.addObserver(this);
    // 初始化应用信息
    cur_app_info_list = null;
    // 初始化appState
    appState = Get.find<ApplicationState>();

    // 初始化当前页面的安装按钮
    install_button = MyButton_AppInfoPage_Install(
      text: Text(
        '安装',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ), 
      is_pressed: ValueNotifier<bool>(false), 
      indicator_width: 30, 
      onPressed: () async {
        await install_app(cur_app_info_list![0], null, install_button);
      }
    );

    // 初始化当前页面的卸载按钮
    uninstall_button = MyButton_AppInfoPage_Uninstall(
      text: Text(
        '卸载',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ), 
      is_pressed: ValueNotifier<bool>(false), 
      indicator_width: 30, 
      onPressed: () async {
        await uninstall_app(
          cur_app_info_list![0].id, 
          null, 
          uninstall_button,
        );
      }
    );

    // 初始化当前页面的启动应用按钮
    launch_app_button = MyButton_AppInfoPage_LaunchApp(
      text: Text(
        '启动',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ), 
      is_pressed: ValueNotifier<bool>(false), 
      indicator_width: 30, 
      onPressed: () async {
        await launch_app(cur_app_info_list![0].id, launch_app_button);
      }
    );

    // 暴力异步获取应用信息
    Future.delayed(Duration.zero).then((_) async {
      // 先检连接状态
      await get_connection_status();
      if (is_connection_good) {
        // 网络状态良好则更新应用具体信息,并更新对应的状态开关
        if (await getAppDetails(widget.appId)) {
          await setAppLocalInfoLoading();
          // 如果商店中有这个应用再更新应用具体安装情况
          await update_app_installed_info(widget.appId);
          await setAppLocalInfoLoaded();
          // 发送全局广播页面加载完成
          await set_page_loaded();
        }
      }
      // 这里之所以用else,是防止对应应用没有时仍然往下加载
      // 因为对应应用如果没有,往下加载会出问题,所以如果应用商店里
      // 没有这个应用就始终设置页面未加载完成防止不必要的Exception
      else
        await set_page_loaded();
    });

    // 开启定时器定时检查
    checkTimer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.inactive) {
        if (is_page_loaded && !is_app_local_info_loading) {
          // 进行刷新本地安装的应用信息
          await appState.updateInstalledAppsList_Online();
          await update_app_installed_info(widget.appId);
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    print('Lifecycle state changed to: $state'); // 添加日志用于调试
    return;
  }

  @override
  void dispose() {
    // 在析构函数里移除观察者
    WidgetsBinding.instance.removeObserver(this);
    // 再移除定时器
    checkTimer?.cancel();
    checkTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    // 传入UI构建用的应用信息, 强制非空用于UI构建
    List <LinyapsPackageInfo> curAppInfo_build = cur_app_info_list ?? [];

    // 获取窗口的相对长宽像素
    double height = MediaQuery.of(context).size.height;
    // double width = MediaQuery.of(context).size.width;

    return YaruTheme(
      data: YaruThemeData(
        themeMode: ThemeMode.system,
      ),
      child: Scaffold(
        body: is_page_loaded
          ? Padding(
            padding: EdgeInsets.only(
              left: 30,
              top: 20,
              right: 30,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 70,
                  height: 40,
                  child: MyButton_Back(
                    // 定义返回操作
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    size: 20,
                  ),
                ),
                // 水平列用来放置应用具体信息UI
                // Expanded用于占据剩下的空间
                Expanded(
                  child: is_connection_good
                    ? ListView(
                      shrinkWrap: true,
                      // 这里检查用户是否把鼠标放到了截图列表上
                      // 截图列表需要借助鼠标滚轮横向滚动
                      // 此时列表不能滚动
                      physics: const ClampingScrollPhysics(),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: 40,
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const SizedBox(width: 10,),
                                  // 先显示图片
                                  CachedNetworkImage(
                                    height: 130,
                                    width: 130,
                                    imageUrl: curAppInfo_build[curAppInfo_build.length - 1].Icon ?? '',
                                    placeholder: (context, url) => Center(
                                      child: YaruCircularProgressIndicator(
                                        strokeWidth:2.5, // 设置加载条宽度
                                      ),
                                    ),
                                    // 无法显示图片时显示错误
                                    errorWidget:(
                                      context,
                                      error,
                                      stackTrace,
                                    ) => Center(
                                      child: Image(
                                        image: AssetImage(
                                          'assets/images/linyaps-generic-app.png',
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 40),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          // 显示应用名字用控件
                                          curAppInfo_build[0].name,
                                          style: TextStyle(
                                            fontSize: 40,
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  curAppInfo_build[0].devName ?? '未知',
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(
                                                  '应用维护者',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 40,
                                              height: 50,
                                              child: VerticalDivider(),
                                            ),
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  curAppInfo_build[0].version,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                const SizedBox(height: 5,),
                                                Text(
                                                  '应用当前版本',
                                                  style: TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 40,
                                              height: 50,
                                              child: VerticalDivider(),
                                            ),
                                            SizedBox(
                                              width: 450,
                                              child: Text(
                                                curAppInfo_build[0].description,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  cur_installed_version == null
                                  ? SizedBox(
                                    height: 45,
                                    width: 120,
                                    child: install_button,
                                  )
                                  : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 45,
                                        width: 120,
                                        child: launch_app_button,
                                      ),
                                      const SizedBox(height: 15,),
                                      SizedBox(
                                        height: 45,
                                        width: 120,
                                        child: uninstall_button,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              // 下面的列式布局用于放置应用具体介绍
                              Text(
                                '应用详情',
                                style: TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                              const SizedBox(height: 20,),
                              Text(
                                curAppInfo_build[0].descInfo ?? '暂无',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 15,),
                              Text(
                                '基础环境: ${curAppInfo_build[0].base}',
                                style: TextStyle(
                                  fontSize: 19,
                                ),
                              ),
                              Text(
                                '运行依赖库: ${curAppInfo_build[0].runtime == null
                                               ? "无"
                                               : curAppInfo_build[0].runtime!.isEmpty
                                                 ? "无"
                                                 : curAppInfo_build[0].runtime!}',
                                style: TextStyle(
                                  fontSize: 19,
                                ),
                              ),
                              const SizedBox(height: 40,),
                              // 检查应用是否有应用截图
                              // 如果有才显示控件
                              curAppInfo_build[0].screenshots != null
                                ? curAppInfo_build[0].screenshots!.isNotEmpty
                                  ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '应用截图',
                                        style: TextStyle(
                                          fontSize: 30,
                                        ),
                                      ),
                                      const SizedBox(height: 25,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          YaruCarousel(
                                            height: 450,
                                            width: 750,
                                            navigationControls: true,
                                            children: AppInfo_SCapList(
                                              SCapList: curAppInfo_build[0].screenshots!,
                                            ).widgets(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 40,),
                                    ],
                                  )
                                  : SizedBox.shrink()
                              : SizedBox.shrink(),
                              Text(
                                '应用版本',
                                style: TextStyle(
                                  fontSize: 30,
                                ),
                              ),
                              const SizedBox(height: 15,),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: curAppInfo_build.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      top: 5.0,
                                      bottom: 5.0,
                                    ),
                                    child: AppInfoListView(
                                      app_info: curAppInfo_build[index],
                                      downloadingAppsQueue: appState.downloadingAppsQueue.cast<LinyapsPackageInfo>(),
                                      is_cur_version_installed:
                                        (cur_installed_version == null)
                                        ? false
                                        : (curAppInfo_build[index].version == cur_installed_version!) ? true : false,
                                      install_app: (appInfo,button_install,) async {
                                        await install_app(
                                          appInfo,
                                          button_install,
                                          null,
                                        );
                                      },
                                      uninstall_app: (appId, button_uninstall) async {
                                        await uninstall_app(
                                          appId,
                                          button_uninstall,
                                          null,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : Center(
                      child: Text(
                        '糟糕,网络连接好像丢掉了呢 :(',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ),
              ],
            ),
          )
        : Padding(
            padding: EdgeInsets.only(
              left: 30,
              top: 20,
              right: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 70,
                  height: 40,
                  child: MyButton_Back(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    size: 20,
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 50,
                            width: 50,
                            child: YaruCircularProgressIndicator(
                              strokeWidth: 5,
                            ),
                          ),
                          SizedBox(height: height * 0.03),
                          Text(
                            "稍等片刻,正在加载应用详情 ~",
                            style: TextStyle(fontSize: height * 0.03),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
