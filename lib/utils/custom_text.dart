import 'package:flutter/material.dart';

import 'constant/color_constants.dart';

class CustomText {
  CustomText._();

  static Widget subTitle(
      {required String text,
      double size = 12,
      Color? color,
      bool? isBold,
      int? maxLine,
      TextAlign? textAlign,
      EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: Text(text,
          overflow: TextOverflow.ellipsis,
          textAlign: textAlign,
          maxLines: maxLine,
          style: textStyle(size: size, bold: isBold, color: color)),
    );
  }

  static Widget title(
      {required String? text,
      double size = 14,
      Color? color,
      bool? isBold,
      int? maxLine,
      TextOverflow? overflow,
      TextAlign? textAlign,
      TextDecoration? decoration,
      EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: Text(text ?? "",
          overflow: overflow ?? TextOverflow.ellipsis,
          textAlign: textAlign,
          maxLines: maxLine,
          style: textStyle(
              size: size, bold: isBold, color: color, decoration: decoration)),
    );
  }

  static Widget richText({
    required List<InlineSpan> textSpans,
    TextAlign textAlign = TextAlign.start,
    TextDirection textDirection = TextDirection.ltr,
    double textScaleFactor = 1.0,
    int? maxLines,
    TextOverflow overflow = TextOverflow.clip,
    TextStyle? defaultStyle,
    BuildContext? context,
  }) {
    return RichText(
      textAlign: textAlign,
      textDirection: textDirection,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(
        style: defaultStyle ??
            (context != null ? DefaultTextStyle.of(context).style : null),
        children: textSpans,
      ),
    );
  }

  static TextStyle textStyle(
          {required double size,
          bool? bold = false,
          Color? color,
          TextDecoration? decoration}) =>
      TextStyle(
          fontSize: size,
          decoration: decoration,
          height: 1.2,
          decorationColor: color ?? ColorConstant.primaryTextColor,
          fontWeight: (bold != null && bold) ? FontWeight.w500 : null,
          color: color ?? ColorConstant.primaryTextColor);
}
