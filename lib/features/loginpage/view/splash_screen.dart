import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:tracure/utils/stagger_dot_loading.dart';

import '../../../servies/hive_service.dart';
import '../../../utils/custom_text.dart';
import '../../homepage/view/homepage.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2), () {
        final loginData = HiveService.instance.getBool(
          HiveService.isUserLoggedIn,
        );
        if (loginData == true) {
          Get.offAll(() => Homepage());
        } else {
          Get.offAll(() => LoginPage());
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText.title(text: "Tracure", size: 50),
            SizedBox(height: 20),
            ThreeDotLoading(),
          ],
        ),
      ),
    );
  }
}
