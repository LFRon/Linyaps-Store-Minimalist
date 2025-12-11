// 从玲珑商店的API接口获取对应信息

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_if_null_operators

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/instance_manager.dart';
import 'package:get/utils.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/version_compare/version_compare.dart';

class LinyapsStoreApiService {

  // 初始化指定API总线链接地址
  static String serverHost_Store = "https://storeapi.linyaps.org.cn";
  static String serverHost_Repo = "https://mirror-repo-linglong.deepin.com";
  static String serverHost_RepoExtra = "https://cdn-linglong.odata.cc/icon/main";

  // 拿到GetX的全局应用信息
  static ApplicationState globalAppState = Get.find<ApplicationState>();

  // 进行系统架构更新
  static String os_arch = globalAppState.os_arch.value;
  static String repo_arch = globalAppState.repo_arch.value;
  
  // 获取首页连播图信息用函数
  static Future <List<LinyapsPackageInfo>> get_welcome_carousel_list () async {
    String serverUrl = "$serverHost_Store/visit/getWelcomeCarouselList";
    Dio dio = Dio();    // 新建Dio请求对象
    Map <String,dynamic> upload_data = {    // 准备请求数据
      "repo":"stable",
      "arch":repo_arch,
    };
    // 发送并获取请求
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_data),
    );  
    dio.close();
    List <LinyapsPackageInfo> WelcomeCarouseApps = [];     // 新建具体化的欢迎应用列表
    // 将API响应的信息经过精准切割,加入到欢迎应用列表中
    for (int i=0;i<response.data['data'].length;i++) {
      WelcomeCarouseApps.add(
        LinyapsPackageInfo(
          id: response.data['data'][i]['appId'], 
          repoName: response.data['data'][i]['repoName'],
          name: response.data['data'][i]['zhName'], 
          categoryName: response.data['data'][i]['categoryName'], 
          version: response.data['data'][i]['version'], 
          Icon: response.data['data'][i]['icon'],
          description: response.data['data'][i]['description'], 
          arch: response.data['data'][i]['arch'], 
        ),
      );
    }
    return WelcomeCarouseApps;
  }

  // 获取首页最受欢迎的No.a到No.b的应用
  static Future <List<LinyapsPackageInfo>> get_welcome_app_list () async {
    String serverUrl = "$serverHost_Store/visit/getWelcomeAppList";
    Dio dio = Dio();    // 新建Dio请求对象
    Map <String,dynamic> upload_data = {    // 准备请求数据
      "repoName": "stable",
      "arch": repo_arch,
      "pageNo": 1,
      "pageSize": 10,
    };

    // 发送并获取请求
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_data),
    );  
    dio.close();
    
    // 将API响应的信息经过精准切割,加入到应用列表中
    List<LinyapsPackageInfo> welcome_app_list = [];
    for (dynamic i in response.data['data']['records']) {
      welcome_app_list.add(
        LinyapsPackageInfo(
          id: i['appId'], 
          repoName: i['repoName'],
          name: i['zhName'], 
          version: i['version'], 
          Icon: i['icon'],
          description: i['description'], 
          arch: i['arch'], 
          categoryName: i['categoryName'], 
          module: i['module'],
          runtime: i['runtime'],
          createTime: i['createTime'],
        ),
      );
    }
    return welcome_app_list;    // 返回对应信息
  }

  // 获取排行榜里最新上架的前100个应用
  static Future <List<LinyapsPackageInfo>> get_newest_app_list () async {
    String serverUrl = "$serverHost_Store/visit/getNewAppList";
    Dio dio = Dio();    // 新建Dio请求对象
    Map <String,dynamic> upload_data = {    // 准备请求数据
      "repoName": "stable",
      "arch": repo_arch,
      "pageNo": 1,
      "pageSize": 100,
    };
    // 发送并获取请求
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_data),
    );  
    dio.close();

    // 将API响应的信息经过精准切割,加入到应用列表中
    List <LinyapsPackageInfo> newest_app_list = [];
    for (int i=0;i<response.data['data']['records'].length;i++) {
      newest_app_list.add(
        LinyapsPackageInfo(
          id: response.data['data']['records'][i]['appId'], 
          repoName: response.data['data']['records'][i]['repoName'],
          name: response.data['data']['records'][i]['zhName'], 
          version: response.data['data']['records'][i]['version'], 
          Icon: response.data['data']['records'][i]['icon'],
          description: response.data['data']['records'][i]['description'], 
          arch: response.data['data']['records'][i]['arch'], 
          categoryName: response.data['data']['records'][i]['categoryName'], 
          module: response.data['data']['records'][i]['module'],
          runtime: response.data['data']['records'][i]['runtime'],
          createTime: response.data['data']['records'][i]['createTime'],
        ),
      );
    }
    return newest_app_list;
  }

  // 获取排行榜里下载量最高的前100个应用
  static Future <List<LinyapsPackageInfo>> get_most_downloaded_app_list () async {
    String serverUrl = "$serverHost_Store/visit/getInstallAppList";
    Dio dio = Dio();    // 新建Dio请求对象
    Map <String,dynamic> upload_data = {    // 准备请求数据
      "repoName": "stable",
      "arch": repo_arch,
      "pageNo": 1,
      "pageSize": 100,
    };
    // 发送并获取请求
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_data),
    );  
    dio.close();

    // 将API响应的信息经过精准切割,加入到应用列表中
    List <LinyapsPackageInfo> most_downloaded_app_list = [];
    dynamic i;
    for (i in response.data['data']['records']) {
      most_downloaded_app_list.add(
        LinyapsPackageInfo(
          id: i['appId'], 
          repoName: i['repoName'],
          name: i['zhName'], 
          version: i['version'], 
          Icon: i['icon'],
          description: i['description'], 
          arch: i['arch'], 
          categoryName: i['categoryName'], 
          module: i['module'],
          runtime: i['runtime'],
          createTime: i['createTime'],
          installCount: i['installCount'],
        ),
      );
    }
    return most_downloaded_app_list;
  }

  // 用于获取所有应用的方法
  ///
   // 获取从startPage页开始,一页数量为pageSize里的应用信息,之所以要加入app_list是因为每次获取到的应用信息都是叠加的
   // 举个例子,startPage = 2,pageSize = 100就是说明显示从第101个到第200个应用
   ///
  static Future <List <LinyapsPackageInfo>> get_all_app_list (int startPage,int pageSize) async {
    String serverUrl = "$serverHost_Store/visit/getSearchAppList";
    Dio dio = Dio();    // 新建Dio请求对象
    Map <String,dynamic> upload_data = {    // 准备请求数据
      "repoName": "stable",
      "arch": repo_arch,
      "pageNo": startPage,
      "pageSize": pageSize,
    };

    // 发送并获取请求
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_data),
    );  
    dio.close();

    // 初始化获取到的所有应用信息列表
    List <LinyapsPackageInfo> app_list = [];

    // 将API响应的信息经过精准切割,加入到应用列表中
    for (dynamic i in response.data['data']['records']) {
      app_list.add(
        LinyapsPackageInfo(
          id: i['appId'], 
          repoName: i['repoName'],
          name: i['zhName'], 
          version: i['version'], 
          Icon: i['icon'],
          description: i['description'], 
          arch: i['arch'], 
          categoryName: i['categoryName'], 
          channel: i['channel'],
          module: i['module'],
          runtime: i['runtime'],
        ),
      );
    }
    return app_list;
  }

  // 获取用户搜索结果的后端对接方法
  static Future <List<LinyapsPackageInfo>> get_search_results (String searchId) async {
    String serverUrl = '$serverHost_Store/visit/getSearchAppList';
    Dio dio = Dio ();    // 创建Dio请求对象
    Map <String,dynamic> upload_data = {    // 准备请求数据
      "repoName": "stable",
      "name": searchId,
      "arch": repo_arch,
      "pageNo": 1,
      "pageSize": 100,
    };
    // 发送并获取返回结果
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_data),
    );  
    dio.close();

    List <dynamic> search_info_get = response.data['data']['records'];

    // 循环加入最终结果对象中
    List <LinyapsPackageInfo> returnItems = [];
    for (dynamic i in search_info_get) {
      returnItems.add(
        LinyapsPackageInfo(
          id: i['id']==null ? i['appId'] : i['id'], 
          name: i['name'], 
          version: i['version'], 
          description: i['description'], 
          arch: i['arch'],
          Icon: i['icon'],
          channel: i['channel'],
          module: i['module'],
          categoryName: i['categoryName'],
          installCount: i['installCount'],
        ),
      );
    }
    // 直接以玲珑包类返回结果
    return returnItems;
  }

  // 获取具体应用的详细信息的方法2: 此方法是仅返回应用的最新版本信息
  // 当能获取到应用信息时返回对应类, 否则返回null
  static Future <LinyapsPackageInfo?> get_app_detail_latest (String appId) async {  
    // 指定具体响应API地址
    String serverUrl = '$serverHost_Store/app/getAppDetail';
    // 创建Dio请求对象
    Dio dio = Dio ();    
    // 准备请求数据
    Map <String,dynamic> upload_data = {   
      "appId": appId,
      "arch": repo_arch
    };
    List <Map<String, dynamic>> upload_data_list = [];
    upload_data_list.add(upload_data);
    // 发送并获取返回信息
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_data_list),
    );  
    dio.close();

    // 在这里提前读获取的应用信息,若为Null直接返回
    if (response.data['data'][appId] == null) return null;

    Map <dynamic, dynamic> app_info_get = response.data['data'][appId][0];
    
    // 进行解析并返回应用详情
    return LinyapsPackageInfo(
      id: app_info_get['appId'], 
      name: app_info_get['name'], 
      arch: repo_arch,
      version: app_info_get['version'], 
      description: app_info_get['description'], 
      createTime: app_info_get['createTime'], 
      Icon: app_info_get['icon'],
    );
  }

  // 单开获取本地应用图标的函数, 同步进行减少应用加载时间
  static Future <List<LinyapsPackageInfo>> updateAppIcon (List<LinyapsPackageInfo> installed_apps) async {
    // 指定具体响应API地址
    String serverUrl = '$serverHost_Store/visit/getAppDetails';
    
    // 初始化待提交应用
    List <Map<String, String>> upload_installed_apps = [];
    for (LinyapsPackageInfo i in installed_apps) {
      upload_installed_apps.add({
        'appId': i.id,
        'channel': 'main',
        'module': 'binary',
        'arch': repo_arch
      });
    }
    // 创建Dio请求对象
    Dio dio = Dio ();    
    // 发送并获取返回信息
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_installed_apps),
    );  
    dio.close();

    List <dynamic> app_info_get = response.data['data'];
    List <LinyapsPackageInfo> returnItems = [];

    // 拿到请求后遍历返回的列表逐个加入后, 进行标准玲珑应用类返回
    for (dynamic i in app_info_get) {
      // 先检查返回的应用信息是否在已安装应用里
      LinyapsPackageInfo app_local_info = installed_apps.firstWhere(
        (app) => app.id == i['appId'],
        orElse: () => LinyapsPackageInfo(
          id: '', 
          name: '', 
          version: '', 
          description: '', 
          arch: ''
        )
      );
      // 依次加入元素
      returnItems.add(
        LinyapsPackageInfo(
          id: i['appId'], 
          name: app_local_info.name, 
          version: app_local_info.version, 
          description: i['description'] ?? app_local_info.description, 
          arch: i['arch'] ?? app_local_info.arch,
          Icon: i['icon'],
        )
      );
    }

    return returnItems;
  }

  // 返回应用可更新列表
  static Future <List<LinyapsPackageInfo>> get_upgradable_apps () async {
    // 指定具体响应API地址
    String serverUrl = '$serverHost_Store/app/appCheckUpdate';
    ApplicationState globalAppState = Get.find<ApplicationState>();
    List <LinyapsPackageInfo> installed_apps = globalAppState.installedAppsList.cast<LinyapsPackageInfo>();
    List <LinyapsPackageInfo> downloading_apps = globalAppState.downloadingAppsQueue.cast<LinyapsPackageInfo>();
    // 初始化待提交应用
    List <Map<String, String>> upload_installed_apps = [];
    for (LinyapsPackageInfo i in installed_apps) {
      upload_installed_apps.add({
        'appId': i.id,
        'arch': repo_arch,
        'version': i.version
      });
    }
    // 创建Dio请求对象
    Dio dio = Dio ();    
    // 发送并获取返回信息
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_installed_apps),
    );  
    List <dynamic> app_info_get = response.data['data'];

    // 初始化待返回应用抽象类列表, 以及遍历其的指针
    List <LinyapsPackageInfo> upgradable_apps = [];
    int point=-1;

    // 遍历已安装的应用
    for (dynamic i  in app_info_get) {
      // 先尝试从商店获取当前应用信息,若没有则直接返回空对象
      // 1. 如果找不到对应应用,或者发现是base/runtime则直接跳过
      if (i != null && i['version'] != null) {
        if (
          i['appId'] == 'org.deepin.base' || 
          i['appId'] == 'org.deepin.foundation' ||
          i['appId'] == 'org.deepin.Runtime' ||
          i['appId'] == 'org.deepin.runtime.dtk' || 
          i['appId'] == 'org.deepin.runtime.gtk4' ||
          i['appId'] == 'org.deepin.base.flatpak.freedesktop' ||
          i['appId'] == 'org.deepin.base.flatpak.kde' ||
          i['appId'] == 'org.deepin.base.flatpak.gnome' ||
          i['appId'] == 'org.deepin.base.wine' ||
          i['appId'] == 'org.deepin.runtime.wine' ||
          i['appId'] == 'org.deepin.runtime.qt5' ||
          i['appId'] == 'org.deepin.runtime.webengine'
        ) continue;
      } else continue;

      // 1. 先获取本地应用信息
      LinyapsPackageInfo? app_from_local_info = installed_apps.firstWhereOrNull(
        (app) => app.id == i['appId'],
      );

      // 2. 将待升级应用信息加入至待升级的应用列表中, 并后移指针
      upgradable_apps.add(LinyapsPackageInfo(
        id: i['appId'], 
        name: i['name'], 
        version: i['version'],
        curOldVersion: app_from_local_info==null ? '' : app_from_local_info.version, 
        description: i['description'], 
        arch: i['arch'],
        Icon: i['icon']
      ));
      point++;
      
      // 3. 如果发现待升级应用正好在下载队列中则设置其下载状态
      // 先在下载队列里进行查询
      LinyapsPackageInfo? app_find_in_downloading_queue =  downloading_apps.cast<LinyapsPackageInfo>().firstWhereOrNull(
        (app) => app.id == i['appId'] && app.version == i['version'] && (app.downloadState == DownloadState.downloading || app.downloadState == DownloadState.waiting),
      );
      // 如果发现真的在下载队列中则更新其下载状态
      if (app_find_in_downloading_queue != null) {
        upgradable_apps[point].downloadState = app_find_in_downloading_queue.downloadState;
      }
    }
    return upgradable_apps;
  }

  // 由于应用检查更新接口与图标获取API重合, 因此在这里做一个统一实现的版本
  // 列表第0位是更新了图标之后的应用列表, 第1位是待更新应用列表
  static Future <List<List<LinyapsPackageInfo>>> get_upgradable_apps_and_icon (List<LinyapsPackageInfo> installed_apps) async {
    // 指定具体响应API地址
    String serverUrl = '$serverHost_Store/visit/getAppDetails';
    // 初始化待提交应用
    List <Map<String, String>> upload_installed_apps = [];
    for (LinyapsPackageInfo i in installed_apps) {
      upload_installed_apps.add({
        'appId': i.id,
        'channel': 'main',
        'module': 'binary',
        'arch': repo_arch
      });
    }
    // 创建Dio请求对象
    Dio dio = Dio ();    
    // 发送并获取返回信息
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_installed_apps),
    );  
    dio.close();

    List <dynamic> app_info_get = response.data['data'];   // 用于接收服务器返回的列表
    List <LinyapsPackageInfo> returned_installed_apps = [];    // 用于存储更新过图标链接的本地应用列表
    List <LinyapsPackageInfo> returned_upgradable_apps = [];    // 用于存储待更新应用
    List <List<LinyapsPackageInfo>> returnItems = [];   // 用于存储最终返回的信息
    
    for (dynamic i in app_info_get) {
      // 先检查返回的应用信息是否在已安装应用里
      LinyapsPackageInfo app_local_info = installed_apps.firstWhere(
        (app) => app.id == i['appId'],
        orElse: () => LinyapsPackageInfo(
          id: '', 
          name: '', 
          version: '', 
          description: '', 
          arch: ''
        )
      );
      // 如果发现这个应用在云端有
      // 先依次加入元素至本地应用列表
      returned_installed_apps.add(
        LinyapsPackageInfo(
          id: i['appId'], 
          name: app_local_info.name, 
          version: app_local_info.version, 
          description: i['description'] ?? app_local_info.description, 
          arch: i['arch'] ?? app_local_info.arch,
          Icon: i['icon'],
        )
      );
      // 如果商店后端有这个应用的信息, 就检查商店的版本信息是否更高
      // 如果是则推入待更新列表中
      if (i['version'] != null) {
        if (VersionCompare.isFirstGreaterThanSec(
          i['version'], 
          app_local_info.version
        )) {
          returned_upgradable_apps.add(LinyapsPackageInfo(
            id: i['appId'], 
            name: i['name'], 
            curOldVersion: app_local_info.version, 
            version: i['version'],
            description: i['description'], 
            arch: i['arch']
          ));
        }
      }
    }
    returnItems.add(returned_installed_apps);
    returnItems.add(returned_upgradable_apps);
    return returnItems;
  }

  // 获取具体应用的详细信息的方法2: 此方法是返回一个应用的每个版本的列表信息
  static Future <List<LinyapsPackageInfo>?> get_app_details_list (String appId) async {
    // 指定具体响应API地址
    String serverUrl = '$serverHost_Store/app/getAppDetail';
    Dio dio = Dio ();    // 创建Dio请求对象
    // 由于该API强制要求列表形式添加故在这里也使用列表形式
    List<Map<String,dynamic>> upload_data = [];
    upload_data.add({
      "appId": appId,
      "arch": repo_arch,
    });

    // 发送并获取返回信息
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_data),
    );  
    dio.close();

    // 如果发现返回的应用信息为空则直接返回空列表
    if (response.data['data'].isEmpty) return null;

    // 如果获取信息不为空则拿到信息
    List <dynamic> app_info_get = response.data['data'][appId];

    // 将返回的信息变成玲珑应用类的列表
    List <LinyapsPackageInfo> cur_app_info = [];

    // 提前初始化i变量
    for (dynamic i in app_info_get) {
      cur_app_info.add(
        LinyapsPackageInfo(
          id: i['appId'] ?? '', 
          devName: i['devName'],
          name: i['name'], 
          zhName: i['zhName'],
          base: i['base'] ?? '', 
          installCount: i['installCount'],
          runtime: i['runtime'],
          repoName: i['repoName'],
          channel: i['channel'],
          module: i['module'],
          version: i['version'], 
          description: i['description'], 
          arch: i['arch'],
          Icon: i['icon'],  
        ),
      );
    }
    // 最终从服务器返回必需的信息
    return cur_app_info;
  }
}

