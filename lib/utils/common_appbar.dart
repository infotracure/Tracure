import 'package:flutter/material.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/extensions.dart';

import '../utils/custom_text.dart';

class CustomAppbar extends StatelessWidget implements PreferredSize {
  const CustomAppbar({
    super.key,
    required this.title,
    this.bgColor = Colors.white,
  });
  final String title;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: bgColor,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 40,
                width: 40,
                padding: EdgeInsets.all(12),
                child: Image.asset("assets/images/arrow_back_black.png"),
              ),
            ).padSymm(horizontal: 10, vertical: 10),
            Center(
              child: CustomText.title(text: title, size: 16, isBold: true),
            ),
            const SizedBox(
              height: 40,
              width: 40,
            ).padSymm(horizontal: 10, vertical: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget get child => this;

  @override
  Size get preferredSize => Size.fromHeight(60);
}
