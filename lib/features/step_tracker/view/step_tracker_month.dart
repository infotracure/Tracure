import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_day.dart';
import 'package:tracure/servies/health_service.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

class StepTrackerMonth extends StatefulWidget {
  const StepTrackerMonth({super.key});

  @override
  State<StepTrackerMonth> createState() => _StepTrackerMonthState();
}

class _StepTrackerMonthState extends State<StepTrackerMonth> {
  final Map<DateTime, int> dayValues = {
    DateTime(2025, 7, 1): 2509,
    DateTime(2025, 7, 2): 4324,
    DateTime(2025, 7, 3): 1924,
    DateTime(2025, 7, 4): 3372,
    DateTime(2025, 7, 5): 3278,
    DateTime(2025, 7, 6): 3365,
    DateTime(2025, 7, 13): 1224,
    // Add more if needed
  };
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 16,
      children: [
        Container(
          decoration: CommonWidget.containerDecoration(),
          child: Column(
            children: [
              CustomCalendar(initialMonth: DateTime.now()),
            ],
          ),
        ),
        stepDistanceWidget().padSymm(horizontal: 8),
      ],
    ).padSymm(horizontal: 16, vertical: 16);
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

class CustomCalendar extends StatefulWidget {
  final DateTime initialMonth;
  final void Function(DateTime)? onDaySelected;

  const CustomCalendar({
    super.key,
    required this.initialMonth,
    this.onDaySelected,
  });

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  List<HealthDataPoint> _monthlySteps = [];
  Map<String, List<HealthDataPoint>> _stepsCache = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialMonth;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final now = DateTime.now();
      final steps = await HealthDataService().getMonthlySteps(now);

      setState(() {
        _monthlySteps = steps;
        _focusedDay = now; // keep calendar focused on today
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2025, 5, 25),
      lastDay: DateTime.now(),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      calendarStyle: const CalendarStyle(outsideDaysVisible: false),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekendStyle: TextStyle(
          fontSize: 14,
          height: 1, // Fixes clipping
        ),
        weekdayStyle: TextStyle(
          fontSize: 14,

          height: 1, // Fixes clipping
        ),
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

        final key =
            "${focusedDay.year}-${focusedDay.month.toString().padLeft(2, '0')}";

        if (_stepsCache.containsKey(key)) {
          // ✅ Already cached, just use it
          setState(() {
            _monthlySteps = _stepsCache[key]!;
          });
        } else {
          // 🔄 Not cached yet, fetch from Health
          final steps = await HealthDataService().getMonthlySteps(focusedDay);

          setState(() {
            _monthlySteps = steps;
            _stepsCache[key] = steps; // save to cache
          });
        }
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
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        headerPadding: EdgeInsets.zero,
        titleCentered: true,
        leftChevronPadding: EdgeInsets.zero,
        leftChevronIcon: LeftRightIconButton().padSymm(),
        rightChevronIcon: LeftRightIconButton().rotate(180).padSymm(),
      ),
    );
  }

  Widget _buildDayCell(
    DateTime day, {
    bool isSelected = false,
    bool isToday = false,
  }) {
    final key = DateTime(day.year, day.month, day.day);
    final dailySteps = getDailySteps(_monthlySteps);
    final steps = dailySteps[DateTime(day.year, day.month, day.day)] ?? 0;

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.transparent : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${day.day}",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "$steps",
            style: TextStyle(fontSize: 10, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Map<DateTime, int> getDailySteps(List<HealthDataPoint> data) {
    final Map<DateTime, int> stepsPerDay = {};

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

    return stepsPerDay;
  }
}
