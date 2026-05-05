import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/blood_sugar/controller/blood_sugar_controller.dart';
import 'package:tracure/features/blood_sugar/view/blood_sugar_overview.dart';
import 'package:tracure/features/blood_sugar/view/blood_sugar_settings.dart';
import 'package:tracure/features/blood_sugar/view/blood_sugar_activity.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_appbar.dart';
import '../../step_tracker/view/step_tracker_screen.dart';

class BloodSugarScreen extends StatelessWidget {
  BloodSugarScreen({super.key});
  final bloodSugarController = Get.put(BloodSugarController());
  // 0xFF4CAF50
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Blood Sugar"),
      body: RoundedTabBarExample(
        color: ColorConstant.bloodSugarGlobal,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Activity'),
          Tab(text: 'Settings'),
        ],
        tabViews: const [
          BloodSugarOverview(),
          BloodSugarActivity(),
          BloodSugarSettings(),
        ],
      ).padOnly(t: 16),
    );
  }
}
