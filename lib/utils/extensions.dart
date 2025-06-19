import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'constant/color_constants.dart';

extension ExtendedWidget on Widget {
  Widget padSymm({double horizontal = 0, double vertical = 0}) => Padding(
        padding: EdgeInsets.symmetric(
            horizontal: horizontal, vertical: vertical),
        child: this,
      );

  Widget padAll({double all = 0}) => Padding(
        padding: EdgeInsets.all(all),
        child: this,
      );

  Widget padOnly({double l = 0, double r = 0, double b = 0, double t = 0}) =>
      Padding(
        padding: EdgeInsets.only(left: l, right: r, bottom: b, top: t),
        child: this,
      );

  Widget visible({required bool isVisible}) =>
      (isVisible) ? this : const SizedBox.shrink();

  Widget rotate(int degree) => RotationTransition(
        turns: AlwaysStoppedAnimation(degree / 360),
        child: this,
      );

  ClipRRect clipR(double radius) => ClipRRect(
        borderRadius: BorderRadius.circular(radius.r),
        child: this,
      );

  ClipRRect clipROnly({
    double botLeft = 0,
    double botRight = 0,
    double topLeft = 0,
    double topRight = 0,
  }) =>
      ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(botLeft),
          bottomRight: Radius.circular(botRight),
          topLeft: Radius.circular(topLeft),
          topRight: Radius.circular(topRight),
        ),
        child: this,
      );

  Align align(AlignmentGeometry alignment) => Align(
        alignment: alignment,
        child: this,
      );

  Shimmer shimmer() => Shimmer.fromColors(
        baseColor: Colors.transparent,
        highlightColor: ColorConstant.primaryColor,
        child: this,
      );
}
