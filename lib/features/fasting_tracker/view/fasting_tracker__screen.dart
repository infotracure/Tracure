import 'package:flutter/material.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker__month.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker__week.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker_day.dart';
import 'package:tracure/features/water_intake/view/water_intake_day.dart';
import 'package:tracure/features/water_intake/view/water_intake_month.dart';
import 'package:tracure/features/water_intake/view/water_intake_week.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_appbar.dart';
import '../../sleep_tracker/view/sleep_tracker_screen.dart';

class FastingTrackerScreen extends StatelessWidget {
  const FastingTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Fasting Tracker"),
      body: RoundedTabBarExample(
        tabs: const [
          Tab(text: 'Day'),
          Tab(text: 'Week'),
          Tab(text: 'Month'),
        ],
        tabViews: const [
          FastingTrackerDay(),
          FastingTrackerWeek(),
          FastingTrackerMonth(),
        ],
      ).padOnly(t: 16),
    );
  }
}
