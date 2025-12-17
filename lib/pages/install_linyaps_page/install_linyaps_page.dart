// 若用户未安装玲珑则跳出的页面

// 关闭VSCode非必要报错
// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/generic_buttons/confirm_button.dart';
import 'package:url_launcher/url_launcher.dart';

class InstallLinyapsPage extends StatefulWidget {
  const InstallLinyapsPage({super.key});
  @override
  State<InstallLinyapsPage> createState() => _InstallLinyapsPageState();
}

class _InstallLinyapsPageState extends State<InstallLinyapsPage> {

  // 打开玲珑官方源链接函数
  Future <void> launchLinyapsOfficialGuideUrl () async {
    // 设置即将打开的链接
    Uri url_official = Uri.parse('https://linyaps.org.cn/guide/start/install.html');
    await launchUrl(url_official);
    return;
  }

  // 打开玲珑社区源链接函数
  Future <void> launchLinyapsCommunityGuideUrl () async {
    // 设置即将打开的链接
    Uri url_community = Uri.parse('https://bbs.deepin.org.cn/post/289061');
    await launchUrl(url_community);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '糟糕, 您似乎并未安装玲珑  :(',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '请根据下面的指南进行安装',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ],
            ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '如果您追求稳定, 不想追新, \n点击右侧按钮跳转玲珑官方源安装教程即可 ->',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 50,),
                      SizedBox(
                        width: 220,
                        height: 60,
                        child: MyButton_Confirm(
                          onPressed: () async {
                            await launchLinyapsOfficialGuideUrl();
                          }, 
                          text: Text(
                            '点击访问官方源安装教程',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '如果您追新, 想第一时间体验最新功能, \n点击右侧按钮跳转玲珑社区源安装教程即可 ->',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 50,),
                      SizedBox(
                        width: 220,
                        height: 60,
                        child: MyButton_Confirm(
                          onPressed: () async {
                            await launchLinyapsCommunityGuideUrl();
                          }, 
                          text: Text(
                            '点击访问社区源安装教程',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
