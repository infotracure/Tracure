import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

import '../../../servies/sleep_service.dart';
import '../../../utils/constant/color_constants.dart';
import '../../../utils/custom_text.dart';
import 'gym_checkin_dialog.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  final homeController = Get.find<HomeController>();
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
      // Sync steps silently in background
      homeController.checkForLastStepPushedData(silent: true);
      homeController.checkForLastSleepPushedData(silent: true);
      SleepService.requestAlarmPermission()
          .then((isGranted) async {
            if (isGranted) {
              await homeController.scheduleSleep();
            }
          })
          .then((_) async {
            await PermissionManager.requestActivityPermission();
          })
          .then((_) async {
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
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            homeController.mainScaffoldKey.currentState?.openDrawer();
          },
        ),
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
              WeeklyHealthInsight(),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterFastinWidget extends StatelessWidget {
  WaterFastinWidget({super.key});
  final homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final waterData =
          homeController.dashboardActivityModel?.value?.data?.water;
      final totalMl = waterData?.totalMl ?? 0;
      final waterProgress = (waterData?.percentageAchieved ?? 0) / 100;

      return SizedBox(
        height: 90,
        child: Row(
          children: [
            Expanded(
              child: iconLabelCard(
                label: "Water Intake",
                img: "assets/images/fluent-emoji_glass-of-milk.png",
                color: Color(0xFF5B84D0),
                value: _formatWaterValue(totalMl),
                progress: waterProgress.clamp(0.0, 1.0),
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
                progress: 0.0,
                onTap: () => Get.to(() => const FastingTrackerScreen()),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _formatWaterValue(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)} L';
    }
    return '$ml ml';
  }

  Widget iconLabelCard({
    required String label,
    required String img,
    required Color color,
    required String value,
    required double progress,
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
                value: progress,
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

class GymCheckinWidget extends StatefulWidget {
  const GymCheckinWidget({super.key});

  @override
  State<GymCheckinWidget> createState() => _GymCheckinWidgetState();
}

class _GymCheckinWidgetState extends State<GymCheckinWidget> {
  final homeController = Get.find<HomeController>();
  int _weekOffset = 0; // 0 = current week, -1 = previous week, etc.

  void _onWeekChanged(int newOffset) {
    setState(() => _weekOffset = newOffset);
    _fetchGymCheckIn();
  }

  void _fetchGymCheckIn() {
    final weekDates = getWeekDates(_weekOffset);
    final dateFormat = DateFormat('yyyy-MM-dd');
    homeController.getGymCheckIn(
      startDate: dateFormat.format(weekDates.first),
      endDate: dateFormat.format(weekDates.last),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekList = ["M", "T", "W", "T", "F", "S", "S"];
    final weekDates = getWeekDates(_weekOffset);
    final isCurrentWeek = _weekOffset == 0;

    return Obx(() {
      final checkInData = homeController.gymCheckInModel?.value?.data ?? [];

      return Container(
        padding: EdgeInsets.all(16),
        decoration: CommonWidget.containerDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomText.title(
                  text: "Gym Check-in",
                  size: 16,
                  isBold: true,
                ).padOnly(b: 8),
                Spacer(),
                GestureDetector(
                  onTap: () => _onWeekChanged(_weekOffset - 1),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 16,
                  ).padAll(all: 6),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: isCurrentWeek
                      ? null
                      : () => _onWeekChanged(_weekOffset + 1),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isCurrentWeek ? Colors.grey.shade300 : null,
                  ).padAll(all: 6),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...weekList.map((day) {
                  return Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(day, style: TextStyle(fontSize: 16)),
                  );
                }),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ...weekDates.map((date) {
                  final isCheckedIn = _isCheckedIn(date, checkInData);
                  final isToday = _isSameDay(date, DateTime.now());
                  final isFuture = _isFutureDate(date);

                  return GestureDetector(
                    onTap: () {
                      if (isToday && !isCheckedIn) {
                        showCheckInDialog(context, date);
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _getDayColor(isCheckedIn, isToday, isFuture),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${date.day}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getTextColor(isCheckedIn, isToday, isFuture),
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
    });
  }

  bool _isCheckedIn(DateTime date, List checkInData) {
    return checkInData.any(
      (item) =>
          item.checkinDate != null &&
          _isSameDay(item.checkinDate!, date) &&
          item.checkedIn == true,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getDayColor(bool isCheckedIn, bool isToday, bool isFuture) {
    if (isFuture) {
      return Colors.white;
    } else if (isCheckedIn) {
      return Colors.green.withAlpha(50);
    } else if (isToday) {
      return ColorConstant.backgroundColor;
    }
    return Colors.redAccent.withAlpha(50);
  }

  Color _getTextColor(bool isCheckedIn, bool isToday, bool isFuture) {
    if (isFuture) {
      return Colors.grey.shade400;
    } else if (isCheckedIn) {
      return Colors.green;
    } else if (isToday) {
      return ColorConstant.primaryColor;
    }
    return Colors.redAccent;
  }

  bool _isFutureDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate.isAfter(today);
  }

  List<DateTime> getWeekDates(int weekOffset) {
    final now = DateTime.now();

    // Start of this week (Monday), then apply offset
    final startOfWeek = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: weekOffset * 7));

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
    return Obx(() {
      final dashboard = homeController.dashboardActivityModel?.value?.data;
      final overallScore = (dashboard?.overallScore ?? 0) / 100;

      // Steps data
      final stepsData = dashboard?.steps;
      final totalSteps = stepsData?.totalSteps ?? 0;
      final stepsProgress = (stepsData?.stepsPercentage ?? 0) / 100;

      // Sleep data
      final sleepData = dashboard?.sleep;
      final sleepHours = sleepData?.totalSleepHours ?? '0h 0m';
      final sleepProgress = (sleepData?.qualityScore ?? 0) / 100;

      // Calories (using steps data for now as API doesn't have calories)
      final caloriesValue = homeController.todayCalories.value;

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
                          _getMotivationalMessage(overallScore),
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
                  CircularProgressWidget(percent: overallScore.clamp(0.0, 1.0)),
                ],
              ),
            ),
            SizedBox(height: 10),
            Divider(height: 8, thickness: 1, color: Colors.grey.shade300),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 80,
                child: Row(
                  children: [
                    Expanded(
                      child: iconLabelCard(
                        label: "Steps",
                        img: "assets/images/emojione_running-shoe.png",
                        color: Color(0xFFFAB005),
                        value: totalSteps.toString(),
                        progress: stepsProgress.clamp(0.0, 1.0),
                        onTap: () => Get.to(() => const StepTrackerScreen()),
                      ),
                    ),
                    VerticalDivider(thickness: 1, color: Colors.grey.shade300),
                    Expanded(
                      child: iconLabelCard(
                        label: "Sleep",
                        img: "assets/images/fluent-emoji_sleeping-face.png",
                        color: Color(0xFF228BE6),
                        value: sleepHours,
                        progress: sleepProgress.clamp(0.0, 1.0),
                        onTap: () => Get.to(() => const SleepTrackerScreen()),
                      ),
                    ),
                    VerticalDivider(thickness: 1, color: Colors.grey.shade300),
                    Expanded(
                      child: iconLabelCard(
                        label: "Calories",
                        img: "assets/images/fluent-emoji_fire.png",
                        color: ColorConstant.verdigris,
                        value: caloriesValue.isEmpty ? '0' : caloriesValue,
                        progress: 0.0,
                        onTap: () => Get.to(() => const StepTrackerScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  String _getMotivationalMessage(double progress) {
    if (progress >= 0.8) return "You're Doing Great!";
    if (progress >= 0.5) return "Keep Going!";
    if (progress >= 0.25) return "Good Start!";
    return "Let's Get Moving!";
  }

  Widget iconLabelCard({
    required String label,
    required String img,
    required Color color,
    required String value,
    required double progress,
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
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Image.asset(img, height: 20, width: 20),
              ],
            ),
            SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
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
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: iconLabelCard(
                  label: "BMI Calculator",
                  img: "assets/images/ic_personStanding.png",
                  onTap: () => Get.to(() =>  BloodSugarScreen()),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: iconLabelCard(
                  label: "Blood Sugar",
                  img: "assets/images/fluent-emoji_drop-of-blood.png",
                  onTap: () => Get.to(() =>  BloodSugarScreen()),
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: iconLabelCard(
                  label: "Blood Pressure",
                  img: "assets/images/fluent-emoji_drop-of-blood.png",
                  onTap: () => Get.to(() => BloodPressureScreen()),
                ),
              ),
              // Expanded(
              //   // child: iconLabelCard(
              //   //   label: "Sleep Tracker",
              //   //   img: "assets/images/fluent-emoji_sleeping-face.png",
              //   //   onTap: () => Get.to(() => const SleepTrackerScreen()),
              //   // ),
              //   child: SizedBox.shrink(),
              // ),
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

class WeeklyHealthInsight extends StatelessWidget {
  const WeeklyHealthInsight({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [keyHealthBenefits()]);
  }

  Widget keyHealthBenefits() {
    var benefitList = [
      {
        "icon": "assets/images/ion_water-outline.png",
        "title": "Hydration",
        "subTitle": "Daily water intake increased by 20%",
      },
      {
        "icon": "assets/images/ic_heart.png",
        "title": "Heart Health",
        "subTitle": "Improved resting heart rate by 12%",
      },
      {
        "icon": "assets/images/hugeicons_energy.png",
        "title": "Daily Activity",
        "subTitle": "Increased step count by 35%",
      },
      {
        "icon": "assets/images/solar_moon-sleep-linear.png",
        "title": "Sleep Quality",
        "subTitle": "Deep sleep extended by 13%",
      },
    ];
    return Container(
      decoration: CommonWidget.containerDecoration(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          CustomText.title(
            text: "Weekly Health Highlights",
            isBold: true,
          ).padSymm(horizontal: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: benefitList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (BuildContext context, int i) {
              return Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xffF9F9FA),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(benefitList[i]["icon"]!, height: 24),
                    SizedBox(height: 4),
                    CustomText.title(
                      text: benefitList[i]["title"],
                      isBold: true,
                      size: 12,
                      overflow: TextOverflow.visible,
                    ),
                    SizedBox(height: 4),
                    CustomText.title(
                      text: benefitList[i]["subTitle"],
                      size: 10,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              );
            },
          ),
          Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xffF9F9FA),
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset("assets/images/ic_target_goal.png", height: 24),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText.title(
                      text: "Goal Achievement",
                      isBold: true,
                      size: 12,
                      overflow: TextOverflow.visible,
                    ),
                    SizedBox(height: 4),
                    CustomText.title(
                      text: "You've achieved 85% of your weekly goals",
                      size: 10,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
