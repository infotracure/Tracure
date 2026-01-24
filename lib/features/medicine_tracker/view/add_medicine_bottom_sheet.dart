import 'package:flutter/material.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

class AddMedicineBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText.title(
                      text: "Add New Medicine",
                      size: 18,
                      isBold: true,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /// Reusable components
                const TitledTextField(
                  title: "Name",
                  hint: "Enter medicine name",
                ),
                const SizedBox(height: 16),

                TitledDropdown(
                  title: "Medication Type",
                  items: ["Capsule", "Tablet", "Syrup"],
                  onChanged: (value) {},
                ),
                const SizedBox(height: 16),

                /// Dose Schedule
                CustomText.title(text: "Dose Schedule", size: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TitledDropdown(
                        title: "",
                        hint: "3 time",
                        items: ["1 time", "2 times", "3 times"],
                        onChanged: (value) {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: const TitledTextField(
                        title: "",
                        hint: "9am, 3pm, 9pm",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const TitledTextField(
                  title: "Quantity",
                  hint: "e.g. 50 Capsules",
                ),
                const SizedBox(height: 24),

                /// Add Button
                CommonWidget.roundedButton(
                  bgColor: Colors.green,
                  context: context,
                  title: "Add Medicine",
                  onTap: () {
                    // Handle add medicine logic
                    Navigator.pop(context);
                  },
                ),
                // SizedBox(
                //   width: double.infinity,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.green,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       padding: const EdgeInsets.symmetric(vertical: 14),
                //     ),
                //     onPressed: () {
                //       // handle save
                //     },
                //     child: const Text(
                //       "Add",
                //       style: TextStyle(fontSize: 16, color: Colors.white),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TitledTextField extends StatelessWidget {
  final String title;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const TitledTextField({
    Key? key,
    required this.title,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(
          text: title,
          size: 16,
        ).visible(isVisible: title.isNotEmpty),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,

          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }
}

/// Reusable dropdown with title
class TitledDropdown extends StatelessWidget {
  final String title;
  final String? hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final double fontSize;

  const TitledDropdown({
    super.key,
    required this.title,
    this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(
          text: title,
          size: fontSize,
        ).visible(isVisible: title.isNotEmpty),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
