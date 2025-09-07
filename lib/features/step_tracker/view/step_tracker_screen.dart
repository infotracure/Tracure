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

class _StepTrackerScreenState extends State<StepTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController? tabController;
  final List<Map<String, String>> tabData = [
    {"title": "Overview", "icon": "assets/images/ic_overview_chart.png"},
    {"title": "Activity", "icon": "assets/images/ic_person_running.png"},
    {"title": "Challenges", "icon": "assets/images/ic_trophy.png"},
    {"title": "Settings", "icon": "assets/images/ic_settings.png"},
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
    tabController?.addListener(() {
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
      appBar: CustomAppbar(title: "Step Tracking"),
      body: RoundedTabBarExample(
        controller: tabController,
        color: ColorConstant.verdigris,
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
          StepTrackerDay(),
          StepTrackerWeek(),
          StepTrackerMonth(),
          SizedBox(),
        ],
      ).padOnly(t: 16),
    );
  }

  Tab createTabs({
    required String title,
    required String icon,
    required int index,
  }) {
    return Tab(
      child: Row(
        children: [
          Image.asset(
            icon,
            color: tabController?.index == index ? Colors.white : Colors.grey,
            height: 20,
            width: 20,
          ),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: tabController?.index == index ? Colors.white : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class RoundedTabBarExample extends StatelessWidget {
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final Color? color;
  final TabController? controller;

  const RoundedTabBarExample({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.color,
    this.controller,
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
                controller: controller,
                tabAlignment: TabAlignment.start,
                isScrollable: true,
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsetsGeometry.all(3),
                indicator: BoxDecoration(
                  color:
                      color ??
                      ColorConstant
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
          Expanded(
            child: TabBarView(controller: controller, children: tabViews),
          ),
        ],
      ),
    );
  }
}
