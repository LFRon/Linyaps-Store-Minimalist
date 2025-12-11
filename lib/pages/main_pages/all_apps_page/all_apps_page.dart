// 显示全部应用的页面

// 关闭VSCode非必要报错
// ignore_for_file: curly_braces_in_flow_control_structures, non_constant_identifier_names, avoid_function_literals_in_foreach_calls

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Check_Connection_Status/check_connection_status.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_store_api_service.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/all_apps_page/all_apps_grid_items.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/all_apps_page/bottom_loading_widget.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/fatal_warning_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/search_button.dart';

class AllAppsPage extends StatefulWidget {

  const AllAppsPage({super.key});

  @override
  State<AllAppsPage> createState() => _AllAppsPageState();
}

class _AllAppsPageState extends State<AllAppsPage> {

  // 声明存储当前已加载的所有应用信息列表对象
  List <LinyapsPackageInfo> cur_app_list = [];

  // 声明并初始化应该加载的页数
  int curPageStart = 1;
  
  // 声明每次加载多少的对象
  int curPageSize = 100;

  // 用于确认页面是否加载完成的对象,初始化为未完成
  bool is_page_loaded = false;

  // 用于确认是否有更多的应用在加载,初始化为否
  bool is_app_info_loading = false;

  // 用于检查当前网络连接状态, 初始化为假
  bool is_connection_good = false;

  // 声明滚动监听器,用于监听用户是否滚到了最底部
  late ScrollController _scrollController;

  // 声明搜索按钮对象
  late MyButton_SearchItem button_search;

  // 声明重置搜索结果按钮对象
  late MyButton_FatalWarning button_reset;

  // 声明搜索栏的文本控制器
  final TextEditingController _controller_searchtext = TextEditingController();

  // 刷新网络连接状态的函数
  Future <void> update_connection_status () async {
    // 先异步获取网络连接状态
    bool get_connection_status =  await CheckInternetConnectionStatus.staus_is_good();
    // 刷新变量信息并触发页面重构
    if (mounted) {
      setState(() {
        is_connection_good = get_connection_status;
      });
    }
    return;
  }
  
  // 重置按钮按下后重置页面的函数
  Future <void> reloadPage_all () async {
    // 先重置curPage迭代器,cur_app_list列表里的应用信息
    curPageStart = 1;
    cur_app_list = [];
    // 先重置页面加载状态
    await resetPageStatus();
    // 重新执行加载页面函数
    await loadPage_allApps();
    await setPageLoaded();
    return;
  }

  // 搜索按钮按下后重置页面显示信息为搜索结果的函数
  Future <void> reloadPage_searchResult () async {
    // 先重置页面加载状态
    await resetPageStatus();
    // 先更新网络连接状态
    await update_connection_status();
    if (is_connection_good) {
      // 调用具体函数更新应用更新状态
      await getSearchResult(_controller_searchtext.text);
    }     
    await setPageLoaded();
    return;
  }

  // 显示底部的加载动画方法
  Future <void> showMoreAppsLoadingPopWindow () async {
    await BottomLoading_AllApps(context: context,).show();
    return;
  }
  // 隐藏底部的加载动画方法
  Future <void> hideMoreAppsLoadingPopWindow () async {
    if (Navigator.canPop(context)) Navigator.pop(context);
    return;
  }

  // 加载具体的应用信息方法
  Future <void> updateAppList () async {
    // 声明新的变量用来承接新获得的应用信息
    List <LinyapsPackageInfo> app_info_get = await LinyapsStoreApiService.get_all_app_list(
      curPageStart, 
      curPageSize, 
    );
    
    // 触发页面重构并修改对应变量
    if (mounted) setState(() {
      // 将获得的元素信息加入cur_app_list
      app_info_get.forEach((app_info) {
        cur_app_list.add(app_info);
      });
      // 起始页面信息后移
      curPageStart++;
    });
    return;
  }

  // 与后端中间件对接的搜索方法
  Future <void> getSearchResult (String searchId) async {
    // 声明新的变量用来承接新获得的应用信息
    List <LinyapsPackageInfo> app_info_get = await LinyapsStoreApiService.get_search_results(
      searchId,
    );
    // 更新应用列表
    if (mounted) {
      setState(() {
        cur_app_list = app_info_get;
      });
    }
    return;
  }
  
  // 设置页面需要重载的方法
  Future <void> resetPageStatus () async {
    if (mounted) {
      setState(() {
        is_page_loaded = false;
      });
    }
  }

