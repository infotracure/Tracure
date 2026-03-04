import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_methods.dart';
import '../../step_tracker/view/step_tracker_overview.dart';
import '../../step_tracker/view/view_monthly_bottom_sheet.dart';
import '../controller/medicine_tracker_controller.dart';
import '../model/medicine_summary_by_date_range.dart';
import 'medicine_tracker_screen.dart';

class MedicineTrackerHistory extends StatefulWidget {
  const MedicineTrackerHistory({super.key});

  @override
  State<MedicineTrackerHistory> createState() => _MedicineTrackerHistoryState();
}

class _MedicineTrackerHistoryState extends State<MedicineTrackerHistory> {
  final _ctrl = Get.find<MedicineTrackerController>();
  DateTime _selectedWeek = DateTime.now();
  List<double> _weeklyAdherence = List.filled(7, 0.0);
  List<int> _weeklyTaken = List.filled(7, 0);
  List<int> _weeklyExpected = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeeklyData(_selectedWeek);
    });
  }

  Future<void> _loadWeeklyData(DateTime weekDate) async {
    final start = startOfWeek(weekDate);
    final end = endOfWeek(weekDate);
    final fmt = DateFormat('yyyy-MM-dd');
    await _ctrl.getWeeklyMedicineSummary(fmt.format(start), fmt.format(end));

    final byDate = _ctrl.weeklyMedicineSummary.value?.data?.byDate ?? [];
    final Map<DateTime, ByDate> byDateMap = {
      for (final e in byDate)
        if (e.date != null)
          DateTime(e.date!.year, e.date!.month, e.date!.day): e,
    };

    final adherence = List.generate(7, (i) {
      final d = DateTime(start.year, start.month, start.day + i);
      return byDateMap[d]?.adherencePct ?? 0.0;
    });
    final taken = List.generate(7, (i) {
      final d = DateTime(start.year, start.month, start.day + i);
      return byDateMap[d]?.takenDoses ?? 0;
    });
    final expected = List.generate(7, (i) {
      final d = DateTime(start.year, start.month, start.day + i);
      return byDateMap[d]?.expectedDoses ?? 0;
    });

    if (mounted) {
      setState(() {
        _weeklyAdherence = adherence;
        _weeklyTaken = taken;
        _weeklyExpected = expected;
      });
    }
  }

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final currentWeekStart = startOfWeek(now);
    final selectedWeekStart = startOfWeek(_selectedWeek);
    return DateTime(
          currentWeekStart.year,
          currentWeekStart.month,
          currentWeekStart.day,
        ) ==
        DateTime(
          selectedWeekStart.year,
          selectedWeekStart.month,
          selectedWeekStart.day,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final data = _ctrl.weeklyMedicineSummary.value?.data;
      final taken = data?.totalTaken ?? 0;
      final missed = (data?.totalExpected ?? 0) - taken;
      final adherence = data?.overallAdherence?.toStringAsFixed(0) ?? '0';

      return SingleChildScrollView(
        child: Column(
          children: [
            _weeklyChartSection(context),
            const SizedBox(height: 16),
            _statsWidget(
              taken: taken,
              missed: missed < 0 ? 0 : missed,
              adherence: '$adherence%',
            ),
            const SizedBox(height: 16),
            _keyHealthBenefits(),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      );
    });
  }

  Widget _weeklyChartSection(BuildContext context) {
    return Container(
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LeftRightIconButton(
                iconColor: medicineGreen,
                onTap: () {
                  setState(() {
                    _selectedWeek = _selectedWeek.subtract(
                      const Duration(days: 7),
                    );
                  });
                  _loadWeeklyData(_selectedWeek);
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
                      iconColor: medicineGreen,
                      onTap: () {
                        setState(() {
                          _selectedWeek = _selectedWeek.add(
                            const Duration(days: 7),
                          );
                        });
                        _loadWeeklyData(_selectedWeek);
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
                  child: _MedicineWeekBarChart(
                    data: _weeklyAdherence,
                    takenData: _weeklyTaken,
                    expectedData: _weeklyExpected,
                  ),
                ),
                CommonWidget.roundedButton(
                      context: context,
                      titleColor: medicineGreen,
                      bgColor: const Color(0xFFE8F5E9),
                      title: "View Monthly Record",
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                      prefixIcon: Icon(
                        Icons.calendar_month,
                        color: medicineGreen,
                        size: 20,
                      ),
                      onTap: () async {
                        final now = DateTime.now();
                        final first = DateTime(now.year, now.month, 1);
                        final last = DateTime(now.year, now.month + 1, 0);
                        final fmt = DateFormat('yyyy-MM-dd');
                        await _ctrl.getMonthlyMedicineSummary(
                          fmt.format(first),
                          fmt.format(last),
                        );
                        if (!context.mounted) return;
                        showRoundedBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          child: MedicineCalendar(initialMonth: now),
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

  Widget _statsWidget({
    required int taken,
    required int missed,
    required String adherence,
  }) {
    return SizedBox(
      height: 60,
      child: Container(
        decoration: CommonWidget.containerDecoration(),
        child: Row(
          children: [
            Expanded(
              child: _statCard(
                label: "Taken",
                color: medicineGreen,
                value: "$taken",
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
                label: "Missed",
                color: const Color(0xFFE53935),
                value: "$missed",
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
                label: "Adherence",
                color: const Color(0xFF1E88E5),
                value: adherence,
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
        "title": "Consistent Dosing",
        "subTitle": "Maintains therapeutic levels",
      },
      {
        "icon": "assets/images/ic_mental_clarity.png",
        "title": "Better Recovery",
        "subTitle": "Faster treatment outcomes",
      },
      {
        "icon": "assets/images/ic_energy_boost.png",
        "title": "Reduced Risk",
        "subTitle": "Lower chance of complications",
      },
      {
        "icon": "assets/images/ic_immune_system.png",
        "title": "Drug Efficacy",
        "subTitle": "Optimal medication response",
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
class _MedicineWeekBarChart extends StatelessWidget {
  final List<double> data;
  final List<int> takenData;
  final List<int> expectedData;
  const _MedicineWeekBarChart({
    required this.data,
    required this.takenData,
    required this.expectedData,
  });

  @override
  Widget build(BuildContext context) {
    const dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    return BarChart(
      BarChartData(
        maxY: 100,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final i = group.x;
              final label = '${takenData[i]}/${expectedData[i]}';
              return BarTooltipItem(
                label,
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
          horizontalInterval: 25,
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
              interval: 25,
              reservedSize: 35,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox();
                return Text(
                  '${value.toInt()}%',
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
                color: medicineGreen,
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
class MedicineCalendar extends StatefulWidget {
  final DateTime initialMonth;
  const MedicineCalendar({super.key, required this.initialMonth});

  @override
  State<MedicineCalendar> createState() => _MedicineCalendarState();
}

class _MedicineCalendarState extends State<MedicineCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, ByDate> _monthlyData = {};
  final _ctrl = Get.find<MedicineTrackerController>();

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialMonth;
    _updateDataFromController();
  }

  void _updateDataFromController() {
    final byDate = _ctrl.monthlyMedicineSummary.value?.data?.byDate ?? [];
    final Map<DateTime, ByDate> dataPerDay = {};
    for (final e in byDate) {
      if (e.date != null) {
        dataPerDay[DateTime(e.date!.year, e.date!.month, e.date!.day)] = e;
      }
    }
    if (mounted) setState(() => _monthlyData = dataPerDay);
  }

  Future<void> _loadMonthData(DateTime month) async {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final fmt = DateFormat('yyyy-MM-dd');
    await _ctrl.getMonthlyMedicineSummary(fmt.format(first), fmt.format(last));
    _updateDataFromController();
  }

  Color _adherenceColor(double pct) {
    if (pct >= 80) return const Color(0xFF43A047);
    if (pct >= 50) return const Color(0xFFFB8C00);
    if (pct > 0) return const Color(0xFFE53935);
    return Colors.grey.shade400;
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
        },
        onPageChanged: (focusedDay) {
          setState(() => _focusedDay = focusedDay);
          _loadMonthData(focusedDay);
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) => _buildDayCell(day),
          selectedBuilder: (context, day, focusedDay) =>
              _buildDayCell(day, isSelected: true),
          todayBuilder: (context, day, focusedDay) =>
              _buildDayCell(day, isToday: true),
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
            iconColor: medicineGreen,
          ).padSymm(),
          rightChevronIcon: LeftRightIconButton(
            iconColor: medicineGreen,
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
    final entry = _monthlyData[key];
    final label = entry != null
        ? '${entry.takenDoses ?? 0}/${entry.expectedDoses ?? 0}'
        : '';
    final pct = entry?.adherencePct ?? 0.0;

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
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: entry != null
                    ? _adherenceColor(pct)
                    : Colors.transparent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
