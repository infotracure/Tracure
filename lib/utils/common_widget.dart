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
    TextEditingController? controller,
    FormFieldValidator<String>? validator,
    String? initVal,
    int? maxLength,
    bool readOnly = false,
    Function()? onTap,
    Widget? prefixIcon,
    Widget? suffixIcon,
    String? suffixText,

    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      onTap: onTap,
      initialValue: initVal,
      readOnly: readOnly,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: TextCapitalization.sentences,
      validator: validator,
      decoration: InputDecoration(
        // labelText: hint,
        counter: SizedBox.shrink(),
        hintText: hint,
        filled: true,
        fillColor: Color(0xffE9ECEF),
        hintStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        errorStyle: CustomText.textStyle(size: 14, color: ColorConstant.red),
        isDense: true,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40, // default ~48, reduce to make tighter
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
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

  static Widget customDropdown<T>(
    String hint, {
    T? value,
    required List<DropdownMenuItem<T>> items,
    FormFieldValidator<T>? validator,
    ValueChanged<T?>? onChanged,
    Widget? prefixIcon,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      decoration: InputDecoration(
        counter: const SizedBox.shrink(),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xffE9ECEF),

        labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
        errorStyle: CustomText.textStyle(size: 14, color: ColorConstant.red),
        isDense: true,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40, // default ~48, reduce to make tighter
        ),
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
      items: items,
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_back_ios_new, size: 16).rotate(-90),
      style: const TextStyle(fontSize: 14, color: Colors.black),
      dropdownColor: const Color(0xffE9ECEF),
      borderRadius: BorderRadius.circular(16),
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
    double? elevation,
    Widget? prefixIcon,

    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          backgroundColor: bgColor,
          // minimumSize: Size(120.w, 40),
          padding:
              padding ?? EdgeInsets.symmetric(vertical: 12, horizontal: 42),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ?prefixIcon,
            SizedBox(width: 8).visible(isVisible: prefixIcon != null),
            CustomText.title(text: title, color: titleColor, size: textsize),
          ],
        ),
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
    bool isShadow = true,
  }) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      image: (imgUrl != null)
          ? DecorationImage(fit: BoxFit.cover, image: NetworkImage(imgUrl))
          : null,
      boxShadow: (isShadow)
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
