import 'package:flutter/material.dart';
import 'package:tracure/features/medicine_tracker/view/add_medicine_bottom_sheet.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';

class FastingScheduleBottomSheet extends StatelessWidget {
  final List<String> selectedDays;
  final List<Map<String, String>> fastingHours;
  final Function(String dayKey) onDayToggle;
  final VoidCallback onAddHours;
  final VoidCallback onSave;

  const FastingScheduleBottomSheet({
    Key? key,
    required this.selectedDays,
    required this.fastingHours,
    required this.onDayToggle,
    required this.onAddHours,
    required this.onSave,
  }) : super(key: key);

  // Days with unique keys and short labels
  final List<Map<String, String>> days = const [
    {"key": "Mon", "label": "M"},
    {"key": "Tue", "label": "T"},
    {"key": "Wed", "label": "W"},
    {"key": "Thu", "label": "T"},
    {"key": "Fri", "label": "F"},
    {"key": "Sat", "label": "S"},
    {"key": "Sun", "label": "S"},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Fasting Schedule",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Days row
            CustomText.title(text: "Fasting Days", size: 16),

            const SizedBox(height: 12),
            Row(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((day) {
                final key = day["key"]!;
                final label = day["label"]!;
                final isSelected = selectedDays.contains(key);

                return GestureDetector(
                  onTap: () => onDayToggle(key),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? ColorConstant.primaryColor
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? ColorConstant.primaryColor
                            : Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Fasting hours
            CustomText.title(text: "Fasting Hours", size: 16),

            const SizedBox(height: 12),
            Column(
              children: fastingHours.map((hours) {
                return Row(
                  children: [
                    Expanded(
                      child: TitledTextField(title: "", hint: "05:00"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "→",
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Expanded(
                      child: TitledTextField(title: "", hint: "19:00"),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            GestureDetector(
              onTap: onAddHours,
              child: Container(
                height: 45,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(0xffDEE6F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "+ Add More Hours",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstant.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onSave,
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showFastingSheet(BuildContext context) {
  List<String> selectedDays = []; // stores keys like "Mon", "Tue"
  List<Map<String, String>> fastingHours = [
    {"start": "05:00", "end": "19:00"},
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) {
          return FastingScheduleBottomSheet(
            selectedDays: selectedDays,
            fastingHours: fastingHours,
            onDayToggle: (dayKey) {
              setState(() {
                if (selectedDays.contains(dayKey)) {
                  selectedDays.remove(dayKey);
                } else {
                  selectedDays.add(dayKey);
                }
              });
            },
            onAddHours: () {
              setState(() {
                fastingHours.add({"start": "06:00", "end": "18:00"});
              });
            },
            onSave: () {
              Navigator.pop(context);
              print("Selected days: $selectedDays");
              print("Fasting hours: $fastingHours");
            },
          );
        },
      );
    },
  );
}
