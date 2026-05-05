import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/step_tracker/controller/step_tracker_controller.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_overview.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_month.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_setting.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_activity.dart';
import 'package:tracure/utils/common_appbar.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/extensions.dart';

class StepTrackerScreen extends StatefulWidget {
  final bool initialShowCalories;

  const StepTrackerScreen({super.key, this.initialShowCalories = false});

  @override
  State<StepTrackerScreen> createState() => _StepTrackerScreenState();
}

class _StepTrackerScreenState extends State<StepTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController? tabController;
  final List<Map<String, String>> tabData = [
    {"title": "Overview", "icon": "assets/images/ic_overview_chart.png"},
    {"title": "Activity", "icon": "assets/images/ic_person_running.png"},
    // {"title": "Challenges", "icon": "assets/images/ic_trophy.png"},
    {"title": "Settings", "icon": "assets/images/ic_settings.png"},
  ];
  final StepTrackerController stepTrackerController = Get.put(
    StepTrackerController(),
  );
  @override
  void initState() {
    super.initState();
    stepTrackerController.showCalories.value = widget.initialShowCalories;
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
      appBar: CustomAppbar(
        title: "Step Tracking",
        trailing: Obx(() {
          final isCalories = stepTrackerController.showCalories.value;
          return Container(
            height: 34,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _toggleTab('Steps', !isCalories, ColorConstant.stepGlobal,
                    () => stepTrackerController.showCalories.value = false),
                _toggleTab('Calories', isCalories, ColorConstant.stepGlobal,
                    () => stepTrackerController.showCalories.value = true),
              ],
            ),
          );
        }),
      ),
      body: RoundedTabBarExample(
        controller: tabController,
        color: ColorConstant.stepGlobal,
        tabs: tabData.asMap().entries.map((entry) {
          int index = entry.key;
          String title = entry.value["title"]!;
          String icon = entry.value["icon"]!;

          return createTabs(
            title: title,
            icon: icon,
            index: index,
          );
        }).toList(),
        tabViews: const [
          StepTrackerOverview(),
          StepTrackerActivity(),
          // SizedBox(),
          StepTrackerSetting(),
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
      child: FittedBox(
        child: Row(
          children: [
            Image.asset(
              icon,
              color: selected ? Colors.white : Colors.grey,
              height: 18,
              width: 18,
            ),
            SizedBox(width: 6),
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

  bool isSelected(int tabIndex) {
    final currentPage =
        tabController?.animation?.value.round() ?? tabController?.index;
    return currentPage == tabIndex;
  }

  Widget _toggleTab(
    String label,
    bool selected,
    Color activeColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class RoundedTabBarExample extends StatelessWidget {
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final Color? color;
  final TabController? controller;
  final Widget? headerWidget;

  const RoundedTabBarExample({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.color,
    this.controller,
    this.headerWidget,
  }) : assert(
         tabs.length == tabViews.length,
         'Tabs and TabViews must have the same length.',
       );

  @override
  Widget build(BuildContext context) {
    final isThree = tabs.length <= 3;
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
                tabAlignment: isThree ? null : TabAlignment.start,
                isScrollable: !isThree,
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsetsGeometry.all(3),
                indicator: BoxDecoration(
                  color: color ?? ColorConstant.primaryColor,
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
          if (headerWidget != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: headerWidget!,
            ),
          if (headerWidget != null) const SizedBox(height: 12),
          Expanded(
            child: TabBarView(controller: controller, children: tabViews),
          ),
        ],
      ),
    );
  }
}
