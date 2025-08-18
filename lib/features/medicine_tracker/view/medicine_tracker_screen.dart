import 'package:flutter/material.dart';
import 'package:tracure/utils/extensions.dart';
import '../../../utils/common_appbar.dart';
import '../../sleep_tracker/view/sleep_tracker_screen.dart';
import 'medicine_tracker_day.dart';
import 'medicine_tracker_month.dart';
import 'medicine_tracker_week.dart';

class MedicineTrackerScreen extends StatelessWidget {
  const MedicineTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Medicine Tracker"),
      // body: RoundedTabBarExample(
      //   tabs: const [
      //     Tab(text: 'Day'),
      //     Tab(text: 'Week'),
      //     Tab(text: 'Month'),
      //   ],
      //   tabViews: const [
      //     MedicineTrackerDay(),
      //     MedicineTrackerWeek(),
      //     MedicineTrackerMonth(),
      //   ],
      body: SingleChildScrollView(child: MedicineTrackerDay().padOnly(t: 16)),
    );
  }
}
