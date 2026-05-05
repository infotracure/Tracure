import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/sleep_tracker/controller/sleep_tracker_controller.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_overview.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';
import 'package:tracure/utils/string_extension.dart';

import '../../../utils/common_methods.dart';
import '../../step_tracker/view/view_monthly_bottom_sheet.dart';
import 'sleep_tracker_month.dart';

class SleepTrackerInsights extends StatefulWidget {
  const SleepTrackerInsights({super.key});

  @override
  State<SleepTrackerInsights> createState() => _SleepTrackerInsightsState();
}

class _SleepTrackerInsightsState extends State<SleepTrackerInsights> {
  final sleepTrackerController = Get.find<SleepTrackerController>();
  DateTime _selectedWeek = DateTime.now();
  List<double> _weeklySleep = List.filled(7, 0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final start = startOfWeek(DateTime.now());
      final end = endOfWeek(DateTime.now());
      final dateFormat = DateFormat('yyyy-MM-dd');

      // Call API to fetch sleep stats
      await sleepTrackerController.getSleepStats(
        dateFormat.format(start),
        dateFormat.format(end),
      );
      // Load weekly sleep data
      await _loadWeeklySleep(_selectedWeek);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            CustomText.title(text: "Sleep Environment", isBold: true, size: 14),
            activitesCardGrid(),
            // SizedBox(height: 16),
            Container(
              decoration: CommonWidget.containerDecoration(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LeftRightIconButton(
                        iconColor: ColorConstant.sleepGlobal,
                        onTap: () {
                          setState(() {
                            _selectedWeek = _selectedWeek.subtract(
                              Duration(days: 7),
                            );
                            _loadWeeklySleep(_selectedWeek);
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
                              iconColor: ColorConstant.sleepGlobal,
                              onTap: () {
                                setState(() {
                                  _selectedWeek = _selectedWeek.add(
                                    Duration(days: 7),
                                  );
                                  _loadWeeklySleep(_selectedWeek);
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
                          child: WeekBarChart(data: _weeklySleep),
                        ),
                        CommonWidget.roundedButton(
                              context: context,
                              titleColor: ColorConstant.sleepGlobal,

                              bgColor: ColorConstant.sleepGlobal.withAlpha(30),
                              title: "View Monthly Record",
                              padding: EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                color: ColorConstant.sleepGlobal,
                                size: 20,
                              ),
                              onTap: () async {
                                await sleepTrackerController
                                    .getMonthlySleepSummary(DateTime.now());
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
            SleepPersonlizedRecommTile(),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      ),
    );
  }

  Column activitesCardGrid() {
    final avgBedtime =
        sleepTrackerController.sleepStatsModel.value?.data?.avgBedtime ?? "-";
    final avgWakeUp =
        sleepTrackerController.sleepStatsModel.value?.data?.avgWaketime ?? "-";
    final avgTimeToFall =
        sleepTrackerController
            .sleepStatsModel
            .value
            ?.data
            ?.timeToFallAsleepMinutes ??
        0;
    final sleepEfficiency =
        sleepTrackerController.sleepStatsModel.value?.data?.sleepEfficiency ??
        "-";
    return Column(
      children: [
        Row(
          children: [
            tileCard(
              "Avg. Bedtime",
              avgBedtime,
              "assets/images/tabler_activity.png",
            ),
            SizedBox(width: 10),
            tileCard(
              "Avg. WakeUp",
              avgWakeUp,
              "assets/images/material-symbols_distance-outline.png",
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            tileCard(
              "Time of fall asleep",
              avgTimeToFall.toString(),
              "assets/images/mingcute_time-line.png",
            ),
            SizedBox(width: 10),
            tileCard(
              "Sleep Efficiency",
              "${sleepEfficiency.toFormattedNumber()}%",
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

  Future<void> _loadWeeklySleep(DateTime weekDate) async {
    final start = startOfWeek(weekDate);
    final end = endOfWeek(weekDate);
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Call API to fetch weekly data
    await sleepTrackerController.getWeeklySleepSummary(
      dateFormat.format(start),
      dateFormat.format(end),
    );

    // Map API data to _weeklySleep list
    final apiData = sleepTrackerController.weeklySleepSummary.value?.data ?? [];

    // Create a map of date -> totalSleepMinutes for quick lookup
    final Map<DateTime, int> sleepPerDay = {};
    for (var datum in apiData) {
      if (datum.summaryDate != null) {
        final date = normalizeDate(datum.summaryDate!);
        final minutes = datum.totalSleepMinutes ?? 0;
        sleepPerDay[date] = minutes < 0 ? 0 : minutes;
      }
    }

    // Build the 7-day list (Monday to Sunday)
    List<double> result = [];
    for (int i = 0; i < 7; i++) {
      final date = normalizeDate(start.add(Duration(days: i)));
      result.add((sleepPerDay[date] ?? 0).toDouble());
    }

    if (mounted) {
      setState(() {
        _weeklySleep = result;
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

class SleepPersonlizedRecommTile extends StatelessWidget {
  const SleepPersonlizedRecommTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CommonWidget.containerDecoration(),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.title(
            text: "Personalized Recommendations",
            isBold: true,
            size: 14,
          ).padSymm(horizontal: 16, vertical: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),

            decoration: CommonWidget.containerDecoration(
              color: Colors.grey.shade200,
            ),
            child: Column(
              children: [
                tile(
                  icon: Icons.bed,
                  title: "Avoid caffeine after 7pm",
                  subtitle: "Could improve sleep quality by 15%",
                ),
                SizedBox(height: 16),
                tile(
                  icon: Icons.bed,
                  title: "Going to bed 30 minutes earlier",
                  subtitle: "Helps you get closer to your 8-hour goal",
                ),
                SizedBox(height: 16),

                tile(
                  icon: Icons.bed,
                  title: "Enable night mode 1 hour before bed",
                  subtitle: "Reduce blue light exposure for better sleep onset",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              CustomText.title(text: title, overflow: TextOverflow.visible),
              CustomText.title(
                text: subtitle,
                color: Colors.grey,
                size: 12,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WeekBarChart extends StatefulWidget {
  final List<double> data;

  const WeekBarChart({super.key, required this.data});

  @override
  State<WeekBarChart> createState() => _WeekBarChartState();
}

class _WeekBarChartState extends State<WeekBarChart> {
  double _calculateMaxY() {
    if (widget.data.isEmpty) return 480.0;

    final maxVal = widget.data.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 480) return 480.0;

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
        // minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),

            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                minutesToHours(rod.toY.toInt()),
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
                  "${(value.toInt() / 60).toStringAsFixed(0)}h",
                  style: TextStyle(fontSize: 10),
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
          widget.data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: widget.data[i].isFinite ? widget.data[i] : 0,
                color: ColorConstant.sleepGlobal,
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
