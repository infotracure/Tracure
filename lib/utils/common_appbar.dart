import 'package:flutter/material.dart';
import 'package:tracure/utils/common_widget.dart';

import '../utils/custom_text.dart';

class CustomAppbar extends StatelessWidget implements PreferredSize {
  const CustomAppbar({
    super.key,
    required this.title,
    this.bgColor = Colors.white,
    this.trailing,
  });
  final String title;
  final Color bgColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: SafeArea(
        child: Container(
          color: bgColor,
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: double.infinity,
                  width: 60,
                  padding: EdgeInsets.all(22),
                  child: Image.asset("assets/images/arrow_back_black.png"),
                ),
              ),
              Expanded(
                child: Center(
                  child: CustomText.title(text: title, size: 16, isBold: true),
                ),
              ),
              if (trailing != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: trailing!,
                )
              else
                const SizedBox(width: 60),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget get child => this;

  @override
  Size get preferredSize => Size.fromHeight(60);
}
