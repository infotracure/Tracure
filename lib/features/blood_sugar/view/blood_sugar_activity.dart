import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_overview.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_methods.dart';
import '../../step_tracker/view/view_monthly_bottom_sheet.dart';
import '../controller/blood_sugar_controller.dart';
import '../model/blood_sugar_trend.dart';

class BloodSugarActivity extends StatefulWidget {
  const BloodSugarActivity({super.key});

  @override
  State<BloodSugarActivity> createState() => _BloodSugarActivityState();
}

class _BloodSugarActivityState extends State<BloodSugarActivity> {
  final bloodSugarController = Get.find<BloodSugarController>();
  DateTime _selectedWeek = DateTime.now();
  List<double> _weeklyValues = List.filled(7, 0.0);

  static const Color _primaryColor = Color(0xFF4CAF50);
  static const Color _secondaryColor = Color(0xFF81C784);
  static const Color _lightBgColor = Color(0xFFE8F5E9);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadWeeklyBloodSugar(_selectedWeek);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
                        iconColor: _primaryColor,
                        onTap: () {
                          setState(() {
                            _selectedWeek = _selectedWeek.subtract(
                              const Duration(days: 7),
                            );
                            _loadWeeklyBloodSugar(_selectedWeek);
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
                              iconColor: _primaryColor,
                              onTap: () {
                                setState(() {
                                  _selectedWeek = _selectedWeek.add(
                                    const Duration(days: 7),
                                  );
                                  _loadWeeklyBloodSugar(_selectedWeek);
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
                          child: BloodSugarWeekBarChart(
                            data: _weeklyValues,
                          ),
                        ),
                        CommonWidget.roundedButton(
                              context: context,
                              titleColor: _primaryColor,
                              bgColor: _lightBgColor,
                              title: "View Monthly Record",
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                              prefixIcon: const Icon(
                                Icons.calendar_month,
                                color: _primaryColor,
                                size: 20,
                              ),
                              onTap: () async {
                                await bloodSugarController
                                    .getMonthlyBloodSugarSummary(
                                  DateTime.now(),
                                );
                                if (!context.mounted) return;
                                showRoundedBottomSheet(
                                  context: context,
                                  child: BloodSugarCalendar(
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
            statsWidget(),
            keyHealthBenefits(),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      );
    });
  }

  Future<void> _loadWeeklyBloodSugar(DateTime weekDate) async {
    final start = startOfWeek(weekDate);
    final end = endOfWeek(weekDate);
    final dateFormat = DateFormat('yyyy-MM-dd');

    await bloodSugarController.getWeeklyBloodSugarSummary(
      dateFormat.format(start),
      dateFormat.format(end),
    );

    final records =
        bloodSugarController.weeklyBloodSugarSummary.value?.data?.records ?? [];

    final Map<DateTime, int> valuePerDay = {};

    for (var record in records) {
      if (record.date != null) {
        final date = _normalizeDate(record.date!);
        valuePerDay[date] = record.avgValue ?? 0;
      }
    }

    List<double> valuesResult = [];

    for (int i = 0; i < 7; i++) {
      final date = _normalizeDate(start.add(Duration(days: i)));
      valuesResult.add((valuePerDay[date] ?? 0).toDouble());
    }

    if (mounted) {
      setState(() {
        _weeklyValues = valuesResult;
      });
    }
  }

  DateTime _normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isCurrentWeek() {
    final now = DateTime.now();
    final currentWeekStart = startOfWeek(now);
    final selectedWeekStart = startOfWeek(_selectedWeek);
    return _normalizeDate(currentWeekStart) ==
        _normalizeDate(selectedWeekStart);
  }

  Widget statsWidget() {
    final avgValue =
        bloodSugarController.bloodSugarStats.value?.data?.avgValue ?? 0;
    final minValue =
        bloodSugarController.bloodSugarStats.value?.data?.minValue ?? 0;
    final maxValue =
        bloodSugarController.bloodSugarStats.value?.data?.maxValue ?? 0;

    return SizedBox(
      height: 60,
      child: Container(
        decoration: CommonWidget.containerDecoration(),
        child: Row(
          children: [
            Expanded(
              child: iconLabelCard(
                label: "Avg Value",
                color: _primaryColor,
                value: "$avgValue mg/dL",
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
                label: "Min Value",
                color: _secondaryColor,
                value: "$minValue mg/dL",
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
                label: "Max Value",
                color: const Color(0xFFFF9800),
                value: "$maxValue mg/dL",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget iconLabelCard({
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

  Widget keyHealthBenefits() {
    var benefitList = [
      {
        "icon": "assets/images/ic_heart.png",
        "title": "Diabetes Prevention",
        "subTitle": "Reduces diabetes risk by 58%",
      },
      {
        "icon": "assets/images/ic_mental_clarity.png",
        "title": "Energy Balance",
        "subTitle": "Maintains stable energy levels",
      },
      {
        "icon": "assets/images/ic_energy_boost.png",
        "title": "Heart Health",
        "subTitle": "Lowers cardiovascular risk by 25%",
      },
      {
        "icon": "assets/images/ic_immune_system.png",
        "title": "Kidney Protection",
        "subTitle": "Prevents kidney damage long-term",
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

class BloodSugarWeekBarChart extends StatefulWidget {
  final List<double> data;

  const BloodSugarWeekBarChart({
    super.key,
    required this.data,
  });

  @override
  State<BloodSugarWeekBarChart> createState() => _BloodSugarWeekBarChartState();
}

class _BloodSugarWeekBarChartState extends State<BloodSugarWeekBarChart> {
  double _calculateMaxY() {
    if (widget.data.isEmpty) return 200.0;

    final maxVal = widget.data.reduce((a, b) => a > b ? a : b);

    if (maxVal <= 200) return 200.0;

    // Round up to nearest 50
    return ((maxVal / 50).ceil() * 50).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    const dayLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
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
                '${rod.toY.toInt()} mg/dL',
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
          horizontalInterval: maxY / 4,
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4,
              reservedSize: 35,
              getTitlesWidget: (value, _) {
                if (value == 0) return const SizedBox();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
          widget.data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: widget.data[i].isFinite ? widget.data[i] : 0,
                color: const Color(0xFF4CAF50),
                width: 14,
                borderRadius: BorderRadius.circular(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BloodSugarCalendar extends StatefulWidget {
  final DateTime initialMonth;
  final void Function(DateTime)? onDaySelected;
  final Color headerColor = const Color(0xFF4CAF50);

  const BloodSugarCalendar({
    super.key,
    required this.initialMonth,
    this.onDaySelected,
  });

  @override
  State<BloodSugarCalendar> createState() => _BloodSugarCalendarState();
}

class _BloodSugarCalendarState extends State<BloodSugarCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, Record> _monthlyData = {};
  final _bloodSugarController = Get.find<BloodSugarController>();

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialMonth;
    _loadMonthData(_focusedDay);
  }

  Future<void> _loadMonthData(DateTime month) async {
    await _bloodSugarController.getMonthlyBloodSugarSummary(month);
    _updateDataFromController();
  }

  void _updateDataFromController() {
    final records =
        _bloodSugarController.monthlyBloodSugarSummary.value?.data?.records ?? [];
    final Map<DateTime, Record> dataPerDay = {};

    for (var record in records) {
      if (record.date != null) {
        final date = DateTime(
          record.date!.year,
          record.date!.month,
          record.date!.day,
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

  String _formatBSValue(Record record) {
    final avg = record.avgValue ?? 0;
    if (avg > 0) {
      return '$avg';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2025, 5, 25),
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
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        headerPadding: EdgeInsets.zero,
        titleCentered: true,
        leftChevronPadding: EdgeInsets.zero,
        leftChevronIcon: LeftRightIconButton(
          iconColor: widget.headerColor,
        ).padSymm(),
        rightChevronIcon: LeftRightIconButton(
          iconColor: widget.headerColor,
        ).rotate(180).padSymm(),
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
              record != null ? _formatBSValue(record) : "",
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
