import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tracure/features/homepage/view/homepage.dart';
import 'package:tracure/features/loginpage/view/otp_verification_screen.dart';
import 'package:tracure/features/register_screen/view/register_screen.dart';
import 'package:tracure/servies/hive_service.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';
import 'package:tracure/utils/text_field_validator.dart';

import '../controller/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final loginContoller = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/images/ic_tracure.png",
                width: 200,
              ).padOnly(b: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                decoration: CommonWidget.containerDecoration(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText.title(
                      text: "Sign in to your account",
                      size: 22,
                      isBold: true,
                    ).padOnly(b: 8).center(),
                    // CustomText.richText(
                    //   textSpans: [
                    //     TextSpan(
                    //       text: "or ",
                    //       style: TextStyle(color: Colors.black),
                    //     ),
                    //     TextSpan(
                    //       text: "Register to start your 14-day free trial",
                    //       style: TextStyle(
                    //         color: ColorConstant.primaryColor,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //       recognizer: TapGestureRecognizer()
                    //         ..onTap = () {
                    //           CommonWidget.pushTo(context, RegisterScreen());
                    //         },
                    //     ),
                    //   ],
                    // ),
                    // CustomText.title(
                    //   text: "Sign in with",
                    //   size: 14,
                    //   isBold: true,
                    // ).padSymm(vertical: 10),
                    // googleFbLoginBtn(),
                    // continueWithOptionText(),
                    SizedBox(height: 30),
                    Form(
                      key: loginContoller.formKeyMobile,
                      child: CommonWidget.customTextField(
                        "Enter Mobile Number",
                        maxLength: 10,
                        controller: loginContoller.mobileTFC,
                        validator: TextfieldValidator.validateMobile,
                        keyboardType: TextInputType.number,
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    SizedBox(height: 16),
                    CommonWidget.roundedButton(
                      context: context,
                      title: "Generate OTP",
                      onTap: () => loginContoller.validateAndSubmit(),
                    ),
                  ],
                ),
              ),
            ],
          ).padSymm(horizontal: 40),
        ),
      ),
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

  SizedBox googleFbLoginBtn() {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: GoogleFacebookTile(img: "assets/images/ic_google.png"),
          ),
          SizedBox(width: 10),
          Expanded(
            child: GoogleFacebookTile(img: "assets/images/ic_facebook.png"),
          ),
        ],
      ),
    );
  }
}

class GoogleFacebookTile extends StatelessWidget {
  const GoogleFacebookTile({super.key, this.onTap, required this.img});
  final void Function()? onTap;
  final String img;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Color(0xffADB5BD)),
        ),
        child: Image.asset(img),
      ),
    );
  }
}
