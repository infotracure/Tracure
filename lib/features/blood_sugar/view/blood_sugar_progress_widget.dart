import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';

class GaugeWidget extends StatelessWidget {
  final double value;
  final double max;

  const GaugeWidget({super.key, required this.value, required this.max});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(250, 150), painter: GaugePainter(value / max)),
          Positioned(
            top: 50,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'mg/dL',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Last checkup\n22-June-2025',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double percentage;

  GaugePainter(this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final strokeWidth = 15.0;
    final arcRect = Rect.fromCircle(center: center, radius: radius);

    final colors = [Colors.blue, Colors.green, Colors.yellow, Colors.orange];
    final steps = 100; // more steps = smoother arc
    final startAngle = pi;
    final sweepAngle = pi;

    for (int i = 0; i < steps; i++) {
      double t = i / steps;
      double nextT = (i + 1) / steps;
      final color = interpolateGradientColor(colors, t);
      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final currentSweep = sweepAngle / steps;

      canvas.drawArc(
        arcRect,
        startAngle + currentSweep * i,
        currentSweep,
        false,
        paint,
      );
    }

    // Draw dot indicator
    final angle = startAngle + sweepAngle * percentage;
    final knobRadius = 8.0;
    final knobX = center.dx + radius * cos(angle);
    final knobY = center.dy + radius * sin(angle);

    final knobColor = interpolateGradientColor(
      colors,
      percentage.clamp(0.0, 1.0),
    );

    canvas.drawCircle(
      Offset(knobX, knobY),
      knobRadius + 2,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(knobX, knobY),
      knobRadius,
      Paint()..color = knobColor,
    );
  }

  Color interpolateGradientColor(List<Color> colors, double t) {
    if (colors.isEmpty) return Colors.black;
    if (t <= 0.0) return colors.first;
    if (t >= 1.0) return colors.last;

    double scaledT = t * (colors.length - 1);
    int i = scaledT.floor();
    double localT = scaledT - i;

    Color c1 = colors[i];
    Color c2 = colors[i + 1];

    return Color.lerp(c1, c2, localT)!;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
