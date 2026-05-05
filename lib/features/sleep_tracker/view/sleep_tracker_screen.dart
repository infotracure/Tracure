import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:tracure/features/sleep_tracker/view/sleep_tracker_overview.dart';
import 'package:tracure/features/sleep_tracker/view/sleep_tracker_month.dart';
import 'package:tracure/features/sleep_tracker/view/sleep_tracker_setting.dart';
import 'package:tracure/features/sleep_tracker/view/sleep_tracker_insight.dart';
import 'package:tracure/utils/common_appbar.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/extensions.dart';

import '../../step_tracker/view/step_tracker_screen.dart';
import '../controller/sleep_tracker_controller.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController? tabController;
  final List<Map<String, String>> tabData = [
    {"title": "Overview", "icon": "assets/images/ic_overview_chart.png"},
    {"title": "Insights", "icon": "assets/images/ic_person_running.png"},
    {"title": "Settings", "icon": "assets/images/ic_settings.png"},
  ];
  final sleepTrackerController = Get.put(SleepTrackerController());
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabData.length, vsync: this);
    tabController?.animation?.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Sleep Tracking"),
      body: RoundedTabBarExample(
        controller: tabController,
        color: ColorConstant.sleepGlobal,
        tabs: tabData.asMap().entries.map((entry) {
          int index = entry.key;
          String title = entry.value["title"]!;
          String icon = entry.value["icon"]!;

          return createTabs(
            title: title,
            icon: icon,
            index: index, // ✅ pass index here
          );
        }).toList(),

        tabViews: const [
          SleepTrackerOverview(),
          SleepTrackerInsights(),
          SleepTrackerSetting(),
        ],
      ),
    );
  }

  Tab createTabs({
    required String title,
    required String icon,
    required int index,
  }) {
    final selected = isSelected(index);

    return Tab(
      child: Row(
        children: [
          Image.asset(
            icon,
            color: selected ? Colors.white : Colors.grey,
            height: 18,
            width: 18,
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: selected ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  bool isSelected(int tabIndex) {
    final currentPage =
        tabController?.animation?.value.round() ?? tabController?.index;
    return currentPage == tabIndex;
  }
}
