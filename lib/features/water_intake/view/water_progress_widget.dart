import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';

class WaterProgressWidget extends StatefulWidget {
  final int current;
  final int goal;

  const WaterProgressWidget({required this.current, required this.goal});

  @override
  _WaterProgressWidgetState createState() => _WaterProgressWidgetState();
}

class _WaterProgressWidgetState extends State<WaterProgressWidget>
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
    double percentage = widget.current / widget.goal;
    String percentageText = ((widget.current / widget.goal) * 100)
        .toStringAsFixed(0);

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Water Wave (inside circle)
          ClipOval(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(200, 200),
                  painter: WaterWavePainter(
                    animationValue: _controller.value,
                    percentage: percentage,
                  ),
                );
              },
            ),
          ),

          // 2. Circular Border (on top of wave)
          CustomPaint(
            size: const Size(200, 200),
            painter: CircleBorderPainter(percentage),
          ),

          // 3. Text Content (centered)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 40),
              Text(
                "${widget.current}ml",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.primaryTextColor,
                ),
              ),
              Text(
                "of ${widget.goal}ml",
                style: const TextStyle(
                  fontSize: 16,
                  color: ColorConstant.primaryTextColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '$percentageText%',
                style: TextStyle(
                  fontSize: 24,
                  color: ColorConstant.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
            ],
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
    final strokeWidth = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFADC2E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..shader = LinearGradient(
        colors: [ColorConstant.primaryColor, ColorConstant.primaryColor],
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

class WaterWavePainter extends CustomPainter {
  final double animationValue;
  final double percentage;

  WaterWavePainter({required this.animationValue, required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final waveHeight = 10.0;
    final waveLength = size.width;

    final baseHeight = size.height * (1 - percentage);

    final path = Path()..moveTo(0, baseHeight);
    for (double i = 0; i <= size.width; i++) {
      double dx = i;
      double dy =
          waveHeight *
          sin((i / waveLength * 2 * pi) + (animationValue * 2 * pi));
      path.lineTo(dx, baseHeight + dy);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    final paint = Paint()..color = Color(0xFFB9E0FF);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaterWavePainter oldDelegate) => true;
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
