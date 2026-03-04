import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracure/features/fasting_tracker/controller/fasting_tracker_controller.dart';
import 'package:tracure/features/fasting_tracker/model/fasting_summary_by_range_model.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_overview.dart';
import 'package:tracure/features/step_tracker/view/view_monthly_bottom_sheet.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_methods.dart';

const Color _fastingRed = Color(0xFFE53935);

class FastingTrackerActivity extends StatefulWidget {
  const FastingTrackerActivity({super.key});

  @override
  State<FastingTrackerActivity> createState() => _FastingTrackerActivityState();
}

class _FastingTrackerActivityState extends State<FastingTrackerActivity> {
  final controller = Get.find<FastingTrackerController>();
  DateTime _selectedWeek = DateTime.now();
  List<double> _weeklyFastingHours = List.filled(7, 0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadWeeklyFasting(_selectedWeek);
      await _loadStats();
    });
  }

  Future<void> _loadWeeklyFasting(DateTime weekDate) async {
    final start = startOfWeek(weekDate);
    final end = endOfWeek(weekDate);
    final dateFormat = DateFormat('yyyy-MM-dd');

    await controller.getWeeklyFastingSummary(
      dateFormat.format(start),
      dateFormat.format(end),
    );

    final records = controller.weeklyFastingSummary.value?.data ?? [];

    final Map<DateTime, double> hoursPerDay = {};
    for (var record in records) {
      if (record.fastingDate != null) {
        final date = _normalizeDate(record.fastingDate!);
        hoursPerDay[date] = (record.totalDurationMinutes ?? 0) / 60.0;
      }
    }

    List<double> result = [];
    for (int i = 0; i < 7; i++) {
      final date = _normalizeDate(start.add(Duration(days: i)));
      result.add(hoursPerDay[date] ?? 0.0);
    }

    if (mounted) {
      setState(() {
        _weeklyFastingHours = result;
      });
    }
  }

  Future<void> _loadStats() async {
    final start = startOfWeek(_selectedWeek);
    final end = endOfWeek(_selectedWeek);
    final dateFormat = DateFormat('yyyy-MM-dd');
    await controller.getFastingStats(
      dateFormat.format(start),
      dateFormat.format(end),
    );
  }

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final currentWeekStart = startOfWeek(now);
    final selectedWeekStart = startOfWeek(_selectedWeek);
    return _normalizeDate(currentWeekStart) ==
        _normalizeDate(selectedWeekStart);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            // Weekly bar chart
            _weeklyChartSection(),
            // Stats
            _statsWidget(),
            // Health benefits
            _keyHealthBenefits(),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      );
    });
  }

  Widget _weeklyChartSection() {
    return Container(
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LeftRightIconButton(
                iconColor: _fastingRed,
                onTap: () {
                  setState(() {
                    _selectedWeek = _selectedWeek.subtract(
                      const Duration(days: 7),
                    );
                    _loadWeeklyFasting(_selectedWeek);
                    _loadStats();
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
                      iconColor: _fastingRed,
                      onTap: () {
                        setState(() {
                          _selectedWeek = _selectedWeek.add(
                            const Duration(days: 7),
                          );
                          _loadWeeklyFasting(_selectedWeek);
                          _loadStats();
                        });
                      },
                    ).rotate(180).padSymm(horizontal: 10, vertical: 10),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 210,
            child: Stack(
              children: [
                SizedBox(
                  height: 150,
                  child: _FastingWeekBarChart(data: _weeklyFastingHours),
                ),
                CommonWidget.roundedButton(
                      context: context,
                      titleColor: _fastingRed,
                      bgColor: const Color(0xFFFFF0F0),
                      title: "View Monthly Record",
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      prefixIcon: const Icon(
                        Icons.calendar_month,
                        color: _fastingRed,
                        size: 20,
                      ),
                      onTap: () async {
                        await controller.getMonthlySleepSummary(DateTime.now());
                        if (!mounted) return;
                        showRoundedBottomSheet(
                          context: context,
                          child: FastingCalendar(initialMonth: DateTime.now()),
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
    );
  }

  Widget _statsWidget() {
    final stats = controller.fastingStatsModel.value?.data;
    final avgDuration = stats?.avgDurationMinutes ?? 0;
    final maxDuration = stats?.maxDurationMinutes ?? 0;
    final totalRecords = stats?.recordsCount ?? 0;

    return SizedBox(
      height: 60,
      child: Container(
        decoration: CommonWidget.containerDecoration(),
        child: Row(
          children: [
            Expanded(
              child: _statCard(
                label: "Avg Duration",
                color: _fastingRed,
                value: minutesToHours(avgDuration),
              ),
            ),
            VerticalDivider(
              thickness: 1,
              color: Colors.grey.shade300,
              indent: 4,
              endIndent: 4,
            ),
            Expanded(
              child: _statCard(
                label: "Max Duration",
                color: const Color(0xFFEC407A),
                value: minutesToHours(maxDuration),
              ),
            ),
            VerticalDivider(
              thickness: 1,
              color: Colors.grey.shade300,
              indent: 4,
              endIndent: 4,
            ),
            Expanded(
              child: _statCard(
                label: "Total Fasts",
                color: const Color(0xFFFF7043),
                value: "$totalRecords",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required String label,
    required Color color,
    required String value,
  }) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _keyHealthBenefits() {
    const benefitList = [
      {
        "icon": "assets/images/ic_heart.png",
        "title": "Heart Health",
        "subTitle": "Improves cardiovascular health",
      },
      {
        "icon": "assets/images/ic_mental_clarity.png",
        "title": "Mental Clarity",
        "subTitle": "Enhances focus and cognition",
      },
      {
        "icon": "assets/images/ic_energy_boost.png",
        "title": "Energy Boost",
        "subTitle": "Increases metabolic efficiency",
      },
      {
        "icon": "assets/images/ic_immune_system.png",
        "title": "Cell Protection",
        "subTitle": "Activates autophagy process",
      },
    ];

    return Container(
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          CustomText.title(
            text: "Key Health Benefits",
            isBold: true,
          ).padSymm(horizontal: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: benefitList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (BuildContext context, int i) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xffF9F9FA),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(benefitList[i]["icon"]!, height: 24),
                    const SizedBox(height: 4),
                    CustomText.title(
                      text: benefitList[i]["title"],
                      isBold: true,
                      size: 12,
                      overflow: TextOverflow.visible,
                    ),
                    const SizedBox(height: 4),
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
}

// --- Weekly Bar Chart ---

class _FastingWeekBarChart extends StatelessWidget {
  final List<double> data;

  const _FastingWeekBarChart({required this.data});

  double _calculateMaxY() {
    if (data.isEmpty) return 24.0;
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 24) return 24.0;
    return ((maxVal / 6).ceil() * 6).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    const dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
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
                '${rod.toY.toStringAsFixed(1)}h',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: maxY / 3,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 3,
              reservedSize: 35,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox();
                return Text(
                  '${value.toInt()}h',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                int index = value.toInt();
                if (index < 0 || index >= dayLabels.length) {
                  return const SizedBox();
                }
                return Text(
                  dayLabels[index],
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
                color: _fastingRed,
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

// --- Monthly Calendar ---

class FastingCalendar extends StatefulWidget {
  final DateTime initialMonth;
  final void Function(DateTime)? onDaySelected;

  const FastingCalendar({
    super.key,
    required this.initialMonth,
    this.onDaySelected,
  });

  @override
  State<FastingCalendar> createState() => _FastingCalendarState();
}

class _FastingCalendarState extends State<FastingCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, Datum> _monthlyData = {};
  final _controller = Get.find<FastingTrackerController>();

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialMonth;
    _loadMonthData(_focusedDay);
  }

  Future<void> _loadMonthData(DateTime month) async {
    await _controller.getMonthlySleepSummary(month);
    _updateDataFromController();
  }

  void _updateDataFromController() {
    final records = _controller.monthlyFastingSummary.value?.data ?? [];
    final Map<DateTime, Datum> dataPerDay = {};

    for (var record in records) {
      if (record.fastingDate != null) {
        final date = DateTime(
          record.fastingDate!.year,
          record.fastingDate!.month,
          record.fastingDate!.day,
        );
        dataPerDay[date] = record;
      }
    }

    if (mounted) {
      setState(() {
        _monthlyData = dataPerDay;
      });
    }
  }

  String _formatFastingValue(Datum record) {
    final minutes = record.totalDurationMinutes ?? 0;
    if (minutes > 0) {
      final h = minutes ~/ 60;
      final m = minutes % 60;
      if (h > 0 && m > 0) return '${h}h ${m}m';
      if (h > 0) return '${h}h';
      return '${m}m';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: TableCalendar(
        firstDay: DateTime.utc(2025, 1, 1),
        lastDay: DateTime.now(),
        focusedDay: _focusedDay,
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 52,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarStyle: const CalendarStyle(outsideDaysVisible: false),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekendStyle: TextStyle(fontSize: 14, height: 1),
          weekdayStyle: TextStyle(fontSize: 14, height: 1),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
          if (widget.onDaySelected != null) {
            widget.onDaySelected!(selectedDay);
          }
        },
        onPageChanged: (focusedDay) async {
          setState(() {
            _focusedDay = focusedDay;
          });
          await _loadMonthData(focusedDay);
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildDayCell(day);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, isSelected: true);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildDayCell(day, isToday: true);
          },
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
          headerPadding: EdgeInsets.zero,
          titleCentered: true,
          leftChevronPadding: EdgeInsets.zero,
          leftChevronIcon: LeftRightIconButton(
            iconColor: _fastingRed,
          ).padSymm(),
          rightChevronIcon: LeftRightIconButton(
            iconColor: _fastingRed,
          ).rotate(180).padSymm(),
        ),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final key = DateTime(day.year, day.month, day.day);
    final record = _monthlyData[key];

    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.transparent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${day.day}",
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              record != null ? _formatFastingValue(record) : "",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: record != null ? _fastingRed : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
