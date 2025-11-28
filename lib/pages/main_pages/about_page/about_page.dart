// 关于应用的页面设计

// 忽略VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/main.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/launch_url_button.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {

  // 通过MyApp类获取当前应用本体版本号
  String cur_version = MyApp.cur_version;

  // 用于在关于页面统一全局启动对应链接的方法
  // 注意: 其中launch_number形参用法为:
  // 取值0,启动玲珑项目官网
  // 取值1,启动玲珑在线商店官网
  // 取值2,启动本应用Gitee项目链接
  // 取值3,启动本应用Github项目链接
  Future <void> launchPageUrl (int launch_number) async {
    String launch_url = '';
    switch (launch_number) {
      case 0: launch_url = 'https://linglong.space'; break;
      case 1: launch_url = 'https://store.linyaps.org.cn'; break;
      case 2: launch_url = 'https://gitee.com/LFRon/Linyaps-Store-Minimalist'; break;
      case 3: launch_url = 'https://github.com/LFRon/Linyaps-Store-Minimalist'; break;
      default: throw ArgumentError('FATAL: Invalid launch_number! The launch_number must between 0-3!!!');
    }
    // 启动网页
    await launchUrl(Uri.parse(launch_url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0,top: 20,right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  height: 100,
                  width: 100,
                  'assets/images/linyaps_icon.png'
                ),
                const SizedBox(width: 60,),
                Column(
                  children: [
                    Text(
                      '玲珑应用商店极速版',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.grey.shade800
                      ),
                    ),
                    SizedBox(height: 10,),
                    Text(
                      '极致简洁,快速可靠',
                      style: TextStyle(
                        fontSize: 25,
                        color: Colors.grey.shade800
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  size: 30,
                  Icons.info_outline_rounded
                ),
                const SizedBox(width: 10,),
                Text(
                  '当前应用商店版本: $cur_version',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25,),
            // 玲珑友情链接UI
            Row(
              children: [
                Icon(
                  size: 30,
                  Icons.link
                ),
                const SizedBox(width: 10,),
                Text(
                  '玲珑友情链接',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Text(
                  '玲珑官网: https://linglong.space',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 18,),
                SizedBox(
                  width: 140,
                  height: 40,
                  child: MyButton_LaunchUrl(
                    onPressed: () async {
                      await launchPageUrl(0);
                    }, 
                    icon: Icon(
                      Icons.open_in_browser
                    ), 
                    text: Text(
                      '点击访问',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '玲珑网页商店官网: https://store.linyaps.org.cn',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 18,),
                SizedBox(
                  width: 140,
                  height: 40,
                  child: MyButton_LaunchUrl(
                    onPressed: () async {
                      await launchPageUrl(1);
                    }, 
                    icon: Icon(
                      Icons.open_in_browser
                    ), 
                    text: Text(
                      '点击访问',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50,),
            Row(
              children: [
                Icon(
                  size: 30,
                  Icons.link
                ),
                const SizedBox(width: 10,),
                Text(
                  '本应用项目链接',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              children: [
                Text(
                  'Gitee 链接: https://gitee.com/LFRon/Linyaps-Store-Minimalist',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 18,),
                SizedBox(
                  width: 140,
                  height: 40,
                  child: MyButton_LaunchUrl(
                    onPressed: () async {
                      await launchPageUrl(2);
                    }, 
                    icon: Icon(
                      Icons.open_in_browser
                    ), 
                    text: Text(
                      '点击访问',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  'Github 链接: https://github.com/LFRon/Linyaps-Store-Minimalist',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 18,),
                SizedBox(
                  width: 140,
                  height: 40,
                  child: MyButton_LaunchUrl(
                    onPressed: () async {
                      await launchPageUrl(3);
                    }, 
                    icon: Icon(
                      Icons.open_in_browser
                    ), 
                    text: Text(
                      '点击访问',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
