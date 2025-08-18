import 'package:flutter/material.dart';
import 'package:tracure/features/blood_pressure/view/blodd_pressure_progress_widget.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_widget.dart';
import '../../../utils/constant/color_constants.dart';
import '../../../utils/custom_text.dart';

class BloodPressureDay extends StatelessWidget {
  const BloodPressureDay({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Center(child: BloodPressureProgressWidget(sys: 128, dia: 60)),
        Row(
          children: [
            Expanded(
              child: dailyBtns(
                icon: Icons.notifications,
                text: "Checkup Reminder",
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: dailyBtns(
                icon: Icons.insert_drive_file,
                text: "New Result",
              ),
            ),
          ],
        ),
        Container(
          decoration: CommonWidget.containerDecoration(),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 4),
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  const SizedBox(width: 8),
                  CustomText.title(text: "02:22 pm", size: 14),
                  Spacer(),
                  CustomText.title(
                    text: "128 / 60",
                    isBold: true,
                    size: 14,
                  ).padOnly(r: 12),
                  Icon(Icons.edit, color: Colors.grey, size: 20),
                ],
              ).padSymm(horizontal: 16, vertical: 8);
            },
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey, thickness: 0.5, height: 1),
          ),
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

  Container dailyBtns({required IconData icon, required String text}) {
    return Container(
      height: 40,
      decoration: CommonWidget.containerDecoration(
        color: ColorConstant.backgroundColor,
        boolShadow: false,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: ColorConstant.primaryColor, size: 20),
          const SizedBox(width: 6),
          CustomText.title(
            text: text,
            isBold: true,
            size: 12,
            color: ColorConstant.primaryColor,
          ),
        ],
      ).padSymm(horizontal: 16, vertical: 8),
    );
  }
}
