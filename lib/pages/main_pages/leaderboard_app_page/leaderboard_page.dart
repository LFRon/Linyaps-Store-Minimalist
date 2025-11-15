// 应用排行榜页面

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Check_Connection_Status/check_connection_status.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_store_api_service.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/leaderboard_app_page/MostDownloadAppsItems.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/leaderboard_app_page/NewestAppsItems.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/leaderboard_app_page/my_ratios/my_ratio.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  // 覆写页面希望保持存在状态开关
  // bool get wantKeepAlive => true;

  // 声明网络连接状态,默认状态为不好
  bool is_connection_good = false;

  // 声明页面加载状态控制开关,默认情况下为未加载完
  bool is_page_loaded = false;

  // 声明显示是最近更新应用还是下载应用的变量,1代表最近更新,2代表下载最多
    int radio_choice = 1;

  // 声明从API服务获取的排行榜应用信息对象
  List<LinyapsPackageInfo> AppsRakingList = [];

  // 刷新网络状态用函数
  Future<void> updateConnectionStatus() async {
    bool connection_status_get = await CheckInternetConnectionStatus().staus_is_good();
    if (mounted) {
      setState(() {
        is_connection_good = connection_status_get;
      });
    }
  }

  // 从API服务中获取顶栏展示应用列表信息
  Future<void> updateAppsRakingList(int radio_choice) async {
    List<LinyapsPackageInfo> await_get = [];
    if (radio_choice == 1) await_get = await LinyapsStoreApiService().get_newest_app_list();
    else if (radio_choice == 2) await_get = await LinyapsStoreApiService().get_most_downloaded_app_list();
    if (mounted) {
      setState(() {
        AppsRakingList = await_get;
      });
    }
  }

  // 设置页面加载完成的函数
  Future<void> setPageLoaded() async {
    if (mounted) {
      setState(() {
        is_page_loaded = true;
      });
    }
  }

  // 抽象出页面加载函数,方便用户选择看哪个排行榜时进行重载
  Future <void> loadPage() async {
    // 先设置页面加载状态为假
    if (mounted) {
      setState(() {
        is_page_loaded = false;
      });
    }
    // 再进行页面加载
    // 先更新网络状态
    await updateConnectionStatus();
    if (is_connection_good) {
      // 如果网络连接状态正常就更新应用列表
      await updateAppsRakingList(radio_choice);
    }
    // 设置页面加载状态为完成
    await setPageLoaded();
  }

  // 覆写父类构造函数
  @override
  void initState() {
    super.initState();

    // 直接强开异步加载必需内容
    Future.delayed(Duration.zero).then((_) async {
      await loadPage();
    });

  }

  @override
  Widget build(BuildContext context) {
    
    // 获取当前窗口的相对长宽
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // 声明GridView网格视图中当前应该显示多少列对象(跟随屏幕像素改变而改变)
    late int gridViewCrossAxisCount;
    if (width > 1800) gridViewCrossAxisCount = 6;
    else if (width > 1550) gridViewCrossAxisCount = 5;
    else if (width > 1100) gridViewCrossAxisCount = 4;
    else gridViewCrossAxisCount = 3;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: 0,
          bottom: 50,
          left: 30,
          right: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height*0.1,
              width: width*0.5,
              child: MyRadio_SelectNewOrMost(
                width: width,
                height: height,
                onChanged:(value) async {
                  // 从回调函数拿来返回值
                  if (mounted)
                    {
                      setState(() {
                        radio_choice = value;
                      });
                    }
                  // 再执行页面重载函数
                  await loadPage();
                },
              ),
            ),
            is_page_loaded     // 先检查页面是否完全加载
              ? is_connection_good      // 再检查网络连接状态
                ? Flexible(
                  child: GridView(
                    // 先设置网格UI样式
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridViewCrossAxisCount, // 设置水平网格个数
                      mainAxisSpacing: height * 0.02,
                      crossAxisSpacing: width * 0.02,
                    ),
                    children: radio_choice == 1
                      ? NewestAppGridItems(
                        NewestAppsList: AppsRakingList,
                        context: context,
                        height: height * 0.9,
                        width: height * 0.8,
                      ).Items()
                      : MostDownloadAppGridItems(
                        NewestAppsList: AppsRakingList,
                        context: context,
                        height: height * 0.9,
                        width: height * 0.8,
                      ).Items(),
                  ),
                )
                : Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          "啊哦,网络连接好像被吃掉了呢 :(",
                          style: TextStyle(
                            fontSize: height*0.03,
                            color: Colors.grey.shade600
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Flexible(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: height * 0.06,
                        width: height * 0.06,
                        child: CircularProgressIndicator (
                          color: Colors.grey.shade500,
                          strokeWidth: 4.5,
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      Text(
                        "稍等片刻,正在加载应用排行榜信息 ~",
                        style: TextStyle(fontSize: height * 0.022),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      )
    );
  }
}
