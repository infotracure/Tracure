import 'package:flutter/material.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_day.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_month.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_week.dart';
import 'package:tracure/utils/common_appbar.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/extensions.dart';

class StepTrackerScreen extends StatefulWidget {
  const StepTrackerScreen({super.key});

  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Step Tracking"),
      body: RoundedTabBarExample(
        tabs: const [
          Tab(text: 'Day'),
          Tab(text: 'Week'),
          Tab(text: 'Month'),
        ],
        tabViews: const [
          StepTrackerDay(),
          StepTrackerWeek(),
          StepTrackerMonth(),
        ],
      ).padOnly(t: 16),
    );
  }
}

class RoundedTabBarExample extends StatelessWidget {
  final List<Widget> tabs;
  final List<Widget> tabViews;

  const RoundedTabBarExample({
    super.key,
    required this.tabs,
    required this.tabViews,
  }) : assert(
         tabs.length == tabViews.length,
         'Tabs and TabViews must have the same length.',
       );

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicatorPadding: EdgeInsetsGeometry.all(3),
                indicator: BoxDecoration(
                  color: ColorConstant
                      .primaryColor, // Replace with ColorConstant.primaryColor if defined
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                dividerColor: Colors.transparent,
                tabs: tabs,
              ),
            ),
          ),
          Expanded(child: TabBarView(children: tabViews)),
        ],
      ),
    );
  }
}
