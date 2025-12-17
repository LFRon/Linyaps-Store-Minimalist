// 应用管理页面

// 忽略VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, use_build_context_synchronously, unnecessary_overrides

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/state_manager.dart';
import 'package:get/utils.dart';
import 'package:linglong_store_flutter/utils/Check_Connection_Status/check_connection_status.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_App_Management_API/linyaps_app_manager.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_store_api_service.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/application_management/installed_apps_grid_items.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/application_management/upgradable_app_grid_item.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/application_management/buttons/refresh_upgradable_apps_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/application_management/buttons/upgrade_all_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/application_management/buttons/upgrade_button.dart';

class AppsManagementPage extends StatefulWidget {

  const AppsManagementPage({super.key});

  @override
  State<AppsManagementPage> createState() => AppsManagementPageState();
}

class AppsManagementPageState extends State<AppsManagementPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  // 覆写页面希望保持存在状态开关
  @override
  bool get wantKeepAlive => true; 

  // 增加页面检查定时器
  Timer? checkTimer;

  // 检查页面自身是否为打开应用后的第一次加载,初始化为真
  bool _is_page_first_loading = true;

  // 检查网络连接是否正常的开关,初始化为假
  bool is_connection_good = false;

  // 检查页面本地应用信息是否在加载的开关
  bool is_installed_apps_loading = false;

  // 检查页面应用图标获取进程是否在进行的状态开关
  bool is_app_icons_loading = false;

  // 检查页面待更新应用获取进程是否在进行的状态开关
  bool is_upgradable_apps_loading = false;

  // 检查当前页面所有应用是否都在下载队列里的状态开关,默认为真
  bool is_apps_all_upgrading = true;

  // 判断页面是否加载完全的状态开关
  // 在这里页面加载只用于判断所有应用信息是否加载完成,而不涉及应用更新
  // 判断应用更新情况是否加载完成需要额外的开关
  bool is_page_loaded = false;

  // 声明全局应用列表对象
  late ApplicationState globalAppState;

  // 声明"一键升级"按钮对象
  late MyButton_UpgradeAll button_all_upgrade;

  // 声明"刷新待更新应用"按钮对象
  late MyButton_RefreshUpgradableApps button_refresh_upgradable_apps;

  // 用于存储ListView.builder里所有升级对象
  List <MyButton_Upgrade> button_upgrade_list = [];

  // 更新当前网络连接状态
  Future <void> updateConnectionStatus () async {
    bool get_connection_status = await CheckInternetConnectionStatus.staus_is_good();
    if (mounted) setState(() {
      is_connection_good = get_connection_status;
    });
  }

  // 更新页面为加载完成的方法
  Future <void> setPageLoaded () async {
    if (mounted) setState(() {
      is_page_loaded = true;
    });
    return;
  }

  // 设置页面正在获取本地应用的状态改变方法
  Future <void> setInstalledAppsLoading () async {
    if (mounted) setState(() {
      is_installed_apps_loading = true;
    });
  }

  // 设置页面完成获取本地应用的状态改变方法
  Future <void> setInstalledAppsLoaded () async {
    if (mounted) setState(() {
      is_installed_apps_loading = false;
    });
  }

  // 设置页面正在获取应用图标的方法
  Future <void> setAppsIconLoading () async {
    if (mounted) setState(() {
      is_app_icons_loading = true;
    });
    return;
  }

  // 设置页面已完成获取应用图标的方法
  Future <void> setAppsIconLoaded () async {
    if (mounted) setState(() {
      is_app_icons_loading = false;
    });
    return;
  }

  // 设置页面正在获取待更新应用的方法
  Future <void> setUpgradableAppLoading () async {
    if (mounted) setState(() {
      is_upgradable_apps_loading = true;
    });
    return;
  }
  
  // 设置页面获取待更新应用已完成的方法
  Future <void> setUpgradableAppLoaded () async {
    if (mounted) setState(() {
      is_upgradable_apps_loading = false;
    });
    return;
  }

  // 更新待更新应用列表方法
  Future <void> updateUpgradableAppsList () async {
    // 更新对应变量并触发页面重构
    await globalAppState.updateUpgradableAppsList_Online();
    return;
  }
  
  // 调用在线功能获取所有应用
  Future <void> updateInstalledAppsList () async {
    await globalAppState.updateInstalledAppsList_Online();
    return;
  }
  
  // 获取本地已安装应用图标的方法
  Future <void> updateInstalledAppsIcon () async {
    // 用于存储了带了AppIcon链接的Icon列表
    List <LinyapsPackageInfo> newAppsList = await LinyapsStoreApiService.updateAppIcon(globalAppState.installedAppsList.cast<LinyapsPackageInfo>());
    if (mounted) setState(() {
      globalAppState.updateInstalledAppsList(newAppsList);
    });
    return;
  }

  /*
  // 同时获取本地应用图标链接与待更新应用的方法
  Future <void> updateAppsIconAndUpgradeAppsList () async {
    // 用于存储了带了AppIcon链接的Icon列表
    List <List<LinyapsPackageInfo>> newAppsList = await LinyapsStoreApiService.get_upgradable_apps_and_icon(globalAppState.installedAppsList.cast<LinyapsPackageInfo>());
    if (mounted) setState(() {
      globalAppState.updateInstalledAppsList(newAppsList[0]);
      globalAppState.updateUpgradableAppsList(newAppsList[1]);
    });
    return;
  }
  */

  // 更新全部应用的回调方法, 用于待更新列表内函数实现
  Future <void> upgradeAllApp () async {
    for (LinyapsPackageInfo i in globalAppState.upgradableAppsList) {
      await LinyapsAppManagerApi.install_app(i);
    }
    return;
  }

  // 更新指定应用的回调方法, 用于待更新列表内函数实现
  Future <void> upgradeApp (LinyapsPackageInfo wait_upgrade_app) async {
    await LinyapsAppManagerApi.install_app(wait_upgrade_app);
  }
  
  // 当用户重新切回页面时执行函数
  @override
  void didChangeAppLifecycleState (AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    // ignore: avoid_print
    print('Lifecycle state changed to: $state'); // 添加日志用于调试
  }
  

  // 覆写父类构造函数
  @override
  void initState () {
    super.initState();
    // 添加页面观察者
    WidgetsBinding.instance.addObserver(this); 
    if(_is_page_first_loading) {
      // 首次加载时初始化globalAppState
      globalAppState = Get.find<ApplicationState>();
      _is_page_first_loading = false;
      // 先暴力异步加载页面信息
      Future.microtask(() async {
        // 更新已安装的应用信息
        await updateInstalledAppsList();
        // 再更新网络连接状态
        await updateConnectionStatus();
        await setPageLoaded();
        if (is_connection_good) {
          // 如果网络状态好, 则同时进行获取应用图标与待更新应用信息
          Future.microtask(() async {
            await setAppsIconLoading();
            await updateInstalledAppsIcon();
            await setAppsIconLoaded();
          });
          Future.microtask(() async {
            await setUpgradableAppLoading();
            await updateUpgradableAppsList();
            await setUpgradableAppLoaded();
          });
        } else {    // 当网络连接异常的时候只设置页面加载完成
          await setPageLoaded();
        }      
      });
    } 

    // 开启定时器开始定时更新页面信息
    checkTimer = Timer.periodic(Duration(milliseconds: 500), (timer) async {
      // 加入检查页面是否在加载开关,如果已经在加载则避免无意义的重复加载
      if (mounted && (WidgetsBinding.instance.lifecycleState != AppLifecycleState.inactive || WidgetsBinding.instance.lifecycleState == null)) {
        if (!is_installed_apps_loading) {
          await setInstalledAppsLoading();
          bool is_installed_apps_updated = await refreshInstalledApps();
          await setInstalledAppsLoaded();
          if (is_installed_apps_updated) await refreshAppIcons();
        }
      }
    });
    
  }

  //// 抽象出页面二次加载时的数据加载过程
  // 且仅在页面状态为没有加载时进行加载
  // 用于刷新已安装状态的应用, 如果安装的应用有更新则返回true, 否则返回false
  Future <bool> refreshInstalledApps () async {
    // 如果页面当前处于暂停加载的状态
    // 网络好的话那么就更新已安装的应用信息
    bool is_installed_apps_updated = await globalAppState.updateInstalledAppsList_Online();
    return is_installed_apps_updated;
  }

  // 用于刷新应用图标的函数
  Future <void> refreshAppIcons () async {
    // 如果页面当前处于暂停加载的状态
    // 网络好的话那么就更新已安装的应用信息
    if (!is_app_icons_loading) {
      await setAppsIconLoading();
      // 那就先检查网络连接状态
      // 这里之所以没有进行全局刷新, 是因为考虑到用户可能同时按下刷新待更新应用并同时获取图标的行为
      // 直接await updateConnectionStatus();很可能会带来不可测的问题
      // 因此这里进行独立检查
      bool connection_status = await CheckInternetConnectionStatus.staus_is_good();
      // 再执行具体更新函数功能
      if (connection_status) await updateInstalledAppsIcon();
      // 设置页面更新状态为已完成
      await setAppsIconLoaded();
    }
    return;
  }

  Future <void> refreshUpgradableApps () async {
    // 如果页面当前处于暂停加载的状态
    // 网络好的话那么就更新已安装的应用信息
    if (!is_upgradable_apps_loading) {
      // 先设置页面为加载中状态
      await setUpgradableAppLoading();
      // 那就先检查网络连接状态
      await updateConnectionStatus();
      if (is_connection_good) await updateUpgradableAppsList();
      // 设置页面更新状态为已完成
      await setUpgradableAppLoaded();
    }
    return;
  }

  @override
  void dispose () {
    // 销毁时移除观察者
    WidgetsBinding.instance.removeObserver(this); 
    // 销毁定时器
    checkTimer?.cancel();
    checkTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 获取当前窗口的相对长宽
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // 声明GridView网格视图中当前应该显示多少列对象(跟随屏幕像素改变而改变)
    late int gridViewCrossAxisCount;
    if (width > 1600) gridViewCrossAxisCount = 6;
    else if (width > 1450) gridViewCrossAxisCount = 5;
    else if (width > 1100) gridViewCrossAxisCount = 4;
    else gridViewCrossAxisCount = 3;

    // 使用Consumer对ApplicationState实例进行监听
    return GetBuilder <ApplicationState> (
      builder: (appState) {

        // 先假设每个应用都在进行升级
        is_apps_all_upgrading = true;
        // 然后通过遍历下载中的列表来验证真的假的
        for (LinyapsPackageInfo i in globalAppState.upgradableAppsList) {
          // 寻找下载列表里有没有待升级应用
          LinyapsPackageInfo? cur_app = appState.downloadingAppsQueue.firstWhereOrNull(
            (app) => app.id == i.id && app.version == i.version,
            // 如果找不到就返回Null
          );
          if (cur_app == null) {
            is_apps_all_upgrading = false;
            break;
          }
        }

        // 初始化"一键升级"按钮对象
        button_all_upgrade = MyButton_UpgradeAll(
          text: Text(
            "一键升级",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ), 
          // 若识别到所有应用都在下载队列里则直接显示为加载中
          is_pressed: ValueNotifier<bool>(is_apps_all_upgrading), 
          indicator_width: 22, 
          onPressed: () async {
            await upgradeAllApp();
          },
        );

        // 初始化"刷新待更新应用"按钮对象
        button_refresh_upgradable_apps = MyButton_RefreshUpgradableApps(
          onPressed: () async {
            await refreshUpgradableApps();
          }, 
          text: Text(
            '刷新待更新应用',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white
            ),
          ),
        );

        return Scaffold(
          body: is_page_loaded
            ? Padding(
              padding: EdgeInsets.only(left: 30,right: 30, top: 20,bottom: 20),
              child: ListView(
                children: [
                  // 第一个子行用于显示应用应用更新信息
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          // 只是设置右侧"一键升级"与右侧的间距而已
                          Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "应用更新信息:",
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                                // 页面是否在获取待更新应用, 如果是则仅显示加载动画
                                is_upgradable_apps_loading
                                  ? SizedBox()
                                  : appState.upgradableAppsList.isNotEmpty
                                    ? Row(
                                      children: [
                                        SizedBox(
                                          height: 45,
                                          width: 170,
                                          child: button_refresh_upgradable_apps
                                        ),
                                        const SizedBox(width: 20,),
                                        SizedBox(
                                          height: 45,
                                          width: 120,
                                          child: button_all_upgrade
                                        )
                                      ],
                                    )
                                    : SizedBox(
                                      height: 45,
                                      width: 170,
                                      child: button_refresh_upgradable_apps
                                    ),
                              ],
                            ),
                          ),
                          // 根据是否有可更新应用输出不同内容
                          // 只有当首次加载且页面在检查应用更新, 才显示加载动画
                          (!is_upgradable_apps_loading)
                            ? is_connection_good
                              ? appState.upgradableAppsList.isEmpty
                                ? SizedBox(
                                  height: 150,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          size: 50,
                                          color: Colors.black.withValues(alpha: 0.5),
                                          Icons.update,
                                        ),
                                        SizedBox(width: 30,),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "您安装的所有应用都为最新 :)",
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              "然而您并未站在世界之巅 ~ (坏笑)",
                                              style: TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : Padding(    // 设置上下控件间距离
                                  padding: EdgeInsets.only(top:12.0,bottom: 15.0,right: width*0.01),
                                  child: ListView.builder(    // 不使用ListView.builder方便按下
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),    // 禁止滚动
                                    itemCount: appState.upgradableAppsList.length,
                                    itemBuilder:(context, index) {
                                      return UpgradableAppListItems(
                                        cur_upgradable_app_info: appState.upgradableAppsList[index], 
                                        upgrade_cur_app: (cur_upgradable_app_info) async {
                                          await upgradeApp(cur_upgradable_app_info);
                                        },
                                        context: context, 
                                      ).item();
                                    }, 
                                  ),
                                )
                              // 如果应用可更新信息未加载完
                              : SizedBox(
                                height: 120,
                                child: Center(
                                  child: Text(
                                    '糟糕, 网络连接好像丢掉了呢 :(',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade600
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                              height: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '正在检查应用更新',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  SizedBox(
                                    width: 140,
                                    height: 3,
                                    child: LinearProgressIndicator(
                                      color: Colors.blueAccent,
                                      minHeight: 4.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Text(
                                "已安装的应用:",
                                style: TextStyle(
                                  fontSize: 25,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: height*0.02,right: width*0.01),
                            child: GridView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridViewCrossAxisCount,
                                mainAxisSpacing: height * 0.02,
                                crossAxisSpacing: width * 0.02,
                              ), 
                              children: InstalledAppsGridItems(
                                installed_app_info: appState.installedAppsList.cast<LinyapsPackageInfo>(), 
                                context: context, 
                                height: height, 
                                width: width,
                              ).items(),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
            : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: Colors.grey.shade500,
                      strokeWidth: 5,
                    ),
                  ),
                  SizedBox(height: 35,),
                  Text(
                    "正在载入本地应用信息 ~",
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
        );
      },
    );
  }
}
