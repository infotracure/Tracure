import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/water_intake/view/water_intake_overview.dart';
import 'package:tracure/features/water_intake/view/water_intake_settings.dart';
import 'package:tracure/features/water_intake/view/water_intake_acitvity.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_appbar.dart';
import '../../step_tracker/view/step_tracker_screen.dart';
import '../controller/water_intake_controller.dart';

class WaterIntakeScreen extends StatefulWidget {
  const WaterIntakeScreen({super.key});

  @override
  State<WaterIntakeScreen> createState() => _WaterIntakeScreenState();
}

class _WaterIntakeScreenState extends State<WaterIntakeScreen> {
  final watercontroller = Get.put(WaterIntakeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Water Intake"),
      body: RoundedTabBarExample(
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Activity'),
          Tab(text: 'Settings'),
        ],
        tabViews: const [
          WaterIntakeDay(),
          WaterIntakeWeek(),
          WaterIntakeSettings(),
        ],
      ).padOnly(t: 16),
    );
  }
}
