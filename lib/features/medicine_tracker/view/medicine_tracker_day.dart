import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/blood_pressure/view/blodd_pressure_progress_widget.dart';
import 'package:tracure/features/medicine_tracker/view/medicine_schedule_screen.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_widget.dart';
import '../../../utils/constant/color_constants.dart';
import '../../../utils/custom_text.dart';
import 'add_medicine_bottom_sheet.dart';

class MedicineTrackerDay extends StatelessWidget {
  const MedicineTrackerDay({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          UpcomingMedsWidget(),
          TodaysMedsButtons(),
          ScheduleMedsWidget(),
        ],
      ).padSymm(horizontal: 16, vertical: 16),
    );
  }
}

class TodaysMedsButtons extends StatelessWidget {
  const TodaysMedsButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: dailyBtns(
            icon: Icons.notifications,
            text: "Medicine Reminder",
          ),
        ),
        Expanded(
          child: dailyBtns(
            icon: Icons.add,
            text: "Add New Medicine",
            onTap: () => AddMedicineBottomSheet.show(context),
          ),
        ),
        Expanded(
          child: dailyBtns(
            icon: Icons.add,
            text: "Add New Schedule",
            onTap: () => Get.to(() => MedicineScheduleScreen()),
          ),
        ),
      ],
    );
  }

  dailyBtns({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: CommonWidget.containerDecoration(color: Color(0xFFD6ECDF)),
        child: Column(
          children: [
            Icon(icon, color: Colors.green.shade600, size: 24),
            SizedBox(height: 4),
            CustomText.title(
              text: text,
              size: 14,
              isBold: true,
              maxLine: 2,
              color: Colors.green.shade600,
              textAlign: TextAlign.center,
            ),
          ],
        ).padSymm(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class ScheduleMedsWidget extends StatelessWidget {
  const ScheduleMedsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(text: "Schedule", isBold: true, size: 16),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: CommonWidget.containerDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText.title(
                text: "Today",
                isBold: true,
                size: 14,
              ).padSymm(horizontal: 16, vertical: 8),
              ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 4),
                itemCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          CustomText.title(text: "Morning", size: 14),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ).padSymm(horizontal: 8),
                          ),
                          CustomText.title(text: "09:30 am", size: 14),
                        ],
                      ).padSymm(horizontal: 16),
                      ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        itemCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Image.asset(
                                "assets/images/ic_med_tablet.png",
                                height: 40,
                              ).padOnly(r: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  CustomText.title(
                                    text: "Dolo 650",
                                    size: 16,
                                    isBold: true,
                                  ),
                                  CustomText.title(
                                    text: "x1 Dose",
                                    size: 14,
                                    isBold: true,
                                  ),
                                  CustomText.title(text: "Tablet", size: 12),
                                ],
                              ),
                              Spacer(),
                              Checkbox(value: true, onChanged: (val) {}),
                            ],
                          ).padSymm(horizontal: 16, vertical: 8);
                        },
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 8),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UpcomingMedsWidget extends StatelessWidget {
  const UpcomingMedsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.title(text: "Upcoming Meds", isBold: true, size: 16),
          SizedBox(height: 16),
          SizedBox(
            height: 81,
            child: ListView.separated(
              itemCount: 3,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  width: 143,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Color(0xFFCFE3EF),
                  ),
                  child: Column(
                    spacing: 5,
                    children: [
                      Image.asset(
                        "assets/images/ic_med_tablet.png",
                        height: 20,
                      ),
                      CustomText.title(
                        text: "Dolo 650",
                        size: 14,
                        isBold: true,
                      ),
                      CustomText.title(text: "Tablet", size: 12),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Icon(
                  Icons.add,
                  size: 18,
                  color: Colors.grey,
                ).padSymm(horizontal: 6);
              },
            ),
          ),
          Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ).padSymm(vertical: 16),
          Row(
            children: [
              Row(
                children: [
                  CustomText.title(text: "View All Details ", size: 14),
                  Icon(Icons.arrow_forward_ios, size: 14),
                ],
              ),
              Spacer(),
              CustomText.title(text: "Reminder", size: 14),
              Transform.scale(
                scale: 0.8,
                child: SizedBox(
                  height: 20,
                  child: Switch(value: true, onChanged: (val) {}),
                ),
              ),
            ],
          ),
        ],
      ).padSymm(horizontal: 16, vertical: 16),
    );
  }
}
