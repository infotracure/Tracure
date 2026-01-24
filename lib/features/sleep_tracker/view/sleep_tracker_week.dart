import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:tracure/features/sleep_tracker/view/sleep_tracker_day.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';
import 'package:tracure/utils/string_extension.dart';

class SleepTrackerWeek extends StatefulWidget {
  const SleepTrackerWeek({super.key});

  @override
  State<SleepTrackerWeek> createState() => _SleepTrackerWeekState();
}

class _SleepTrackerWeekState extends State<SleepTrackerWeek> {
  final sleepData = [4000.0, 1000.0, 3000.0, 9000.0, 3000.0, 2000.0, 0.0];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
                SizedBox(
                  height: 210,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 150,
                        child: WeekBarChart(data: sleepData),
                      ),
                      CommonWidget.roundedButton(
                            context: context,
                            titleColor: ColorConstant.primaryColor,
                            bgColor: Color(0xffC8E2F9),
                            title: "View Monthly Record",
                            padding: EdgeInsets.symmetric(vertical: 10),
                            elevation: 0,
                            prefixIcon: Icon(
                              Icons.calendar_month,
                              color: ColorConstant.primaryColor,
                              size: 20,
                            ),
                            onTap: () {},
                            // onTap: () => showRoundedBottomSheet(
                            //   context: context,
                            //   child: CustomCalendar(
                            //     initialMonth: DateTime.now(),
                            //   ),
                            // ),
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
    );
  }

  Column activitesCardGrid() {
    final todayStep = 0;
    final stepRemain = (todayStep > 10000) ? 0 : (10000 - todayStep);
    return Column(
      children: [
        Row(
          children: [
            tileCard(
              "Avg. Bedtime",
              stepRemain.toString().toFormattedNumber(),
              "assets/images/tabler_activity.png",
            ),
            SizedBox(width: 10),
            tileCard(
              "Avg. WakeUp",
              "2.3km",
              "assets/images/material-symbols_distance-outline.png",
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            tileCard(
              "Time of fall asleep",
              "32 min",
              "assets/images/mingcute_time-line.png",
            ),
            SizedBox(width: 10),
            tileCard(
              "Sleep Efficiency",
              "${"4785".toFormattedNumber()} cal",
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
