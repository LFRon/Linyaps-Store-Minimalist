// 从玲珑商店的API接口获取对应信息

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_if_null_operators

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/os_arch_info_middleware/get_os_arch_info.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/version_compare/version_compare.dart';

class LinyapsStoreApiService {

  // 初始化指定API总线链接地址
  String serverHost_Store = "https://storeapi.linyaps.org.cn";
  String serverHost_Repo = "https://mirror-repo-linglong.deepin.com";
  String serverHost_RepoExtra = "https://cdn-linglong.odata.cc/icon/main";

  // 存储操作系统对应架构信息
  String os_arch = "";
  String repo_arch = "";

  // 进行操作系统架构更新函数
  Future <void> update_os_arch () async {
    os_arch = await getOSArchInfo.getUnameArch();
    repo_arch = await getOSArchInfo.getLinyapsStoreApiArch();
  }
  
  // 初始化响应总线
  Dio init_service () {
    return Dio(
      BaseOptions(
        baseUrl: serverHost_Store, 
        connectTimeout: Duration(seconds: 10),   // 设置最长连接响应时间
        receiveTimeout: Duration(seconds: 15),    // 设置最长获取响应时间
        headers: {
          'Content-Type': 'application/json;charset=utf-8',
          'Access-Control-Allow-Origin': '*',   // 设置允许的域名
          'Access-Control-Allow-Headers': 'Origin, X-Requested-With, Content-Type, Accept'
        },
      ),
    );
  }
  
