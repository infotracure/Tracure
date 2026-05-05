import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/medicine_tracker/view/add_medicine_bottom_sheet.dart';
import 'package:tracure/features/sleep_tracker/controller/sleep_tracker_controller.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/constant/color_constants.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

class SleepTrackerSetting extends StatefulWidget {
  const SleepTrackerSetting({super.key});

  @override
  State<SleepTrackerSetting> createState() => _SleepTrackerSettingState();
}

class _SleepTrackerSettingState extends State<SleepTrackerSetting> {
  final sleepController = Get.find<SleepTrackerController>();

  TimeOfDay _preferredBedtime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _preferredWakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _targetDurationMinutes = 480; // 8 hours in minutes
  bool _automaticDetection = true;
  bool _bedtimeReminder = true;
  int _smartAlarmWindow = 15;
  bool _gradualWakeup = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await sleepController.getSleepSettings();
    final settings = sleepController.sleepGoalModel.value?.data;
    if (settings != null) {
      setState(() {
        if (settings.preferredBedtime != null) {
          _preferredBedtime = _parseTimeString(settings.preferredBedtime!);
        }
        if (settings.preferredWaketime != null) {
          _preferredWakeTime = _parseTimeString(settings.preferredWaketime!);
        }
        if (settings.targetDurationMinutes != null) {
          _targetDurationMinutes = settings.targetDurationMinutes!;
        }
      });
    }
  }

  // Parse "HH:mm" string to TimeOfDay
  TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Convert TimeOfDay to "HH:mm" string
  String _timeToApiFormat(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _preferredBedtime : _preferredWakeTime,
    );
    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _preferredBedtime = picked;
        } else {
          _preferredWakeTime = picked;
        }
      });
    }
  }

  Future<void> _selectDuration(BuildContext context) async {
    final int? selectedHours = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Sleep Duration'),
        children: List.generate(8, (index) {
          final hours = index + 4; // 4 to 11 hours
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, hours),
            child: Text('$hours hours'),
          );
        }),
      ),
    );
    if (selectedHours != null) {
      setState(() {
        _targetDurationMinutes = selectedHours * 60;
      });
    }
  }

  Future<void> _saveSettings() async {
    await sleepController.saveSleepSettings(
      preferredBedtime: _timeToApiFormat(_preferredBedtime),
      preferredWaketime: _timeToApiFormat(_preferredWakeTime),
      targetDurationMinutes: _targetDurationMinutes,
      automaticDetection: _automaticDetection,
      bedtimeReminder: _bedtimeReminder,
      smartAlarmWindow: _smartAlarmWindow,
      gradualWakeup: _gradualWakeup,
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours hours';
    }
    return '$hours hr $mins min';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: CommonWidget.containerDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomText.title(text: "Sleep Goals", isBold: true),

                dailyStepsGoalWidget(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: CommonWidget.containerDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomText.title(text: "Smart Alarm", isBold: true),
                smartAlarm(),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: CommonWidget.containerDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomText.title(text: "Sleep Tracking", isBold: true),
                toggleCard(
                  "Automatic Detection",
                  "Detect sleep/wake automatically",
                  (val) => setState(() => _automaticDetection = val),
                  _automaticDetection,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: CommonWidget.containerDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                CustomText.title(text: "Reminders", isBold: true),
                toggleCard(
                  "Bedtime Reminder",
                  "Remind me 30min before bedtime",
                  (val) => setState(() => _bedtimeReminder = val),
                  _bedtimeReminder,
                ),
              ],
            ),
          ),
          SizedBox(height: 18),
          CommonWidget.roundedButton(
            title: "Save Changes",
            bgColor: ColorConstant.sleepGlobal,
            onTap: _saveSettings,
            context: context,
          ),
          SizedBox(height: 24),
        ],
      ).padSymm(horizontal: 16, vertical: 16),
    );
  }

  Widget toggleCard(
    String title,
    String subTitle,
    Function(bool)? onChanged,
    bool value,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText.title(text: title, isBold: true, size: 12),
              CustomText.title(
                text: subTitle,
                size: 12,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
        SizedBox(height: 4),
        Transform.scale(
          scale: 0.7,
          child: SizedBox(
            height: 20,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: ColorConstant.sleepGlobal,
            ),
          ),
        ),
      ],
    );
  }

  Column dailyStepsGoalWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        _buildTimePickerField(
          title: "Target Sleep Duration",
          value: _formatDuration(_targetDurationMinutes),
          onTap: () => _selectDuration(context),
        ),
        SizedBox(height: 10),
        _buildTimePickerField(
          title: "Preferred Bedtime",
          value: _formatTimeOfDay(_preferredBedtime),
          onTap: () => _selectTime(context, true),
        ),
        SizedBox(height: 10),
        _buildTimePickerField(
          title: "Preferred Wake Time",
          value: _formatTimeOfDay(_preferredWakeTime),
          onTap: () => _selectTime(context, false),
        ),
        SizedBox(height: 2),
      ],
    );
  }

  Widget _buildTimePickerField({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(text: title, size: 12),
        SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              // color: ColorConstant.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText.title(text: value, size: 12, isBold: true),
                Icon(Icons.access_time, size: 18, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Column smartAlarm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8),
        TitledDropdown(
          fontSize: 12,
          title: "Smart Alarm Window",
          value: "$_smartAlarmWindow min",
          items: ["5 min", "15 min", "30 min"],
          onChanged: (value) {
            if (value != null) {
              final minutes = int.tryParse(value.replaceAll(' min', ''));
              if (minutes != null) {
                setState(() => _smartAlarmWindow = minutes);
              }
            }
          },
        ),
        SizedBox(height: 10),
        toggleCard(
          "Gradual Wake-up",
          "Gentle light and sound increase",
          (v) => setState(() => _gradualWakeup = v),
          _gradualWakeup,
        ),
        SizedBox(height: 2),
      ],
    );
  }
}
