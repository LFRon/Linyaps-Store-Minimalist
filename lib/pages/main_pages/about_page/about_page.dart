import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20.0,top: 20,right: 20),
        child: Column(
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
                Text(
                  '玲珑应用商店极速版',
                  style: TextStyle(
                    fontSize: 50,
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
