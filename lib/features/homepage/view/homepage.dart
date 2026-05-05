import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tracure/features/blood_pressure/view/blood_pressure_screen.dart';
import 'package:tracure/features/blood_sugar/view/blood_sugar_screen.dart';
import 'package:tracure/features/blood_sugar/view/blood_sugar_settings.dart';
import 'package:tracure/features/fasting_tracker/controller/fasting_tracker_controller.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker__screen.dart';
import 'package:tracure/features/homepage/controller/home_controller.dart';
import 'package:tracure/features/medicine_tracker/view/medicine_tracker_screen.dart';
import 'package:tracure/features/profile/controller/profile_controller.dart';
import 'package:tracure/features/sleep_tracker/view/sleep_tracker_screen.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_screen.dart';
import 'package:tracure/features/water_intake/view/water_intake_screen.dart';
import 'package:tracure/servies/app_permission.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../servies/sleep_service.dart';
import '../../../utils/constant/color_constants.dart';
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
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      homeController.setStepValue();
      homeController.setSleepValue();
      homeController.checkForLastStepPushedData(silent: true);
      homeController.checkForLastSleepPushedData(silent: true);
      _requestPermissionsOnResume();
    }
  }

  Future<void> _requestPermissionsOnResume() async {
    final isAlarmGranted = await SleepService.requestAlarmPermission();
    if (isAlarmGranted) {
      await homeController.scheduleSleep();
    }
    await AppPermission.requestActivityPermission();
    await AppPermission.requestMicrophonePermission();
    await AppPermission.requestBatteryUnrestricted();
    await SleepService.startTrackingIfNeeded();
    await AppPermission.requestNotificationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _WelcomeHeader(),
                SizedBox(height: 16),
                _DailyProgressCard(),
                SizedBox(height: 16),
                _SleepStepsCaloriesCard(),
                // SizedBox(height: 16),
                // _YogaPromoCard(),
                SizedBox(height: 16),
                _WaterFastingRow(),
                SizedBox(height: 16),
                GymCheckinWidget(),
                SizedBox(height: 16),
                _ExploreHealthEcosystem(),
                SizedBox(height: 16),
                _WeeklyHealthHighlights(),
                SizedBox(height: 16),
                _OtherHighlights(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome Header
// ---------------------------------------------------------------------------
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    ProfileController? profileCtrl;
    try {
      profileCtrl = Get.find<ProfileController>();
    } catch (_) {}

    if (profileCtrl != null) {
      return Obx(() {
        final name = profileCtrl!.profileModel.value?.data?.firstName ?? 'User';
        return Text(
          'Welcome back, $name',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        );
      });
    }
    return const Text(
      'Welcome back,',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Daily Progress Card (white with green circular progress)
// ---------------------------------------------------------------------------
class _DailyProgressCard extends StatelessWidget {
  const _DailyProgressCard();

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Obx(() {
      final dashboard = homeController.dashboardActivityModel?.value?.data;
      final overallScore = (dashboard?.overallScore ?? 0);
      final percent = (overallScore / 100).clamp(0.0, 1.0);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: CommonWidget.containerDecoration(),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _heading(percent),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Keep up the momentum by finishing your\ndaily goals.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: percent,
                      strokeWidth: 7,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2ECC71),
                      ),
                    ),
                  ),
                  Text(
                    '${overallScore.round()}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  String _heading(double p) {
    if (p >= 0.7) return "You're Doing Great!";
    if (p >= 0.4) return "Keep Going!";
    return "Let's Get Moving!";
  }
}

// ---------------------------------------------------------------------------
// Sleep / Steps / Calories — single card, 3 columns
// ---------------------------------------------------------------------------
class _SleepStepsCaloriesCard extends StatelessWidget {
  const _SleepStepsCaloriesCard();

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Obx(() {
      final dashboard = homeController.dashboardActivityModel?.value?.data;

      // Sleep
      final sleepMinutes = dashboard?.sleep?.totalSleepMinutes ?? 0;
      final sleepRaw = homeController.todaySleep.value;
      final sleepDisplay = _formatSleep(sleepRaw);
      final sleepProgress = (sleepMinutes / 480).clamp(0.0, 1.0);

      // Steps
      final totalSteps = dashboard?.steps?.totalSteps ?? 0;
      final stepsProgress = ((dashboard?.steps?.stepsPercentage ?? 0) / 100)
          .clamp(0.0, 1.0);
      final stepsDisplay = _fmtNum(totalSteps);

      // Calories — calculated from today's steps using 0.04 kcal/step
      final calories = (totalSteps * 0.04).round();
      final caloriesProgress = (calories / 500).clamp(0.0, 1.0);
      final caloriesDisplay = _fmtNum(calories);

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
        decoration: CommonWidget.containerDecoration(),
        child: Row(
          children: [
            Expanded(
              child: _statColumn(
                label: 'Sleep',
                value: sleepDisplay,
                icon: "assets/images/fluent-emoji_sleeping-face.png",
                iconColor: const Color(0xFF5B84D0),
                progress: sleepProgress,
                progressColor: const Color(0xFF5B84D0),
                onTap: () => Get.to(() => const SleepTrackerScreen()),
              ),
            ),
            _divider(),
            Expanded(
              child: _statColumn(
                label: 'Steps',
                value: stepsDisplay,
                icon: "assets/images/emojione_running-shoe.png",
                iconColor: const Color(0xFF20C997),
                progress: stepsProgress,
                progressColor: const Color(0xFF5B84D0),
                onTap: () => Get.to(() => const StepTrackerScreen()),
              ),
            ),
            _divider(),
            Expanded(
              child: _statColumn(
                label: 'Calories',
                value: '$caloriesDisplay kcal',
                icon: "assets/images/fluent-emoji_fire.png",
                iconColor: const Color(0xFFFF922B),
                progress: caloriesProgress,
                progressColor: const Color(0xFFFF922B),
                onTap: () => Get.to(
                  () => const StepTrackerScreen(initialShowCalories: true),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _divider() =>
      Container(width: 1, height: 64, color: Colors.grey.shade200);

  Widget _statColumn({
    required String label,
    required String value,
    required String icon,
    required Color iconColor,
    required double progress,
    required Color progressColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Image.asset(icon, width: 20, height: 20),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtNum(int n) => n >= 1000 ? NumberFormat('#,###').format(n) : '$n';

  String _formatSleep(String raw) {
    // "8h 14min" → "8 h 14m"
    return raw.replaceAll('min', 'm').replaceAll('h ', ' h ');
  }
}

// ---------------------------------------------------------------------------
// Yoga Gurukul Promo Card (static recommendation card)
// ---------------------------------------------------------------------------
class _YogaPromoCard extends StatelessWidget {
  const _YogaPromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yoga Gurukul',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        children: const [
                          TextSpan(
                            text:
                                'Know the benefits of yoga from world renowned specialist ',
                          ),
                          TextSpan(
                            text: 'Dr. David Frawley',
                            style: TextStyle(
                              color: Color(0xFF5B84D0),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '02nd June 2025',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5B84D0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 14,
                          color: Color(0xFF5B84D0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipOval(
                child: Container(
                  width: 72,
                  height: 72,
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.self_improvement,
                    size: 36,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Pagination dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == 0 ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == 0
                      ? const Color(0xFF5B84D0)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Water Intake & Fasting Row
// ---------------------------------------------------------------------------
class _WaterFastingRow extends StatelessWidget {
  const _WaterFastingRow();

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    FastingTrackerController? fastingCtrl;
    try {
      fastingCtrl = Get.find<FastingTrackerController>();
    } catch (_) {}

    return Obx(() {
      final waterData =
          homeController.dashboardActivityModel?.value?.data?.water;
      final totalMl = waterData?.totalMl ?? 0;
      final waterProgress = ((waterData?.percentageAchieved ?? 0) / 100).clamp(
        0.0,
        1.0,
      );

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Water Intake
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(() => const WaterIntakeScreen()),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: CommonWidget.containerDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Water Intake',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          '$totalMl',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ml',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                        Image.asset(
                          "assets/images/fluent-emoji_glass-of-milk.png",
                          width: 23,
                          height: 23,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: waterProgress,
                        minHeight: 5,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF5B84D0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Fasting
          Expanded(
            child: GestureDetector(
              onTap: () => Get.to(() => const FastingTrackerScreen()),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: CommonWidget.containerDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fasting',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (fastingCtrl != null)
                      Obx(() {
                        final totalMinutes =
                            fastingCtrl!.fastingByDateModel.value?.data
                                ?.fold<int>(
                                  0,
                                  (sum, d) => sum + (d.durationMinutes ?? 0),
                                ) ??
                            0;
                        final goalMinutes =
                            fastingCtrl.selectedPlan.value.fastHours * 60;
                        final progress = goalMinutes > 0
                            ? (totalMinutes / goalMinutes).clamp(0.0, 1.0)
                            : 0.0;
                        return Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  _formatFasting(totalMinutes * 60),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'hr',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const Spacer(),
                                Image.asset(
                                  "assets/images/ic_fasting.png",
                                  width: 23,
                                  height: 23,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (fastingCtrl.isFasting.value) ...[
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF51CF66),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 5,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF51CF66),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      })
                    else
                      Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                '--:--',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'hr',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const Spacer(),
                              Image.asset(
                                "assets/images/ic_fasting.png",
                                width: 25,
                                height: 25,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF51CF66),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: 0.0,
                                    minHeight: 5,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF51CF66),
                                        ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  String _formatFasting(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

// ---------------------------------------------------------------------------
// Gym Check-in Widget (colored circles for each day)
// ---------------------------------------------------------------------------
class GymCheckinWidget extends StatefulWidget {
  const GymCheckinWidget({super.key});

  @override
  State<GymCheckinWidget> createState() => _GymCheckinWidgetState();
}

class _GymCheckinWidgetState extends State<GymCheckinWidget> {
  final homeController = Get.find<HomeController>();
  int _weekOffset = 0;

  static const _dayColors = [
    Color(0xFFFF6B6B),
    Color(0xFF51CF66),
    Color(0xFF20C997),
    Color(0xFF339AF0),
    Color(0xFF51CF66),
    Color(0xFF845EF7),
    Color(0xFFFF922B),
  ];

  void _onWeekChanged(int newOffset) {
    setState(() => _weekOffset = newOffset);
    _fetchGymCheckIn();
  }

  void _fetchGymCheckIn() {
    final weekDates = _getWeekDates(_weekOffset);
    final fmt = DateFormat('yyyy-MM-dd');
    homeController.getGymCheckIn(
      startDate: fmt.format(weekDates.first),
      endDate: fmt.format(weekDates.last),
    );
  }

  @override
  Widget build(BuildContext context) {
    const weekLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final weekDates = _getWeekDates(_weekOffset);
    final isCurrentWeek = _weekOffset == 0;

    return Obx(() {
      final checkInData = homeController.gymCheckInModel?.value?.data ?? [];

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: CommonWidget.containerDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Gym Check-in',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _onWeekChanged(_weekOffset - 1),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 14,
                    color: Colors.grey.shade500,
                  ).padAll(all: 6),
                ),
                GestureDetector(
                  onTap: isCurrentWeek
                      ? null
                      : () => _onWeekChanged(_weekOffset + 1),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isCurrentWeek
                        ? Colors.grey.shade300
                        : Colors.grey.shade500,
                  ).padAll(all: 6),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekLabels.map((day) {
                return SizedBox(
                  width: 38,
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final date = weekDates[i];
                final isCheckedIn = _isCheckedIn(date, checkInData);
                final isToday = _isSameDay(date, DateTime.now());
                final isFuture = _isFutureDate(date);
                final dayColor = _dayColors[i];

                return GestureDetector(
                  onTap: () {
                    if (isToday && !isCheckedIn) {
                      showCheckInDialog(context, date);
                    }
                  },
                  child: Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isCheckedIn
                          ? dayColor.withValues(alpha: 0.12)
                          : isToday
                          ? ColorConstant.backgroundColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isCheckedIn
                            ? dayColor
                            : isToday
                            ? ColorConstant.primaryColor
                            : Colors.transparent,
                        width: isCheckedIn || isToday ? 1.5 : 0,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCheckedIn
                            ? dayColor
                            : isToday
                            ? ColorConstant.primaryColor
                            : isFuture
                            ? Colors.grey.shade300
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }),
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isFutureDate(DateTime date) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    return DateTime(date.year, date.month, date.day).isAfter(today);
  }

  List<DateTime> _getWeekDates(int weekOffset) {
    final now = DateTime.now();
    final startOfWeek = now
        .subtract(Duration(days: now.weekday - 1))
        .add(Duration(days: weekOffset * 7));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }
}

// ---------------------------------------------------------------------------
// Explore Health Ecosystem (deep blue, 3+2 button layout)
// ---------------------------------------------------------------------------
class _ExploreHealthEcosystem extends StatelessWidget {
  const _ExploreHealthEcosystem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3B5BDB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Health Ecosystem',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Here's our recommendations based on your history",
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          // Row 1: 3 buttons
          Row(
            children: [
              _ecoBtn(
                icon: "assets/images/fluent-emoji_pill.png",
                label: 'Medicine\nTracker',
                onTap: () => Get.to(() => const MedicineTrackerScreen()),
              ),
              const SizedBox(width: 10),
              _ecoBtn(
                icon: "assets/images/ic_drop-of-blood.png",
                label: 'Blood\nSugar',
                onTap: () => Get.to(() => BloodSugarScreen()),
              ),
              const SizedBox(width: 10),
              _ecoBtn(
                icon: "assets/images/hypertension.png",
                label: 'Blood\nPressure',
                onTap: () => Get.to(() => BloodPressureScreen()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2: 2 buttons (same width via Expanded inside a Row with padding)
          // Row(
          //   children: [
          //     // _ecoBtn(
          //     //   icon: "assets/images/fluent-emoji_pill.png",
          //     //   label: 'BMI\nCalculator',
          //     //   onTap: () {},
          //     // ),
          //     // const SizedBox(width: 10),
          //     _ecoBtn(
          //       icon: "assets/images/fluent-emoji_pill.png",
          //       label: 'Menstrual\nCycle',
          //       onTap: () {},
          //     ),
          //     const SizedBox(width: 10),
          //     _ecoBtn(
          //       icon: "assets/images/fluent-emoji_pill.png",
          //       label: 'Breathing\nExercise',
          //       onTap: () {},
          //     ),
          //     const SizedBox(width: 10),
          //     const Expanded(child: SizedBox()),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _ecoBtn({
    required String icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(icon, width: 24, height: 24),
              // Icon(icon, color: const Color(0xFF3B5BDB), size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekly Health Highlights (section title outside, 2x2 separate cards)
// ---------------------------------------------------------------------------
class _WeeklyHealthHighlights extends StatelessWidget {
  const _WeeklyHealthHighlights();

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Obx(() {
      final water = homeController.dashboardActivityModel?.value?.data?.water;
      final waterPct = (water?.percentageAchieved ?? 0).round();
      final steps = homeController.dashboardActivityModel?.value?.data?.steps;
      final stepsPct = (steps?.stepsPercentage ?? 0).round();

      final items = [
        _HighlightItem(
          icon: Icons.water_drop_outlined,
          iconColor: const Color(0xFF339AF0),
          label: 'Hydration',
          desc: 'Daily water increased by $waterPct%',
        ),
        _HighlightItem(
          icon: Icons.favorite_outline,
          iconColor: const Color(0xFFFA5252),
          label: 'Heart Health',
          desc: 'Improved resting rate by 12%',
        ),
        _HighlightItem(
          icon: Icons.directions_walk_outlined,
          iconColor: const Color(0xFF20C997),
          label: 'Daily Activity',
          desc: 'You have taken $stepsPct%',
        ),
        _HighlightItem(
          icon: Icons.bedtime_outlined,
          iconColor: const Color(0xFFAE3EC9),
          label: 'Sleep Quality',
          desc: 'Deep sleep achieved by 13%',
        ),
      ];

      return Container(
        decoration: CommonWidget.containerDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Weekly Health Highlights',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (_, i) {
                final item = items[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xffF9F9FA),
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: item.iconColor, size: 22),
                      const SizedBox(height: 8),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.desc,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

class _HighlightItem {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String desc;
  const _HighlightItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.desc,
  });
}

// ---------------------------------------------------------------------------
// Other Highlights
// ---------------------------------------------------------------------------
class _OtherHighlights extends StatelessWidget {
  const _OtherHighlights();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CommonWidget.containerDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Other Highlights',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            //  padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xffF9F9FA),
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD3F9D8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sentiment_satisfied_alt_outlined,
                    color: Color(0xFF2ECC71),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Goal Achievement',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Workout goal completion by',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        '42%',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2ECC71),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