  // 设置页面信息加载已完成的方法
  Future <void> setPageLoaded () async {
    if (mounted){
      setState(() {
        is_page_loaded = true;
      });
    }
    return;
  }

  // 将加载全部应用页面的加载方法抽象出来,方便按下重置时快速重载
  Future <void> loadPage_allApps () async {
    // 先更新网络连接状态
    await update_connection_status();
    // 如果网络正常就更新应用列表
    if (is_connection_good) await updateAppList();  
    return;
  }

  // 覆写父类构造函数
  @override
  void initState () {
    super.initState();

    // 初始化滚动监听器
    _scrollController = ScrollController()..addListener(() async {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        // 立刻显示加载的动画
        showMoreAppsLoadingPopWindow();
        await updateAppList();
        // 关闭加载动画
        hideMoreAppsLoadingPopWindow();
      }
    });
    
    // 进行暴力异步同步信息
    Future.delayed(Duration.zero).then((_) async {
      // 进行页面加载
      await loadPage_allApps();
      // 异步设置加载完成
      await setPageLoaded();
    });
  }

  // 覆写父类析构函数
  @override
  void dispose () {
    // 先释放滚动监听器
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前窗口的相对长宽
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // 初始化搜索动态按钮对象
    button_search = MyButton_SearchItem(
      text: Text(
        "搜索",
        style: TextStyle(
          fontSize: 18,
        ),
      ), 
      is_pressed: ValueNotifier<bool>(false),
      indicator_width: height*0.022, 
      onPressed: () async {
        await reloadPage_searchResult();
      },
    );

    // 初始化重置动态按钮对象
    button_reset = MyButton_FatalWarning(
      text: Text(
        "重置",
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ), 
      is_pressed: ValueNotifier<bool>(false), 
      indicator_width: 10, 
      onPressed: () async {
        // 先清空页面控制器内容
        _controller_searchtext.text = '';
        // 再重新加载页面内容
        await reloadPage_all();
      },
    );

    // 声明GridView网格视图中当前应该显示多少列对象(跟随屏幕像素改变而改变)
    late int gridViewCrossAxisCount;
    if (width > 1800)         gridViewCrossAxisCount = 6;
    else if (width > 1450) gridViewCrossAxisCount = 5;
    else if (width > 1100) gridViewCrossAxisCount = 4;
    else                              gridViewCrossAxisCount = 3;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 20,left: 30,right: 50),
        child: Column(
          children: [
            // 列式布局放置应用分类与搜索框
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "全部应用",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
                // 子列用于放置搜索框
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: 40,
                      width: width*0.25,
                      child: TextField(
                        controller: _controller_searchtext,
                        style: TextStyle(
                          fontSize: 18
                        ),
                        // 设置光标高度
                        cursorHeight: 22,  
                        // 与回车键按下捆绑
                        onSubmitted: (value) => reloadPage_searchResult(),
                        decoration: InputDecoration(
                          // 设定垂直内边距
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10), 
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(    // 设置其被选中时变为蓝色
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Colors.grey.shade700,
                              width: 2,
                            )
                          ),
                          // 设置输入框的提示文字内容与样式
                          hintText: "在这里输入您想搜索的应用 ~",
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 30,),
                    // 放置"搜索"按钮
                    SizedBox(
                      height: 40,
                      width: 85,
                      child: button_search
                    ),
                    SizedBox(width: 20,),
                    // 放置"重置"按钮
                    SizedBox(
                      height: 40,
                      width: 85,
                      child: button_reset,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20,),
            Flexible(
              child: is_page_loaded
                ? is_connection_good
                  ? GridView.builder(
                    controller: _scrollController,    // 增加监听滚动状态的指示器
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridViewCrossAxisCount,  // 根据窗口像素大小调整
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    itemCount: cur_app_list.length,
                    itemBuilder:(context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: 13),
                        child: AppGridItem(
                          cur_app: cur_app_list[index], 
                          context: context, 
                        ).item(),
                      );
                    },
                  )
                  : Center(
                    child: Text(
                      '糟糕,网络连接好像丢掉了呢 :(',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: RepaintBoundary(
                          child: CircularProgressIndicator(
                            color: Colors.grey.shade500,
                            strokeWidth: 5,
                          ),
                        ),
                      ),
                      SizedBox(height: 30,),
                      Text(
                        "稍等一下,信息正在加载中哦 ~",
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