  // 获取首页连播图信息用函数
  Future <List<LinyapsPackageInfo>> get_welcome_carousel_list () async {
    await update_os_arch();    // 更新系统架构信息
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
    int i=0;
    // 将API响应的信息经过精准切割,加入到欢迎应用列表中
    for (i=0;i<response.data['data'].length;i++) {
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
  Future <List<LinyapsPackageInfo>> get_welcome_app_list () async {
    await update_os_arch();   // 更新系统架构信息
    String serverUrl = "$serverHost_Store/visit/getWelcomeAppList";
    Dio dio = Dio();    // 新建Dio请求对象
    Map <String,dynamic> upload_data = {    // 准备请求数据
      "repoName": "stable",
      "arch": "x86_64",
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
    dynamic i;
    for (i in response.data['data']['records']) {
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
  Future <List<LinyapsPackageInfo>> get_newest_app_list () async {
    await update_os_arch();   // 更新系统架构信息
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
    int i=0;
    for (i=0;i<response.data['data']['records'].length;i++) {
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
  Future <List<LinyapsPackageInfo>> get_most_downloaded_app_list () async {
    await update_os_arch();   // 更新系统架构信息
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
  Future <List <LinyapsPackageInfo>> get_app_list (int startPage,int pageSize) async {
    await update_os_arch();   // 更新系统架构信息
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

    // 声明获取
    List <LinyapsPackageInfo> app_list = [];

    // 将API响应的信息经过精准切割,加入到应用列表中
    dynamic i;
    for (i in response.data['data']['records']) {
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
  Future <List<LinyapsPackageInfo>> get_search_results (String searchId) async 
    {
      await update_os_arch();   // 更新系统架构信息
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
      List <dynamic> search_info_get = response.data['data']['records'];

      // 循环加入最终结果对象中
      List <LinyapsPackageInfo> returnItems = [];
      dynamic i;
      for (i in search_info_get) {
        returnItems.add(
          LinyapsPackageInfo(
            id: i['id']==null?i['appId']:i['id'], 
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

  // 获取应用Base信息的方法
  Future <String> get_app_base (String appId) async 
    {
      await update_os_arch();    // 更新系统架构信息
      String serverUrl = '$serverHost_Repo/api/v0/apps/fuzzysearchapp';
      Dio dio = Dio ();    // 创建Dio请求对象
      int i=0;
      Map <String,dynamic> upload_data = {    // 准备请求数据
        "repoName": "stable",
        "channel": "main",
        "arch": repo_arch,
        "appId": appId,
      };
      // 发送并获取返回信息
      Response response = await dio.post(
        serverUrl,
        data: jsonEncode(upload_data),
      );  
      dio.close();
      // 防止点开没有收录的应用而获取到null的base
      if (response.data['data'] == null) return "";
      List <dynamic> app_info_get = response.data['data'];
      List <LinyapsPackageInfo> app_info_sorted = [];
      // 对版本号进行二叉树的升序排序
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
          if (app_info_sorted.isEmpty) app_info_sorted.add(wait_add_info);
          else {
            // 使用二分法寻找待插入节点
            int left = 0;
            int right = app_info_sorted.length - 1;
            while (left<=right) {
              // 存储中间节点 (这里是整除)
              int m =(left + right) ~/ 2;
              // 如果中间节点大于待插入节点
              if (
                VersionCompare(
                ver1: app_info_sorted[m].version, 
                ver2: wait_add_info.version,
                ).isFirstGreaterThanSec()
              ) {
                right=m-1;
              }
              else left=m+1;
            }
            // 最后插入待插入节点
            // 特殊处理最后一个让用专用的插入函数,因为insert不支持在末尾追加,这样会导致原先的最后一个元素被往后挤
            if (left<app_info_sorted.length) app_info_sorted.insert(left,wait_add_info);
            else app_info_sorted.add(wait_add_info);
          }    
        }
        // 返回对应信息
        return app_info_sorted[app_info_sorted.length-1].base ?? '';
      }
      // 如果没有对应应用直接返回空列表
      else return "";
    }

  // 获取具体应用的详细信息的方法2: 此方法是仅返回应用的最新版本信息
  // 当能获取到应用信息时返回对应类, 否则返回null
  Future <LinyapsPackageInfo?> get_app_detail_latest (String appId) async {
    // 更新系统架构信息
    await update_os_arch();   
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
    Map <dynamic,dynamic> app_info_get = response.data['data'][appId][0];
    
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

  // 单开返回本地应用图标的函数,同步进行减少应用加载时间
  Future <List<LinyapsPackageInfo>> updateAppIcon (List<LinyapsPackageInfo> installed_apps) async {
    // 更新系统架构信息
    await update_os_arch();   
    // 指定具体响应API地址
    String serverUrl = '$serverHost_Store/app/getAppDetail';
    
    // 初始化待提交应用
    List <Map<String, String>> upload_installed_apps = [];
    for (dynamic i in installed_apps) {
      upload_installed_apps.add({
        'appId': i.id,
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

    Map <String, dynamic> app_info_get = response.data['data'];
    // 拿到请求后准备逐个返回
    List <LinyapsPackageInfo> returnItems = [];
    int i=0;
    for (LinyapsPackageInfo cur_app_info in installed_apps) {
      // 不管其他,先加入元素
      returnItems.add(installed_apps[i]);
      String? IconUrl;
      if (app_info_get.containsKey(returnItems[i].id)) {
        IconUrl = app_info_get[returnItems[i].id][0]['icon'];
        returnItems[i].Icon = IconUrl;
      }
      i++;
    }

    return returnItems;
  }

  // 获取具体应用的详细信息的方法2: 此方法是返回一个应用的每个版本的列表信息
  Future <List<LinyapsPackageInfo>> get_app_details_list (String appId) async {
    // 更新系统架构信息
    await update_os_arch();   
    // 指定具体响应API地址
    String serverUrl = '$serverHost_Store/visit/getSearchAppVersionList';
    Dio dio = Dio ();    // 创建Dio请求对象
    Map <String,dynamic> upload_data = {    // 准备请求数据
      "repoName":"stable",
      "channel": "main",
      "arch": repo_arch,
      "appId": appId,
    };

    // 发送并获取返回信息
    Response response = await dio.post(
      serverUrl,
      data: jsonEncode(upload_data),
    );  
    dio.close();
    List <dynamic> app_info_get = response.data['data'];

    // 将返回的信息变成玲珑应用类
    List <LinyapsPackageInfo> cur_app_info = [];

    // 提前初始化i变量
    int i=0;
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
    // 如果没有对应应用直接返回空列表
    else return [];
  }

}
