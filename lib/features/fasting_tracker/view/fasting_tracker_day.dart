import 'dart:ffi';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker_Progress_widget.dart';
import 'package:tracure/features/fasting_tracker/view/schedule_fasting_bottom_sheet.dart';
import 'package:tracure/features/water_intake/view/water_progress_widget.dart';

import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

class FastingTrackerDay extends StatefulWidget {
  const FastingTrackerDay({super.key});

  @override
  State<FastingTrackerDay> createState() => _FastingTrackerDayState();
}

class _FastingTrackerDayState extends State<FastingTrackerDay> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Center(
          child: FastingProgress(
            elapsed: const Duration(hours: 1, minutes: 24),
            total: const Duration(hours: 14),
          ),
        ),
        Container(
          height: 45,
          width: 160,
          decoration: CommonWidget.containerDecoration(
            color: ColorConstant.backgroundColor,
            boolShadow: false,
          ),
          child: CustomText.title(
            text: "Stop",
            isBold: true,
            size: 14,
            color: ColorConstant.primaryColor,
          ).padSymm(horizontal: 12, vertical: 8).center(),
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
              child: dailyBtns(
                icon: Icons.edit,
                text: "Fasting Schedule",
                onTap: () => showFastingSheet(context),
              ),
            ),
          ],
        ),
        Container(
          height: 45,
          decoration: CommonWidget.containerDecoration(
            color: ColorConstant.backgroundColor,
            boolShadow: false,
          ),
          child: Row(
            children: [
              const SizedBox(width: 6),
              CustomText.title(
                text: "Notify Me",
                isBold: true,
                size: 14,
                color: ColorConstant.primaryColor,
              ),
              Spacer(),
              Transform.scale(
                scale: 0.8,
                child: Switch(value: true, onChanged: (v) {}),
              ),
            ],
          ).padSymm(horizontal: 12, vertical: 8),
        ),
        articalCard(),
      ],
    ).padSymm(horizontal: 16, vertical: 16);
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

  Widget dailyBtns({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        decoration: CommonWidget.containerDecoration(
          color: ColorConstant.backgroundColor,
          boolShadow: false,
        ),
        child: Row(
          children: [
            Icon(icon, color: ColorConstant.primaryColor, size: 20),
            const SizedBox(width: 6),
            CustomText.title(
              text: text,
              isBold: true,
              size: 14,
              color: ColorConstant.primaryColor,
            ),
          ],
        ).padSymm(horizontal: 12, vertical: 8),
      ),
    );
  }
}
