// 显示每个下载中的应用功能实现

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:linglong_store_flutter/pages/app_info_page/app_info_page.dart';
import 'package:linglong_store_flutter/utils/Backend_API/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';
import 'package:linglong_store_flutter/utils/GetSystemTheme/syscolor.dart';
import 'package:linglong_store_flutter/utils/Global_Variables/global_application_state.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/generic_buttons/fatal_warning_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:yaru/widgets.dart';

class DownloadingAppListItem extends StatelessWidget {

  // 获取当前应用下载信息
  LinyapsPackageInfo cur_app_info;

  // 获取到全局应用实例
  ApplicationState globalAppState = Get.find<ApplicationState>();

  // 初始化取消按钮对象
  late MyButton_FatalWarning cancel_waiting_button;

  DownloadingAppListItem({
    super.key,
    required this.cur_app_info,
  });

  // 用于当前对象正在等待时, 用户按下取消按钮其在下载队列的方法
  Future <void> cancelCurAppWaiting () async {
    // 设置当前传入的按钮引用对象的按下状态为已按下
    cancel_waiting_button.is_pressed.value = true;
    // 将其从列表中移除, 并触发UI重构
    globalAppState.downloadingAppsQueue.removeWhere(
      (app) => app.id == cur_app_info.id && app.version == cur_app_info.version
    );
    globalAppState.update();
    return;
  }

  @override
  Widget build(BuildContext context) {
    // 初始化取消等待按钮对象
    cancel_waiting_button = MyButton_FatalWarning(
      text: Text(
        '取消',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      is_pressed: ValueNotifier<bool>(false), 
      indicator_width: 20, 
      onPressed: () async {
        await cancelCurAppWaiting();
      },
    );
    return Container(
      height: 85,
      margin: EdgeInsets.symmetric(vertical: 6.0),    // 设置ListView.builder子控件间的间距
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Syscolor.isBlack(context)
               ? Colors.grey.shade800
               : Colors.grey.shade200,
      ),
      child: InkWell(
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.fade,
              duration: const Duration(milliseconds: 100),
              reverseDuration: const Duration(milliseconds: 130),
              child: AppInfoPage(
                appId: cur_app_info.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.only(top:8.0,bottom: 8.0,left: 30.0,right: 35.0),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: cur_app_info.Icon ?? '',
                      placeholder: (context, url) => Center(
                        child: YaruCircularProgressIndicator(
                          strokeWidth:2.5,     // 设置加载条宽度
                        ),
                      ),
                      // 如果图片无法加载就使用默认玲珑图标
                      errorWidget: (context, error, stackTrace) => Center(
                        child: Image(
                          image: AssetImage(
                            'assets/images/linyaps-generic-app.png',
                          ),
                        ),
                      ),
                      height: 70,
                      width: 70,
                    ),
                    SizedBox(width: 30,),  // 设置应用图标和名称的横向间距
                    Text(
                      cur_app_info.name,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
        
              Expanded(
                flex: 1,
                child: Text(
                  '版本: ${cur_app_info.version}',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              
              Expanded(
                flex: 2,
                child: cur_app_info.downloadState == DownloadState.downloading
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: YaruCircularProgressIndicator(
                          strokeWidth: 3.5,
                        ),
                      ),
                      SizedBox(width: 20,),
                      Text(
                        '正在下载',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      cur_app_info.downloadState == DownloadState.waiting
                        ? Row(
                          children: [
                            Text(
                              '正在等待下载',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(width: 40,),
                            SizedBox(
                              width: 100,
                              height: 40,
                              child: cancel_waiting_button,
                            )
                          ],
                        )
                        : SizedBox(),
                    ],
                  ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
