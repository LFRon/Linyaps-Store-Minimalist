import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/main_pages/downloading_page/downloading_page.dart';
import 'package:linglong_store_flutter/pages/main_pages/about_page/about_page.dart';
import 'package:linglong_store_flutter/pages/main_pages/all_apps_page/all_apps_page.dart';
import 'package:linglong_store_flutter/pages/main_pages/application_management/application_management.dart';
import 'package:linglong_store_flutter/pages/main_pages/leaderboard_app_page/leaderboard_page.dart';
import 'package:linglong_store_flutter/pages/main_pages/my_side_menu/my_side_menu.dart';
import 'package:linglong_store_flutter/pages/main_pages/recommend_app_page/recommend_app_page.dart';

class MainMiddlePage extends StatefulWidget {
  
  const MainMiddlePage({super.key});

  @override
  State<MainMiddlePage> createState() => _MainMiddlePageState();
}


class _MainMiddlePageState extends State<MainMiddlePage> {

  // 初始化会传入的中间页控制器
  PageController pageController=PageController();  // 传入当前页面控制器方便直接切换页面

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MySideMenu(pageController: pageController),
          Expanded(
            child: PageView(
              controller: pageController,
              // 禁用pageView自带的左右滑动切换手势效果
              physics: const NeverScrollableScrollPhysics(),
              children: [
                RecommendAppPage(),
                LeaderboardPage(),
                AllAppsPage(),
                AppsManagementPage(),
                DownloadingPage(),
                AboutPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
