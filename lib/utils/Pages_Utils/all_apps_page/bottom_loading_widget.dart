// 页面底部显示的加载框实现

// 关闭VSCode非必要报错
// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

class BottomLoading_AllApps {

  // 获取父页面必须的页面构建上下文
  BuildContext context;

  BottomLoading_AllApps({
    required this.context,
  });

  Future <dynamic> show() async
    {
      // 获取当前窗口的相对长宽
      double height = MediaQuery.of(context).size.height;
      double width = MediaQuery.of(context).size.width;
      return showModalBottomSheet(
        context: context, 
        barrierColor: Colors.transparent,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(bottom: height*0.01),
            child: Container(
              height: height*0.15,
              width: width*0.2,
              decoration: BoxDecoration(
                color:Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: height*0.04,
                      width: height*0.04,
                      child: CircularProgressIndicator(
                        strokeWidth: height*0.004,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: height*0.02,),
                    Text(
                      "更多app正在加载中 ~",
                      style: TextStyle(
                        fontSize: height*0.025,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      );
    }
}
