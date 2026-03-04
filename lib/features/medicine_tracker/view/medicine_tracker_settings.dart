import 'package:flutter/material.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import 'medicine_tracker_screen.dart';

class MedicineTrackerSettings extends StatefulWidget {
  const MedicineTrackerSettings({super.key});

  @override
  State<MedicineTrackerSettings> createState() =>
      _MedicineTrackerSettingsState();
}

class _MedicineTrackerSettingsState extends State<MedicineTrackerSettings> {
  bool _enableReminders = true;
  bool _sound = true;
  bool _vibration = true;
  String _remindBefore = "5 minutes";
  String _snoozeDuration = "5 minutes";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Notification Settings
          Container(
            padding: const EdgeInsets.all(16),
            decoration: CommonWidget.containerDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_outlined,
                        color: medicineGreen, size: 22),
                    const SizedBox(width: 8),
                    CustomText.title(
                      text: "Notification Settings",
                      size: 16,
                      isBold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsToggle(
                  title: "Enable Reminders",
                  subtitle: "Get notified for scheduled medicines",
                  value: _enableReminders,
                  onChanged: (v) => setState(() => _enableReminders = v),
                ),
                Divider(color: Colors.grey.shade200),
                _SettingsToggle(
                  title: "Sound",
                  subtitle: "Play sound with notifications",
                  value: _sound,
                  onChanged: (v) => setState(() => _sound = v),
                ),
                Divider(color: Colors.grey.shade200),
                _SettingsToggle(
                  title: "Vibration",
                  subtitle: "Vibrate on reminder",
                  value: _vibration,
                  onChanged: (v) => setState(() => _vibration = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Reminder Timing
          Container(
            padding: const EdgeInsets.all(16),
            decoration: CommonWidget.containerDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: medicineGreen, size: 22),
                    const SizedBox(width: 8),
                    CustomText.title(
                      text: "Reminder Timing",
                      size: 16,
                      isBold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsDropdown(
                  title: "Remind before",
                  value: _remindBefore,
                  items: const [
                    "5 minutes",
                    "10 minutes",
                    "15 minutes",
                    "30 minutes",
                  ],
                  onChanged: (v) => setState(() => _remindBefore = v!),
                ),
                const SizedBox(height: 12),
                _SettingsDropdown(
                  title: "Snooze duration",
                  value: _snoozeDuration,
                  items: const [
                    "5 minutes",
                    "10 minutes",
                    "15 minutes",
                    "30 minutes",
                  ],
                  onChanged: (v) => setState(() => _snoozeDuration = v!),
                ),
              ],
            ),
          ),
        ],
      ).padSymm(horizontal: 16, vertical: 16),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.title(text: title, size: 14, isBold: true),
                const SizedBox(height: 2),
                CustomText.title(
                    text: subtitle, size: 12, color: Colors.grey),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: medicineGreen,
          ),
        ],
      ),
    );
  }
}

class _SettingsDropdown extends StatelessWidget {
  final String title;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _SettingsDropdown({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText.title(text: title, size: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            isDense: true,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
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
