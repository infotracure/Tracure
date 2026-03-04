import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';
import 'package:tracure/utils/text_field_validator.dart';

import '../../../utils/common_widget.dart';
import '../../loginpage/view/otp_verification_screen.dart';
import '../controller/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final registerController = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: registerController.formKey,
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
                        controller: registerController.fnameController,
                        keyboardType: TextInputType.name,
                        validator: TextfieldValidator.validateName,
                        prefixIcon: Image.asset(
                          "assets/images/ic_personEdit.png",
                          scale: 2.8,
                        ),
                      ),
                      CommonWidget.customTextField(
                        "Last Name",
                        controller: registerController.lnameController,
                        validator: TextfieldValidator.validateName,
                        keyboardType: TextInputType.name,
                        prefixIcon: Image.asset(
                          "assets/images/ic_personEdit.png",
                          scale: 2.8,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CommonWidget.customDropdown(
                              "Gender",
                              prefixIcon: Image.asset(
                                "assets/images/ic_gender.png",
                                scale: 2.8,
                              ),
                              onChanged: (value) =>
                                  registerController.gender.value = value ?? "",
                              validator: TextfieldValidator.validateGender,
                              items: ["Male", "Female"]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: CommonWidget.customTextField(
                              "DOB",
                              readOnly: true,
                              controller: registerController.dobController,
                              keyboardType: TextInputType.number,
                              validator: TextfieldValidator.validateDob,
                              prefixIcon: Image.asset(
                                "assets/images/ic_dob.png",
                                scale: 2.8,
                              ),
                              onTap: () async {
                                final now = DateTime.now();
                                final pickedDate = await showDatePicker(
                                  context:
                                      context, // 👈 use your global key or pass context
                                  initialDate: now,
                                  firstDate: now.subtract(
                                    Duration(days: 365 * 100),
                                  ),
                                  lastDate: now,
                                );
                                if (pickedDate != null) {
                                  final year = pickedDate.year;
                                  final month = pickedDate.month
                                      .toString()
                                      .padLeft(2, '0'); // 👈 ensures 01..12
                                  final day = pickedDate.day.toString().padLeft(
                                    2,
                                    '0',
                                  ); // 👈 ensures 01..31

                                  registerController.dobController.text =
                                      "$year-$month-$day";
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      CommonWidget.customTextField(
                        "Email",
                        controller: registerController.emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: TextfieldValidator.validateEmail,

                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      // CommonWidget.customTextField(
                      //   "Mobile Number",
                      //   controller: mobileTFC,
                      //   keyboardType: TextInputType.number,
                      //   prefixIcon: Icon(Icons.phone),
                      // ),
                      Row(
                        children: [
                          Expanded(
                            child: CommonWidget.customTextField(
                              "Height (cm)",
                              controller: registerController.heightCmController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              prefixIcon: Icon(
                                Icons.height,
                                color: Colors.grey.shade800,
                              ),
                              suffixText: "cm",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CommonWidget.customTextField(
                              "Weight (kg)",
                              controller: registerController.weightKgController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              prefixIcon: Icon(
                                Icons.monitor_weight_outlined,
                                color: Colors.grey.shade800,
                              ),
                              suffixText: "kg",
                            ),
                          ),
                        ],
                      ),
                      CommonWidget.roundedButton(
                        context: context,
                        title: "Register",
                        onTap: () => registerController.validateAndSubmit(),
                      ),
                    ],
                  ),
                ),
              ],
            ).padSymm(horizontal: 20),
          ),
        ),
      ),
    );
  }
}
