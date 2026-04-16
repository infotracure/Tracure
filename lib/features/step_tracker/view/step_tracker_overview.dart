import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/homepage/controller/home_controller.dart';
import 'package:tracure/features/step_tracker/controller/step_tracker_controller.dart';
import 'package:tracure/features/step_tracker/model/step_by_date_model.dart';
import 'package:tracure/features/step_tracker/view/step_progress_widget.dart';

import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

class StepTrackerOverview extends StatefulWidget {
  const StepTrackerOverview({super.key});

  @override
  State<StepTrackerOverview> createState() => _StepTrackerOverviewState();
}

class _StepTrackerOverviewState extends State<StepTrackerOverview> {
  final homeController = Get.find<HomeController>();
  final stepController = Get.find<StepTrackerController>();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(
        () {
          final isCalories = stepController.showCalories.value;
          return Column(
            spacing: 16,
            children: [
              Column(
                children: [
                  if (isCalories)
                    StepProgressWidget(
                      current: stepController.calculatedCalories,
                      goal: stepController.calorieGoal,
                      unit: 'kcal',
                    )
                  else
                    StepProgressWidget(
                      current:
                          stepController.stepsSummaryByDate.value?.data?.steps ??
                          0,
                      goal:
                          stepController
                              .stepsSummaryByDate
                              .value
                              ?.data
                              ?.stepGoals ??
                          0,
                    ),
                  SizedBox(height: 16),
                  activitesCardGrid(stepController),
                  SizedBox(height: 16),
                  dayBarChartWidget(showCalories: isCalories),
                ],
              ),
              keyHealthBenefits(),
            ],
          ).padSymm(horizontal: 16, vertical: 16);
        },
      ),
    );
  }

  Column activitesCardGrid(StepTrackerController stepController) {
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

  Container dayBarChartWidget({bool showCalories = false}) {
    final todayData = stepController.todayAllSteps.value?.data ?? [];
    final stepBuckets = _bucketStepsToHourlyIntervals(todayData);
    final stepData = showCalories
        ? stepBuckets.map((s) => s * 0.04).toList()
        : stepBuckets;
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy');

    return Container(
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LeftRightIconButton(
                onTap: () async {
                  _selectedDate = _selectedDate.subtract(Duration(days: 1));
                  await stepController.getStepsbydate(
                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                  );
                },
              ).padSymm(horizontal: 10, vertical: 10),
              CustomText.title(
                text: dateFormat.format(_selectedDate),
                isBold: true,
                size: 14,
              ),
              _isToday()
                  ? const SizedBox(width: 55)
                  : LeftRightIconButton(
                      onTap: () async {
                        _selectedDate = _selectedDate.add(Duration(days: 1));
                        await stepController.getStepsbydate(
                          DateFormat('yyyy-MM-dd').format(_selectedDate),
                        );
                      },
                    ).rotate(180).padSymm(horizontal: 10, vertical: 10),
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

  bool _isToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  List<double> _bucketStepsToHourlyIntervals(List<Datum> data) {
    // 24 intervals of 1 hour each (00:00-01:00, 01:00-02:00, ...)
    final List<double> buckets = List.filled(24, 0.0);

    for (final datum in data) {
      if (datum.startTime == null ||
          datum.endTime == null ||
          datum.steps == null) {
        continue;
      }

      final start = datum.startTime!;
      final end = datum.endTime!;
      final steps = datum.steps!;
      final totalDuration = end.difference(start).inSeconds;

      if (totalDuration <= 0 || steps == 0) continue;

      DateTime cursor = start;

      while (cursor.isBefore(end)) {
        // Calculate current hour bucket index
        final bucketIndex = cursor.hour;

        // Calculate end of current hour bucket
        final bucketEnd = DateTime(
          cursor.year,
          cursor.month,
          cursor.day,
          cursor.hour + 1,
        );

        final effectiveEnd = end.isBefore(bucketEnd) ? end : bucketEnd;
        final duration = effectiveEnd.difference(cursor).inSeconds;

        final fraction = duration / totalDuration;
        final stepsForBucket = steps * fraction;

        if (bucketIndex >= 0 && bucketIndex < 24) {
          buckets[bucketIndex] += stepsForBucket;
        }

        cursor = effectiveEnd;
      }
    }

    return buckets;
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

List<String> generateHourlyLabels() {
  List<String> timeList = [];

  for (int hour = 0; hour < 24; hour++) {
    // Show label every 4 hours (12am, 4am, 8am, 12pm, 4pm, 8pm)
    if (hour % 4 == 0) {
      String period = hour < 12 ? "\nam" : "\npm";
      int displayHour = hour % 12 == 0 ? 12 : hour % 12;
      timeList.add("$displayHour$period");
    } else {
      timeList.add("");
    }
  }

  return timeList;
}

class LeftRightIconButton extends StatelessWidget {
  const LeftRightIconButton({
    super.key,
    this.onTap,
    this.iconColor = ColorConstant.verdigris,
  });
  final VoidCallback? onTap;
  final Color iconColor;

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
          color: iconColor,
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

  double _calculateMaxY() {
    if (data.isEmpty) return 1000.0;

    final maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 0) return 1000.0;

    // Round up to nearest 500 or 1000 for cleaner intervals
    if (maxVal <= 1000) return ((maxVal / 100).ceil() * 100).toDouble();
    return ((maxVal / 500).ceil() * 500).toDouble();
  }

  String _formatHour(int hour) {
    final period = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    return '$displayHour$period';
  }

  @override
  Widget build(BuildContext context) {
    final hourLabels = generateHourlyLabels();
    final maxY = _calculateMaxY();
    return BarChart(
      BarChartData(
        maxY: maxY,
        groupsSpace: 1,
        alignment: BarChartAlignment.spaceEvenly,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final hour = group.x;
              final nextHour = (hour + 1) % 24;
              final hourStr = _formatHour(hour);
              final nextHourStr = _formatHour(nextHour);
              return BarTooltipItem(
                '${rod.toY.toInt()}\n',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                children: [
                  TextSpan(
                    text: '$hourStr-$nextHourStr',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY / 2,
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
                width: 6,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
