import 'dart:math';

import 'package:flutter/material.dart';

class BloodSugarGaugeWidget extends StatelessWidget {
  final double value;
  final String mealType;
  final String date;

  const BloodSugarGaugeWidget({
    super.key,
    required this.value,
    this.mealType = "After Meal",
    this.date = "Jun 22, 2025",
  });

  Color _getStatusColor() {
    if (value < 70) return Colors.blue;
    if (value <= 140) return Colors.green;
    if (value <= 199) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 280,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(280, 180),
                painter: BloodSugarGaugePainter(value: value, maxValue: 300),
              ),
              Positioned(
                bottom: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                    Text(
                      'mg/dL',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('✨ ', style: TextStyle(fontSize: 12)),
                        Text(
                          mealType,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendItem(Colors.blue, "Low"),
            const SizedBox(width: 16),
            _legendItem(Colors.green, "Normal"),
            const SizedBox(width: 16),
            _legendItem(Colors.amber, "Elevated"),
            const SizedBox(width: 16),
            _legendItem(Colors.red, "High"),
          ],
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}

class BloodSugarGaugePainter extends CustomPainter {
  final double value;
  final double maxValue;

  BloodSugarGaugePainter({required this.value, this.maxValue = 300});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = size.width / 2 - 30;
    const strokeWidth = 18.0;

    final startAngle = pi;
    final sweepAngle = pi;

    // Draw gradient arc with colors aligned to blood sugar ranges
    // Range boundaries as percentages of maxValue (300):
    // Low: 0-70 (0% - 23.3%), Normal: 70-140 (23.3% - 46.7%)
    // Elevated: 140-200 (46.7% - 66.7%), High: 200-300 (66.7% - 100%)

    // Draw arc in small segments for smooth gradient effect
    const steps = 100;
    for (int i = 0; i < steps; i++) {
      final t = i / steps;

      final color = _getColorForPosition(t);
      final paint = Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;

      final segmentStart = startAngle + sweepAngle * t;
      final segmentSweep = sweepAngle / steps;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        segmentStart,
        segmentSweep + 0.01, // Small overlap to avoid gaps
        false,
        paint,
      );
    }

    // Draw tick marks and labels
    final tickValues = [40, 70, 140, 200, 300];
    final tickRadius = radius + 25;
    final innerTickRadius = radius + 8;

    for (var tickValue in tickValues) {
      final tickPercent = tickValue / maxValue;
      final tickAngle = startAngle + sweepAngle * tickPercent;

      // Draw tick line
      final tickPaint = Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = 1.5;

      final innerX = center.dx + innerTickRadius * cos(tickAngle);
      final innerY = center.dy + innerTickRadius * sin(tickAngle);
      final outerX = center.dx + (innerTickRadius + 6) * cos(tickAngle);
      final outerY = center.dy + (innerTickRadius + 6) * sin(tickAngle);

      canvas.drawLine(
        Offset(innerX, innerY),
        Offset(outerX, outerY),
        tickPaint,
      );

      // Draw tick label
      final labelX = center.dx + tickRadius * cos(tickAngle);
      final labelY = center.dy + tickRadius * sin(tickAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: tickValue.toString(),
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
      );
    }

    // Draw indicator ball
    final clampedValue = value.clamp(0.0, maxValue);
    final indicatorPercent = clampedValue / maxValue;
    final indicatorAngle = startAngle + sweepAngle * indicatorPercent;
    final indicatorX = center.dx + radius * cos(indicatorAngle);
    final indicatorY = center.dy + radius * sin(indicatorAngle);

    // Get indicator color based on value
    // Low: < 70, Normal: 70-140, Elevated: 141-199, High: >= 200
    Color indicatorColor;
    if (value < 70) {
      indicatorColor = Colors.blue;
    } else if (value <= 140) {
      indicatorColor = Colors.green;
    } else if (value <= 199) {
      indicatorColor = Colors.amber;
    } else {
      indicatorColor = Colors.red;
    }

    // White border
    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      12,
      Paint()..color = Colors.white,
    );
    // Colored center
    canvas.drawCircle(
      Offset(indicatorX, indicatorY),
      9,
      Paint()..color = indicatorColor,
    );
  }

  // Get color based on position (t = 0 to 1) mapped to blood sugar ranges
  // Ranges: Low (<70), Normal (70-140), Elevated (140-200), High (>200)
  Color _getColorForPosition(double t) {
    // Convert t (0-1) to actual value (0-300)
    final value = t * maxValue;

    // Range boundaries
    const lowEnd = 70.0;
    const normalEnd = 140.0;
    const elevatedEnd = 200.0;

    // Solid colors for each zone without transitions
    if (value < lowEnd) {
      return Colors.blue;
    } else if (value < normalEnd) {
      return Colors.green;
    } else if (value < elevatedEnd) {
      return Colors.amber;
    } else {
      return Colors.red;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
