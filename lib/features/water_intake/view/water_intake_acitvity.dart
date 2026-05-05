import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_overview.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_methods.dart';
import '../../step_tracker/view/view_monthly_bottom_sheet.dart';
import '../controller/water_intake_controller.dart';
import 'water_intake_month.dart';

class WaterIntakeActivity extends StatefulWidget {
  const WaterIntakeActivity({super.key});

  @override
  State<WaterIntakeActivity> createState() => _WaterIntakeActivityState();
}

class _WaterIntakeActivityState extends State<WaterIntakeActivity> {
  final waterController = Get.find<WaterIntakeController>();
  DateTime _selectedWeek = DateTime.now();
  List<double> _weeklyWater = List.filled(7, 0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadWeeklyWater(_selectedWeek);
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
                        iconColor: ColorConstant.waterGlobal,
                        onTap: () {
                          setState(() {
                            _selectedWeek = _selectedWeek.subtract(
                              Duration(days: 7),
                            );
                            _loadWeeklyWater(_selectedWeek);
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
                              iconColor: ColorConstant.waterGlobal,
                              onTap: () {
                                setState(() {
                                  _selectedWeek = _selectedWeek.add(
                                    Duration(days: 7),
                                  );
                                  _loadWeeklyWater(_selectedWeek);
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
                          child: WeekBarChart(data: _weeklyWater),
                        ),
                        CommonWidget.roundedButton(
                              context: context,
                              titleColor: ColorConstant.waterGlobal,
                              bgColor: ColorConstant.backgroundColor,
                              title: "View Monthly Record",
                              padding: EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                              prefixIcon: Icon(
                                Icons.calendar_month,
                                color: ColorConstant.waterGlobal,
                                size: 20,
                              ),
                              onTap: () async {
                                await waterController.getMonthlyWaterSummary(
                                  DateTime.now(),
                                );
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
            stepDistanceWidget(),
            keyHealthBenefits(),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      );
    });
  }

  Future<void> _loadWeeklyWater(DateTime weekDate) async {
    final start = startOfWeek(weekDate);
    final end = endOfWeek(weekDate);
    final dateFormat = DateFormat('yyyy-MM-dd');

    // Call API to fetch weekly data
    await waterController.getWeeklyWaterSummary(
      dateFormat.format(start),
      dateFormat.format(end),
    );

    // Map API data to _weeklyWater list
    final apiData = waterController.weeklyWaterSummary.value?.data ?? [];

    // Create a map of date -> totalMl for quick lookup
    final Map<DateTime, int> waterPerDay = {};
    for (var datum in apiData) {
      if (datum.summaryDate != null) {
        final date = _normalizeDate(datum.summaryDate!);
        final ml = datum.totalMl ?? 0;
        waterPerDay[date] = ml < 0 ? 0 : ml;
      }
    }

    // Build the 7-day list (Monday to Sunday)
    List<double> result = [];
    for (int i = 0; i < 7; i++) {
      final date = _normalizeDate(start.add(Duration(days: i)));
      result.add((waterPerDay[date] ?? 0).toDouble());
    }

    if (mounted) {
      setState(() {
        _weeklyWater = result;
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

  SizedBox stepDistanceWidget() {
    final avgDailyIntake =
        waterController.waterStats.value?.data?.avgDailyMl ?? 0;
    final dailyTarget =
        waterController.waterStats.value?.data?.dailyTargetMl ?? 0;
    return SizedBox(
      height: 60,
      child: Container(
        decoration: CommonWidget.containerDecoration(),
        child: Row(
          children: [
            Expanded(
              child: iconLabelCard(
                label: "Avg Daily Intake",
                img: "assets/images/emojione_running-shoe.png",
                color: Color(0xFFFAB005),
                value: "$avgDailyIntake ml",
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
                label: "Goal",
                img: "assets/images/emojione_running-shoe.png",
                color: ColorConstant.waterGlobal,
                value: "$dailyTarget ml",
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

  Widget keyHealthBenefits() {
    var benefitList = [
      {
        "icon": "assets/images/ic_heart.png",
        "title": "Heart Health",
        "subTitle": "Improves blood circulation by 20%",
      },
      {
        "icon": "assets/images/ic_mental_clarity.png",
        "title": "Brain Function",
        "subTitle": "Boosts cognitive performance by 30%",
      },
      {
        "icon": "assets/images/ic_energy_boost.png",
        "title": "Energy Levels",
        "subTitle": "Increases daily energy by 25%",
      },
      {
        "icon": "assets/images/ic_immune_system.png",
        "title": "Detoxification",
        "subTitle": "Helps flush toxins effectively",
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
}

class WeekBarChart extends StatefulWidget {
  final List<double> data;

  const WeekBarChart({super.key, required this.data});

  @override
  State<WeekBarChart> createState() => _WeekBarChartState();
}

class _WeekBarChartState extends State<WeekBarChart> {
  double _calculateMaxY() {
    if (widget.data.isEmpty) return 3000.0;

    final maxVal = widget.data.reduce((a, b) => a > b ? a : b);
    if (maxVal <= 3000) return 3000.0;

    // round up to nearest 500
    return ((maxVal / 500).ceil() * 500).toDouble();
  }

  String _formatWaterValue(int ml) {
    if (ml >= 1000) {
      return '${(ml / 1000).toStringAsFixed(1)}L';
    }
    return '${ml}ml';
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
                _formatWaterValue(rod.toY.toInt()),
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
                  _formatWaterValue(value.toInt()),
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
          widget.data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: widget.data[i].isFinite ? widget.data[i] : 0,
                color: ColorConstant.waterGlobal,
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
