import 'package:flutter/material.dart';
import 'dart:math';

class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final Color progressColor;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.percentage,
    this.progressColor = Colors.green,
    this.backgroundColor = const Color(0xFFE0F2F1),
  });

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 8;
    double radius = (size.width / 2) - strokeWidth;

    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final foregroundPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw background circle
    canvas.drawArc(rect, 0, 2 * pi, false, backgroundPaint);

    // Draw progress arc
    double sweepAngle = 2 * pi * percentage;
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class CircularProgressWidget extends StatelessWidget {
  final double percent;

  const CircularProgressWidget({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(80, 80),
            painter: CircularProgressPainter(percentage: percent),
          ),
          Text(
            "${(percent * 100).round()}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
