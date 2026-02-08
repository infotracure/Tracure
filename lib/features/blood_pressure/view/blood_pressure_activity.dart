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
import '../controller/blood_pressure_controller.dart';
import '../model/blood_pressure_trend_model.dart';

class BloodPressureActivity extends StatefulWidget {
  const BloodPressureActivity({super.key});

  @override
  State<BloodPressureActivity> createState() => _BloodPressureActivityState();
}

class _BloodPressureActivityState extends State<BloodPressureActivity> {
  final bloodPressureController = Get.find<BloodPressureController>();
  DateTime _selectedWeek = DateTime.now();
  List<double> _weeklySystolic = List.filled(7, 0.0);
  List<double> _weeklyDiastolic = List.filled(7, 0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadWeeklyBloodPressure(_selectedWeek);
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
                        iconColor: const Color(0xFFE53935),
                        onTap: () {
                          setState(() {
                            _selectedWeek = _selectedWeek.subtract(
                              const Duration(days: 7),
                            );
                            _loadWeeklyBloodPressure(_selectedWeek);
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
                              iconColor: const Color(0xFFE53935),
                              onTap: () {
                                setState(() {
                                  _selectedWeek = _selectedWeek.add(
                                    const Duration(days: 7),
                                  );
                                  _loadWeeklyBloodPressure(_selectedWeek);
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
                          child: BloodPressureWeekBarChart(
                            systolicData: _weeklySystolic,
                            diastolicData: _weeklyDiastolic,
                          ),
                        ),
                        CommonWidget.roundedButton(
                              context: context,
                              titleColor: const Color(0xFFE53935),
                              bgColor: const Color(0xFFFFF0F0),
                              title: "View Monthly Record",
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                              prefixIcon: const Icon(
                                Icons.calendar_month,
                                color: Color(0xFFE53935),
                                size: 20,
                              ),
                              onTap: () async {
                                await bloodPressureController
                                    .getMonthlyBloodPressureSummary(
                                  DateTime.now(),
                                );
                                if (!context.mounted) return;
                                showRoundedBottomSheet(
                                  context: context,
                                  child: BloodPressureCalendar(
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

  Future<void> _loadWeeklyBloodPressure(DateTime weekDate) async {
    final start = startOfWeek(weekDate);
    final end = endOfWeek(weekDate);
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Call API to fetch weekly data
    await bloodPressureController.getWeeklyBloodPressureSummary(
      dateFormat.format(start),
      dateFormat.format(end),
    );

    // Map API data to weekly lists
    final records =
        bloodPressureController.weeklyBloodPressureSummary.value?.data?.records ?? [];

    // Create maps for quick lookup
    final Map<DateTime, int> systolicPerDay = {};
    final Map<DateTime, int> diastolicPerDay = {};

    for (var record in records) {
      if (record.date != null) {
        final date = _normalizeDate(record.date!);
        systolicPerDay[date] = record.avgSystolic ?? 0;
        diastolicPerDay[date] = record.avgDiastolic ?? 0;
      }
    }

    // Build the 7-day lists (Monday to Sunday)
    List<double> systolicResult = [];
    List<double> diastolicResult = [];

    for (int i = 0; i < 7; i++) {
      final date = _normalizeDate(start.add(Duration(days: i)));
      systolicResult.add((systolicPerDay[date] ?? 0).toDouble());
      diastolicResult.add((diastolicPerDay[date] ?? 0).toDouble());
    }

    if (mounted) {
      setState(() {
        _weeklySystolic = systolicResult;
        _weeklyDiastolic = diastolicResult;
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
    final avgSystolic =
        bloodPressureController.bloodPressureStats.value?.data?.avgSystolic ?? 0;
    final avgDiastolic =
        bloodPressureController.bloodPressureStats.value?.data?.avgDiastolic ?? 0;
    final avgPulse =
        bloodPressureController.bloodPressureStats.value?.data?.avgPulse ?? 0;

    return SizedBox(
      height: 60,
      child: Container(
        decoration: CommonWidget.containerDecoration(),
        child: Row(
          children: [
            Expanded(
              child: iconLabelCard(
                label: "Avg Systolic",
                color: const Color(0xFFE53935),
                value: "$avgSystolic mmHg",
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
                label: "Avg Diastolic",
                color: const Color(0xFFEC407A),
                value: "$avgDiastolic mmHg",
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
                label: "Avg Pulse",
                color: const Color(0xFFFF7043),
                value: "$avgPulse bpm",
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
        "title": "Heart Protection",
        "subTitle": "Reduces heart attack risk by 40%",
      },
      {
        "icon": "assets/images/ic_mental_clarity.png",
        "title": "Stroke Prevention",
        "subTitle": "Lowers stroke risk by 35%",
      },
      {
        "icon": "assets/images/ic_energy_boost.png",
        "title": "Kidney Health",
        "subTitle": "Protects kidney function long-term",
      },
      {
        "icon": "assets/images/ic_immune_system.png",
        "title": "Vision Care",
        "subTitle": "Reduces eye damage risk by 30%",
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

class BloodPressureWeekBarChart extends StatefulWidget {
  final List<double> systolicData;
  final List<double> diastolicData;

  const BloodPressureWeekBarChart({
    super.key,
    required this.systolicData,
    required this.diastolicData,
  });

  @override
  State<BloodPressureWeekBarChart> createState() =>
      _BloodPressureWeekBarChartState();
}

class _BloodPressureWeekBarChartState extends State<BloodPressureWeekBarChart> {
  double _calculateMaxY() {
    if (widget.systolicData.isEmpty) return 180.0;

    final maxSystolic = widget.systolicData.reduce((a, b) => a > b ? a : b);
    final maxDiastolic = widget.diastolicData.reduce((a, b) => a > b ? a : b);
    final maxVal = maxSystolic > maxDiastolic ? maxSystolic : maxDiastolic;

    if (maxVal <= 180) return 180.0;

    // Round up to nearest 20
    return ((maxVal / 20).ceil() * 20).toDouble();
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
              final label = rodIndex == 0 ? 'SYS' : 'DIA';
              return BarTooltipItem(
                '$label: ${rod.toY.toInt()}',
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
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 3,
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
          widget.systolicData.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: widget.systolicData[i].isFinite ? widget.systolicData[i] : 0,
                color: const Color(0xFFE53935),
                width: 8,
                borderRadius: BorderRadius.circular(2),
              ),
              BarChartRodData(
                toY: widget.diastolicData[i].isFinite ? widget.diastolicData[i] : 0,
                color: const Color(0xFFEC407A),
                width: 8,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BloodPressureCalendar extends StatefulWidget {
  final DateTime initialMonth;
  final void Function(DateTime)? onDaySelected;
  final Color headerColor = const Color(0xFFE53935);

  const BloodPressureCalendar({
    super.key,
    required this.initialMonth,
    this.onDaySelected,
  });

  @override
  State<BloodPressureCalendar> createState() => _BloodPressureCalendarState();
}

class _BloodPressureCalendarState extends State<BloodPressureCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, Record> _monthlyData = {};
  final _bloodPressureController = Get.find<BloodPressureController>();

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialMonth;
    _loadMonthData(_focusedDay);
  }

  Future<void> _loadMonthData(DateTime month) async {
    await _bloodPressureController.getMonthlyBloodPressureSummary(month);
    _updateDataFromController();
  }

  void _updateDataFromController() {
    final records =
        _bloodPressureController.monthlyBloodPressureSummary.value?.data?.records ?? [];
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

  String _formatBPValue(Record record) {
    final sys = record.avgSystolic ?? 0;
    final dia = record.avgDiastolic ?? 0;
    if (sys > 0 && dia > 0) {
      return '$sys/$dia';
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
              record != null ? _formatBPValue(record) : "",
              style: TextStyle(fontSize: 10, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
