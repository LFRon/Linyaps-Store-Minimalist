// 下载页面

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/downloading_page/downloading_app_list_item.dart';

class DownloadingPage extends StatefulWidget {
  const DownloadingPage({super.key});

  @override
  State<DownloadingPage> createState() => _DownloadingPageState();
}

class _DownloadingPageState extends State<DownloadingPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {

  // 覆写页面希望保持存在状态开关
  @override
  bool get wantKeepAlive => true; 
  
  @override
  Widget build(BuildContext context) {
    
    super.build(context);

    // 全局监听下载列表
    return GetBuilder <ApplicationState> (
      builder: (appState) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.only(top: 20,left: 10,right: 30),
            child: appState.downloadingAppsQueue.isNotEmpty
              ? ListView.builder(
                itemCount: appState.downloadingAppsQueue.length,
                itemBuilder: (context,index) {
                  return DownloadingAppListItem(
                    cur_app_info: appState.downloadingAppsQueue[index],
                  );
                },
              )
              : Center(
                child: Text(
                  '哎呀,看上去你还没有在下载的应用呢 :)',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
          )
        );
      }
    );
  }
}
