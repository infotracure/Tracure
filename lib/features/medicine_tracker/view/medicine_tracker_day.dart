import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../controller/medicine_tracker_controller.dart';
import '../model/medicine_status_by_date.dart';
import 'medicine_tracker_screen.dart';

// ---------- helpers ----------
String _timePeriod(String time24) {
  final h = int.tryParse(time24.split(':').first) ?? 0;
  if (h < 12) return 'Morning';
  if (h < 17) return 'Afternoon';
  return 'Evening';
}

String _formatTime(String time24) {
  final parts = time24.split(':');
  if (parts.length < 2) return time24;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = parts[1];
  final period = h >= 12 ? 'PM' : 'AM';
  final display = h > 12 ? h - 12 : (h == 0 ? 12 : h);
  return '$display:$m $period';
}

Color _medicineColor(String? type) {
  switch (type?.toLowerCase()) {
    case 'capsule':
      return Colors.orange;
    case 'syrup':
      return Colors.blue;
    case 'injection':
      return Colors.purple;
    case 'drops':
      return Colors.teal;
    case 'inhaler':
      return Colors.indigo;
    default:
      return Colors.red; // tablet / pill / default
  }
}

void _showConfirmDialog({
  required BuildContext context,
  required String medicineName,
  required bool isTaken,
  required VoidCallback onConfirm,
}) {
  final action = isTaken ? 'Unmark' : 'Mark as Taken';
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actionsPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      title: Row(
        children: [
          Icon(
            isTaken ? Icons.remove_circle_outline : Icons.check_circle_outline,
            color: isTaken ? Colors.red : medicineGreen,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(action)),
        ],
      ),
      content: Text(
        isTaken
            ? 'Unmark "$medicineName" as taken?'
            : 'Mark "$medicineName" as taken?',
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTaken ? Colors.red : medicineGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onConfirm();
                },
                child: FittedBox(child: Text(action)),
              ),
            ),
          ],
        ).padOnly(b: 12),
      ],
    ),
  );
}

class _GroupedItem {
  final Datum medicine;
  final TimeSlot slot;
  const _GroupedItem(this.medicine, this.slot);
}

Map<String, List<_GroupedItem>> _groupByPeriod(List<Datum> data) {
  final groups = <String, List<_GroupedItem>>{
    'Morning': [],
    'Afternoon': [],
    'Evening': [],
  };
  for (final med in data) {
    for (final slot in (med.timeSlots ?? [])) {
      final period = _timePeriod(slot.scheduledTime ?? '00:00');
      groups[period]!.add(_GroupedItem(med, slot));
    }
  }
  return groups;
}

// ---------- main widget ----------
class MedicineTrackerDashboard extends StatelessWidget {
  const MedicineTrackerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicineTrackerController>();
    return Obx(() {
      final medicines = controller.medicineStatusModel.value?.data ?? [];
      final grouped = _groupByPeriod(medicines);

      return RefreshIndicator(
        color: medicineGreen,
        onRefresh: () =>
            controller.getMedicineStatusByDate(controller.todayDate),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsRow(controller: controller),
              const SizedBox(height: 16),
              _TodaysScheduleHeader(),
              const SizedBox(height: 12),
              if (medicines.isEmpty)
                _EmptyState()
              else ...[
                if (grouped['Morning']!.isNotEmpty) ...[
                  _TimeGroup(
                    title: 'Morning',
                    subtitle:
                        '${grouped["Morning"]!.length} dose${grouped["Morning"]!.length > 1 ? "s" : ""}',
                    icon: Icons.wb_sunny,
                    iconBgColor: const Color(0xFFFFF3E0),
                    iconColor: Colors.orange,
                    items: grouped['Morning']!,
                    controller: controller,
                  ),
                  const SizedBox(height: 16),
                ],
                if (grouped['Afternoon']!.isNotEmpty) ...[
                  _TimeGroup(
                    title: 'Afternoon',
                    subtitle:
                        '${grouped["Afternoon"]!.length} dose${grouped["Afternoon"]!.length > 1 ? "s" : ""}',
                    icon: Icons.wb_sunny_outlined,
                    iconBgColor: const Color(0xFFFFF9C4),
                    iconColor: const Color(0xFFFFB300),
                    items: grouped['Afternoon']!,
                    controller: controller,
                  ),
                  const SizedBox(height: 16),
                ],
                if (grouped['Evening']!.isNotEmpty) ...[
                  _TimeGroup(
                    title: 'Evening',
                    subtitle:
                        '${grouped["Evening"]!.length} dose${grouped["Evening"]!.length > 1 ? "s" : ""}',
                    icon: Icons.nightlight_round,
                    iconBgColor: const Color(0xFFE8EAF6),
                    iconColor: Colors.indigo,
                    items: grouped['Evening']!,
                    controller: controller,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
              SizedBox(height: 16),
              _MedicationReminderTip(),
            ],
          ).padSymm(horizontal: 16, vertical: 16),
        ),
      );
    });
  }
}

