// 下载页面

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/global_variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/pages_utils/downloading_page/downloading_app_list_item.dart';
import 'package:provider/provider.dart';

class DownloadingPage extends StatefulWidget {
  const DownloadingPage({super.key});

  @override
  State<DownloadingPage> createState() => _DownloadingPageState();
}

class _DownloadingPageState extends State<DownloadingPage> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver, ChangeNotifier {

  // 覆写页面希望保持存在状态开关
  @override
  bool get wantKeepAlive => true; 
  
  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 全局监听下载列表
    return Consumer<ApplicationState>(
      builder: (context, appState, child) {
        List <LinyapsPackageInfo> downloading_apps_queue = appState.downloadingAppsQueue;
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.only(top: 20,left: 10,right: 10),
            child: downloading_apps_queue.isNotEmpty
            ? ListView.builder(
              itemCount: downloading_apps_queue.length,
              itemBuilder: (context,index) {
                return DownloadingAppListItem(
                  cur_app_info: downloading_apps_queue[index],
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
