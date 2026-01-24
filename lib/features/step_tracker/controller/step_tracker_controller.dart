import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/homepage/model/feature_mapper_model.dart';
import 'package:tracure/features/step_tracker/model/step_average_model.dart';
import 'package:tracure/features/step_tracker/model/step_by_date_model.dart';
import 'package:tracure/features/step_tracker/model/step_setting_model.dart';
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
  StepAverageModel? stepAverageModel;
  StepSettingModel? stepSettingModel;
  @override
  void onInit() async {
    super.onInit();
    await getStepSummaryByDate();
  }

  Future<void> getStepsbydate() async {
    try {
      showGlobalLoader();
      final param = {"stepDate": "2025-06-22"};
      final url = EndPoints.stepsbydate;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      final stepByDateModel = jsonToObject(res, StepByDateModel.fromJson);
      if (stepByDateModel?.code != 1) {
        CommonWidget.showToast(
          stepByDateModel?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getStepSummaryByDate() async {
    try {
      showGlobalLoader();
      
      final param = {"stepDate":  DateFormat('yyyy-MM-dd').format(DateTime.now())};
      final url = EndPoints.stepssummarybydate;
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

  Future<void> getStepAverageData() async {
    try {
      showGlobalLoader();
      final param = {"startDate": "2025-06-22", "endDate": "2025-06-22"};
      final url = EndPoints.stepsaverage;
      final res = await DioClient().get(url, queryParam: param);
      hideGlobalLoader();
      final stepAverageModel = jsonToObject(res, StepAverageModel.fromJson);
      if (stepAverageModel?.code != 1) {
        CommonWidget.showToast(
          stepAverageModel?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }

  Future<void> getStepSettingData() async {
    try {
      showGlobalLoader();

      final url = EndPoints.stepsetting;
      final res = await DioClient().get(url);
      hideGlobalLoader();
      final stepSettingModel = jsonToObject(res, StepSettingModel.fromJson);
      if (stepSettingModel?.code != 1) {
        CommonWidget.showToast(
          stepSettingModel?.message ??
              StringConstant.internalErrorExceptionMessage,
        );
        return;
      }
    } catch (e) {
      hideGlobalLoader();
      CommonWidget.showToast(StringConstant.internalErrorExceptionMessage);
    }
  }
}
