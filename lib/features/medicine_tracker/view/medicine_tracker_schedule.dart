import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../controller/medicine_tracker_controller.dart';
import '../model/all_medicine_model.dart';
import 'add_medicine_bottom_sheet.dart';
import 'medicine_tracker_screen.dart';

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
      return Colors.red;
  }
}

class MedicineTrackerSchedule extends StatelessWidget {
  const MedicineTrackerSchedule({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MedicineTrackerController>();
    return Obx(() {
      final medicines = controller.allMedicineModel.value?.data ?? [];
      return RefreshIndicator(
        color: medicineGreen,
        onRefresh: controller.getAllMedicines,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _AllMedicinesSection(
                medicines: medicines,
                controller: controller,
              ),
              const SizedBox(height: 16),
              _ManageMedicationsTip(),
            ],
          ).padSymm(horizontal: 16, vertical: 16),
        ),
      );
    });
  }
}

// ---------- All Medicines section ----------
class _AllMedicinesSection extends StatelessWidget {
  final List<Datum> medicines;
  final MedicineTrackerController controller;

  const _AllMedicinesSection({
    required this.medicines,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText.title(
                    text: 'All Medicines',
                    size: 16,
                    isBold: true,
                  ),
                  const SizedBox(height: 2),
                  CustomText.title(
                    text:
                        '${medicines.length} active prescription${medicines.length == 1 ? "" : "s"}',
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => AddMedicineBottomSheet.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: medicineGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 18),
                      SizedBox(width: 4),
                      Text(
                        'Add',
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
          const SizedBox(height: 16),
          if (medicines.isEmpty)
            _EmptyMedicines()
          else
            ...medicines.asMap().entries.map(
              (e) => Padding(
                padding: EdgeInsets.only(
                  bottom: e.key < medicines.length - 1 ? 12 : 0,
                ),
                child: _MedicineCard(medicine: e.value, controller: controller),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyMedicines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.medication_outlined,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            CustomText.title(
              text: 'No medicines added yet',
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Single medicine card ----------
class _MedicineCard extends StatelessWidget {
  final Datum medicine;
  final MedicineTrackerController controller;

  const _MedicineCard({required this.medicine, required this.controller});

  // daysOfWeek from API: 0=Mon … 6=Sun; chip order: M T W T F S S
  static const List<String> _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final color = _medicineColor(medicine.medicationType);
    final days = medicine.daysOfWeek ?? [];
    final times = medicine.doseSchedule ?? [];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: medicineGreen.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: medicineGreen.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: avatar + info + action buttons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: color.withAlpha(40),
                      child: Image.asset(
                        'assets/images/ic_med_tablet.png',
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText.title(
                          text: medicine.medicineName ?? '—',
                          size: 15,
                          isBold: true,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            CustomText.title(
                              text: medicine.quantityPerDose ?? '1 dose',
                              size: 12,
                              color: medicineGreen,
                              isBold: true,
                            ),
                            if (medicine.medicationType != null)
                              CustomText.title(
                                text:
                                    '  •  ${_capitalize(medicine.medicationType!)}',
                                size: 12,
                                color: Colors.grey.shade600,
                              ),
                          ],
                        ),
                      ],
                    ),

                    // Edit & Delete
                  ],
                ),
                const SizedBox(height: 12),
                // Day chips
                FittedBox(
                  child: Row(
                    children: List.generate(7, (i) {
                      final isActive = days.contains(i);
                      return Container(
                        width: 28,
                        height: 28,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(
                          color: isActive
                              ? medicineGreen
                              : Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _dayLabels[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                if (times.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  // Time chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: times
                        .map(
                          (t) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: medicineGreen.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _formatTime24(t),
                              style: TextStyle(
                                fontSize: 12,
                                color: medicineGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              _actionButton(
                icon: Icons.edit_outlined,
                color: Colors.blue,
                onTap: () =>
                    AddMedicineBottomSheet.show(context, existing: medicine),
              ),
              const SizedBox(height: 10),
              _actionButton(
                icon: Icons.delete_outline,
                color: Colors.red,
                onTap: () => _confirmDelete(context, medicine, controller),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    Datum medicine,
    MedicineTrackerController controller,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Medicine',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          'Remove "${medicine.medicineName}" from your schedule?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              if (medicine.scheduleId != null) {
                await controller.deleteMedicineSchedule(medicine.scheduleId!);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// "08:00" → "8:00 AM"
  String _formatTime24(String t) {
    final parts = t.split(':');
    if (parts.length < 2) return t;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final display = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$display:$m $period';
  }
}

// ---------- Manage tip ----------
class _ManageMedicationsTip extends StatelessWidget {
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
                  text: 'Manage Your Medications',
                  size: 14,
                  isBold: true,
                ),
                const SizedBox(height: 4),
                CustomText.title(
                  text:
                      'Keep track of all your prescriptions in one place. Use the edit and delete buttons to manage your medicines.',
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
