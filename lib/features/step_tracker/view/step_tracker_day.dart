import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:health/health.dart';
import 'package:tracure/features/homepage/controller/home_controller.dart';
import 'package:tracure/features/step_tracker/controller/step_tracker_controller.dart';
import 'package:tracure/features/step_tracker/view/step_progress_widget.dart';

import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';
import 'package:tracure/utils/string_extension.dart';

class StepTrackerDay extends StatefulWidget {
  const StepTrackerDay({super.key});

  @override
  State<StepTrackerDay> createState() => _StepTrackerDayState();
}

class _StepTrackerDayState extends State<StepTrackerDay> {
  final stepData = generateRandomDoubleList(48);
  final homeController = Get.find<HomeController>();
  final stepController = Get.find<StepTrackerController>();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(
        () => Column(
          spacing: 16,
          children: [
            Column(
              children: [
                StepProgressWidget(
                  current: int.tryParse(homeController.todayStep.value) ?? 0,
                  goal: 10000,
                ),
                SizedBox(height: 16),
                activitesCardGrid(stepController),
                SizedBox(height: 16),
                dayBarChartWidget(),
              ],
            ),
            keyHealthBenefits(),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      ),
    );
  }

  Column activitesCardGrid(StepTrackerController stepController) {
    final todayStep = int.tryParse(homeController.todayStep.value) ?? 0;
    final stepRemain = (todayStep > 10000) ? 0 : (10000 - todayStep);
    return Column(
      children: [
        Row(
          children: [
            tileCard(
              "Steps Remaining",
              stepController.stepsSummaryByDate.value?.data?.stepsRemaining
                      ?.toString() ??
                  "",
              "assets/images/tabler_activity.png",
            ),
            SizedBox(width: 10),
            tileCard(
              "Total Distance",
              stepController.stepsSummaryByDate.value?.data?.distance
                      ?.toString() ??
                  "",
              "assets/images/material-symbols_distance-outline.png",
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            tileCard(
              "Active Time",
              stepController.stepsSummaryByDate.value?.data?.activeTime
                      ?.toString() ??
                  "",
              "assets/images/mingcute_time-line.png",
            ),
            SizedBox(width: 10),
            tileCard(
              "Calories Burned",
              stepController.stepsSummaryByDate.value?.data?.caloriesBurned
                      ?.toString() ??
                  "",
              "assets/images/flowbite_fire-outline.png",
            ),
          ],
        ),
      ],
    );
  }

  Widget tileCard(String title, String value, String img) {
    return Expanded(
      child: Container(
        decoration: CommonWidget.containerDecoration(),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.title(text: title, size: 10),
                SizedBox(height: 8),
                CustomText.title(text: value, size: 14, isBold: true),
              ],
            ),
            Image.asset(img, height: 35),
          ],
        ),
      ),
    );
  }

  Container dayBarChartWidget() {
    return Container(
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
          SizedBox(
            height: 120,
            child: DayBarChart(data: stepData).padOnly(l: 8),
          ),
        ],
      ),
    );
  }

  Widget keyHealthBenefits() {
    var benefitList = [
      {
        "icon": "assets/images/ic_heart.png",
        "title": "Cardiovascular Health",
        "subTitle": "Reduces Heart Disease risk by 30-50%",
      },
      {
        "icon": "assets/images/ic_mental_clarity.png",
        "title": "Mental Clarity",
        "subTitle": "Improves Cognitive function by 25%",
      },
      {
        "icon": "assets/images/ic_energy_boost.png",
        "title": "Energy Boost",
        "subTitle": "Increases daily energy by 40%",
      },
      {
        "icon": "assets/images/ic_immune_system.png",
        "title": "Immune System",
        "subTitle": "Reduces illness risk by 35%",
      },
    ];
    return Container(
      decoration: CommonWidget.containerDecoration(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          CustomText.title(
            text: "Key Health Benefits",
            isBold: true,
          ).padSymm(horizontal: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: benefitList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (BuildContext context, int i) {
              return Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xffF9F9FA),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(benefitList[i]["icon"]!, height: 24),
                    SizedBox(height: 4),
                    CustomText.title(
                      text: benefitList[i]["title"],
                      isBold: true,
                      size: 12,
                      overflow: TextOverflow.visible,
                    ),
                    SizedBox(height: 4),
                    CustomText.title(
                      text: benefitList[i]["subTitle"],
                      size: 10,
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Container iconLabelCard({
    required String label,
    required String img,
    required Color color,
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

List<String> generateTimeListWith4HourLabels({
  Duration gap = const Duration(minutes: 30),
}) {
  List<String> timeList = [];
  DateTime time = DateTime(0, 1, 1, 0, 0); // Start at 12:00 AM

  int step = 0;
  do {
    if (step % 8 == 0) {
      String period = time.hour < 12 ? "\nam" : "\npm";
      int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      String minute = time.minute.toString().padLeft(2, '0');

      String formattedTime = minute == "00"
          ? "$hour$period"
          : "$hour:$minute$period";
      timeList.add(formattedTime);
    } else {
      timeList.add("");
    }

    time = time.add(gap);
    step++;
  } while (time.day == 1);
  // timeList.last = "12\nam";
  return timeList;
}

List<double> generateRandomDoubleList(
  int length, {
  double min = 0,
  double max = 10000,
}) {
  Random random = Random();
  return List.generate(length, (_) {
    double range = max - min;
    return min + random.nextDouble() * range;
  });
}

class LeftRightIconButton extends StatelessWidget {
  const LeftRightIconButton({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 35,
        width: 35,
        padding: EdgeInsets.all(10),
        decoration: CommonWidget.containerDecoration(
          radius: 10,
          color: ColorConstant.verdigris,
        ),
        child: Image.asset(
          "assets/images/arrow_back_black.png",
          color: Colors.white,
        ),
      ),
    );
  }
}

class DayBarChart extends StatelessWidget {
  final List<double> data;

  const DayBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final hourLabels = generateTimeListWith4HourLabels();
    const maxY = 10000.0;
    return BarChart(
      BarChartData(
        maxY: maxY,
        // minY: 0,
        groupsSpace: 1,
        alignment: BarChartAlignment.spaceEvenly,
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
              reservedSize: 34,
              showTitles: true,
              getTitlesWidget: (value, _) {
                int index = value.toInt();
                if (index < 0 || index >= hourLabels.length) {
                  return const SizedBox();
                }
                return Text(
                  hourLabels[index],
                  textAlign: TextAlign.center,
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
                width: 2,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Map<int, int> bucketStepsByHour(List<HealthDataPoint> dataPoints) {
  final Map<int, double> hourlyBuckets = {for (var i = 0; i < 24; i++) i: 0.0};

  for (final point in dataPoints) {
    if (point.type != HealthDataType.STEPS) continue;

    final int steps = (point.value as num).toInt();
    final DateTime start = point.dateFrom;
    final DateTime end = point.dateTo;

    final totalDuration = end.difference(start).inSeconds;
    if (totalDuration <= 0 || steps == 0) continue;

    DateTime cursor = start;

    while (cursor.isBefore(end)) {
      // End of current hour (e.g. 1:00 → 2:00)
      final DateTime hourEnd = DateTime(
        cursor.year,
        cursor.month,
        cursor.day,
        cursor.hour + 1,
      );

      final DateTime bucketEnd = end.isBefore(hourEnd) ? end : hourEnd;
      final int duration = bucketEnd.difference(cursor).inSeconds;

      final double fraction = duration / totalDuration;
      final double stepsForBucket = steps * fraction;

      hourlyBuckets[cursor.hour] =
          (hourlyBuckets[cursor.hour] ?? 0) + stepsForBucket;

      cursor = bucketEnd;
    }
  }

  // Convert to int for charting
  return hourlyBuckets.map((key, value) => MapEntry(key, value.round()));
}
