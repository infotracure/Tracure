import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/fasting_tracker/controller/fasting_tracker_controller.dart';
import 'package:tracure/features/homepage/controller/home_controller.dart';
import 'package:tracure/features/homepage/view/activity_screen.dart';
import 'package:tracure/features/homepage/view/homepage.dart';
import 'package:tracure/features/loginpage/view/login_page.dart';
import 'package:tracure/features/profile/view/profile_screen.dart';
import 'package:tracure/features/shorts/view/shorts_screen.dart';
import 'package:tracure/servies/hive_service.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/extensions.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  int _previousIndex = 0;
  final homeController = Get.put(HomeController());

  final List<Widget> _pages = [
    const Homepage(),
    const ActivityScreen(),
    const ShortsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Get.put(FastingTrackerController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: homeController.mainScaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(child: ListView()),
              CommonWidget.roundedButton(
                context: context,
                titleColor: ColorConstant.bgWhite,
                bgColor: ColorConstant.red,
                title: "Logout",
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
                onTap: () async {
                  await HiveService.instance.clear();
                  Get.offAll(() => LoginPage());
                },
              ).paddingSymmetric(horizontal: 16),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_rounded,
                  // label: 'Home',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.grid_view_rounded,
                  // label: 'Activities',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.play_circle_outline_rounded,
                  // label: 'Shorts',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  // label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    String? label,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (_selectedIndex != index) {
          _previousIndex = _selectedIndex;
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? ColorConstant.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 18,
            ),
            const SizedBox(width: 8).visible(isVisible: label != null),
            Text(
              label ?? '',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ).visible(isVisible: label != null),
          ],
        ),
      ),
    );
  }
}
