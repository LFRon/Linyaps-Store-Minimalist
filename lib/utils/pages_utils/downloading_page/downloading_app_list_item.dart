// 显示每个下载中的应用功能实现

// 关闭VSCode非必要报错
// ignore_for_file: must_be_immutable, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/linyaps_package_info_model/linyaps_package_info.dart';

class DownloadingAppListItem extends StatelessWidget {

  // 获取当前应用下载信息
  LinyapsPackageInfo cur_app_info;

  DownloadingAppListItem({
    super.key,
    required this.cur_app_info,
  });

  @override
  Widget build(BuildContext context) {
    return Container(

    );
  }
}
