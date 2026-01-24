import 'package:flutter/material.dart';
import 'package:tracure/features/blood_pressure/view/blood_pressure_day.dart';
import 'package:tracure/features/blood_pressure/view/blood_pressure_month.dart';
import 'package:tracure/features/blood_pressure/view/blood_pressure_week.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_appbar.dart';
import '../../sleep_tracker/view/sleep_tracker_screen.dart';
import '../../step_tracker/view/step_tracker_screen.dart';

class BloodPressureScreen extends StatelessWidget {
  const BloodPressureScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: CustomAppbar(title: "Blood Pressure"),
      body: RoundedTabBarExample(
        tabs: const [
          Tab(text: 'Day'),
          Tab(text: 'Week'),
          Tab(text: 'Month'),
        ],
        tabViews: const [
          BloodPressureDay(),
          BloodPressureWeek(),
          BloodPressureMonth(),
        ],
      ).padOnly(t: 16),
    );
  }
}
