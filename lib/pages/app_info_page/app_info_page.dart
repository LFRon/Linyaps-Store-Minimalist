// 应用详情设计页面

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_print, use_build_context_synchronously, curly_braces_in_flow_control_structures

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/AppListView/app_list_view.dart';
import 'package:linglong_store_flutter/utils/Check_Connection_Status/check_connection_status.dart';
import 'package:linglong_store_flutter/utils/Linyaps_App_Management_API/linyaps_app_manager.dart';
import 'package:linglong_store_flutter/utils/Linyaps_CLI_Helper/linyaps_cli_helper.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_store_api_service.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/application_management/dialog_app_not_exist_in_store.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/back_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/install_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/fatal_warning_button.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_color/my_color.dart';

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

class AppInfoPageState extends State<AppInfoPage> {

  // 声明网络连接的状态对象,默认为假
  bool is_connection_good = false;

  // 声明页面加载状态,默认为没加载完
  bool is_page_loaded = false;

  // 声明当前应用对象
  late List <LinyapsPackageInfo> cur_app_info;

  // 由于商店目前不支持获取应用base信息,因此单开一个变量获取应用最新的base信息
  String cur_app_base = '';

  // 声明存储当前应用安装的第几个版本,默认为字符串为空代表没有安装
  String cur_installed_version = '';

  // 获取当前网络具体状况函数
  Future <void> get_connection_status () async {
    bool is_connection_good_get = await CheckInternetConnectionStatus().staus_is_good();
    // 更新页面具体变量信息
    if (mounted) {
      setState(() {
        is_connection_good = is_connection_good_get;
      });
    }
    return;
  }

  // 由于商店目前不支持获取应用base信息,因此单开一个函数获取应用最新的base信息
  Future <void> getAppBase (String appId) async {
    String get_app_base = await LinyapsStoreApiService().get_app_base(appId);
    if (mounted) cur_app_base = get_app_base;
  }

  // 获取应用具体信息函数,返回的值为"是否在商店中找到这个应用"
  Future <bool> getAppDetails (String appId) async {
    // 从玲珑后端API中获得玲珑应用数据
    List <LinyapsPackageInfo> get_app_info = await LinyapsStoreApiService().get_app_details_list(appId);

    // 检查应用是否存在,不存在直接调商店没有此应用的对话框
    if (get_app_info.isEmpty) {
      await showDialog(     // 这里用异步是直接阻断页面继续加载
        context: context, 
        barrierDismissible: false,    // 禁止用户按别的地方关闭
        builder:(context) {
          return MyDialog_AppNotExistInStore();
        },
      );
      Navigator.of(context).popUntil((route){
        return route.isFirst;
      });
      return false;
    }

    // 进行赋值
    if (mounted) {
      setState(() {
        cur_app_info = get_app_info;
      });
    }
    return true;
  }
  
  // 获取应用具体安装状态与安装版本的函数
  Future <void> update_app_installed_status (String appId) async {
    dynamic installed_apps = await LinyapsCliHelper().get_app_installed_info(appId);
    // 如果应用存在
    if (installed_apps != "") {
      // 立刻通知页面重构获取安装的应用的版本
      if (mounted) {
        setState(() {
          cur_installed_version = installed_apps.version;
        });
      }
    }
  }
  
  // 设置页面响应已完成的函数
  Future <void> set_page_loaded () async {
    if (mounted) {
      setState(() {
        is_page_loaded = true;
      });
    }
  }

  // 设置安装函数实现,用于被ListView.builder里的控件当回调函数调用
  // 该页面安装应用的方法,version代表当前安装的目标版本,cur_app_version代表如果有的本地安装版本
  Future <void> install_app (LinyapsPackageInfo appInfo,MyButton_Install button_install) async {
    // 设置按钮被按下
    // 设置安装按钮被按下
    button_install.is_pressed.value = true;
    await LinyapsAppManagerApi().install_app(appInfo,context);
    // 设置安装按钮被释放
    button_install.is_pressed.value = true;
    if (mounted) setState(() {});
  }
  
  // 设置卸载函数实现,用于被ListView.builder里的控件当回调函数用
  Future <void> uninstall_app (String appId,MyButton_FatalWarning button_uninstall) async {
    // 设置按钮被按下
    // 设置卸载按钮被按下
    button_uninstall.is_pressed.value = true;
    int excute_result = await LinyapsCliHelper().uninstall_app(appId);
    // 设置安装按钮被释放
    button_uninstall.is_pressed.value = false;
    // 如果启动失败设置启动按钮文字为"失败"提醒用户
    if (excute_result != 0) {
      button_uninstall.text = Text(
        "失败",
        style: TextStyle(
          fontSize: 15,
          color: Colors.white,
        ),
      );
    }
    // 如果成功则触发重构
    else {
      print('Uninstalled version from $cur_installed_version');
      if (mounted) {
        setState(() {
          cur_installed_version = '';
        });
      }
    }
  }

