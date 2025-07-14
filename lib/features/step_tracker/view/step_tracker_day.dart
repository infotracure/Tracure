import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

class StepTrackerDay extends StatefulWidget {
  const StepTrackerDay({super.key});

  @override
  State<StepTrackerDay> createState() => _StepTrackerDayState();
}

class _StepTrackerDayState extends State<StepTrackerDay> {
  final stepData = generateRandomStringList(24);
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Container(
          decoration: CommonWidget.containerDecoration(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LeftRightIconButton().padSymm(horizontal: 10, vertical: 10),
                  CustomText.title(
                    text: "Tuesday, 10 June 2025",
                    isBold: true,
                    size: 14,
                  ),
                  LeftRightIconButton()
                      .rotate(180)
                      .padSymm(horizontal: 10, vertical: 10),
                ],
              ),
              SizedBox(height: 200, child: DayBarChart(data: [])),
            ],
          ),
        ),
        stepDistanceWidget().padSymm(horizontal: 8),
      ],
    ).padSymm(horizontal: 16, vertical: 16);
  }

  SizedBox stepDistanceWidget() {
    return SizedBox(
      height: 60,
      child: Container(
        decoration: CommonWidget.containerDecoration(),
        child: Row(
          children: [
            Expanded(
              child: iconLabelCard(
                label: "Steps",
                img: "assets/images/emojione_running-shoe.png",
                color: 0xFFFAB005,
                value: "14566",
              ),
            ),
            VerticalDivider(
              thickness: 1,
              color: Colors.grey.shade300,
              indent: 4,
              endIndent: 4,
            ),
            Expanded(
              child: iconLabelCard(
                label: "Total Distance",
                img: "assets/images/emojione_running-shoe.png",
                color: 0xFF40B8B2,
                value: "2.4 km",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container iconLabelCard({
    required String label,
    required String img,
    required int color,
    required String value,
  }) {
    return Container(
      height: 60,
      width: 100,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              // Image.asset(img, height: 20, width: 20),
            ],
          ),
        ],
      ),
    );
  }
}

List<String> generateTimeList({Duration gap = const Duration(hours: 1)}) {
  List<String> timeList = [];
  DateTime time = DateTime(0, 1, 1, 0, 0); // Start at 12:00 AM

  do {
    String period = time.hour < 12 ? "am" : "pm";
    int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    String minute = time.minute.toString().padLeft(2, '0');

    // Only show minute part if it's not zero
    String formattedTime = minute == "00"
        ? "$hour$period"
        : "$hour:$minute$period";
    timeList.add(formattedTime);

    time = time.add(gap);
  } while (time.day == 1); // Stop when we roll over to the next day

  return timeList;
}

List<String> generateRandomStringList(
  int length, {
  int min = 0,
  int max = 10000,
}) {
  Random random = Random();
  return List.generate(length, (_) => random.nextInt(max - min + 1).toString());
}

class LeftRightIconButton extends StatelessWidget {
  const LeftRightIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 35,
      padding: EdgeInsets.all(10),
      decoration: CommonWidget.containerDecoration(
        radius: 10,
        color: ColorConstant.primaryColor,
      ),
      child: Image.asset(
        "assets/images/arrow_back_black.png",
        color: Colors.white,
      ),
    );
  }
}

class DayBarChart extends StatelessWidget {
  final List<double> data;

  const DayBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hourLabels = generateTimeList(gap: Duration(hours: 1));
    const maxY = 10000.0;
    return BarChart(
      BarChartData(
        maxY: maxY,
        // minY: 0,
        barTouchData: BarTouchData(enabled: true),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 5000.0,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 2,
              reservedSize: 40,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox();

                return Text(
                  value.toInt().toString(),
                  style: TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, _) {
                int index = value.toInt();
                final labels = generateTimeList(gap: const Duration(hours: 1));

                // Show only every 4th label (e.g. 0, 4, 8, 12, 16, 20, 24)
                if (index % 4 != 0 || index >= labels.length) {
                  return const SizedBox.shrink(); // Hide other labels
                }

                return Text(
                  labels[index],
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(
          data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].isFinite ? data[i] : 0,
                color: Colors.teal,
                width: 5,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
