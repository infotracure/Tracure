import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/ic_tracure.png", width: 200),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.title(
                  text: "Sign in to your account",
                  size: 20,
                  isBold: true,
                ).padOnly(b: 8),
                CustomText.richText(
                  textSpans: [
                    TextSpan(
                      text: "or ",
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: "start your 14-day free trial",
                      style: TextStyle(
                        color: ColorConstant.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                CustomText.title(
                  text: "Sign in with",
                  size: 14,
                  isBold: true,
                ).padSymm(vertical: 10),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(),
                          ),
                          child: Image.asset("assets/images/ic_google.png"),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(),
                          ),
                          child: Image.asset("assets/images/ic_facebook.png"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ).padSymm(horizontal: 40),
      ),
    );
  }
}
