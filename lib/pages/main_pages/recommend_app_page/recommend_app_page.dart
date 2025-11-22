// 显示推荐应用信息页面

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, unnecessary_overrides, use_build_context_synchronously

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/install_linyaps_page/install_linyaps_page.dart';
import 'package:linglong_store_flutter/utils/Check_Connection_Status/check_connection_status.dart';
import 'package:linglong_store_flutter/utils/Linyaps_CLI_Helper/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_store_api_service.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/recommend_app_page/CarouselSliderItems.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/recommend_app_page/WelcomeAppsItems.dart';

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
    List<LinyapsPackageInfo>  await_get = await LinyapsStoreApiService().get_welcome_carousel_list();
    if (mounted) setState(() {
      RecommendAppsList = await_get;
    });
  }
  
  // 声明从API服务获取的推荐应用列表信息对象
  Future <void> updateWelcomeAppsList () async {
    List<LinyapsPackageInfo>  await_get = await LinyapsStoreApiService().get_welcome_app_list();
    if (mounted) setState(() {
      WelcomeAppsList = await_get;
    });
  }

  // 声明连播图控制器
  CarouselSliderController carousel_controller = CarouselSliderController();

  // 覆写父类构造函数
  @override
  void initState () {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 进行暴力异步加载页面
    Future.delayed(Duration.zero).then((_) async {
      // 先检测玲珑是否安装了, 若未安装则直接跳转
      if (!await LinyapsCliHelper.is_installed_linyaps()) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return InstallLinyapsPage();
            },
          ),
        );
      }
      // 先异步获取网络连接状态
      is_connection_good = await CheckInternetConnectionStatus.staus_is_good();
      if (is_connection_good) {
        await updateRecommendAppsList();
        await updateWelcomeAppsList();
      }
      // 广播页面信息加载已完成
      if (mounted) {
        setState(() {
          is_page_loaded =true;
        });
      }
    });

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
        ? Padding(
          padding: EdgeInsets.only(top: 20,left: 30,right: 50),
          child: Column(
            children: [
              Stack(
                children: [
                  CarouselSlider(
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
              
                  // 通过精准定位设置左右轮换按钮
                  Positioned(
                    top: height*0.08,
                    left: width*0.01,
                    child: Center(
                      child: FloatingActionButton(
                        heroTag: "RecommendAppPage_FloatingActionButton_Left",
                        backgroundColor: Colors.grey.withValues(alpha: 0.1),
                        child: Icon(Icons.keyboard_double_arrow_left),
                        onPressed: (){
                          carousel_controller.previousPage();
                        },
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
                        onPressed: (){
                          carousel_controller.nextPage();
                        },
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
                "稍等一下,信息正在加载中哦 ~",
                style: TextStyle(
                  fontSize: width*0.015,
                ),
              ),
            ],
          ),
        ),
    );
  }
}