// ---------- Stats Row ----------
class _StatsRow extends StatelessWidget {
  final MedicineTrackerController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _statCard(
          'Taken',
          '${controller.takenCount}',
          const Color(0xFF4CAF50),
          Icons.check_circle_outline,
        ),
        const SizedBox(width: 10),
        _statCard(
          'Scheduled',
          '${controller.scheduledCount}',
          const Color(0xFF1E88E5),
          Icons.access_time,
        ),
        const SizedBox(width: 10),
        _statCard(
          'Missed',
          '${controller.missedCount}',
          const Color(0xFFE53935),
          Icons.error_outline,
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                CustomText.title(text: label, size: 12, color: color),
              ],
            ),
            const SizedBox(height: 6),
            CustomText.title(text: value, size: 22, isBold: true, color: color),
          ],
        ),
      ),
    );
  }
}

// ---------- Date header ----------
class _TodaysScheduleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(text: "Today's Schedule", size: 16, isBold: true),
        const SizedBox(height: 4),
        CustomText.title(text: today, size: 12, color: Colors.grey),
      ],
    );
  }
}

// ---------- Empty state ----------
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        children: [
          Icon(
            Icons.medication_outlined,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          CustomText.title(
            text: 'No medicines scheduled today',
            size: 14,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

// ---------- Time group card ----------
class _TimeGroup extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final List<_GroupedItem> items;
  final MedicineTrackerController controller;

  const _TimeGroup({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.items,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText.title(text: title, size: 16, isBold: true),
                  CustomText.title(
                    text: subtitle,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ).padSymm(horizontal: 16, vertical: 14),
          ...items.map(
            (item) => _MedicineRow(item: item, controller: controller),
          ),
        ],
      ),
    );
  }
}

// ---------- Individual medicine row with checkbox ----------
class _MedicineRow extends StatelessWidget {
  final _GroupedItem item;
  final MedicineTrackerController controller;

  const _MedicineRow({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    final med = item.medicine;
    final slot = item.slot;
    final color = _medicineColor(med.medicationType);
    final isTaken = slot.taken ?? false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withAlpha(40),
            child: Image.asset('assets/images/ic_med_tablet.png', height: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.title(
                  text: med.medicineName ?? '—',
                  size: 14,
                  isBold: true,
                ),
                CustomText.title(
                  text: med.quantityPerDose ?? '1 dose',
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
          CustomText.title(
            text: _formatTime(slot.scheduledTime ?? ''),
            size: 13,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          // Checkbox — tapping shows confirmation dialog
          GestureDetector(
            onTap: () {
              if (med.scheduleId == null) return;
              _showConfirmDialog(
                context: context,
                medicineName: med.medicineName ?? 'Medicine',
                isTaken: isTaken,
                onConfirm: () => controller.toggleMedicineTaken(
                  scheduleId: med.scheduleId!,
                  scheduledTime: slot.scheduledTime ?? '',
                  intakeDate: controller.todayDate,
                  taken: !isTaken,
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isTaken ? medicineGreen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isTaken ? medicineGreen : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isTaken
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Reminder tip ----------
class _MedicationReminderTip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: medicineGreen.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: medicineGreen.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medication_outlined,
              color: medicineGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.title(
                  text: 'Medication Reminder',
                  size: 14,
                  isBold: true,
                ),
                const SizedBox(height: 4),
                CustomText.title(
                  text:
                      'Take your medicines on time for better health outcomes. Enable reminders in settings to never miss a dose.',
                  overflow: TextOverflow.visible,
                  size: 12,
                  color: Colors.grey.shade700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
