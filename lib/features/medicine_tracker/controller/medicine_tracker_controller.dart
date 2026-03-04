import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/medicine_tracker/model/medicine_status_by_date.dart';

import '../../../servies/api_service/dio_client.dart';
import '../../../servies/api_service/end_points.dart';
import '../../../servies/api_service/response_handler.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constant/string_constants.dart';
import '../../../utils/loading_overlay.dart';
import '../model/all_medicine_model.dart';
import '../model/create_medicine_model.dart';
import '../model/medicine_schedule_by_date.dart';
import '../model/medicine_summary_by_date_range.dart';

class MedicineTrackerController extends GetxController {
  final Rx<MedicineScheduleByDateModel?> medicineSummaryModel =
      Rx<MedicineScheduleByDateModel?>(null);
  final Rx<MedicineStatusByDateModel?> medicineStatusModel =
      Rx<MedicineStatusByDateModel?>(null);
  final Rx<AllMedicineModel?> allMedicineModel =
      Rx<AllMedicineModel?>(null);
  final Rx<MedicineStatusByDateRangeModel?> weeklyMedicineSummary =
      Rx<MedicineStatusByDateRangeModel?>(null);
  final Rx<MedicineStatusByDateRangeModel?> monthlyMedicineSummary =
      Rx<MedicineStatusByDateRangeModel?>(null);

  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // --- Computed stats from today's status ---
  int get takenCount =>
      medicineStatusModel.value?.data
          ?.expand((d) => d.timeSlots ?? [])
          .where((t) => t.taken == true)
          .length ??
      0;

  int get scheduledCount =>
      medicineStatusModel.value?.data
          ?.expand((d) => d.timeSlots ?? [])
          .length ??
      0;

  int get missedCount =>
      medicineStatusModel.value?.data
          ?.expand((d) => d.timeSlots ?? [])
          .where((t) => t.taken == false && _isTimePast(t.scheduledTime))
          .length ??
      0;

