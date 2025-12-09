// 本地应用不在商店里的报错信息对话框

// 关闭VSCode非必要报错
// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:linglong_store_flutter/utils/Pages_Utils/my_buttons/confirm_button.dart';

class MyDialog_AppNotExistInStore extends StatelessWidget {

  const MyDialog_AppNotExistInStore({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
     backgroundColor: Colors.grey.shade300,
      titlePadding: EdgeInsets.only(top: 20, bottom: 20),
      title: Center(
        child: Text(
          "应用未找到",
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
                "哎呀,你装的这个应用貌似没有上架到商店哦 ~",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 45,
              width: 200,
              child: MyButton_Confirm(
                text: Text(
                  "好吧 :(",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ), 
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
