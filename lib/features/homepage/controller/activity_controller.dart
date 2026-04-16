import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/blood_pressure/controller/blood_pressure_controller.dart';
import 'package:tracure/features/blood_sugar/controller/blood_sugar_controller.dart';
import 'package:tracure/features/medicine_tracker/controller/medicine_tracker_controller.dart';
import 'package:tracure/features/sleep_tracker/controller/sleep_tracker_controller.dart';
import 'package:tracure/features/step_tracker/controller/step_tracker_controller.dart';
import 'package:tracure/features/water_intake/controller/water_intake_controller.dart';

class ActivityController extends GetxController {
  var isLoading = false.obs;

  // Sub-controllers — found if already registered, created otherwise
  late StepTrackerController stepCtrl;
  late SleepTrackerController sleepCtrl;
  late WaterIntakeController waterCtrl;
  late MedicineTrackerController medicineCtrl;
  late BloodSugarController bloodSugarCtrl;
  late BloodPressureController bpCtrl;

  @override
  void onInit() {
    super.onInit();
    _resolveControllers();
    loadWeeklyData();
  }

  void _resolveControllers() {
    stepCtrl = Get.isRegistered<StepTrackerController>()
        ? Get.find<StepTrackerController>()
        : Get.put(StepTrackerController());
    sleepCtrl = Get.isRegistered<SleepTrackerController>()
        ? Get.find<SleepTrackerController>()
        : Get.put(SleepTrackerController());
    waterCtrl = Get.isRegistered<WaterIntakeController>()
        ? Get.find<WaterIntakeController>()
        : Get.put(WaterIntakeController());
    medicineCtrl = Get.isRegistered<MedicineTrackerController>()
        ? Get.find<MedicineTrackerController>()
        : Get.put(MedicineTrackerController());
    bloodSugarCtrl = Get.isRegistered<BloodSugarController>()
        ? Get.find<BloodSugarController>()
        : Get.put(BloodSugarController());
    bpCtrl = Get.isRegistered<BloodPressureController>()
        ? Get.find<BloodPressureController>()
        : Get.put(BloodPressureController());
  }

  Future<void> loadWeeklyData() async {
    isLoading.value = true;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final fmt = DateFormat('yyyy-MM-dd');
    final start = fmt.format(weekStart);
    final end = fmt.format(weekEnd);

    await Future.wait([
      stepCtrl.getStepSummaryByRange(start, end, toast: false),
      sleepCtrl.getWeeklySleepSummary(start, end, toast: false),
      waterCtrl.getWeeklyWaterSummary(start, end, toast: false),
      bloodSugarCtrl.getWeeklyBloodSugarSummary(start, end, toast: false),
      bpCtrl.getWeeklyBloodPressureSummary(start, end, toast: false),
      // medicine weekly is already loaded in MedicineTrackerController.onInit
    ]);
    isLoading.value = false;
  }

  @override
  Future<void> refresh() => loadWeeklyData();

  // ── Helpers to build 7-element bar arrays (Mon=0 … Sun=6) ──────────────

  List<double> weeklyStepBars() {
    final data = stepCtrl.stepWeeklyModel.value?.data;
    return _mapToWeek(
      data
              ?.map((d) => MapEntry(d.stepDate, (d.steps ?? 0).toDouble()))
              .toList() ??
          [],
    );
  }

  List<double> weeklySleepBars() {
    final data = sleepCtrl.weeklySleepSummary.value?.data;
    return _mapToWeek(
      data
              ?.map(
                (d) => MapEntry(
                  d.summaryDate,
                  (d.totalSleepMinutes ?? 0).toDouble(),
                ),
              )
              .toList() ??
          [],
    );
  }

  List<double> weeklyWaterBars() {
    final data = waterCtrl.weeklyWaterSummary.value?.data;
    return _mapToWeek(
      data
              ?.map((d) => MapEntry(d.summaryDate, (d.totalMl ?? 0).toDouble()))
              .toList() ??
          [],
    );
  }

  List<double> weeklyMedicineBars() {
    final byDate = medicineCtrl.weeklyMedicineSummary.value?.data?.byDate;
    return _mapToWeek(
      byDate
              ?.map((d) => MapEntry(d.date, (d.adherencePct ?? 0).toDouble()))
              .toList() ??
          [],
    );
  }

  List<double> weeklyBloodSugarBars() {
    final records = bloodSugarCtrl.weeklyBloodSugarSummary.value?.data?.records;
    return _mapToWeek(
      records
              ?.map((r) => MapEntry(r.date, (r.avgValue ?? 0).toDouble()))
              .toList() ??
          [],
    );
  }

  List<double> weeklyBloodPressureBars() {
    final records = bpCtrl.weeklyBloodPressureSummary.value?.data?.records;
    return _mapToWeek(
      records
              ?.map((r) => MapEntry(r.date, (r.avgSystolic ?? 0).toDouble()))
              .toList() ??
          [],
    );
  }

  /// Maps a list of (date, value) pairs into a fixed 7-slot array for Mon–Sun.
  List<double> _mapToWeek(List<MapEntry<DateTime?, double>> entries) {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day - (now.weekday - 1),
    );
    final result = List<double>.filled(7, 0.0);
    for (final e in entries) {
      if (e.key == null) continue;
      final date = DateTime(e.key!.year, e.key!.month, e.key!.day);
      final diff = date.difference(weekStart).inDays;
      if (diff >= 0 && diff < 7) result[diff] = e.value;
    }
    return result;
  }
}