/**
// 备份用的二分查找算法
if (app_info_get.isNotEmpty) {
  for (i=0;i<app_info_get.length;i++) {
    LinyapsPackageInfo wait_add_info = LinyapsPackageInfo(
      id: app_info_get[i]['id']==null?app_info_get[i]['appId']:app_info_get[i]['id'], 
      devName: app_info_get[i]['devName'],
      name: app_info_get[i]['name'], 
      base: app_info_get[i]['base'], 
      installCount: app_info_get[i]['installCount'],
      runtime: app_info_get[i]['runtime'],
      repoName: app_info_get[i]['repoName'],
      channel: app_info_get[i]['channel'],
      module: app_info_get[i]['module'],
      version: app_info_get[i]['version'], 
      description: app_info_get[i]['description'], 
      arch: app_info_get[i]['arch'],
      Icon: app_info_get[i]['icon'],  
    );
    
    // 使用二分查找找到合适的插入位置
    if (cur_app_info.isEmpty) cur_app_info.add(wait_add_info);
    else {
      // 使用二分法寻找待插入节点
      int left = 0;
      int right = cur_app_info.length - 1;
      while (left<=right)
        {
          // 存储中间节点
          int m =(left + right) ~/ 2;
          // 如果中间节点大于待插入节点
          if (
            VersionCompare(
              ver1: cur_app_info[m].version, 
              ver2: wait_add_info.version,
            ).isFirstGreaterThanSec()
          ) {
            right=m-1;
          }
          else left=m+1;
        }
      // 最后插入待插入节点
      // 特殊处理最后一个让用专用的插入函数,因为insert不支持在末尾追加,这样会导致原先的最后一个元素被往后挤
      if (left<cur_app_info.length) cur_app_info.insert(left,wait_add_info);
      else cur_app_info.add(wait_add_info);
    }    
  }
  // 返回对应信息
  return cur_app_info;
} 
else return [];
*/
