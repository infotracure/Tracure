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
          (waterController.waterTrend.value?.data?.records ?? [])..sort(
            (a, b) => (b.intakeTime ?? DateTime(0)).compareTo(
              a.intakeTime ?? DateTime(0),
            ),
          );
      return SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            Center(
              child: WaterProgressWidget(
                current: currWaterIntake,
                goal: waterGoal,
              ),
            ),
            WaterIntakeQuickAdd(),
            WaterDailyLog(),

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
        isShadow: false,
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

class WaterIntakeQuickAdd extends StatelessWidget {
  WaterIntakeQuickAdd({super.key});
  final waterController = Get.find<WaterIntakeController>();
  final List<Map<String, String>> quickAddValues = [
    {"ml": "250ml", "glasses": "1 glass"},
    {"ml": "500ml", "glasses": "2 glasses"},
    {"ml": "750ml", "glasses": "3 glasses"},
    {"ml": "1000ml", "glasses": "4 glasses"},
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Add",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8),
        Row(
          spacing: 8,
          children: quickAddValues.map((value) {
            return Expanded(
              child: intakeCard(value["ml"]!, value["glasses"]!, () async {
                final confirmed = await showWaterConfirmDialog(
                  context,
                  value["ml"]!,
                  value["glasses"]!,
                );
                if (confirmed == true) {
                  var data = [
                    await waterController.covertToWaterJson(
                      value:
                          double.tryParse(value["ml"]!.replaceAll("ml", "")) ??
                          0,
                    ),
                  ];
                  waterController.addWater(waterData: data);
                }
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget intakeCard(String amountMl, String glasses, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: CommonWidget.containerDecoration(color: Colors.white),
        child: Column(
          spacing: 4,
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorConstant.primaryColor,
              ),
              child: Image.asset(
                "assets/images/drop.png",
                height: 12,
                width: 12,
                color: Colors.white,
              ),
            ),
            Text(
              amountMl,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
            FittedBox(
              child: Text(
                glasses,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: ColorConstant.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> showWaterConfirmDialog(
    BuildContext context,
    String ml,
    String glasses,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE3F2FD),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: const Color(0xFF29B6F6),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Add Water Intake?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  children: [
                    const TextSpan(text: "You're about to log "),
                    TextSpan(
                      text: ml,
                      style: const TextStyle(
                        color: ColorConstant.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: " ($glasses) of water"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: ColorConstant.primaryColor,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterDailyLog extends StatefulWidget {
  const WaterDailyLog({super.key});

  @override
  State<WaterDailyLog> createState() => _WaterDailyLogState();
}

class _WaterDailyLogState extends State<WaterDailyLog> {
  final waterController = Get.find<WaterIntakeController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String formatTime(DateTime? time) {
    if (time == null) return "";
    return DateFormat('h:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final waterRecords =
          (waterController.waterTrend.value?.data?.records ?? [])..sort(
            (a, b) => (b.intakeTime ?? DateTime(0)).compareTo(
              a.intakeTime ?? DateTime(0),
            ),
          );

      return Container(
        decoration: CommonWidget.containerDecoration(),

        child: Column(
          children: [
            SizedBox(height: 12),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText.title(
                      text: "Today's Log",
                      isBold: true,
                      size: 16,
                    ).padOnly(b: 4, l: 12),
                    CustomText.title(
                      text: "${waterRecords.length} entries",
                      size: 12,
                    ).padOnly(l: 12),
                  ],
                ),
                Spacer(),
                GestureDetector(
                  onTap: () => showAddWaterBottomSheet(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorConstant.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          "Add",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ).padOnly(r: 12),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
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
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      decoration: CommonWidget.containerDecoration(
                        color: ColorConstant.backgroundColor.withAlpha(100),
                        isShadow: false,
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
                                color: ColorConstant.primaryColor,
                              ).padOnly(r: 12),
                            ],
                          ),
                          Spacer(),
                          CustomText.title(
                            text: formatTime(waterRecords[index].intakeTime),
                            size: 14,
                            color: Colors.grey.shade800,
                          ),
                        ],
                      ).padSymm(horizontal: 16, vertical: 8),
                    );
                  },
                  separatorBuilder: (context, index) => SizedBox(height: 8),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void showAddWaterBottomSheet(BuildContext context) {
    final amountController = TextEditingController();
    final labelController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorConstant.primaryColor,
                      ColorConstant.primaryColor.withAlpha(230),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Add Water Intake",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Enter a custom amount",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              // Custom Amount section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      "Amount (ml)",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "e.g., 350",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Label (optional)",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: labelController,
                      decoration: InputDecoration(
                        hintText: "e.g., Cup of Tea",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Add Custom Amount button
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      Navigator.pop(context);
                      var data = [
                        await waterController.covertToWaterJson(
                          value: amount,
                          beverageType: labelController.text,
                        ),
                      ];
                      waterController.addWater(waterData: data);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ColorConstant.primaryColor,
                          ColorConstant.primaryColor.withAlpha(230),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "Add Custom Amount",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
