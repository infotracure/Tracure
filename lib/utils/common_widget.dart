import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

class CommonWidget {
  static Future<dynamic> pushTo(BuildContext context, Widget? screen) async {
    if (screen == null) return;
    return await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static Future<dynamic> pop(BuildContext context) async {
    return Navigator.pop(context);
  }

  static Future<dynamic> replaceWith(
    BuildContext context,
    Widget? screen,
  ) async {
    if (screen == null) return;
    return await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  static Widget customTextFieldWithLabel(
    String label,
    String hint, {
    TextInputType? keyboardType,
    required TextEditingController controller,
    Function(String, String)? validator,
    String? initVal,
    Color? labelColor = ColorConstant.primaryTextColor,
    bool readOnly = false,
    EdgeInsetsGeometry? contentPadding = const EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 15,
    ),
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(text: label, color: labelColor).padOnly(l: 4, b: 8),
        TextFormField(
          controller: controller,
          initialValue: initVal,
          readOnly: readOnly,
          // autovalidateMode: AutovalidateMode.onUserInteraction,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: TextCapitalization.sentences,
          validator: (value) {
            if (validator != null) {
              return validator(value ?? "", hint);
            }
            if (value!.trim().isEmpty) return "Please $hint";
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade500),
            fillColor: Colors.white,
            filled: true,
            labelStyle: TextStyle(color: Colors.grey.shade700),
            errorStyle: CustomText.textStyle(
              size: 10,
              color: ColorConstant.red,
            ),
            // isDense: true,
            contentPadding: contentPadding,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: ColorConstant.primaryColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ColorConstant.red),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ColorConstant.red),
            ),
          ),
        ),
      ],
    );
  }

  static Widget customTextField(
    String hint, {
    TextInputType? keyboardType,
    required TextEditingController controller,
    Function(String, String)? validator,
    String? initVal,
    Widget? prefixIcon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: initVal,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.name,
      inputFormatters: inputFormatters,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (validator != null) {
          return validator(value ?? "", hint);
        }
        if (value!.trim().isEmpty) return "Please Enter $hint";
        return null;
      },
      decoration: InputDecoration(
        // labelText: hint,
        hintText: hint,
        filled: true,
        fillColor: Color(0xffDEE2E6),
        labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        errorStyle: CustomText.textStyle(size: 10, color: ColorConstant.red),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        prefixIcon: prefixIcon,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static Widget roundedButton({
    required BuildContext context,
    required String title,
    EdgeInsets? padding,
    double borderRadius = 10,
    Color? bgColor = ColorConstant.primaryColor,
    Color? titleColor = Colors.white,
    double textsize = 16,
    double? width,

    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          // minimumSize: Size(120.w, 40),
          padding:
              padding ?? EdgeInsets.symmetric(vertical: 12, horizontal: 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onTap,
        child: CustomText.title(text: title, color: titleColor, size: textsize),
      ),
    );
  }

  static Widget roundedBtnWithIcon({
    required String title,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          color: ColorConstant.primaryColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                icon,
                height: 20,
                width: 20,
                color: ColorConstant.primaryColor,
              ),
            ),
            CustomText.title(
              text: title,
              color: Colors.white,
            ).padOnly(l: 10, r: 20),
          ],
        ),
      ),
    );
  }

  static BoxDecoration containerDecoration({
    String? imgUrl,
    Color? color,
    double radius = 10,
    bool boolShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      image: (imgUrl != null)
          ? DecorationImage(fit: BoxFit.cover, image: NetworkImage(imgUrl))
          : null,
      boxShadow: (boolShadow)
          ? [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ]
          : [],
    );
  }

  static showToast(String text, {int maxLine = 2, int seconds = 2}) {
    // Get.closeCurrentSnackbar();

    Get.snackbar(
      "",
      "",
      titleText: CustomText.title(
        text: text,
        size: 15,
        maxLine: maxLine,
        isBold: true,
        color: Colors.black87,
      ),
      messageText: const SizedBox(),
      duration: Duration(seconds: seconds),
      margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
