import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/water_intake/view/water_progress_widget.dart';

import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../controller/water_intake_controller.dart';
import 'water_intake_add_bts.dart';

class WaterIntakeDay extends StatefulWidget {
  const WaterIntakeDay({super.key});

  @override
  State<WaterIntakeDay> createState() => _WaterIntakeDayState();
}

class _WaterIntakeDayState extends State<WaterIntakeDay> {
  final waterController = Get.find<WaterIntakeController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currWaterIntake =
          waterController.waterSummary.value?.data?.totalMl ?? 0;
      final waterGoal =
          waterController.waterSummary.value?.data?.dailyTargetMl ?? 0;
      final waterRecords =
          waterController.waterTrend.value?.data?.records ?? [];
      return SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => showDrinkBottomSheet(context),
                child: WaterProgressWidget(
                  current: currWaterIntake,
                  goal: waterGoal,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: dailyBtns(
                    icon: Icons.notifications,
                    text: "Daily Reminder",
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: dailyBtns(icon: Icons.edit, text: "Daily Goal"),
                ),
              ],
            ),
            Container(
              decoration: CommonWidget.containerDecoration(),
              constraints: waterRecords.length > 4
                  ? const BoxConstraints(maxHeight: 240)
                  : null,
              child: RawScrollbar(
                padding: EdgeInsets.symmetric(vertical: 10),
                controller: _scrollController,
                thumbVisibility: waterRecords.length > 4,
                thickness: 4,
                radius: const Radius.circular(8),
                child: ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(vertical: 6),
                  itemCount: waterRecords.length,
                  shrinkWrap: waterRecords.length <= 4,
                  physics: waterRecords.length > 4
                      ? const AlwaysScrollableScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      decoration: CommonWidget.containerDecoration(
                        color: ColorConstant.backgroundColor.withAlpha(150),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/circum_glass.png",
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              CustomText.title(
                                text:
                                    waterRecords[index].beverageType ??
                                    "Glass of Water",
                                size: 12,
                              ).padOnly(r: 12, b: 4),
                              CustomText.title(
                                text: waterRecords[index].amountMl != null
                                    ? "${waterRecords[index].amountMl} ml"
                                    : "",
                                isBold: true,
                                size: 14,
                              ).padOnly(r: 12),
                            ],
                          ),
                          Spacer(),
                          CustomText.title(
                            text: formatTime(waterRecords[index].intakeTime),
                            size: 14,
                          ),
                        ],
                      ).padSymm(horizontal: 16, vertical: 8),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                ),
              ),
            ).visible(isVisible: waterRecords.isNotEmpty),
            articalCard(),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      );
    });
  }

  String formatTime(DateTime? time) {
    if (time == null) return "";
    return DateFormat('h:mm a').format(time);
  }

  Container articalCard() {
    return Container(
      decoration: CommonWidget.containerDecoration(),
      child: Row(
        children: [
          Image.asset(
            "assets/images/bg_quickaction.png",
            height: 124,
            width: 124,
            fit: BoxFit.fill,
          ),
          Expanded(
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.title(
                  text: "Water Intake affects your brain health",
                  isBold: true,
                  overflow: TextOverflow.visible,
                  size: 14,
                ),
                CustomText.title(
                  text:
                      "Walking requirements have changed over the years as sedentary lifestyle",
                  overflow: TextOverflow.ellipsis,
                  maxLine: 2,
                  size: 14,
                ),
                CustomText.title(
                  text: "27 May, 2025",
                  isBold: true,

                  color: ColorConstant.grayTextColor,
                  size: 14,
                ),
              ],
            ).padOnly(l: 16),
          ),
        ],
      ).padSymm(horizontal: 16, vertical: 16),
    );
  }

  Container dailyBtns({required IconData icon, required String text}) {
    return Container(
      decoration: CommonWidget.containerDecoration(
        color: ColorConstant.backgroundColor,
        boolShadow: false,
      ),
      child: Row(
        children: [
          Icon(icon, color: ColorConstant.primaryColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: CustomText.title(
              text: text,
              isBold: true,
              size: 12,
              color: ColorConstant.primaryColor,
            ),
          ),
        ],
      ).padSymm(horizontal: 16, vertical: 8),
    );
  }
}
