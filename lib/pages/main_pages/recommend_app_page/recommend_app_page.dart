// 显示推荐应用信息页面

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, unnecessary_overrides, use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/check_update.dart';
import 'package:linglong_store_flutter/pages/install_linyaps_page/install_linyaps_page.dart';
import 'package:linglong_store_flutter/utils/Check_Connection_Status/check_connection_status.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_CLI_Helper_API/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_store_api_service.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/recommend_app_page/Dialog_AppHaveUpdate.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/recommend_app_page/Items_CarouselSlider.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/recommend_app_page/Items_WelcomeApps.dart';

class RecommendAppPage extends StatefulWidget {

  const RecommendAppPage({super.key});

  @override
  State<RecommendAppPage> createState() => _RecommendAppPageState();
}

// 附带AutomaticKeepAliveClientMixin保证页面即使在被切换后也不会被销毁,再附带监听功能优化窗口大小调整时的重构行为防止报错
class _RecommendAppPageState extends State<RecommendAppPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  // 覆写页面希望保持存在状态开关
  @override
  bool get wantKeepAlive => true; 

  // 声明网络连接状态,默认状态为不好
  bool is_connection_good = false;

  // 声明页面加载状态控制开关,默认情况下为未加载完
  bool is_page_loaded = false;

  // 声明从API服务获取的顶栏应用列表信息对象
  List<LinyapsPackageInfo> RecommendAppsList = [];

  // 声明从API服务获取的推荐应用列表信息对象
  List<LinyapsPackageInfo> WelcomeAppsList = [];

  // 从API服务中获取顶栏展示应用列表信息
  Future <void> updateRecommendAppsList () async {
    List<LinyapsPackageInfo>  await_get = await LinyapsStoreApiService.get_welcome_carousel_list();
    if (mounted) setState(() {
      RecommendAppsList = await_get;
    });
  }
  
  // 声明从API服务获取的推荐应用列表信息对象
  Future <void> updateWelcomeAppsList () async {
    List<LinyapsPackageInfo>  await_get = await LinyapsStoreApiService.get_welcome_app_list();
    if (mounted) setState(() {
      WelcomeAppsList = await_get;
    });
  }

  // 更新当前页面网络连接状态用函数
  Future <void> updateConnectionStatus () async {
    bool connection_status = await CheckInternetConnectionStatus.staus_is_good();
    if (mounted) setState(() {
      is_connection_good = connection_status;
    });
  }

  // 设置页面加载状态为未完全加载的函数
  Future <void> setPageNotLoaded () async {
    if (mounted) setState(() {
      is_page_loaded = false;
    });
  }

  // 设置页面加载状态为已完全加载的函数
  Future <void> setPageLoaded () async {
    if (mounted) setState(() {
      is_page_loaded = true;
    });
  }

  // 声明连播图控制器
  CarouselSliderController carousel_controller = CarouselSliderController();

  // 覆写父类构造函数
  @override
  void initState () {
    super.initState();
    // 添加页面观察者
    WidgetsBinding.instance.addObserver(this); 
    // 进行暴力异步加载页面
    Future.delayed(Duration.zero).then((_) async {
      // 1.先检测玲珑是否安装了, 若未安装则直接跳转报错页面
      // 当网络连接正常时,进行:
      // 2. 更新轮播图与欢迎应用列表
      // 3. 检查应用自身更新
      if (!await LinyapsCliHelper.is_installed_linyaps()) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return InstallLinyapsPage();
            },
          ),
          (route) => false,
        );
      }
      
      // 再更新网络连接状态
      await updateConnectionStatus();
      if (is_connection_good) {
        await updateRecommendAppsList();
        await updateWelcomeAppsList();
        // 最后检查应用更新情况
        if (await CheckAppUpdate.isAppHaveUpate()) {
          // 如果应用有更新就弹出对话框
          showDialog(
            context: context, 
            barrierDismissible: false,    // 禁止用户按空白部分关掉对话框
            builder: (BuildContext context) {
              return MyDialog_AppHaveUpdate();
            },
          );
        }
        // 广播页面信息加载已完成
        await setPageLoaded();
      } else {
        await setPageLoaded();
      }
    });

  }

  // 在页面被重新切换回来 (不论是从其他页面切回来还是app从后台切回前台的该页面) 时重载信息
  @override
  void didChangeAppLifecycleState (AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 先检查网络连接状态, 如果之前是不好也就是断网触发UI报错的, 先检查是不是这个情况
      if (!is_connection_good) {
        await updateConnectionStatus();
        // 如果网路正常就进行页面信息更新
        if (is_connection_good) {
          await setPageNotLoaded();
          await updateRecommendAppsList();
          await updateWelcomeAppsList();
          await setPageLoaded();
        }
      }
    }
  }
  
  // 覆写父类析构函数
  @override
  void dispose () {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // 获取并使用屏幕的相对长宽
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    // 声明GridView网格视图中当前应该显示多少列对象(跟随屏幕像素改变而改变)
    late int gridViewCrossAxisCount;
    if (width > 1200) gridViewCrossAxisCount = 5;
    else if (width > 1100) gridViewCrossAxisCount = 4;
    else gridViewCrossAxisCount = 3;
    return Scaffold(
      body: is_page_loaded 
        ? is_connection_good
          ? Padding(
            padding: EdgeInsets.only(top: 20,left: 30,right: 50),
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: width*0.8,
                      height: height*0.3,
                      child: CarouselSlider(
                        carouselController: carousel_controller,
                        items: RecommendAppSliderItems(
                          context: context,
                          RecommendAppsList: RecommendAppsList, 
                          height: height, 
                          width: width,
                        ).Items(), 
                        // 设定连播图详情
                        options: CarouselOptions(
                          height: height*0.3,   // 设置高度
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 7),
                          autoPlayAnimationDuration: Duration(seconds: 3),
                          enableInfiniteScroll: true,
                        ),
                      ),
                    ),
                
                    // 通过精准定位设置左右轮换按钮
                    Positioned(
                      top: height*0.08,
                      left: width*0.01,
                      child: Center(
                        child: FloatingActionButton(
                          heroTag: "RecommendAppPage_FloatingActionButton_Left",
                          backgroundColor: Colors.grey.withValues(alpha: 0.1),
                          child: Icon(Icons.keyboard_double_arrow_left),
                          onPressed: () => carousel_controller.previousPage(),
                        ),
                      ),
                    ),
                    Positioned(
                      top: height*0.08,
                      right: width*0.01,
                      child: Center(
                        child: FloatingActionButton(
                          heroTag: "RecommendAppPage_FloatingActionButton_Right",
                          backgroundColor: Colors.grey.withValues(alpha: 0.1),
                          child: Icon(Icons.keyboard_double_arrow_right),
                          onPressed: () => carousel_controller.nextPage(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height*0.025,),   // 设置控件间间距
                Text(
                  "玲珑小编推荐 ~",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: height*0.03,
                  ),
                ),
                SizedBox(height: height*0.045,),   // 设置控件间间距
                Flexible(
                  child: GridView(
                    // 先设置网格UI样式
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridViewCrossAxisCount,    // 设置水平网格个数
                      mainAxisSpacing: height*0.02,
                      crossAxisSpacing: width*0.02,
                    ), 
                    children: WelcomeAppGridItems(
                      WelcomeAppsList: WelcomeAppsList, 
                      context: context,
                      height: height*0.9, 
                      width: height*0.8,
                    ).Items(),
                  ),
                ),
              ],
            ),
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
                child: CircularProgressIndicator(
                  color: Colors.grey.shade500,
                  strokeWidth: 5,
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
        )
    );
  }
}
