import 'package:flutter/material.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_widget.dart';
import '../../loginpage/view/otp_verification_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  final mobileTFC = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image.asset(
              //   "assets/images/ic_tracure.png",
              //   width: 200,
              // ).padOnly(b: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: CommonWidget.containerDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    CustomText.title(
                      text: "Register",
                      size: 22,
                      isBold: true,
                    ).padOnly(b: 8).center(),

                    CommonWidget.customTextField(
                      "First Name",
                      controller: mobileTFC,
                      keyboardType: TextInputType.name,
                      prefixIcon: Icon(Icons.person),
                    ),
                    CommonWidget.customTextField(
                      "Last Name",
                      controller: mobileTFC,
                      keyboardType: TextInputType.name,
                      prefixIcon: Icon(Icons.person),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CommonWidget.customTextField(
                            "Gender",
                            controller: mobileTFC,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CommonWidget.customTextField(
                            "DOB",
                            controller: mobileTFC,
                            keyboardType: TextInputType.number,
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                        ),
                      ],
                    ),
                    CommonWidget.customTextField(
                      "Email",
                      controller: mobileTFC,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email),
                    ),
                    CommonWidget.customTextField(
                      "Mobile Number",
                      controller: mobileTFC,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icon(Icons.phone),
                    ),
                    CommonWidget.roundedButton(
                      context: context,
                      title: "Register",
                      onTap: () {
                        CommonWidget.pushTo(context, OTPVerificationScreen());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ).padSymm(horizontal: 20),
        ),
      ),
    );
  }
}
