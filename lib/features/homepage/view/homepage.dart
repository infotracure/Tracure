import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:tracure/features/blood_pressure/view/blood_pressure_screen.dart';
import 'package:tracure/features/blood_sugar/view/blood_sugar_screen.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker__screen.dart';
import 'package:tracure/features/homepage/controller/home_controller.dart';
import 'package:tracure/features/homepage/view/CircularProgressWidget.dart'
    show CircularProgressWidget;
import 'package:tracure/features/medicine_tracker/view/medicine_tracker_screen.dart';
import 'package:tracure/features/sleep_tracker/view/sleep_tracker_screen.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_screen.dart';
import 'package:tracure/features/water_intake/view/water_intake_screen.dart';
import 'package:tracure/servies/app_permission.dart';
import 'package:tracure/servies/health_service.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../main.dart';
import '../../../servies/sleep_service.dart';
import '../../../utils/constant/color_constants.dart';
import '../../../utils/custom_text.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  final homeController = Get.put(HomeController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // start listening
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      homeController.setStepValue();
      homeController.setSleepValue();
      SleepService.requestAlarmPermission().then((isGranted) async {
        if (isGranted) {
          await homeController.scheduleSleep();
        }
        await PermissionManager.requestActivityPermission();
        await AppPermission.requestNotificationPermission();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F3F7),
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () async {
              // await SleepService.stopTracking();
            },
            child: Icon(Icons.notifications),
          ),
          SizedBox(width: 10),
        ],
        backgroundColor: Color(0xFFF2F3F7),
      ),
      drawer: Drawer(child: ListView()),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              WelcomeHeader(),
              SleepStepCalories(),
              BookSpecialistCard(),
              WaterFastinWidget(),
              GymCheckinWidget(),
              HealthEcosystem(),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterFastinWidget extends StatelessWidget {
  const WaterFastinWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          Expanded(
            child: iconLabelCard(
              label: "Water Intake",
              img: "assets/images/fluent-emoji_glass-of-milk.png",
              color: Color(0xFF5B84D0),
              value: "600 ml",

              onTap: () => Get.to(() => const WaterIntakeScreen()),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: iconLabelCard(
              label: "Fasting",
              img: "assets/images/ic_fasting.png",
              color: Color(0xFF40C057),
              value: "01:02 hr",
              onTap: () => Get.to(() => const FastingTrackerScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconLabelCard({
    required String label,
    required String img,
    required Color color,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: CommonWidget.containerDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText.title(text: label, size: 14, isBold: true),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Image.asset(img, height: 20, width: 20),
              ],
            ),
            SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.8,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GymCheckinWidget extends StatelessWidget {
  const GymCheckinWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final weekList = ["M", "T", "W", "T", "F", "S", "S"];
    final weekDates = getCurrentWeekDates();
    final daysList = weekDates.map((d) => d.day).toList();
    return Container(
      padding: EdgeInsets.all(16),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.title(
            text: "Gym Check-in",
            size: 16,
            isBold: true,
          ).padOnly(b: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ...weekList.map((day) {
                return GestureDetector(
                  onTap: () {
                    // Handle day toggle
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,

                    child: Text(day, style: TextStyle(fontSize: 16)),
                  ),
                );
              }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ...daysList.map((day) {
                return GestureDetector(
                  onTap: () {
                    // Handle day toggle
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$day",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  List<DateTime> getCurrentWeekDates() {
    final now = DateTime.now(); // Add 1 day to ensure today is included

    // Start of this week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    // Generate all 7 dates (Mon → Sun)
    return List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }
}

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "Welcome back, Dave",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class SleepStepCalories extends StatelessWidget {
  SleepStepCalories({super.key});
  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 0,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "You're Doing Great!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Keep up the momentum by finishing your daily goals.",
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                CircularProgressWidget(percent: 0.8),
              ],
            ),
          ),
          SizedBox(height: 10),
          Divider(height: 8, thickness: 1, color: Colors.grey.shade300),
          Obx(
            () => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    iconLabelCard(
                      label: "Steps",
                      img: "assets/images/emojione_running-shoe.png",
                      color:  Color(0xFFFAB005),
                      value: homeController.todayStep.value,
                      onTap: () => Get.to(() => const StepTrackerScreen()),
                    ),
                    VerticalDivider(thickness: 1, color: Colors.grey.shade300),
                    iconLabelCard(
                      label: "Sleep",
                      img: "assets/images/fluent-emoji_sleeping-face.png",
                      color:  Color(0xFF228BE6),
                      value: homeController.todaySleep.value,
                      onTap: () => Get.to(() => const SleepTrackerScreen()),
                    ),
                    VerticalDivider(thickness: 1, color: Colors.grey.shade300),
                    iconLabelCard(
                      label: "Calories",
                      img: "assets/images/fluent-emoji_fire.png",
                      color: ColorConstant.verdigris,
                      value: homeController.todayCalories.value,
                      onTap: () => Get.to(() => const StepTrackerScreen()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconLabelCard({
    required String label,
    required String img,
    required Color color,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        width: 100,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Image.asset(img, height: 20, width: 20),
              ],
            ),
            SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: 0.8,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookSpecialistCard extends StatelessWidget {
  const BookSpecialistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            spreadRadius: 0,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Yoga Gurukul",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Know the benefits of yoga from world renowned specialist Dr. David Frawley",
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  "02 June 2025",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: GestureDetector(
                    onTap: () async {
                      // await PermissionManager.requestActivityPermission();
                      // printTodaySteps();
                      // HealthDataService().fetchSleepData();
                      // getSleep();
                      SleepService.getSleepDataForDate('2025-06-30');
                      // printWeeklySteps();
                      printMonthlySteps();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Wraps content tightly
                      children: [
                        Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage("assets/images/bg_quickaction.png"),
          ),
        ],
      ),
    );
  }
}

class HealthEcosystem extends StatelessWidget {
  const HealthEcosystem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage("assets/images/bg_quickaction.png"),
          fit: BoxFit.fill,
        ),
      ),
      child: Column(
        children: [Ecosystem(), SizedBox(height: 10), TrackWellbeing()],
      ),
    );
  }
}

class TrackWellbeing extends StatelessWidget {
  const TrackWellbeing({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Track you well-being",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: iconLabelCard(
                  label: "BMI Calculator",
                  img: "assets/images/ic_personStanding.png",
                  onTap: () => Get.to(() => const BloodSugarScreen()),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: iconLabelCard(
                  label: "Blood Sugar",
                  img: "assets/images/fluent-emoji_drop-of-blood.png",
                  onTap: () => Get.to(() => const BloodSugarScreen()),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                // child: iconLabelCard(
                //   label: "Sleep Tracker",
                //   img: "assets/images/fluent-emoji_sleeping-face.png",
                //   onTap: () => Get.to(() => const SleepTrackerScreen()),
                // ),
                child: SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget iconLabelCard({
    required String label,
    required String img,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(img, height: 20, width: 20),
            SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class Ecosystem extends StatelessWidget {
  const Ecosystem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Explore Health Ecosystem",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Here’s our recommendations based on your history",
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              Expanded(
                child: iconLabelCard(
                  label: "Medicine Tracker",
                  img: "assets/images/fluent-emoji_pill.png",
                  onTap: () => Get.to(() => const MedicineTrackerScreen()),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: iconLabelCard(
                  label: "Menstrual Cycle",
                  img: "assets/images/ic_female.png",
                  onTap: () => Get.to(() => const MedicineTrackerScreen()),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: iconLabelCard(
                  label: "Breathing Exercise",
                  img: "assets/images/ic_personStanding.png",
                  onTap: () => Get.to(() => const FastingTrackerScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget iconLabelCard({
    required String label,
    required String img,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(img, height: 20, width: 20),
            SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
