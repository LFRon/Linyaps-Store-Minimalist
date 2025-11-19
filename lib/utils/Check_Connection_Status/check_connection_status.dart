// 该类用于检查网络连接是否正常

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class CheckInternetConnectionStatus {
  static Future<bool> staus_is_good () async {
    // 新建网络检测对象
    InternetConnection connection = InternetConnection.createInstance(
      customCheckOptions: [
        InternetCheckOption(uri: Uri.parse('https://www.baidu.com')),
      ],
    );
    return await connection.hasInternetAccess;    // 判断其是否能正常连接网络
  }
}
  