import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:tracure/features/loginpage/view/login_page.dart';
import 'package:tracure/features/loginpage/view/splash_screen.dart';
import 'package:tracure/features/register_screen/controller/register_controller.dart';
import 'package:tracure/features/register_screen/view/register_screen.dart';
import 'package:tracure/servies/hive_service.dart';
import 'package:tracure/utils/app_theme.dart';
import 'features/homepage/view/homepage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('appBox');

  // Initialize singleton service
  await HiveService.instance.init();

  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final talker = Talker();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, // lets taps pass through
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeClass.lightTheme,
        // home: navigateToSplash(),
        home: TalkerWrapper(
          talker: talker,
          options: TalkerWrapperOptions(),
          child: SplashScreen(),
        ),
      ),
    );
  }
}
