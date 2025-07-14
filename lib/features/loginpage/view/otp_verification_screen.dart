import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pinput/pinput.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_widget.dart';
import '../../../utils/constant/color_constants.dart';
import '../../../utils/custom_text.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final otpTFC = TextEditingController();

  final focusedBorderColor = ColorConstant.primaryColor;
  final fillColor = Color.fromRGBO(243, 246, 249, 0);

  final defaultPinTheme = PinTheme(
    width: 58,
    height: 58,
    textStyle: const TextStyle(
      fontSize: 22,
      color: Color.fromRGBO(30, 60, 87, 1),
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(19),
      border: Border.all(color: ColorConstant.primaryColor),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/ic_tracure.png",
              width: 200,
            ).padOnly(b: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: CommonWidget.containerDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText.title(
                    text: "Enter Verification Code",
                    size: 22,
                    isBold: true,
                  ).padOnly(b: 8).center(),
                  CustomText.richText(
                    textSpans: [
                      TextSpan(
                        text: "Verification code sent to ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: "+91 9876543210",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Pinput(
                    controller: otpTFC,
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: focusedBorderColor),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyBorderWith(
                      border: Border.all(color: Colors.redAccent),
                    ),
                  ),
                  SizedBox(height: 16),
                  CommonWidget.roundedButton(
                    context: context,
                    title: "Generate OTP",
                    onTap: () {},
                  ),
                  SizedBox(height: 16),
                  CustomText.richText(
                    textSpans: [
                      TextSpan(
                        text: "Didn’t receive code yet? ",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextSpan(
                        text: "Resend Code",
                        style: TextStyle(
                          color: ColorConstant.primaryColor,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ).padSymm(horizontal: 40),
      ).padOnly(b: 38),
    );
  }

  Widget continueWithOptionText() {
    return Row(
      children: [
        Expanded(
          child: Divider(height: 8, thickness: 1, color: Colors.grey.shade300),
        ),
        CustomText.title(
          text: "  Or continue with  ",
          color: Color(0xff868E96),
        ),
        Expanded(
          child: Divider(height: 8, thickness: 1, color: Colors.grey.shade300),
        ),
      ],
    ).padSymm(vertical: 16);
  }
}
