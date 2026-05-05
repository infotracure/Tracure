import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tracure/features/step_tracker/view/step_progress_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/string_extension.dart';

class SleepProgressWidget extends StatefulWidget {
  final int currentMin;
  final int goal;

  const SleepProgressWidget({
    super.key,
    required this.currentMin,
    required this.goal,
  });

  @override
  _SleepProgressWidgetState createState() => _SleepProgressWidgetState();
}

class _SleepProgressWidgetState extends State<SleepProgressWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String goalHours = formatMinutes(widget.goal);
    String currentHours = formatMinutes(widget.currentMin);
    double percentage = widget.currentMin / widget.goal;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 2. Circular Border (on top of wave)
          CustomPaint(
            size: const Size(200, 200),
            painter: CircleBorderPainter(
              percentage,
              ColorConstant.sleepGlobal,
            ),
          ),

          // 3. Text Content (centered)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 5),
              CustomText.title(text: "Last night", isBold: true, size: 12),
              const SizedBox(height: 5),
              CustomText.title(
                text: currentHours,
                isBold: true,
                size: 22,
                color: ColorConstant.sleepGlobal,
              ),
              const SizedBox(height: 8),
              CustomText.title(text: goalHours, isBold: true, size: 12),
              const SizedBox(height: 10),
              CustomText.title(
                text: "22:20 - 7:00",
                color: ColorConstant.sleepGlobal,
                isBold: true,
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String formatMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    if (minutes == 0) {
      return "${hours}h";
    } else if (hours == 0) {
      return "${minutes}min";
    } else {
      return "${hours}h ${minutes}min";
    }
  }

  String getPercentageValue() {
    double percentageValue = ((widget.currentMin / widget.goal) * 100);
    return percentageValue > 100
        ? 100.toStringAsFixed(1)
        : percentageValue.toStringAsFixed(1);
  }
}
