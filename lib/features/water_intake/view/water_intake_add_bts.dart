import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_methods.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/constant/color_constants.dart';
import '../controller/water_intake_controller.dart';

void showDrinkBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => const DrinkBottomSheet(),
  );
}

class DrinkBottomSheet extends StatefulWidget {
  const DrinkBottomSheet({super.key});

  @override
  State<DrinkBottomSheet> createState() => _DrinkBottomSheetState();
}

class _DrinkBottomSheetState extends State<DrinkBottomSheet> {
  double _value = 100;
  final minValue = 100.0;
  final maxValue = 4000.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Header
          Row(
            children: [
              const Expanded(
                child: Text(
                  "How much did you drink?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Value box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Text("ml", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // /// Slider
          // Slider(
          //   value: _value,
          //   min: 100,
          //   max: 7000,
          //   divisions: 690,
          //   label: _value.toInt().toString(),
          //   onChanged: (val) {
          //     setState(() => _value = val);
          //   },
          // ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 10,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
              tickMarkShape: const RoundSliderTickMarkShape(
                tickMarkRadius: 0.0,
              ),
            ),
            child: Slider(
              padding: EdgeInsets.zero,
              activeColor: ColorConstant.primaryColor,
              inactiveColor: Colors.grey.shade200,
              value: _value.toDouble(),
              min: minValue,
              max: maxValue,
              divisions: (maxValue - minValue) ~/ 100,
              label: _value.round().toString(),
              onChanged: (value) {
                setState(() => _value = value);
              },
            ),
          ),

          /// Slider labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${minValue.toStringAsFixed(0)} ml"),
                Text("${maxValue.toStringAsFixed(0)} ml"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// Add button
          //
          CommonWidget.roundedButton(
            context: context,
            titleColor: Colors.white,
            bgColor: ColorConstant.primaryColor,
            title: "Add",
            padding: EdgeInsets.symmetric(vertical: 10),
            elevation: 0,
            onTap: () async {
              final waterController = Get.find<WaterIntakeController>();
              var data = [
                {
                  "uuid": generateWaterRecordId(
                    DateTime.now().toIso8601String(),
                  ),
                  "intakeTime": DateTime.now().toIso8601String(),
                  "amountMl": _value.round(),
                  "beverageType": "WATER",
                  "platform": Platform.isIOS ? "ios" : "android",
                  "deviceId": await getOrCreateDeviceId(),
                  "sourceId": "app",
                  "sourceName": "Tracure",
                },
              ];
              waterController.addWater(waterData: data);
              Navigator.pop(context);
            },
          ).padSymm(horizontal: 16, vertical: 8),
        ],
      ),
    );
  }

  String generateWaterRecordId(String startTime) {
    final bytes = utf8.encode(startTime);
    final hash = sha1.convert(bytes).toString().substring(0, 8);
    return 'water-$hash';
  }
}
