// 应用管理页面

// 忽略VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_App_Management_API/linyaps_app_manager.dart';
import 'package:linglong_store_flutter/utils/Linyaps_CLI_Helper/linyaps_cli_helper.dart';
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

class AppsManagementPageState extends State<AppsManagementPage> {

  // 判断页面是否加载完全的开关
  // 在这里页面加载只用于判断所有应用信息是否加载完成,而不涉及应用更新
  // 判断应用更新情况是否加载完成需要额外的开关
  bool is_page_loaded = false;
  bool is_upgradable_app_loaded = false;

  // 初始化待更新应用抽象列表
  List <LinyapsPackageInfo> get upgradable_apps_list => Provider.of<ApplicationState>(context,listen: false).upgradable_apps_list;

  // 初始化所有本地应用抽象列表
  List <LinyapsPackageInfo> get installed_apps_list => Provider.of<ApplicationState>(context,listen: false).installed_apps_list;

  // 声明"一键升级"按钮对象
  late MyButton_UpgradeAll button_all_upgrade;

  // 用于存储ListView.builder里所有升级对象
  List <MyButton_Upgrade> button_upgrade_list = [];

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
      List <LinyapsPackageInfo> get_upgradable_apps = await LinyapsAppManagerApi().get_upgradable_apps();
      // 更新对应变量并触发页面重构
      Provider.of<ApplicationState>(context,listen: false).updateUpgradableAppsList(get_upgradable_apps);
      return;
    }
  
  // 获取所有应用
  Future <void> updateInstalledAppsList () async 
    {
      List <LinyapsPackageInfo> get_installed_apps = await LinyapsAppManagerApi().get_installed_apps();
      // 更新应用安装信息
      Provider.of<ApplicationState>(context,listen: false).updateInstalledAppsList(get_installed_apps);
      return;
    }
  
  // 获取本地已安装应用图标的方法
  Future <void> updateInstalledAppsIcon () async 
    {
      // 用于存储了带了AppIcon链接的Icon列表
      List<LinyapsPackageInfo> newAppsList = [];
      for (LinyapsPackageInfo i in installed_apps_list)
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
            )
          );
        }
      if (mounted)
        {
          setState(() {
            Provider.of<ApplicationState>(context,listen: false).updateInstalledAppsList(newAppsList);
          });
        }
      return;
    }

  // 更新全部应用的方法
  Future <void> upgradeAllApp (MyButton_UpgradeAll button_upgradeAll,) async 
    {
      // 设置"一键升级"按钮为按下状态
      button_upgradeAll.is_pressed.value = true;
      // 经过迭代器让每个应用的"升级"按钮全部变成加载中
      for (var i in button_upgrade_list)
        {
          // 设置按钮被按下状态为真
          i.is_pressed.value = true;
        }
      for (var i=upgradable_apps_list.length-1;i>=0;i--)
        {
          if (await LinyapsCliHelper().install_app(upgradable_apps_list[i].id, upgradable_apps_list[i].version, upgradable_apps_list[i].current_old_version) != 0)
            {
              button_upgrade_list[i].is_pressed.value = false;
              // 如果安装失败返回失败字样
              button_upgrade_list[i].text = Text(
                "失败",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              );
            }
          // 如果对应应用升级成功
          else 
            {
              // 更新完后进行页面信息的更新
              if (mounted)
                {
                  setState(() {
                    LinyapsPackageInfo appToUpdate = installed_apps_list.firstWhere(
                      (app)=>app.id==upgradable_apps_list[i].id,
                    );     // 先找到要更新的应用
                    appToUpdate.version = upgradable_apps_list[i].version;    // 直接升级版本
                    upgradable_apps_list.removeAt(i);
                  });
                }
            }
        }
    }

  // 进行应用更新 (通过ListView.builder控件按"升级"按钮进行触发)
  Future <void> upgradeApp (MyButton_Upgrade button_upgrade, LinyapsPackageInfo cur_app_info) async
    {
      // 更新当前按钮被按下状态
      button_upgrade.is_pressed.value = true;
      if (await LinyapsCliHelper().install_app(cur_app_info.id, cur_app_info.version, cur_app_info.current_old_version) != 0)
        {
          button_upgrade.is_pressed.value = false;
          // 如果安装失败返回失败字样
          button_upgrade.text = Text(
            "失败",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          );
        }
      // 如果更新成功就触发页面重构
      else 
        {
          // 更新完后进行页面信息的更新
          await updateInstalledAppsList();
          await updateUpgradableAppsList();
          button_upgrade.is_pressed.value = false;
        }
      return;
    }


  // 覆写父类构造函数
  @override
  void initState ()
    {
      super.initState();
      // 初始化"一键升级"按钮对象
      button_all_upgrade = MyButton_UpgradeAll(
        text: Text(
          "一键升级",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ), 
        is_pressed: ValueNotifier<bool>(false), 
        indicator_width: 20, 
        onPressed: () async {
          await upgradeAllApp(button_all_upgrade);
        },
      );

      // 先暴力异步加载页面信息
      Future.delayed(Duration.zero).then((_) async {

        // 更新已安装的应用信息
        // await updateInstalledAppsList();
        
        // 再更新应用图标
        await setPageLoaded();
        await updateInstalledAppsIcon();
        
      });
      // 再暴力异步加载可更新应用信息
      Future.delayed(Duration.zero).then((_) async {
        // 获取应用更新详情
        await ApplicationState().updateUpgradableAppsList_Online();
        // 设置可更新应用信息已完全加载
        setUpgradableAppLoaded();
      });
    }

  @override
  Widget build(BuildContext context) {

    // 获取当前窗口的相对长宽
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // 声明GridView网格视图中当前应该显示多少列对象(跟随屏幕像素改变而改变)
    late int gridViewCrossAxisCount;
    if (width > 1600) gridViewCrossAxisCount = 6;
    else if (width > 1300) gridViewCrossAxisCount = 5;
    else if (width > 1100) gridViewCrossAxisCount = 4;
    else gridViewCrossAxisCount = 3;

    return Consumer<ApplicationState>(
      builder: (context, appState, child) {
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
                                appState.upgradable_apps_list.isNotEmpty
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
                            ? upgradable_apps_list.isEmpty
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
                                child: ListView(    // 不使用ListView.builder方便按下
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),    // 禁止滚动
                                  children: UpgradableAppListItems(
                                    // 进行列表的反转,让应用升级时可以直接从列表尾部操作省去不必要的图标错位问题等
                                    upgradable_apps_info: upgradable_apps_list.reversed.toList(), 
                                    context: context,
                                    exposeUpgradeButton: (button_upgrade) {
                                      button_upgrade_list.add(button_upgrade);
                                    },
                                  ).items(), 
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
                                installed_app_info: installed_apps_list, 
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
