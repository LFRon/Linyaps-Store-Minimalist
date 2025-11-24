// 检查应用更新的类

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

import 'package:dio/dio.dart';
import 'package:linglong_store_flutter/utils/Linyaps_Store_API/version_compare/version_compare.dart';

class CheckAppUpdate {
    // 声明当前版本号
    // 目前刻意调整成低版本调试用
    static String cur_version = "1.0.0";
    // 检查程序更新的函数
    static Future <bool> isAppHaveUpate () async {
        Dio dio = Dio();     // 创建Dio网络请求对象
        // 初始化检查更新的API链接
        String check_update_url = 'https://gitee.com/api/v5/repos/LFRon/Linyaps-Store-Minimalist/releases';
        // 拿到response响应, 如果请求错误则默认没有更新
        try {
            Response response = await dio.get(check_update_url);
            List <dynamic> version_list = response.data;
            // Gitee返回的API请求中, 最新版本为最后一位
            String newest_version = version_list[version_list.length-1]['tag_name'];
            if (
                VersionCompare(
                    ver1: newest_version,
                    ver2: cur_version,
                ).isFirstGreaterThanSec()
            ) {
                return true;
            } else {
                return false;
            }
        } catch (e) {
            return false;
        }
    }
}
