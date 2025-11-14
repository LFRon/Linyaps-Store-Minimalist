// 欢迎界面

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {

  @override
  void initState () {
      super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 获取并使用屏幕的相对长宽
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              height: height*0.15,
              width: width*0.15,
              'assets/images/linyaps_icon.svg',
            ),
            SizedBox(height: height*0.06,),
            Text(
              "玲珑应用商店",
              style: TextStyle(
                fontSize: width*0.025,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
