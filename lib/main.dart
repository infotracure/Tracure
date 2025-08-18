import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/blood_pressure/view/blood_pressure_screen.dart';
import 'package:tracure/features/blood_sugar/view/blood_sugar_screen.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker__screen.dart';
import 'package:tracure/features/loginpage/view/login_page.dart';
import 'package:tracure/features/medicine_tracker/view/medicine_tracker_screen.dart';
import 'package:tracure/utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  runApp(const MyApp());
}

// Alice alice = Alice(
//   configuration: AliceConfiguration(
//     showNotification: true,
//     showInspectorOnShake: true,
//   ),
// );

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: alice.getNavigatorKey(),
      theme: ThemeClass.lightTheme,
      home: const LoginPage(),
    );
  }
}