  bool _isTimePast(String? time) {
    if (time == null) return false;
    final parts = time.split(':');
    if (parts.length < 2) return false;
    final now = DateTime.now();
    final scheduled = DateTime(
      now.year, now.month, now.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
    return now.isAfter(scheduled);
  }

  @override
  void onInit() {
    super.onInit();
    getMedicineStatusByDate(todayDate);
    getAllMedicines();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final fmt = DateFormat('yyyy-MM-dd');
    getWeeklyMedicineSummary(fmt.format(weekStart), fmt.format(weekEnd));
  }

  // --- Fetch today's schedule ---
  Future<void> getMedicineSummaryByDate(String date) async {
    try {
      showGlobalLoader();
      final res = await DioClient().get(
        EndPoints.medicineSchedule,
   
      );
      hideGlobalLoader();
      medicineSummaryModel.value = jsonToObject(
        res,
        MedicineScheduleByDateModel.fromJson,
      );
      if (medicineSummaryModel.value?.code != 1) {
        CommonWidget.showToast(
          medicineSummaryModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

    Future<void> getMedicineStatusByDate(String date) async {
    try {
      showGlobalLoader();
      final res = await DioClient().get(
        EndPoints.medicineScheduleStatus,
        queryParam: {"date": date},
      );
      hideGlobalLoader();
      medicineStatusModel.value = jsonToObject(
        res,
        MedicineStatusByDateModel.fromJson,
      );
      if (medicineStatusModel.value?.code != 1) {
        CommonWidget.showToast(
          medicineStatusModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  // --- Fetch all medicines (no date filter) ---
  Future<void> getAllMedicines() async {
    try {
      showGlobalLoader();
      final res = await DioClient().get(EndPoints.medicineSchedule);
      hideGlobalLoader();
      allMedicineModel.value = jsonToObject(
        res,
        AllMedicineModel.fromJson,
      );
      if (allMedicineModel.value?.code != 1) {
        CommonWidget.showToast(
          allMedicineModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  // --- Create medicine schedule ---
  Future<bool> createMedicineSchedule(CreateMedicineModel data) async {
    try {
      showGlobalLoader();
      final res = await DioClient().post(
        EndPoints.medicineSchedule,
        data.toJson(),
      );
      hideGlobalLoader();
      if (res is DioResponse && res.data["code"] == 1) {
        await getAllMedicines();
        await getMedicineStatusByDate(todayDate);
        return true;
      }
      CommonWidget.showToast(
        res is DioResponse
            ? (res.data["message"] ??
                StringConstant.internalErrorExceptionMessage)
            : StringConstant.internalErrorExceptionMessage,
      );
      return false;
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
      return false;
    }
  }

  // --- Update medicine schedule ---
  Future<bool> updateMedicineSchedule(
      int scheduleId, CreateMedicineModel data) async {
    try {
      showGlobalLoader();
      final body = data.toJson()..['scheduleId'] = scheduleId;
      final res = await DioClient().put(
        EndPoints.medicineScheduleUpdate,
        body,
      );
      hideGlobalLoader();
      if (res is DioResponse && res.data["code"] == 1) {
        await getAllMedicines();
        await getMedicineStatusByDate(todayDate);
        return true;
      }
      CommonWidget.showToast(
        res is DioResponse
            ? (res.data["message"] ??
                StringConstant.internalErrorExceptionMessage)
            : StringConstant.internalErrorExceptionMessage,
      );
      return false;
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
      return false;
    }
  }

  // --- Delete medicine schedule ---
  Future<bool> deleteMedicineSchedule(int id) async {
    try {
      showGlobalLoader();
      final res = await DioClient().delete(
        EndPoints.medicineScheduleDelete,
        queryParam: {"id": id},
      );
      hideGlobalLoader();
      if (res is DioResponse && res.data["code"] == 1) {
        await getAllMedicines();
        await getMedicineStatusByDate(todayDate);
        return true;
      }
      CommonWidget.showToast(
        res is DioResponse
            ? (res.data["message"] ??
                StringConstant.internalErrorExceptionMessage)
            : StringConstant.internalErrorExceptionMessage,
      );
      return false;
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
      return false;
    }
  }

  // --- Toggle medicine taken/untaken (single endpoint, taken=true/false) ---
  Future<void> toggleMedicineTaken({
    required int scheduleId,
    required String scheduledTime,
    required String intakeDate,
    required bool taken,
  }) async {
    try {
      showGlobalLoader();
      final res = await DioClient().post(EndPoints.medicineIntakeTaken, {
        "scheduleId": scheduleId,
        "scheduledTime": scheduledTime,
        "intakeDate": intakeDate,
        "taken": taken,
      });
      hideGlobalLoader();
      if (res is DioResponse && res.data["code"] == 1) {
        await getMedicineStatusByDate(intakeDate);
        return;
      }
      CommonWidget.showToast(
        res is DioResponse
            ? (res.data["message"] ??
                StringConstant.internalErrorExceptionMessage)
            : StringConstant.internalErrorExceptionMessage,
      );
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }
    Future<void> getWeeklyMedicineSummary(
      String startDate, String endDate) async {
    try {
      showGlobalLoader();
      final res = await DioClient().get(
        EndPoints.medicineSummary,
        queryParam: {"start_date": startDate, "end_date": endDate},
      );
      hideGlobalLoader();
      weeklyMedicineSummary.value = jsonToObject(
        res,
        MedicineStatusByDateRangeModel.fromJson,
      );
      if (weeklyMedicineSummary.value?.code != 1) {
        CommonWidget.showToast(
          weeklyMedicineSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getMonthlyMedicineSummary(
      String startDate, String endDate) async {
    try {
      showGlobalLoader();
      final res = await DioClient().get(
        EndPoints.medicineSummary,
        queryParam: {"start_date": startDate, "end_date": endDate},
      );
      hideGlobalLoader();
      monthlyMedicineSummary.value = jsonToObject(
        res,
        MedicineStatusByDateRangeModel.fromJson,
      );
      if (monthlyMedicineSummary.value?.code != 1) {
        CommonWidget.showToast(
          monthlyMedicineSummary.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }
}
