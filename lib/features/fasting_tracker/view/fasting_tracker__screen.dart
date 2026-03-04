import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/fasting_tracker/controller/fasting_tracker_controller.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker_overview.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker_activity.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker_settings.dart';
import 'package:tracure/utils/common_appbar.dart';

import '../../step_tracker/view/step_tracker_screen.dart';

const Color fastingRed = Color(0xFFE53935);

class FastingTrackerScreen extends StatefulWidget {
  const FastingTrackerScreen({super.key});

  @override
  State<FastingTrackerScreen> createState() => _FastingTrackerScreenState();
}

class _FastingTrackerScreenState extends State<FastingTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;
  final FastingTrackerController controller = Get.put(
    FastingTrackerController(),
  );

  final List<Map<String, String>> tabData = [
    {"title": "Overview", "icon": "assets/images/ic_overview_chart.png"},
    {"title": "Activity", "icon": "assets/images/ic_person_running.png"},
    {"title": "Settings", "icon": "assets/images/ic_settings.png"},
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabData.length, vsync: this);
    tabController.animation?.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Fasting Tracker"),
      body: RoundedTabBarExample(
        controller: tabController,
        color: fastingRed,
        tabs: tabData.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value["title"]!;
          final icon = entry.value["icon"]!;
          return _createTab(title: title, icon: icon, index: index);
        }).toList(),
        tabViews: const [
          FastingTrackerOverview(),
          FastingTrackerActivity(),
          FastingTrackerSettings(),
        ],
      ),
    );
  }

  Tab _createTab({
    required String title,
    required String icon,
    required int index,
  }) {
    final selected = _isSelected(index);
    return Tab(
      child: FittedBox(
        child: Row(
          children: [
            Image.asset(
              icon,
              color: selected ? Colors.white : Colors.grey,
              height: 18,
              width: 18,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSelected(int tabIndex) {
    final currentPage =
        tabController.animation?.value.round() ?? tabController.index;
    return currentPage == tabIndex;
  }
}
