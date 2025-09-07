import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tracure/features/step_tracker/view/step_tracker_day.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

class BloodPressureWeek extends StatefulWidget {
  const BloodPressureWeek({super.key});

  @override
  State<BloodPressureWeek> createState() => _BloodPressureWeekState();
}

class _BloodPressureWeekState extends State<BloodPressureWeek> {
  final stepData = [4000.0, 1000.0, 3000.0, 9000.0, 3000.0, 2000.0, 0.0];
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
                  LeftRightIconButton().padSymm(horizontal: 10, vertical: 10),
                  CustomText.title(
                    text: "Tuesday, 10 June 2025",
                    isBold: true,
                    size: 14,
                  ),
                  LeftRightIconButton()
                      .rotate(180)
                      .padSymm(horizontal: 10, vertical: 10),
                ],
              ),
              SizedBox(height: 8),
              SizedBox(height: 150, child: WeekBarChart(data: stepData)),
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
                label: "Avg Sys",
                img: "assets/images/emojione_running-shoe.png",
                color: Color(0xFFFAB005),
                value: "130",
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
                label: "Avg Dia",
                img: "assets/images/emojione_running-shoe.png",
                color: ColorConstant.verdigris,
                value: "60",
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

class WeekBarChart extends StatelessWidget {
  final List<double> data;

  const WeekBarChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const hourLabels = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    const maxY = 10000.0;
    return BarChart(
      BarChartData(
        maxY: maxY,
        // minY: 0,
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
          data.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].isFinite ? data[i] : 0,
                color: ColorConstant.primaryColor,
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
