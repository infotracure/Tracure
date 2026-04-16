import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/string_extension.dart';

class StepProgressWidget extends StatefulWidget {
  final int current;
  final int goal;
  final String unit;

  const StepProgressWidget({
    super.key,
    required this.current,
    required this.goal,
    this.unit = 'steps',
  });

  @override
  _StepProgressWidgetState createState() => _StepProgressWidgetState();
}

class _StepProgressWidgetState extends State<StepProgressWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double percentage = widget.current / widget.goal;

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 2. Circular Border (on top of wave)
          CustomPaint(
            size: const Size(200, 200),
            painter: CircleBorderPainter(percentage, ColorConstant.verdigris),
          ),

          // 3. Text Content (centered)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              CustomText.title(
                text: "${widget.current}".toFormattedNumber(),
                isBold: true,
                size: 25,
                color: ColorConstant.verdigris,
              ),
              const SizedBox(height: 5),
              CustomText.title(
                text: "${"${widget.goal}".toFormattedNumber()} ${widget.unit}",
                isBold: true,
                size: 12,
              ),
              const SizedBox(height: 10),
              CustomText.title(
                text: "${getPercentageValue()}%",
                color: ColorConstant.verdigris,
                isBold: true,
                size: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getPercentageValue() {
    double percentageValue = ((widget.current / widget.goal) * 100);
    return percentageValue > 100
        ? 100.toStringAsFixed(1)
        : percentageValue.toStringAsFixed(1);
  }
}

class CircleBorderPainter extends CustomPainter {
  final double percentage;
  final Color color;

  CircleBorderPainter(this.percentage, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 15.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = color.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color],
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

class SemiCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(rect, pi, pi, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
