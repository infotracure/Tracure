import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/step_tracker/controller/step_tracker_controller.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_overview.dart';
import 'package:tracure/features/step_tracker/view/view_monthly_bottom_sheet.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';
import 'package:tracure/utils/int_extension.dart';
import 'package:tracure/utils/string_extension.dart';

import '../../../utils/common_methods.dart';
import 'step_tracker_month.dart';

class StepTrackerActivity extends StatefulWidget {
  const StepTrackerActivity({super.key});

  @override
  State<StepTrackerActivity> createState() => _StepTrackerActivityState();
}

class _StepTrackerActivityState extends State<StepTrackerActivity> {
  DateTime _selectedWeek = DateTime.now();
  List<double> _weeklySteps = List.filled(7, 0.0);
  final stepTrackerController = Get.find<StepTrackerController>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadWeeklySteps(_selectedWeek); // load current week initially
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCalories = stepTrackerController.showCalories.value;
      final chartData = isCalories
          ? _weeklySteps.map((s) => s * 0.04).toList()
          : _weeklySteps;

      return SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            Container(
              decoration: CommonWidget.containerDecoration(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LeftRightIconButton(
                        onTap: () {
                          setState(() {
                            _selectedWeek = _selectedWeek.subtract(
                              Duration(days: 7),
                            );
                            _loadWeeklySteps(_selectedWeek);
                          });
                        },
                      ).padSymm(horizontal: 10, vertical: 10),
                      CustomText.title(
                        text: formatWeekRange(_selectedWeek),
                        isBold: true,
                        size: 14,
                      ),
                      _isCurrentWeek()
                          ? const SizedBox(width: 55)
                          : LeftRightIconButton(
                              onTap: () {
                                setState(() {
                                  _selectedWeek = _selectedWeek.add(
                                    Duration(days: 7),
                                  );
                                  _loadWeeklySteps(_selectedWeek);
                                });
                              },
                            ).rotate(180).padSymm(horizontal: 10, vertical: 10),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 210,
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 150,
                          child: WeekBarChart(weeklySteps: chartData),
                        ),
                        CommonWidget.roundedButton(
                              context: context,
                              titleColor: ColorConstant.stepGlobal,
                              bgColor: ColorConstant.stepGlobal.withAlpha(30),
                              title: "View Monthly Record",
                              padding: EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                color: ColorConstant.stepGlobal,
                                size: 20,
                              ),
                              onTap: () async {
                                await stepTrackerController
                                    .getStepSummaryByMonth(DateTime.now());
                                if (!context.mounted) return;
                                showRoundedBottomSheet(
                                  context: context,
                                  child: CustomCalendar(
                                    initialMonth: DateTime.now(),
                                  ),
                                );
                              },
                            )
                            .padSymm(horizontal: 16, vertical: 8)
                            .align(Alignment.bottomCenter),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _activitesCardGrid(isCalories),
            keyHealthBenefits(),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      );
    });
  }

  Column _activitesCardGrid(bool isCalories) {
    final avgDataModel = stepTrackerController.stepAverageModel.value?.data;
    final avgSteps = avgDataModel?.avgSteps ?? 0;
    final avgCaloriesFromSteps = (avgSteps * 0.04).round();

    return Column(
      children: [
        Row(
          children: [
            tileCard(
              isCalories ? "Avg. Calories" : "Weekly Average",
              isCalories
                  ? "$avgCaloriesFromSteps kcal"
                  : avgSteps.toFormattedNumber(),
              isCalories
                  ? "assets/images/flowbite_fire-outline.png"
                  : "assets/images/tabler_activity.png",
            ),
            SizedBox(width: 10),
            tileCard(
              "Avg. Distance",
              "${(avgDataModel?.avgDistance ?? 0)} km",
              "assets/images/material-symbols_distance-outline.png",
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            tileCard(
              "Avg. Active Time",
              "${avgDataModel?.avgActiveTime ?? 0} min",
              "assets/images/mingcute_time-line.png",
            ),
            SizedBox(width: 10),
            tileCard(
              "Avg. Calories Burned",
              "${avgDataModel?.avgCaloriesBurned?.toFormattedNumber() ?? 0} cal",
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
        height: 74,
        decoration: CommonWidget.containerDecoration(),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText.title(text: title, size: 10, maxLine: 2),
                  Spacer(),
                  CustomText.title(text: value, size: 14, isBold: true),
                ],
              ),
            ),
            SizedBox(width: 7),
            Image.asset(img, height: 35),
          ],
        ),
      ),
    );
  }

  Widget keyHealthBenefits() {
    var benefitList = [
      {
        "icon": "assets/images/ic_mood.png",
        "title": "Mood Enhancement",
        "subTitle": "Reduces anxiety by 45%",
      },
      {
        "icon": "assets/images/ic_better_sleep.png",
        "title": "Better Sleep",
        "subTitle": "Improves sleep quality by 65%",
      },
    ];
    return Container(
      decoration: CommonWidget.containerDecoration(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          CustomText.title(
            text: "Other Health Benefits",
            isBold: true,
          ).padSymm(horizontal: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: benefitList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 4.8,
            ),
            itemBuilder: (BuildContext context, int i) {
              return Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xffF9F9FA),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(benefitList[i]["icon"]!, height: 24),
                    SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText.title(
                          text: benefitList[i]["title"],
                          isBold: true,
                          size: 12,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(height: 8),
                        CustomText.title(
                          text: benefitList[i]["subTitle"],
                          size: 10,
                          overflow: TextOverflow.visible,
                        ),
                      ],
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

  Future<void> _loadWeeklySteps(DateTime weekDate) async {
    final start = startOfWeek(weekDate);
    final end = endOfWeek(weekDate);
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Call API to fetch weekly data
    await stepTrackerController.getStepSummaryByRange(
      dateFormat.format(start),
      dateFormat.format(end),
    );

    // Map API data to _weeklySteps list
    final apiData = stepTrackerController.stepWeeklyModel.value?.data ?? [];

    // Create a map of date -> steps for quick lookup
    final Map<DateTime, int> stepsPerDay = {};
    for (var datum in apiData) {
      if (datum.stepDate != null) {
        final date = normalizeDate(datum.stepDate!);
        stepsPerDay[date] = datum.steps ?? 0;
      }
    }

    // Build the 7-day list (Monday to Sunday)
    List<double> result = [];
    for (int i = 0; i < 7; i++) {
      final date = normalizeDate(start.add(Duration(days: i)));
      result.add((stepsPerDay[date] ?? 0).toDouble());
    }

    if (mounted) {
      setState(() {
        _weeklySteps = result;
      });
    }
  }

  DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final currentWeekStart = startOfWeek(now);
    final selectedWeekStart = startOfWeek(_selectedWeek);
    return normalizeDate(currentWeekStart) == normalizeDate(selectedWeekStart);
  }




}

class WeekBarChart extends StatefulWidget {
  final List<double> weeklySteps;

  const WeekBarChart({super.key, required this.weeklySteps});

  @override
  State<WeekBarChart> createState() => _WeekBarChartState();
}

class _WeekBarChartState extends State<WeekBarChart> {
  double _calculateMaxY() {
    if (widget.weeklySteps.isEmpty) return 10000.0;

    final maxVal = widget.weeklySteps.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 10000) return 10000.0;

    // round up to nearest 1000
    return ((maxVal / 1000).ceil() * 1000).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    const hourLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final maxY = _calculateMaxY();

    return BarChart(
      BarChartData(
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),

            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                rod.toY.toInt().toString(),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
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
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                int index = value.toInt();
                if (index < 0 || index >= hourLabels.length) {
                  return const SizedBox();
                }
                return Text(
                  hourLabels[index],
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(
          widget.weeklySteps.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: widget.weeklySteps[i].isFinite ? widget.weeklySteps[i] : 0,
                color: ColorConstant.stepGlobal,
                width: 16,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
