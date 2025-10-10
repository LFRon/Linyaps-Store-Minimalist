// 设计应用侧边栏页面

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:sidebar_with_animation/animated_side_bar.dart';

class MySideMenu extends StatefulWidget {

  PageController pageController;  // 传入当前页面控制器方便直接切换页面

  MySideMenu({
    super.key,
    required this.pageController,
  });

  @override
  State<MySideMenu> createState() => _MySideMenuState();
}

class _MySideMenuState extends State<MySideMenu> {

  late PageController pageController;    // 先在类里声明页面控制器对象等一下在构造函数里初始化 

  List <SideBarItem> my_sidebar_item = [    // 设置侧边栏的按钮成员属性们
    SideBarItem(
      iconSelected: Icons.star,
      iconUnselected: Icons.star_border,
      text: '应用推荐',
    ),
    SideBarItem(
      iconSelected: Icons.leaderboard,
      iconUnselected: Icons.leaderboard_outlined,
      text: '应用排行榜',
    ),
    SideBarItem(
      iconSelected: Icons.home,
      iconUnselected: Icons.home_outlined,
      text: '全部应用',
    ),
    SideBarItem(
      iconSelected: Icons.apps,
      iconUnselected: Icons.apps_outlined,
      text: '应用管理',
    ),
    SideBarItem(
      iconSelected: Icons.download,
      iconUnselected: Icons.download_outlined,
      text: '下载管理',
    ),
    SideBarItem(
      iconSelected: Icons.info,
      iconUnselected: Icons.info_outlined,
      text: '关于应用',
    ),
  ];

  @override
  void initState ()
    {
      super.initState();
      // 传入页面控制器
      pageController=widget.pageController;
    }

  @override
  Widget build(BuildContext context) {
    return SideBarAnimated(
      mainLogoImage: 'assets/images/linyaps_icon.png', 
      sidebarItems: my_sidebar_item, 
      borderRadius: 20,
      sideBarWidth: 190, 
      widthSwitch: 100,
      // 强制指定字体用于修复Linux ARM下CJK字体渲染问题
      textStyle: TextStyle(
        color: Colors.white,
        fontFamily: "HarmonyOS Sans",
        fontFamilyFallback: [
          'Noto Color Emoji',
        ],
        fontSize: 16,
      ),
      onTap: (page){
        try {
          pageController.jumpToPage(page);
        }
        catch (e) {
          // 防止某些人(比如我)手速过快导致页面来不及加载
          WidgetsBinding.instance.addPostFrameCallback((_){
            if (mounted && pageController.hasClients) pageController.jumpToPage(page);
          });
        }
      }
    );
  }
}
