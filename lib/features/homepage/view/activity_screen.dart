import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/blood_pressure/view/blood_pressure_screen.dart';
import 'package:tracure/features/blood_sugar/view/blood_sugar_screen.dart';
import 'package:tracure/features/homepage/controller/activity_controller.dart';
import 'package:tracure/features/medicine_tracker/view/medicine_tracker_screen.dart';
import 'package:tracure/features/sleep_tracker/view/sleep_tracker_screen.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_screen.dart';
import 'package:tracure/features/water_intake/view/water_intake_screen.dart';
import 'package:tracure/utils/constant/color_constants.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late ActivityController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ActivityController>()
        ? Get.find<ActivityController>()
        : Get.put(ActivityController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.bgWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadWeeklyData,
          color: ColorConstant.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _buildStepsCard(),
                      const SizedBox(height: 12),
                      _buildSleepCard(),
                      const SizedBox(height: 12),
                      _buildWaterCard(),
                      const SizedBox(height: 12),
                      _buildMedicineCard(),
                      const SizedBox(height: 12),
                      _buildBloodPressureCard(),
                      const SizedBox(height: 12),
                      _buildBloodSugarCard(),
                      const SizedBox(height: 20),
                      _buildMotivationalCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2980ff), ColorConstant.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Track all your health metrics in one place.\nStay consistent and achieve your wellness goals.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => Row(
              children: [
                _buildHeaderStat(
                  value: _activeMetricsCount().toString(),
                  label: 'Activities',
                ),
                _buildHeaderDivider(),
                _buildHeaderStat(value: '7', label: 'Days'),
                _buildHeaderDivider(),
                _buildHeaderStat(
                  value: '${_avgGoalPercent()}%',
                  label: 'Avg Goal',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({required String value, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderDivider() => Container(
    width: 1,
    height: 40,
    color: Colors.white30,
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );

  // ── Computed header stats ─────────────────────────────────────────────────

  int _activeMetricsCount() {
    int count = 0;
    final stepCtrl = controller.stepCtrl;
    final sleepCtrl = controller.sleepCtrl;
    final waterCtrl = controller.waterCtrl;
    final medCtrl = controller.medicineCtrl;
    final bsCtrl = controller.bloodSugarCtrl;
    final bpCtrl = controller.bpCtrl;

    if ((stepCtrl.stepsSummaryByDate.value?.data?.steps ?? 0) > 0) count++;
    if ((sleepCtrl.sleepSummaryModel.value?.data?.totalSleepMinutes ?? 0) > 0)
      count++;
    if ((waterCtrl.waterSummary.value?.data?.totalMl ?? 0) > 0) count++;
    if (medCtrl.scheduledCount > 0) count++;
    if ((bsCtrl.bloodSugarSummary.value?.data?.avgValue ?? 0) > 0) count++;
    if ((bpCtrl.bloodPressureSummary.value?.data?.avgSystolic ?? 0) > 0)
      count++;
    return count;
  }

  int _avgGoalPercent() {
    final goals = <double>[];
    final stepPct =
        controller.stepCtrl.stepsSummaryByDate.value?.data?.stepsPercentage;
    if (stepPct != null) goals.add(stepPct);

    final waterData = controller.waterCtrl.waterSummary.value?.data;
    if (waterData != null &&
        (waterData.dailyTargetMl ?? 0) > 0 &&
        (waterData.totalMl ?? 0) > 0) {
      goals.add(waterData.totalMl! / waterData.dailyTargetMl! * 100);
    }

    final sched = controller.medicineCtrl.scheduledCount;
    if (sched > 0) {
      goals.add(controller.medicineCtrl.takenCount / sched * 100);
    }

    if (goals.isEmpty) return 0;
    return (goals.reduce((a, b) => a + b) / goals.length).round();
  }

  // ── Metric cards ──────────────────────────────────────────────────────────

  Widget _buildStepsCard() {
    return Obx(() {
      final data = controller.stepCtrl.stepsSummaryByDate.value?.data;
      final steps = data?.steps ?? 0;
      final pct = (data?.stepsPercentage ?? 0).round();
      return _buildMetricCard(
        icon: Icons.directions_walk_rounded,
        iconColor: const Color(0xFF00BFA5),
        iconBg: const Color(0xFFE0F7F5),
        title: 'Steps',
        todayValue: '${_fmt(steps)} steps',
        goalPercent: pct,
        barValues: controller.weeklyStepBars(),
        barColor: const Color(0xFF00BFA5),
        onTap: () => Get.to(() => StepTrackerScreen()),
      );
    });
  }

  Widget _buildSleepCard() {
    return Obx(() {
      final data = controller.sleepCtrl.sleepSummaryModel.value?.data;
      final minutes = data?.totalSleepMinutes ?? 0;
      final h = minutes ~/ 60;
      final m = minutes % 60;
      final displayVal = minutes > 0 ? '${h}h ${m}m' : '--';
      final qualityScore = data?.qualityScore ?? 0;
      return _buildMetricCard(
        icon: Icons.bedtime_rounded,
        iconColor: const Color(0xFF7E57C2),
        iconBg: const Color(0xFFF3E5FF),
        title: 'Sleep',
        todayValue: displayVal,
        goalPercent: qualityScore,
        barValues: controller.weeklySleepBars(),
        barColor: const Color(0xFF9575CD),
        onTap: () => Get.to(() => SleepTrackerScreen()),
      );
    });
  }

  Widget _buildWaterCard() {
    return Obx(() {
      final data = controller.waterCtrl.waterSummary.value?.data;
      final ml = data?.totalMl ?? 0;
      final target = data?.dailyTargetMl ?? 1;
      final liters = ml / 1000;
      final pct = target > 0 ? (ml / target * 100).round() : 0;
      final displayVal = ml > 0 ? '${liters.toStringAsFixed(1)} L' : '--';
      return _buildMetricCard(
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFF1E88E5),
        iconBg: const Color(0xFFE3F2FD),
        title: 'Water Intake',
        todayValue: displayVal,
        goalPercent: pct,
        barValues: controller.weeklyWaterBars(),
        barColor: const Color(0xFF42A5F5),
        onTap: () => Get.to(() => WaterIntakeScreen()),
      );
    });
  }

  Widget _buildMedicineCard() {
    return Obx(() {
      final ctrl = controller.medicineCtrl;
      final taken = ctrl.takenCount;
      final scheduled = ctrl.scheduledCount;
      final pct = scheduled > 0 ? (taken / scheduled * 100).round() : 0;
      final displayVal = scheduled > 0 ? '$taken/$scheduled taken' : '--';
      return _buildMetricCard(
        icon: Icons.medication_rounded,
        iconColor: const Color(0xFF43A047),
        iconBg: const Color(0xFFE8F5E9),
        title: 'Medicine Intake',
        todayValue: displayVal,
        goalPercent: pct,
        barValues: controller.weeklyMedicineBars(),
        barColor: const Color(0xFF66BB6A),
        onTap: () => Get.to(() => MedicineTrackerScreen()),
      );
    });
  }

  Widget _buildBloodPressureCard() {
    return Obx(() {
      final data = controller.bpCtrl.bloodPressureSummary.value?.data;
      final sys = data?.avgSystolic;
      final dia = data?.avgDiastolic;
      final displayVal = (sys != null && dia != null) ? '$sys/$dia mmHg' : '--';
      final inRange = data?.inTargetRange ?? false;
      return _buildMetricCard(
        icon: Icons.favorite_rounded,
        iconColor: const Color(0xFFE53935),
        iconBg: const Color(0xFFFFEBEE),
        title: 'Blood Pressure',
        todayValue: displayVal,
        goalPercent: inRange ? 100 : (sys != null ? 80 : 0),
        barValues: controller.weeklyBloodPressureBars(),
        barColor: const Color(0xFFEF5350),
        onTap: () => Get.to(() => BloodPressureScreen()),
      );
    });
  }

  Widget _buildBloodSugarCard() {
    return Obx(() {
      final data = controller.bloodSugarCtrl.bloodSugarSummary.value?.data;
      final avg = data?.avgValue;
      final displayVal = avg != null ? '$avg mg/dL' : '--';
      final inRange = data?.inTargetRange ?? false;
      return _buildMetricCard(
        icon: Icons.water_rounded,
        iconColor: const Color(0xFF8E24AA),
        iconBg: const Color(0xFFF3E5F5),
        title: 'Blood Sugar',
        todayValue: displayVal,
        goalPercent: inRange ? 100 : (avg != null ? 85 : 0),
        barValues: controller.weeklyBloodSugarBars(),
        barColor: const Color(0xFFAB47BC),
        onTap: () => Get.to(() => BloodSugarScreen()),
      );
    });
  }

  // ── Generic metric card ───────────────────────────────────────────────────

  Widget _buildMetricCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String todayValue,
    required int goalPercent,
    required List<double> barValues,
    required Color barColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: ColorConstant.primaryTextColor,
                        ),
                      ),
                      const Text(
                        'Last 7 days',
                        style: TextStyle(
                          fontSize: 11,
                          color: ColorConstant.grayTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: ColorConstant.grayTextColor,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Value + goal row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorConstant.grayTextColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      todayValue,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$goalPercent%',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: goalPercent >= 100
                            ? const Color(0xFF43A047)
                            : ColorConstant.primaryTextColor,
                      ),
                    ),
                    const Text(
                      'Goal',
                      style: TextStyle(
                        fontSize: 11,
                        color: ColorConstant.grayTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Bar chart
            _buildMiniBarChart(barValues, barColor),
          ],
        ),
      ),
    );
  }

  // ── Mini 7-day bar chart ──────────────────────────────────────────────────

  Widget _buildMiniBarChart(List<double> values, Color barColor) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxVal = values.reduce(max);
    const maxBarHeight = 44.0;
    const minBarHeight = 6.0;
    final todayIndex = DateTime.now().weekday - 1; // 0=Mon … 6=Sun

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (i) {
        final val = i < values.length ? values[i] : 0.0;
        final barH = maxVal > 0
            ? (val / maxVal * maxBarHeight).clamp(minBarHeight, maxBarHeight)
            : minBarHeight;
        final isToday = i == todayIndex;
        final isFuture = i > todayIndex;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: barH,
              decoration: BoxDecoration(
                color: isFuture
                    ? Colors.grey.shade200
                    : isToday
                    ? barColor
                    : barColor.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              days[i],
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? barColor : ColorConstant.grayTextColor,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Motivational card ─────────────────────────────────────────────────────

  Widget _buildMotivationalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD54F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep Up the Good Work!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: ColorConstant.primaryTextColor,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Consistency is key to achieving your health goals. Review your trends regularly and adjust your habits accordingly.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: ColorConstant.grayTextColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  String _fmt(int value) {
    if (value >= 1000) {
      return value.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return value.toString();
  }
}
