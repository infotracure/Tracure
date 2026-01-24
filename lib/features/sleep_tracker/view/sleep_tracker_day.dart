import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import 'sleep_progress_widget.dart';

class SleepTrackerDay extends StatefulWidget {
  const SleepTrackerDay({super.key});

  @override
  State<SleepTrackerDay> createState() => _SleepTrackerDayState();
}

class _SleepTrackerDayState extends State<SleepTrackerDay> {
  final sleepData = generateRandomDoubleList(48);
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        children: [
          SleepProgressWidget(currentMin: 441, goal: 10 * 60),
          activitesCardGrid(),
          // Container(
          //   decoration: CommonWidget.containerDecoration(),
          //   child: Column(children: []),
          // ),
          keyHealthBenefits(),
        ],
      ).padSymm(horizontal: 16, vertical: 16),
    );
  }

  Column activitesCardGrid() {
    final todayStep = int.tryParse("2000") ?? 0;
    final stepRemain = (todayStep > 10000) ? 0 : (10000 - todayStep);
    return Column(
      children: [
        Row(
          children: [
            tileCard("Quality", "85 %", "assets/images/ic_percentage.png"),
            SizedBox(width: 10),
            tileCard("Awakenings", "3", "assets/images/ic_sleep_awake.png"),
            SizedBox(width: 10),
            tileCard(
              "Time to fall asleep",
              "12 min",
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomText.title(
                    text: title,
                    size: 10,
                    overflow: TextOverflow.visible,
                  ),
                ),
                SizedBox(width: 4),
                Image.asset(img, height: 25),
              ],
            ),
            Spacer(),
            CustomText.title(text: value, size: 14, isBold: true),
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

class LeftRightIconButton extends StatelessWidget {
  const LeftRightIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      width: 35,
      padding: EdgeInsets.all(10),
      decoration: CommonWidget.containerDecoration(
        radius: 10,
        color: ColorConstant.primaryColor,
      ),
      child: Image.asset(
        "assets/images/arrow_back_black.png",
        color: Colors.white,
      ),
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