  @override
  void initState () {
    super.initState();
    // 初始化应用信息
    cur_app_info = [];
    // 暴力异步获取应用信息
    Future.delayed(Duration.zero).then((_) async {
      // 先检连接状态
      await get_connection_status();
      if (is_connection_good) {
        await getAppBase(widget.appId);
        // 先更新应用具体信息
        if (await getAppDetails(widget.appId)){
          // 如果商店中有这个应用再更新应用具体安装情况
          await update_app_installed_status(widget.appId);
          // 发送全局广播页面加载完成
          await set_page_loaded();
        }
      }
      // 这里之所以用else,是防止对应应用没有时仍然往下加载
      // 因为对应应用如果没有,往下加载会出问题,所以如果应用商店里
      // 没有这个应用就始终设置页面未加载完成防止不必要的Exceptions
      else await set_page_loaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 获取并使用屏幕的相对长宽
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      // 总布局采用行式
      body: is_page_loaded
        ? Padding(
          padding: EdgeInsets.only(left: width*0.02,top: height*0.02,right: width*0.02),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                height: 40,
                child: MyButton_Back(
                  // 定义返回操作
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  size: 20,
                ),
              ),
              // 水平列用来放置应用具体信息UI
              // Expanded用于占据剩下的空间
              Expanded(
                child: is_connection_good
                  ? Padding(
                    padding: EdgeInsets.only(top:height*0.025,left: width*0.02,right: width*0.02),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: MyColor().secondary(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                height: height*0.2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // 先显示图片
                                    Column(    // 这个子行控件只是纯粹地用来控制图片显示到中央
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CachedNetworkImage(
                                          height: height*0.15,
                                          width: height*0.15,
                                          imageUrl: cur_app_info[cur_app_info.length-1].Icon==null?"":cur_app_info[cur_app_info.length-1].Icon!,
                                          placeholder: (context, url) => Center(
                                            child: SizedBox(
                                              height: height*0.02,
                                              width: height*0.02,
                                              child: SizedBox(
                                                height: 16,width: 16,
                                                child: CircularProgressIndicator(
                                                  color: Colors.grey.shade300,
                                                  strokeWidth:2.5,     // 设置加载条宽度
                                                ),
                                              ),  // 加载时显示进度条
                                            ),
                                          ),
                                          // 无法显示图片时显示错误
                                          errorWidget: (context, error, stackTrace) => Center(
                                            child: SizedBox(
                                              width: height*0.14,
                                              height: height*0.14,
                                              child: Image(
                                                image: AssetImage(
                                                  'assets/images/linyaps-generic-app.png',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: width*0.2,),
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max, // 填满父 Row 的高度
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(    // 显示应用名字用控件
                                            cur_app_info[0].name,    
                                            style: TextStyle(
                                              fontSize: 40,
                                            ),
                                          ),
                                          SizedBox(height: height*0.01,),
                                          SizedBox(
                                            width: width*0.4,
                                            child: Center(
                                              child: Text(
                                                "介绍: ${cur_app_info[cur_app_info.length-1].description}",
                                                style: TextStyle(
                                                  fontSize: 25,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height*0.045,),
                        // 下面的列式布局用于放置应用Runtime信息与具体介绍
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(    // 设置底部控件高度
                              height: height*0.6, 
                              width: width*0.32,
                              decoration: BoxDecoration(
                                color: MyColor().secondary(context),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: height*0.015,left: width*0.01,right: width*0.01),
                                child: ListView(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "应用维护者: ${(cur_app_info[cur_app_info.length-1].devName==null || cur_app_info[cur_app_info.length-1].devName=='null')?'未知':cur_app_info[cur_app_info.length-1].devName}",
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 21,
                                          ),
                                        ),
                                        
                                        SizedBox(height: height*0.02,),
                                        Text(
                                          "应用基础环境: $cur_app_base",
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 21,
                                          ),
                                        ),
                                        
                                        SizedBox(height: height*0.02,),
                                        Text(
                                          "应用运行环境: ${(cur_app_info[cur_app_info.length-1].runtime=='' || cur_app_info[cur_app_info.length-1].runtime=='null')?'无':cur_app_info[cur_app_info.length-1].runtime}",
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 21,
                                          ),
                                        ),
                                        SizedBox(height: height*0.02,),
                                        Text(
                                          "应用完整介绍: ${cur_app_info[cur_app_info.length-1].description}",
                                          style: TextStyle(
                                            color: Colors.grey.shade800,
                                            fontSize: 21,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              child:Container(
                                height: height*0.6,
                                width: width*0.56,
                                decoration: BoxDecoration(
                                  color: MyColor().secondary(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.0,right: 2.0,bottom: 8.0,top: 8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "应用安装信息",
                                        style: TextStyle(
                                          fontSize: height*0.025,
                                        ),
                                      ),
                                      SizedBox(height: height*0.006,),
                                      Flexible(
                                        child: ListView.builder(
                                          itemCount: cur_app_info.length,
                                          itemBuilder: (context,index) {
                                            int reversedIndex = cur_app_info.length - 1 - index;
                                            return Padding(
                                              padding: EdgeInsets.only(top:5.0,bottom: 5.0),
                                              child: AppInfoView(
                                                app_info: cur_app_info[reversedIndex],
                                                is_cur_version_installed: cur_app_info[reversedIndex].version == cur_installed_version?true:false,
                                                cur_installed_app_version: cur_installed_version==''?null:cur_installed_version,
                                                install_app: (appInfo, button_install) async {
                                                  await install_app(appInfo, button_install);
                                                },
                                                uninstall_app: (appId, button_uninstall) async {
                                                  await uninstall_app(appId, button_uninstall);
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                  ),
              ),
            ],
          ),
        )
        : Padding(
          padding: EdgeInsets.only(left: width*0.02,top: height*0.02,right: width*0.02,bottom:  height*0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 70,
                height: 40,
                child: MyButton_Back(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  size: 20,
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
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
                              "稍等片刻,正在加载应用详情 ~",
                              style: TextStyle(
                                fontSize: height*0.03
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}
