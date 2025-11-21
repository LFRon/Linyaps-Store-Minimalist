// 若用户未安装玲珑则跳出的页面
import 'package:flutter/material.dart';

class InstallLinyapsPage extends StatefulWidget {

  const InstallLinyapsPage({super.key});

  @override
  State<InstallLinyapsPage> createState() => _InstallLinyapsPageState();
}

class _InstallLinyapsPageState extends State<InstallLinyapsPage> {
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
