import 'package:flutter/material.dart';
import 'package:tracure/features/water_intake/view/water_intake_day.dart';
import 'package:tracure/features/water_intake/view/water_intake_month.dart';
import 'package:tracure/features/water_intake/view/water_intake_week.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_appbar.dart';
import '../../sleep_tracker/view/sleep_tracker_screen.dart';

class WaterIntakeScreen extends StatelessWidget {
  const WaterIntakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Water Intake"),
      body: RoundedTabBarExample(
        tabs: const [
          Tab(text: 'Day'),
          Tab(text: 'Week'),
          Tab(text: 'Month'),
        ],
        tabViews: const [
          WaterIntakeDay(),
          WaterIntakeWeek(),
          WaterIntakeMonth(),
        ],
      ).padOnly(t: 16),
    );
  }
}
