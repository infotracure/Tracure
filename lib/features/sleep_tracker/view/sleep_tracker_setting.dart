import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:tracure/features/medicine_tracker/view/add_medicine_bottom_sheet.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';
import 'package:tracure/utils/string_extension.dart';

class SleepTrackerSetting extends StatefulWidget {
  const SleepTrackerSetting({super.key});

  @override
  State<SleepTrackerSetting> createState() => _SleepTrackerSettingState();
}

class _SleepTrackerSettingState extends State<SleepTrackerSetting> {
  var _currentValue = 10000.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: CommonWidget.containerDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomText.title(text: "Sleep Goals", isBold: true),

                dailyStepsGoalWidget(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: CommonWidget.containerDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomText.title(text: "Sleep Goals", isBold: true),

                smartAlarm(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: CommonWidget.containerDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomText.title(text: "Sleep Tracking", isBold: true),

                toggleCard(
                  "Automatic Detection",
                  "Detect sleep/wake automatically",
                  (val) {},
                  true,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: CommonWidget.containerDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomText.title(text: "Reminders", isBold: true),
                toggleCard(
                  "Bedtime Reminder",
                  "Remind me 30min before bedtime",
                  (val) {},
                  true,
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          CommonWidget.roundedButton(
            title: "Save Changes",
            onTap: () {},
            context: context,
          ),
          SizedBox(height: 24),
        ],
      ).padSymm(horizontal: 16, vertical: 16),
    );
  }

  Widget toggleCard(
    String title,
    String subTitle,
    Function(bool)? onChanged,
    bool value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText.title(text: title, isBold: true, size: 12),
              CustomText.title(
                text: subTitle,
                size: 12,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Transform.scale(
          scale: 0.7,
          child: SizedBox(
            height: 20,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: ColorConstant.verdigris,
            ),
          ),
        ),
      ],
    );
  }

  Column dailyStepsGoalWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        TitledDropdown(
          fontSize: 12,
          title: "Target Sleep Duration",
          value: "5 hours",
          items: [
            "5 hours",
            "6 hours",
            "7 hours",
            "8 hours",
            "9 hours",
            "10 hours",
          ],
          onChanged: (value) {},
        ),
        SizedBox(height: 10),
        TitledDropdown(
          fontSize: 12,
          title: "Preferred Bedtime",
          value: "5 hours",
          items: [
            "5 hours",
            "6 hours",
            "7 hours",
            "8 hours",
            "9 hours",
            "10 hours",
          ],
          onChanged: (value) {},
        ),
        SizedBox(height: 10),

        TitledDropdown(
          fontSize: 12,
          title: "Preferred Wake Time",
          value: "5 hours",
          items: [
            "5 hours",
            "6 hours",
            "7 hours",
            "8 hours",
            "9 hours",
            "10 hours",
          ],
          onChanged: (value) {},
        ),
        SizedBox(height: 2),
      ],
    );
  }

  Column smartAlarm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        TitledDropdown(
          fontSize: 12,
          title: "Target Sleep Duration",
          value: "05 min",
          items: ["05 min", "15 min", "30 min"],
          onChanged: (value) {},
        ),
        SizedBox(height: 10),
        toggleCard(
          "Gradual Wake-up",
          "Gentle light and sound increase",
          (v) {},
          true,
        ),
        SizedBox(height: 2),
      ],
    );
  }
}
