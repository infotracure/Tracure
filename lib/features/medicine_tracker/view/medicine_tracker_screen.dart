import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/common_appbar.dart';
import '../../../utils/constant/color_constants.dart';
import '../../step_tracker/view/step_tracker_screen.dart';
import '../controller/medicine_tracker_controller.dart';
import 'medicine_tracker_day.dart';
import 'medicine_tracker_schedule.dart';
import 'medicine_tracker_history.dart';
import 'medicine_tracker_settings.dart';

const Color medicineGreen = ColorConstant.medicineGlobal;

class MedicineTrackerScreen extends StatefulWidget {
  const MedicineTrackerScreen({super.key});

  @override
  State<MedicineTrackerScreen> createState() => _MedicineTrackerScreenState();
}

class _MedicineTrackerScreenState extends State<MedicineTrackerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  final List<Map<String, dynamic>> tabData = [
    {"title": "Dashboard", "icon": Icons.dashboard_outlined},
    {"title": "Schedule", "icon": Icons.schedule_outlined},
    {"title": "History", "icon": Icons.history_outlined},
    {"title": "Settings", "icon": Icons.settings_outlined},
  ];

  @override
  void initState() {
    super.initState();
    Get.put(MedicineTrackerController());
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
      appBar: CustomAppbar(title: "Medicine Tracker"),
      body: RoundedTabBarExample(
        controller: tabController,
        color: medicineGreen,
        tabs: tabData.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value["title"] as String;
          final icon = entry.value["icon"] as IconData;
          return _createTab(title: title, icon: icon, index: index);
        }).toList(),
        tabViews: const [
          MedicineTrackerDashboard(),
          MedicineTrackerSchedule(),
          MedicineTrackerHistory(),
          MedicineTrackerSettings(),
        ],
      ),
    );
  }

  Tab _createTab({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final selected = _isSelected(index);
    return Tab(
      child: FittedBox(
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.grey,
              size: 18,
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
