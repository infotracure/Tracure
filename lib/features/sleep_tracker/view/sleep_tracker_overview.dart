import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';
import 'package:tracure/utils/int_extension.dart';

import '../controller/sleep_tracker_controller.dart';
import '../model/sleep_trend_model.dart';
import 'sleep_progress_widget.dart';

class SleepTrackerOverview extends StatefulWidget {
  const SleepTrackerOverview({super.key});

  @override
  State<SleepTrackerOverview> createState() => _SleepTrackerDayState();
}

class _SleepTrackerDayState extends State<SleepTrackerOverview> {
  final sleepData = generateRandomDoubleList(48);
  final sleepTrackerController = Get.find<SleepTrackerController>();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(() {
        final todaySleep =
            sleepTrackerController
                .sleepSummaryModel
                .value
                ?.data
                ?.totalSleepMinutes ??
            0;
        return Column(
          spacing: 16,
          children: [
            SleepProgressWidget(currentMin: todaySleep, goal: 10 * 60),
            activitesCardGrid(),
            SleepTrendWidget(),
            keyHealthBenefits(),
          ],
        ).padSymm(horizontal: 16, vertical: 16);
      }),
    );
  }

  Column activitesCardGrid() {
    final qualityScore =
        sleepTrackerController.sleepSummaryModel.value?.data?.qualityScore ?? 0;
    final awakenings =
        sleepTrackerController.sleepSummaryModel.value?.data?.awakenings ?? 0;
    final timeToFallAsleepMinutes =
        sleepTrackerController
            .sleepSummaryModel
            .value
            ?.data
            ?.timeToFallAsleepMinutes ??
        0;
    return Column(
      children: [
        Row(
          children: [
            tileCard(
              "Quality",
              "$qualityScore %",
              "assets/images/ic_percentage.png",
            ),
            SizedBox(width: 10),
            tileCard(
              "Awakenings",
              "$awakenings",
              "assets/images/ic_sleep_awake.png",
            ),
            SizedBox(width: 10),
            tileCard(
              "Time to fall asleep",
              timeToFallAsleepMinutes.toTimeFormat(),
              "assets/images/mingcute_time-line.png",
            ),
          ],
        ),
      ],
    );
  }

  Widget tileCard(String title, String value, String img) {
    return Expanded(
      child: Container(
        height: 80,
        decoration: CommonWidget.containerDecoration(),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText.title(
              text: title,
              size: 10,
              overflow: TextOverflow.visible,
            ),
            Row(
              children: [
                CustomText.title(text: value, size: 14, isBold: true),
                Spacer(),
                SizedBox(width: 4),
                Image.asset(img, height: 25),
              ],
            ),
          ],
        ),
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

  Widget sleepTimeWidget() {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        height: 60,
        child: Container(
          decoration: CommonWidget.containerDecoration(),
          child: Row(
            children: [
              Expanded(
                child: iconLabelCard(
                  label: "Goal",
                  img: "assets/images/emojione_running-shoe.png",
                  color: Color(0xFFFAB005),
                  value: "09h 30m",
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
                  label: "Sleep Time",
                  img: "assets/images/emojione_running-shoe.png",
                  color: Color(0xFFFAB005),
                  value: "09h 00m",
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
                  label: "Wake-up",
                  img: "assets/images/emojione_running-shoe.png",
                  color: ColorConstant.verdigris,
                  value: "08h 38m",
                ),
              ),
            ],
          ),
        ),
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

  int sleep = 0;
  do {
    if (sleep % 8 == 0) {
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
    sleep++;
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

class SleepTrendWidget extends StatefulWidget {
  const SleepTrendWidget({super.key});

  @override
  State<SleepTrendWidget> createState() => _SleepTrendWidgetState();
}

class _SleepTrendWidgetState extends State<SleepTrendWidget> {
  final sleepTrackerController = Get.find<SleepTrackerController>();
  DateTime _selectedDate = DateTime.now().subtract(Duration(days: 1));

  // Sleep time constants (10 PM to 7 AM)
  final TimeOfDay _sleepStartTime = const TimeOfDay(
    hour: 22,
    minute: 0,
  ); // 10 PM
  final TimeOfDay _sleepEndTime = const TimeOfDay(hour: 8, minute: 0); // 7 AM

  bool _isToday() {
    final now = DateTime.now().subtract(Duration(days: 1));
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  String _formatDate() {
    // if (_isToday()) {
    //   return 'Today, ${DateFormat('d MMMM yyyy').format(_selectedDate)}';
    // }
    return DateFormat('EEEE, d MMMM yyyy').format(_selectedDate);
  }

  void _goToPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    });
    _fetchData();
  }

  void _goToNextDay() {
    if (!_isToday()) {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      });
      _fetchData();
    }
  }

  void _fetchData() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    sleepTrackerController.getSleepTrend(dateStr);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.title(text: 'Sleep Trend', isBold: true),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _goToPreviousDay,
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              CustomText.title(text: _formatDate(), size: 14),
              GestureDetector(
                onTap: _isToday() ? null : _goToNextDay,
                child: Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: _isToday()
                        ? Colors.grey.shade300
                        : ColorConstant.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: _isToday() ? Colors.grey.shade500 : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() => _buildSleepTimeline()),
        ],
      ),
    );
  }

  Widget _buildSleepTimeline() {
    final timeLabels = _generateTimeLabels();
    final trends =
        sleepTrackerController.sleepTrendModel.value?.data?.trends ?? [];

    // Calculate total timeline duration in minutes
    int startMinutes = _sleepStartTime.hour * 60 + _sleepStartTime.minute;
    int endMinutes = _sleepEndTime.hour * 60 + _sleepEndTime.minute;
    if (endMinutes <= startMinutes) {
      endMinutes += 24 * 60;
    }
    final totalMinutes = endMinutes - startMinutes;

    return Column(
      children: [
        SizedBox(
          height: 24,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;

              return Stack(
                children: [
                  // Background bar (grey)
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Sleep periods from API
                  ...trends.map((trend) {
                    final position = _calculateBarPosition(
                      trend,
                      totalWidth,
                      totalMinutes,
                      startMinutes,
                    );
                    if (position == null) return const SizedBox();

                    return Positioned(
                      left: position['left'],
                      child: Container(
                        width: position['width'],
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getSleepStageColor(trend.sleepStage),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Time labels - start, intervals, and end
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: timeLabels.map((label) => _timeLabel(label)).toList(),
        ),
      ],
    );
  }

  Map<String, double>? _calculateBarPosition(
    Trend trend,
    double totalWidth,
    int totalMinutes,
    int baseStartMinutes,
  ) {
    if (trend.startTime == null || trend.endTime == null) return null;

    // Convert trend times to minutes from midnight
    int trendStartMinutes =
        trend.startTime!.hour * 60 + trend.startTime!.minute;
    int trendEndMinutes = trend.endTime!.hour * 60 + trend.endTime!.minute;

    // Handle overnight times (adjust to be relative to base start time)
    if (trendStartMinutes < baseStartMinutes) {
      trendStartMinutes += 24 * 60;
    }
    if (trendEndMinutes < baseStartMinutes) {
      trendEndMinutes += 24 * 60;
    }
    if (trendEndMinutes <= trendStartMinutes) {
      trendEndMinutes += 24 * 60;
    }

    // Calculate position relative to timeline start
    final relativeStart = trendStartMinutes - baseStartMinutes;
    final relativeEnd = trendEndMinutes - baseStartMinutes;

    // Clamp to valid range
    final clampedStart = relativeStart.clamp(0, totalMinutes);
    final clampedEnd = relativeEnd.clamp(0, totalMinutes);

    if (clampedEnd <= clampedStart) return null;

    final left = (clampedStart / totalMinutes) * totalWidth;
    final width = ((clampedEnd - clampedStart) / totalMinutes) * totalWidth;

    return {'left': left, 'width': width.clamp(2.0, totalWidth - left)};
  }

  Color _getSleepStageColor(String? stage) {
    switch (stage?.toLowerCase()) {
      case 'deep':
        return const Color(0xFF1565C0); // Dark blue
      case 'light':
        return const Color(0xFF64B5F6); // Light blue
      case 'rem':
        return const Color(0xFF42A5F5); // Medium blue
      case 'awake':
        return const Color(0xFFE0E0E0); // Grey
      default:
        return const Color(0xFF64B5F6); // Default light blue
    }
  }

  List<String> _generateTimeLabels() {
    final labels = <String>[];

    // Convert to minutes for easier calculation
    int startMinutes = _sleepStartTime.hour * 60 + _sleepStartTime.minute;
    int endMinutes = _sleepEndTime.hour * 60 + _sleepEndTime.minute;

    // Handle overnight (end time is next day)
    if (endMinutes <= startMinutes) {
      endMinutes += 24 * 60;
    }

    const intervalHours = 2; // 2-hour intervals
    final intervalMinutes = intervalHours * 60;

    // Add start time
    labels.add(_formatTimeOfDay(_sleepStartTime));

    // Add intermediate labels at 2-hour intervals
    int currentMinutes = startMinutes + intervalMinutes;
    while (currentMinutes < endMinutes) {
      final normalizedMinutes = currentMinutes % (24 * 60);
      final hour = normalizedMinutes ~/ 60;
      final minute = normalizedMinutes % 60;
      labels.add(_formatTimeOfDay(TimeOfDay(hour: hour, minute: minute)));
      currentMinutes += intervalMinutes;
    }

    // Add end time
    labels.add(_formatTimeOfDay(_sleepEndTime));

    return labels;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.hour < 12 ? 'am' : 'pm';
    return '$hour\n$period';
  }

  Widget _timeLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
      textAlign: TextAlign.center,
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
