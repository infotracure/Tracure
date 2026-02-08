import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/blood_pressure/view/blood_pressure_overview.dart';
import 'package:tracure/features/blood_pressure/view/blood_pressure_settings.dart';
import 'package:tracure/features/blood_pressure/view/blood_pressure_activity.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_appbar.dart';
import '../../sleep_tracker/view/sleep_tracker_screen.dart';
import '../../step_tracker/view/step_tracker_screen.dart';
import '../controller/blood_pressure_controller.dart';

class BloodPressureScreen extends StatelessWidget {
  BloodPressureScreen({super.key});
  final bloodPressureController = Get.put(BloodPressureController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF0F0),
      appBar: CustomAppbar(title: "Blood Pressure"),
      body: RoundedTabBarExample(
        color: const Color(0xFFE53935),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Activity'),
          Tab(text: 'Settings'),
        ],
        tabViews: const [
          BloodPressureOverview(),
          BloodPressureActivity(),
          BloodPressureSettings(),
        ],
      ).padOnly(t: 16),
    );
  }
}
