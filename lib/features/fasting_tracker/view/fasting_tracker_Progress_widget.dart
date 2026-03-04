import 'dart:math';

import 'package:flutter/material.dart';

const Color _fastingRed = Color(0xFFE53935);
const Color _fastingPinkBg = Color(0xFFFCE4EC);

class FastingProgressWidget extends StatelessWidget {
  final int elapsedHours;
  final int goalHours;
  final String timerText;
  final bool isFasting;
  final double progress;

  const FastingProgressWidget({
    super.key,
    required this.elapsedHours,
    required this.goalHours,
    required this.timerText,
    required this.isFasting,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: _fastingPinkBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: _FastingCirclePainter(
              progress: progress,
              isFasting: isFasting,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isFasting)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: _fastingRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  const SizedBox(height: 4),
                  const Icon(Icons.favorite, color: Colors.pinkAccent, size: 28),
                  const SizedBox(height: 4),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$elapsedHours',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: ' / $goalHours',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'HRS',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFasting ? timerText : '0 bpm',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isFasting ? _fastingRed : Colors.teal,
                    ),
                  ),
                  Text(
                    isFasting ? 'In Progress' : 'Ready to Start',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FastingCirclePainter extends CustomPainter {
  final double progress;
  final bool isFasting;

  _FastingCirclePainter({required this.progress, required this.isFasting});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = _fastingPinkBg
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // White track
    final trackPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      // Progress arc
      final progressPaint = Paint()
        ..color = _fastingRed
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      final sweepAngle = 2 * pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Red dot at progress tip
      if (isFasting) {
        final dotAngle = -pi / 2 + sweepAngle;
        final dotX = center.dx + radius * cos(dotAngle);
        final dotY = center.dy + radius * sin(dotAngle);
        final dotPaint = Paint()..color = _fastingRed;
        canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2 + 2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FastingCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isFasting != isFasting;
  }
}
