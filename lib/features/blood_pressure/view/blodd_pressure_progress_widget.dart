import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';

class BloodPressureProgressWidget extends StatefulWidget {
  final int sys;
  final int dia;

  const BloodPressureProgressWidget({required this.sys, required this.dia});

  @override
  _BloodPressureProgressWidgetState createState() =>
      _BloodPressureProgressWidgetState();
}

class _BloodPressureProgressWidgetState
    extends State<BloodPressureProgressWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = 0;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset("assets/images/ic_blood_pressure_heart.png", width: 160),
          CustomPaint(
            size: const Size(200, 200),
            painter: CircleBorderPainter(percentage),
          ),

          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${widget.sys}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ColorConstant.bloodPressureGlobal,
                      ),
                    ),
                    TextSpan(
                      text: " sys",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${widget.dia}",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: ColorConstant.bloodPressureGlobal,
                      ),
                    ),
                    TextSpan(
                      text: " dia",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              // CustomText.title(
              //   text: "+Add Water",
              //   color: Colors.blueAccent,
              //   isBold: true,
              //   size: 16,
              // ),
            ],
          ),
          Positioned(
            bottom: 25,
            child: CustomText.title(
              text: "Last checkup",
              size: 8,
              color: ColorConstant.grayTextColor,
            ),
          ),
          Positioned(
            bottom: 15,
            child: CustomText.title(
              text: "22-June-2025",
              size: 8,
              color: ColorConstant.grayTextColor,
            ),
          ),
        ],
      ),
    );
  }
}

class CircleBorderPainter extends CustomPainter {
  final double percentage;

  CircleBorderPainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 6.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFADC2E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..shader = LinearGradient(
        colors: [Color(0xFFADC2E8), ColorConstant.bloodPressureGlobal],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    double sweepAngle = 2 * pi * percentage;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
