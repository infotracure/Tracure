import 'package:flutter/material.dart';

import 'constant/color_constants.dart';

/// Usage:
/// Center(child: ThreeDotLoading());
class ThreeDotLoading extends StatefulWidget {
  const ThreeDotLoading({
    super.key,
    this.color = ColorConstant.primaryTextColor,
    this.dotSize = 8.0,
    this.gap = 8.0,
    this.duration = const Duration(milliseconds: 1200),
    this.semanticLabel = 'Loading',
  });

  final Color color;
  final double dotSize;
  final double gap;
  final Duration duration;
  final String semanticLabel;

  @override
  State<ThreeDotLoading> createState() => _ThreeDotLoadingState();
}

class _ThreeDotLoadingState extends State<ThreeDotLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  // A scale wave: up -> down
  TweenSequence<double> get _pulse => TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.35,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.35,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 50,
    ),
  ]);

  Animation<double> _stagger(double start, double end) {
    return _pulse.animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.linear),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _dot(Animation<double> scale) {
    return ScaleTransition(
      scale: scale,
      child: Container(
        width: widget.dotSize,
        height: widget.dotSize,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3 staggered intervals across the loop
    final a1 = _stagger(0.00, 0.60);
    final a2 = _stagger(0.20, 0.80);
    final a3 = _stagger(0.40, 1.00);

    return Semantics(
      label: widget.semanticLabel,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(a1),
          SizedBox(width: widget.gap),
          _dot(a2),
          SizedBox(width: widget.gap),
          _dot(a3),
        ],
      ),
    );
  }
}
