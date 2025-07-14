import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/homepage/view/homepage.dart';
import 'package:tracure/features/loginpage/view/login_page.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_screen.dart';
import 'package:tracure/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeClass.lightTheme,
      home: const StepTrackerScreen(),
    );
  }
}
