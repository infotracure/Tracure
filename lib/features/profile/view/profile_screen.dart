import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import '../controller/profile_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    return Obx(() {
      final isEditing = controller.isEditing.value;
      return Scaffold(
        backgroundColor: Color(0xFFF2F3F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: isEditing
              ? null
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Icon(Icons.person_outline, size: 22),
                ),
          automaticallyImplyLeading: false,
          title: CustomText.title(
            text: "My Profile",
            size: 16,
            isBold: true,
          ),
          actions: [
            if (!isEditing)
              GestureDetector(
                onTap: () => controller.enterEditMode(),
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        body: controller.profileModel.value?.data == null
            ? Center(child: CustomText.title(text: "Loading..."))
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _profileHeader(controller),
                          SizedBox(height: 16),
                          isEditing
                              ? _editForm(context, controller)
                              : _viewForm(controller),
                        ],
                      ),
                    ),
                  ),
                  if (isEditing) _bottomButtons(context, controller),
                ],
              ),
      );
    });
  }

  Widget _profileHeader(ProfileController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B61FF), Color(0xFFB48CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                child: Text(
                  _getInitials(controller.fullName),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.fullName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (controller.memberSince.isNotEmpty)
                  Text(
                    "Member since ${controller.memberSince}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _headerChip("Age", "${controller.age} years"),
                    SizedBox(width: 10),
                    _headerChip(
                      "Gender",
                      controller.profileModel.value?.data?.gender ?? '',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.white70),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewForm(ProfileController controller) {
    final data = controller.profileModel.value?.data;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _viewField(
            "First Name",
            data?.firstName ?? '',
            Icons.person_outline,
          ),
          _viewField(
            "Last Name",
            data?.lastName ?? '',
            Icons.person_outline,
          ),
          _viewField(
            "Gender",
            data?.gender ?? '',
            Icons.male,
          ),
          _viewField(
            "Date of Birth",
            controller.displayDob,
            Icons.calendar_today_outlined,
          ),
          _viewField(
            "Email Address",
            data?.email ?? '',
            Icons.email_outlined,
          ),
          _mobileField(controller.mobileNumber),
        ],
      ),
    );
  }

  Widget _viewField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.title(
            text: label,
            size: 12,
            color: ColorConstant.primaryColor,
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey.shade600),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : '--',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileField(String mobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(
          text: "Mobile Number",
          size: 12,
          color: ColorConstant.primaryColor,
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.phone, size: 20, color: Colors.grey.shade600),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  mobile.isNotEmpty ? mobile : '--',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "Not Editable",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6),
        CustomText.title(
          text: "Contact support to update your mobile number",
          size: 11,
          color: ColorConstant.primaryColor,
        ),
      ],
    );
  }

  Widget _editForm(BuildContext context, ProfileController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(20),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _editField(
            "First Name",
            controller.firstNameController,
            TextInputType.name,
          ),
          SizedBox(height: 16),
          _editField(
            "Last Name",
            controller.lastNameController,
            TextInputType.name,
          ),
          SizedBox(height: 16),
          _genderSelector(controller),
          SizedBox(height: 16),
          _dobField(context, controller),
          SizedBox(height: 16),
          _editField(
            "Email Address",
            controller.emailController,
            TextInputType.emailAddress,
          ),
          SizedBox(height: 16),
          _mobileField(controller.mobileNumber),
        ],
      ),
    );
  }

  Widget _editField(
    String label,
    TextEditingController textController,
    TextInputType keyboardType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(
          text: label,
          size: 12,
          color: ColorConstant.primaryColor,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: textController,
          keyboardType: keyboardType,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ColorConstant.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderSelector(ProfileController controller) {
    final genders = ['Male', 'Female', 'Other'];
    final emojis = ['\u{1F466}', '\u{1F467}', '\u{1F9D1}'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(
          text: "Gender",
          size: 12,
          color: ColorConstant.primaryColor,
        ),
        SizedBox(height: 8),
        Obx(() => Row(
              children: List.generate(genders.length, (i) {
                final isSelected = controller.selectedGender.value == genders[i];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectedGender.value = genders[i],
                    child: Container(
                      margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? ColorConstant.primaryColor.withValues(alpha: 0.1)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? ColorConstant.primaryColor
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(emojis[i], style: TextStyle(fontSize: 18)),
                          SizedBox(width: 6),
                          Text(
                            genders[i],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? ColorConstant.primaryColor
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            )),
      ],
    );
  }

  Widget _dobField(BuildContext context, ProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(
          text: "Date of Birth",
          size: 12,
          color: ColorConstant.primaryColor,
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller.dobController,
          readOnly: true,
          onTap: () async {
            final now = DateTime.now();
            DateTime initialDate;
            try {
              initialDate =
                  DateFormat('dd-MM-yyyy').parse(controller.dobController.text);
            } catch (_) {
              initialDate = DateTime(2000);
            }

            final pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: now.subtract(Duration(days: 365 * 100)),
              lastDate: now,
            );
            if (pickedDate != null) {
              controller.dobController.text =
                  DateFormat('dd-MM-yyyy').format(pickedDate);
            }
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            suffixIcon:
                Icon(Icons.calendar_today_outlined, color: Colors.grey.shade600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: ColorConstant.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bottomButtons(BuildContext context, ProfileController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.cancelEdit(),
              icon: Icon(Icons.close, size: 18),
              label: Text("Cancel"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.updateProfile(),
              icon: Icon(Icons.save, size: 18),
              label: Text("Save Changes"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstant.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty && parts[0].isNotEmpty
        ? parts[0][0].toUpperCase()
        : 'U';
  }
}
