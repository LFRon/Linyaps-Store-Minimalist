// 应用管理页面

// 忽略VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, use_build_context_synchronously, unnecessary_overrides

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Check_Connection_Status/check_connection_status.dart';
import 'package:linglong_store_flutter/utils/Linyaps_App_Management_API/linyaps_app_manager.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/global_variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/pages_utils/application_management/installed_apps_grid_items.dart';
import 'package:linglong_store_flutter/utils/pages_utils/application_management/upgradable_app_grid_item.dart';
import 'package:linglong_store_flutter/utils/pages_utils/my_buttons/upgrade_all_button.dart';
import 'package:linglong_store_flutter/utils/pages_utils/my_buttons/upgrade_button.dart';
import 'package:provider/provider.dart';

class AppsManagementPage extends StatefulWidget {

  const AppsManagementPage({super.key});

  @override
  State<AppsManagementPage> createState() => AppsManagementPageState();
}

class AppsManagementPageState extends State<AppsManagementPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  // 覆写页面希望保持存在状态开关
  @override
  bool get wantKeepAlive => true; 

  // 检查网络连接是否正常的开关,初始化为假
  bool is_connection_good = false;

  // 检查页面自身是否在加载的状态开关
  bool is_page_loading = false;

  // 检查当前页面所有应用是否都在下载队列里,默认为真
  bool is_apps_all_upgrading = true;

  // 判断页面是否加载完全的开关
  // 在这里页面加载只用于判断所有应用信息是否加载完成,而不涉及应用更新
  // 判断应用更新情况是否加载完成需要额外的开关
  bool is_page_loaded = false;
  bool is_upgradable_app_loaded = false;


  // 声明全局应用列表对象
  late ApplicationState globalAppState;

  // 声明"一键升级"按钮对象
  late MyButton_UpgradeAll button_all_upgrade;

  // 用于存储ListView.builder里所有升级对象
  List <MyButton_Upgrade> button_upgrade_list = [];

  // 更新当前网络连接状态
  Future <void> updateConnectionStatus () async 
    {
      bool get_connection_status = await CheckInternetConnectionStatus().staus_is_good();
      if (mounted)
        {
          setState(() {
            is_connection_good = get_connection_status;
          });
        }
    }

  // 更新页面加载状态为加载中的方法
  Future <void> setPageLoading () async 
    {
      if (mounted)
        {
          setState(() {
            is_page_loading = true;
          });
        }
      return;
    }
  
  // 更新页面加载状态为加载完成的方法
  Future <void> setPageNotLoading () async 
    {
      if (mounted)
        {
          setState(() {
            is_page_loading = true;
          });
        }
      return;
    }

  // 更新页面为加载完成的方法
  Future <void> setPageLoaded () async 
    {
      if (mounted)
        {
          setState(() {
            is_page_loaded = true;
          });
        }
      return;
    }
  
  // 更新页面应用更新情况已完成的方法
  Future <void> setUpgradableAppLoaded () async 
    {
      if (mounted)
        {
          setState(() {
            is_upgradable_app_loaded = true;
          });
        }
      return;
    }

  // 更新待更新应用列表方法
  Future <void> updateUpgradableAppsList () async 
    {
      // List <LinyapsPackageInfo> get_upgradable_apps = await LinyapsAppManagerApi().get_upgradable_apps();
      // 更新对应变量并触发页面重构
      await globalAppState.updateUpgradableAppsList_Online();
      if (mounted) setState(() {});
      return;
    }
  
  // 获取所有应用
  Future <void> updateInstalledAppsList () async 
    {
      await globalAppState.updateInstalledAppsList_Online(globalAppState.installedAppsList);
      // 更新应用安装信息
      if (mounted) setState(() {});
      return;
    }
  
  // 获取本地已安装应用图标的方法
  Future <void> updateInstalledAppsIcon () async 
    {
      // 用于存储了带了AppIcon链接的Icon列表
      List <LinyapsPackageInfo> newAppsList = [];
      for (LinyapsPackageInfo i in globalAppState.installedAppsList)
        {
          String cur_app_icon = await LinyapsAppManagerApi().getAppIcon(i.id);
          newAppsList.add(
            LinyapsPackageInfo(
              id: i.id, 
              name: i.name, 
              version: i.version, 
              description: i.description, 
              arch: i.arch,
              Icon: cur_app_icon,
              IconUpdated: 1,     // 设置图片已加载过
            )
          );
        }
      if (mounted)
        {
          setState(() {
            globalAppState.updateInstalledAppsList(newAppsList);
          });
        }
      return;
    }

  // 更新全部应用的方法
  Future <void> upgradeAllApp (MyButton_UpgradeAll button_upgradeAll,) async 
    {
      for (var i in globalAppState.upgradableAppsList)
        {
          await LinyapsAppManagerApi().install_app(i, context);
        }
    }

  // 进行应用更新 (通过ListView.builder控件按"升级"按钮进行触发)
  Future <void> upgradeApp (LinyapsPackageInfo cur_app_info) async
    {
      // 将应用推入下载列表
      await LinyapsAppManagerApi().install_app(cur_app_info, context);
      if (mounted) setState(() {});
      return;
    }

  // 在initState周期之后调用拿到应用列表
  @override 
  void didChangeDependencies ()
    {
      super.didChangeDependencies();
      // 初始化全局对象
      if(!is_page_loading)
        {
          // 拿到可更新应用和已安装应用的列表
          globalAppState = context.watch<ApplicationState>();
          
          // 先暴力异步加载页面信息
          Future.microtask(() async {
            // 更新当前页面状态为加载中
            await setPageLoading();
            // 更新已安装的应用信息
            await globalAppState.updateInstalledAppsList_Online(globalAppState.upgradableAppsList);
            await setPageLoaded();
            await updateInstalledAppsIcon();
          });

          // 再暴力异步加载可更新应用信息
          Future.microtask(() async {
            // 获取应用更新详情
            await globalAppState.updateUpgradableAppsList_Online();
            // 在这里设置页面已加载完未在加载状态
            await setPageNotLoading();
            // 设置可更新应用信息已完全加载
            setUpgradableAppLoaded();
          });
        }
    }

  // 覆写父类构造函数
  @override
  void initState ()
    {
      super.initState();

      // 添加页面观察者
      WidgetsBinding.instance.addObserver(this);  

    }

  // 抽象出数据加载过程
  // 且仅在页面状态为没有加载时进行加载
  Future <void> _refreshPageData () async 
    {
      // 如果页面当前处于暂停加载的状态
      // 那就先检查网络连接状态
      await updateConnectionStatus();
      // 网络好的话那么就更新已安装的应用信息
      if (!is_page_loading && is_connection_good)
        {
          // 先设置页面为加载中状态
          await setPageLoading();
          // 再执行具体更新函数功能
          await updateInstalledAppsList();
          await updateUpgradableAppsList();
          await updateInstalledAppsIcon();
          // 设置页面更新状态为已完成
          await setPageNotLoading();
        }
    }
  
  // 当用户重新切回页面时执行函数
  @override
  void didChangeAppLifecycleState (AppLifecycleState state) async
    {
      super.didChangeAppLifecycleState(state);
      if (state == AppLifecycleState.resumed && !is_page_loading)
        {
          await _refreshPageData();
        }
    }

  @override
  void dispose ()
    {
      // 销毁时移除观察者
      WidgetsBinding.instance.removeObserver(this); 
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
    else if (width > 1350) gridViewCrossAxisCount = 5;
    else if (width > 1100) gridViewCrossAxisCount = 4;
    else gridViewCrossAxisCount = 3;

    // 使用Consumer对ApplicationState实例进行监听
    return Consumer <ApplicationState> (
      builder: (context, appState, child) {
        // 先假设每个应用都在进行升级
        is_apps_all_upgrading = true;
        // 然后通过遍历下载中的列表来验证真的假的
        for (var i in appState.upgradableAppsList)
          {
            // 寻找下载列表里有没有待升级应用
            LinyapsPackageInfo cur_app = appState.downloadingAppsQueue.firstWhere(
              (app) => app.id == i.id && app.version == i.version,
              // 如果找不到就返回空对象
              orElse: () => LinyapsPackageInfo(
                id: '', 
                name: '', 
                version: '', 
                description: '', 
                arch: ''
              ),
            );
            if (cur_app.id == '')
              {
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
            await upgradeAllApp(button_all_upgrade);
          },
        );
        return Scaffold(
          body: is_page_loaded
            ? Padding(
              padding: EdgeInsets.only(left: width*0.02,right: width*0.03,top: height*0.03,bottom: height*0.03),
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
                            padding: EdgeInsets.only(right: width*0.01),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "应用更新信息:",
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                                // 如果有可更新的应用则全部更新
                                appState.upgradableAppsList.isNotEmpty
                                  ? SizedBox(
                                    height: 45,
                                    width: 120,
                                    child: button_all_upgrade
                                  )
                                  : SizedBox(),
                              ],
                            ),
                          ),
                          // 根据是否有可更新应用输出不同内容
                          is_upgradable_app_loaded
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
                                      context: context, 
                                    ).item();
                                  }, 
                                ),
                              )
                            // 如果应用可更新信息未加载完
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
                                installed_app_info: appState.installedAppsList, 
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
                    height: height*0.06,
                    width: height*0.06,
                    child: CircularProgressIndicator(
                      color: Colors.grey.shade500,
                      strokeWidth: 4.5,
                    ),
                  ),
                  SizedBox(height: height*0.03,),
                  Text(
                    "正在载入本地应用信息 ~",
                    style: TextStyle(
                      fontSize: height*0.025,
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
