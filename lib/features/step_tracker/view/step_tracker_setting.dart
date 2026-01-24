import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/step_tracker/controller/step_tracker_controller.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';
import 'package:tracure/utils/string_extension.dart';

class StepTrackerSetting extends StatefulWidget {
  const StepTrackerSetting({super.key});

  @override
  State<StepTrackerSetting> createState() => _StepTrackerSettingState();
}

class _StepTrackerSettingState extends State<StepTrackerSetting> {
  var _currentValue = 10000.0;
  final stepTrackerController = Get.find<StepTrackerController>();
  @override
  void initState() {
    super.initState();
    _currentValue =
        stepTrackerController.stepSettingModel?.data?.goals?.toDouble() ??
        10000.0;
  }

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
                CustomText.title(text: "Goal Settings", isBold: true),

                dailyStepsGoalWidget(),
                toggleCard(
                  "Auto-adjust Goals",
                  "Adjust goals based on your daily average",
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
                CustomText.title(text: "Notification", isBold: true),

                toggleCard(
                  "Steps Reminder",
                  "Reminders user to walk if inactive for long duration",
                  (val) {},
                  true,
                ),
                toggleCard(
                  "Goal Achievements",
                  "Celebrate when user reaches the goal",
                  (val) {},
                  true,
                ),
              ],
            ),
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText.title(text: title, isBold: true, size: 12),
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
        ),
        SizedBox(height: 4),
        CustomText.title(text: subTitle, size: 12),
      ],
    );
  }

  Column dailyStepsGoalWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(text: "Daily Steps Goal", size: 12, isBold: true),
        SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 10,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0.0),
          ),
          child: Slider(
            padding: EdgeInsets.zero,
            activeColor: ColorConstant.verdigris,
            inactiveColor: Colors.grey.shade200,
            value: _currentValue,
            min: 1000,
            max: 15000,
            divisions: (15000 - 1000) ~/ 500,
            label: _currentValue.round().toString(),
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
            },
          ),
        ),

        SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText.title(text: "1000".toFormattedNumber(), size: 10),
            CustomText.title(text: "15000".toFormattedNumber(), size: 10),
          ],
        ).padSymm(horizontal: 4),
      ],
    );
  }
}
