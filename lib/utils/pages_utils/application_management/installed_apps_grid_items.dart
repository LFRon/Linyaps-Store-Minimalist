// 所有应用中每个网络的应用信息显示

// 关闭VSCode的非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_function_literals_in_foreach_calls, curly_braces_in_flow_control_structures, use_build_context_synchronously

import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_store_api_service.dart';

class InstalledAppsGridItems {

  // 获取窗口当前的像素宽高
  double height,width;

  // 获取当前安装的应用信息
  List <LinyapsPackageInfo> installed_app_info;

  // 获取页面必须的上下文
  BuildContext context;

  // 透传自己的

  InstalledAppsGridItems({
    required this.installed_app_info,
    required this.context,
    required this.height,
    required this.width,
  });

  // 用于检查本地的应用是否在商店里
  Future <bool> isAppExistInStore (String appId) async 
    {
      List <LinyapsPackageInfo> app_info_get = await LinyapsStoreApiService().get_app_details(appId);
      // 检查列表是否为空
      if (app_info_get.isEmpty) return false;
      else return true;
    }

  List <Widget> items ()
    {
      return List.generate(installed_app_info.length, (index) {
        return Container(
          height: 120,
          width: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AppInfoPage(appId: installed_app_info[index].id);
                  },
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              // 关掉所有按钮特效
              backgroundColor: Colors.transparent,
              overlayColor: Colors.transparent,
              shadowColor: Colors.transparent,
              elevation: 0,
              splashFactory: NoSplash.splashFactory,
            ),
            child: Padding(
              padding: EdgeInsets.only(top: height*0.03,bottom: height*0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 先显示图片
                  Hero(
                    tag: "InstalledAppsGridItems_${installed_app_info[index].id}",
                    // 显示图片必须用FutureBuilder,不要因为加载图片延缓整个页面加载
                    child: FastCachedImage(
                      url: installed_app_info[index].Icon!,
                      key: ValueKey('${installed_app_info[index].name}_${installed_app_info[index].IconUpdated}'),
                      height: 80,width: 80,
                      loadingBuilder: (context, loadingProgress) {
                        return Center(
                          child: SizedBox(
                            height: 80,
                            width: 80,
                            child: CircularProgressIndicator(
                              color: Colors.grey,
                              strokeWidth: 3.0,
                            ),  // 加载时显示进度条
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image(
                            image: AssetImage(
                              'assets/images/linyaps-generic-app.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    ),
                  // SizedBox(height:height*0.03,),    // 设置控件间间距
                  // 再显示应用名
                  Text(
                    installed_app_info[index].name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    // 设置最多只能显示1行
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // SizedBox(height:height*0.025,),    // 设置控件间间距
                  Text(
                    "版本号: ${installed_app_info[index].version}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }
}
