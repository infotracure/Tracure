import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_day.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../servies/health_service.dart';

class StepTrackerWeek extends StatefulWidget {
  const StepTrackerWeek({super.key});

  @override
  State<StepTrackerWeek> createState() => _StepTrackerWeekState();
}

class _StepTrackerWeekState extends State<StepTrackerWeek> {
  DateTime _selectedWeek = DateTime.now();
  List<double> _weeklySteps = List.filled(7, 0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _loadWeeklySteps(_selectedWeek); // load current week initially
    });
  }

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
                  LeftRightIconButton(
                    onTap: () {
                      if (_selectedWeek.isAfter(DateTime.now())) return;
                      setState(() {
                        _selectedWeek = _selectedWeek.add(Duration(days: 7));
                        _loadWeeklySteps(_selectedWeek);
                      });
                    },
                  ).rotate(180).padSymm(horizontal: 10, vertical: 10),
                ],
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: WeekBarChart(weeklySteps: _weeklySteps),
              ),
            ],
          ),
        ),
        stepDistanceWidget().padSymm(horizontal: 8),
      ],
    ).padSymm(horizontal: 16, vertical: 16);
  }

  Future<void> _loadWeeklySteps(DateTime weekDate) async {
    final steps = await getDailyStepsForWeek(weekDate);
    setState(() {
      _weeklySteps = steps;
    });
  }

  Future<List<double>> getDailyStepsForWeek(DateTime week) async {
    final Map<DateTime, int> stepsPerDay = {};
    final startOfWeek = week.subtract(
      Duration(days: week.weekday - 1),
    ); // Monday
    final data = await HealthDataService().getWeeklySteps(week);
    for (var point in data) {
      if (point.value is NumericHealthValue) {
        final stepsValue = (point.value as NumericHealthValue).numericValue
            .toInt();
        final date = DateTime(
          point.dateFrom.year,
          point.dateFrom.month,
          point.dateFrom.day,
        );
        stepsPerDay[date] = (stepsPerDay[date] ?? 0) + stepsValue;
      }
    }

    // Ensure exactly 7 days (Sun → Sat for your chart)
    List<double> result = [];
    for (int i = 0; i < 7; i++) {
      final date = normalizeDate(startOfWeek.add(Duration(days: i)));
      result.add((stepsPerDay[date] ?? 0).toDouble());
    }
    return result;
  }

  DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime startOfWeek(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: date.weekday - 1)); // Monday
  }

  DateTime endOfWeek(DateTime date) {
    return startOfWeek(date).add(const Duration(days: 6));
  }

  String formatWeekRange(DateTime selected) {
    final start = startOfWeek(selected);
    final end = endOfWeek(selected);

    final monthName = _monthName(start.month);
    // if week spans two months, show both
    if (start.month != end.month) {
      return "${start.day} ${_monthName(start.month)} - ${end.day} ${_monthName(end.month)} ${end.year}";
    } else {
      return "${start.day}-${end.day} $monthName ${end.year}";
    }
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
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
                color:  Color(0xFFFAB005),
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
                color: ColorConstant.verdigris,
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
        barTouchData: BarTouchData(enabled: true),
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
                color: Colors.teal,
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
