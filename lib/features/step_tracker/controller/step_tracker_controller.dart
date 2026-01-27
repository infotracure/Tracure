import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/homepage/model/feature_mapper_model.dart';
import 'package:tracure/features/step_tracker/model/step_average_model.dart';
import 'package:tracure/features/step_tracker/model/step_by_date_model.dart';
import 'package:tracure/features/step_tracker/model/step_summary_by_date.dart';
import 'package:tracure/features/step_tracker/model/step_summary_range_model.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/string_constants.dart';

import '../../../servies/api_service/dio_client.dart';
import '../../../servies/api_service/end_points.dart';
import '../../../servies/api_service/response_handler.dart';
import '../../../utils/loading_overlay.dart';

class StepTrackerController extends GetxController {
  // Add your methods and properties here
  StepByDateModel? stepByDateModel;
  Rx<StepSummaryByDateModel?> stepsSummaryByDate = Rx<StepSummaryByDateModel?>(
    null,
  );
  Rx<StepAvgModel?> stepAverageModel = Rx<StepAvgModel?>(null);
  Rx<StepSummaryByRangeModel?> stepWeeklyModel = Rx<StepSummaryByRangeModel?>(
    null,
  );
  Rx<StepSummaryByRangeModel?> stepMonthModel = Rx<StepSummaryByRangeModel?>(
    null,
  );
  Rx<StepByDateModel?> todayAllSteps = Rx<StepByDateModel?>(null);
  @override
  void onInit() async {
    super.onInit();
    var todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await getStepSummaryByDate(todayFormatted);

    // Calculate current week's start (Monday) and end (Sunday)
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    final dateFormat = DateFormat('yyyy-MM-dd');

    await getStepAverageData(
      startDate: dateFormat.format(weekStart),
      endDate: dateFormat.format(weekEnd),
    );

    await getStepsbydate(todayFormatted);

    // await getStepSummaryByRange(
    //   dateFormat.format(weekStart),
    //   dateFormat.format(weekEnd),
    // );
  }

  Future<void> getStepsbydate(String date) async {
    try {
      showGlobalLoader();
      final param = {"stepDate": date};
      final url = EndPoints.stepsbydate;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      todayAllSteps.value = jsonToObject(res, StepByDateModel.fromJson);
      if (todayAllSteps.value?.code != 1) {
        CommonWidget.showToast(
          todayAllSteps.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getStepSummaryByDate(String date) async {
    try {
      showGlobalLoader();

      final param = {"stepDate": date};
      final url = EndPoints.stepsSummarybydate;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      stepsSummaryByDate.value = jsonToObject(
        res,
        StepSummaryByDateModel.fromJson,
      );
      if (stepsSummaryByDate.value?.code != 1) {
        CommonWidget.showToast(
          stepsSummaryByDate.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getStepSummaryByRange(String startDate, String endDate) async {
    try {
      showGlobalLoader();

      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.stepsSummarybyRange;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      stepWeeklyModel.value = jsonToObject(
        res,
        StepSummaryByRangeModel.fromJson,
      );
      if (stepWeeklyModel.value?.code != 1) {
        CommonWidget.showToast(
          stepWeeklyModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getStepSummaryByMonth(DateTime month) async {
    try {
      showGlobalLoader();

      // Calculate first and last day of the month
      final firstDay = DateTime(month.year, month.month, 1);
      final lastDay = DateTime(month.year, month.month + 1, 0);
      final dateFormat = DateFormat('yyyy-MM-dd');

      final param = {
        "startDate": dateFormat.format(firstDay),
        "endDate": dateFormat.format(lastDay),
      };
      final url = EndPoints.stepsSummarybyRange;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      stepMonthModel.value = jsonToObject(
        res,
        StepSummaryByRangeModel.fromJson,
      );
      if (stepMonthModel.value?.code != 1) {
        CommonWidget.showToast(
          stepMonthModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getStepAverageData({String? startDate, String? endDate}) async {
    try {
      showGlobalLoader();
      final param = {"startDate": startDate, "endDate": endDate};
      final url = EndPoints.stepsaverage;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      stepAverageModel.value = jsonToObject(res, StepAvgModel.fromJson);
      if (stepAverageModel.value?.code != 1) {
        CommonWidget.showToast(
          stepAverageModel.value?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> pushStepSettingData(int stepGoal) async {
    try {
      showGlobalLoader();

      final url = EndPoints.stepsetting;
      final param = {"stepGoal": stepGoal};
      final res = await DioClient().post(url, param);
      hideGlobalLoader();
      if (res is DioResponse) {
        final responseData = res.data as Map<String, dynamic>;
        final code = responseData['code'];
        final message = responseData['message'];

        CommonWidget.showToast(
          message ?? StringConstant.internalErrorExceptionMessage,
        );
        var todayFormatted = DateFormat('yyyy-MM-dd').format(DateTime.now());

        getStepSummaryByDate(todayFormatted);
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }
}
