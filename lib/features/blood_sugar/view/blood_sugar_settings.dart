import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/extensions.dart';

import '../controller/blood_sugar_controller.dart';

class BloodSugarSettings extends StatefulWidget {
  const BloodSugarSettings({super.key});

  @override
  State<BloodSugarSettings> createState() => _BloodSugarSettingsState();
}

class _BloodSugarSettingsState extends State<BloodSugarSettings> {
  final bloodSugarController = Get.find<BloodSugarController>();
  final TextEditingController _fastingController = TextEditingController();
  final TextEditingController _afterMealController = TextEditingController();

  bool _remindersEnabled = true;

  // Testing schedule state
  final List<_ScheduleItem> _scheduleItems = [
    _ScheduleItem(
      title: 'Fasting (Morning)',
      subtitle: 'Before breakfast',
      time: const TimeOfDay(hour: 7, minute: 0),
      isEnabled: true,
    ),
    _ScheduleItem(
      title: 'Before Lunch',
      subtitle: '12:00 PM',
      time: const TimeOfDay(hour: 12, minute: 0),
      isEnabled: false,
    ),
    _ScheduleItem(
      title: 'After Dinner',
      subtitle: '2 hours post-meal',
      time: const TimeOfDay(hour: 20, minute: 0),
      isEnabled: true,
    ),
    _ScheduleItem(
      title: 'Bedtime',
      subtitle: 'Before sleep',
      time: const TimeOfDay(hour: 22, minute: 0),
      isEnabled: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    final goalData = bloodSugarController.bloodSugarGoal.value?.data;
    _fastingController.text = (goalData?.fastingMax ?? 100).toString();
    _afterMealController.text = (goalData?.afterMealMax ?? 140).toString();
  }

  @override
  void dispose() {
    _fastingController.dispose();
    _afterMealController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _scheduleItems[index].time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C4DFF),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _scheduleItems[index].time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Target Glucose Range Section
          _buildTargetRangeSection(),

          const SizedBox(height: 16),

          // Testing Reminders Section
          _buildRemindersSection(),
        ],
      ).padSymm(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildTargetRangeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFFFF6E40)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.track_changes,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Target Glucose Range",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Set your personal blood sugar targets (consult your healthcare provider)",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          // Fasting and After Meal Inputs
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Target Fasting",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _fastingController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "100",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
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
                          borderSide: const BorderSide(
                            color: Color(0xFF7C4DFF),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Target After Meal",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _afterMealController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: "140",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
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
                          borderSide: const BorderSide(
                            color: Color(0xFF7C4DFF),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reference Ranges Info Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bar_chart,
                      color: Colors.blue.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Reference Ranges",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Fasting Glucose
                const Text(
                  "Fasting Glucose",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _buildReferenceRow(
                  "Normal:",
                  "70-100 mg/dL",
                  Colors.green.shade700,
                ),
                const SizedBox(height: 4),
                _buildReferenceRow(
                  "Prediabetes:",
                  "100-125 mg/dL",
                  Colors.blue.shade700,
                ),
                const SizedBox(height: 4),
                _buildReferenceRow(
                  "Diabetes:",
                  "\u2265126 mg/dL",
                  Colors.red.shade700,
                ),

                const SizedBox(height: 14),

                // After Meal
                const Text(
                  "After Meal (2h)",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                _buildReferenceRow(
                  "Normal:",
                  "<140 mg/dL",
                  Colors.green.shade700,
                ),
                const SizedBox(height: 4),
                _buildReferenceRow(
                  "Prediabetes:",
                  "140-199 mg/dL",
                  Colors.blue.shade700,
                ),
                const SizedBox(height: 4),
                _buildReferenceRow(
                  "Diabetes:",
                  "\u2265200 mg/dL",
                  Colors.red.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF7C4DFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Testing Reminders",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Enable Reminders toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Enable Reminders",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Get notifications to test glucose",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Switch(
                value: _remindersEnabled,
                onChanged: (value) {
                  setState(() {
                    _remindersEnabled = value;
                  });
                },
                activeColor: const Color(0xFF7C4DFF),
              ),
            ],
          ),

          if (_remindersEnabled) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade300),
            const SizedBox(height: 16),

            // Testing Schedule
            const Text(
              "Testing Schedule",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Schedule items
            ...List.generate(_scheduleItems.length, (index) {
              final item = _scheduleItems[index];
              return _buildScheduleItem(item, index);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleItem(_ScheduleItem item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Checkbox
          GestureDetector(
            onTap: () {
              setState(() {
                _scheduleItems[index].isEnabled = !item.isEnabled;
              });
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: item.isEnabled
                    ? const LinearGradient(
                        colors: [Color(0xFF7C4DFF), Color(0xFF448AFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: item.isEnabled ? null : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(6),
              ),
              child: item.isEnabled
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Time
          GestureDetector(
            onTap: () => _selectTime(context, index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(item.time),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _ScheduleItem {
  final String title;
  final String subtitle;
  TimeOfDay time;
  bool isEnabled;

  _ScheduleItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.isEnabled,
  });
}
