// 应用有更新时弹出的对话框

// 关闭VSCode非必要报错
// ignore_for_file: camel_case_types, file_names, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/GetSystemTheme/syscolor.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/generic_buttons/confirm_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

class MyDialog_AppHaveUpdate extends StatelessWidget {
  const MyDialog_AppHaveUpdate({super.key});

  // 打开Gitee项目主页函数
  Future <void> launchProjectGiteeUrl () async {
    Uri project_url = Uri.parse('https://gitee.com/LFRon/Linyaps-Store-Minimalist/releases/latest');
    await launchUrl(project_url);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Syscolor.isBlack(context)
                       ? YaruColors.coolGrey
                       : Colors.grey.shade200,
      titlePadding: EdgeInsets.only(top:20,bottom: 20),
      title: Center(
        child: Text(
          "发现应用更新",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: SizedBox(
        height: 120,
        width: 450,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Text(
                "检测到应用有新版本, 要去更新嘛 ~",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 45,
                  width: 150,
                  child: MyButton_Confirm(
                    text: Text(
                      "我不想更新",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ), 
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(width: 60,),
                SizedBox(
                  height: 45,
                  width: 150,
                  child: MyButton_Confirm(
                    text: Text(
                      "现在带我去!",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ), 
                    onPressed: () async {
                      await launchProjectGiteeUrl();
                      // 弹出窗口后进行Pop
                      if (context.mounted) Navigator.of(context).pop();
                    },
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
