import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/blood_sugar/view/blood_sugar_progress_widget.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_widget.dart';
import '../../../utils/constant/color_constants.dart';
import '../../../utils/custom_text.dart';
import '../controller/blood_sugar_controller.dart';
import '../model/blood_sugar_day_log.dart';
import '../model/blood_sugar_trend.dart';

class BloodSugarOverview extends StatefulWidget {
  const BloodSugarOverview({super.key});

  @override
  State<BloodSugarOverview> createState() => _BloodSugarOverviewState();
}

class _BloodSugarOverviewState extends State<BloodSugarOverview> {
  final bloodSugarController = Get.find<BloodSugarController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = bloodSugarController.bloodSugarSummary.value?.data;
      final trendRecords =
          (bloodSugarController.bloodSugarTrend.value?.data?.readings ?? [])
            ..sort(
              (a, b) => (b.measurementTime ?? DateTime(0)).compareTo(
                a.measurementTime ?? DateTime(0),
              ),
            );

      final avgValue = summary?.avgValue ?? 0;
      final category = summary?.category ?? '';
      final lastRecordDate = trendRecords.isNotEmpty
          ? trendRecords.first.measurementTime
          : null;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gauge Widget
            Container(
              width: double.infinity,
              decoration: CommonWidget.containerDecoration(),
              padding: const EdgeInsets.only(top: 6, bottom: 24),
              child: BloodSugarGaugeWidget(
                value: avgValue.toDouble(),
                mealType: category.isNotEmpty ? category : "No Data",
                date: _formatDate(lastRecordDate),
              ),
            ),

            const SizedBox(height: 16),

            // Current Status Card
            _buildStatusCard(
              category: category,
              avgValue: avgValue,
              readingsCount: summary?.readingsCount ?? 0,
            ),

            const SizedBox(height: 20),

            // Blood Sugar Log Section
            _buildLogSection(trendRecords),

            const SizedBox(height: 16),

            // Understanding Blood Sugar Card
            _understandingCard(),

            const SizedBox(height: 16),

            // Tips Row
            Row(
              children: [
                Expanded(
                  child: _tipCard(
                    "\u{1F34E}",
                    "Balanced Diet",
                    "Control carb intake",
                    const Color(0xFFFFEBEE),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _tipCard(
                    "\u{1F3C3}",
                    "Stay Active",
                    "Walk after meals",
                    const Color(0xFFFFF3E0),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Reference Ranges
            _referenceRangesCard(),

            const SizedBox(height: 16),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      );
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Widget _buildStatusCard({
    required String category,
    required int avgValue,
    required int readingsCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.title(
                  text: 'Current Status',
                  size: 12,
                  color: Colors.white70,
                ),
                const SizedBox(height: 4),
                CustomText.title(
                  text: category.isNotEmpty ? category : 'No Data',
                  size: 24,
                  isBold: true,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                CustomText.title(
                  text: '$avgValue mg/dL \u2022 $readingsCount readings',
                  size: 12,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildLogSection(List<Reading> records) {
    return Container(
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText.title(
                      text: 'Blood Sugar Log',
                      size: 16,
                      isBold: true,
                    ),
                    CustomText.title(
                      text: '${records.length} entries',
                      size: 12,
                      color: ColorConstant.grayTextColor,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddBloodSugarBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            constraints: records.length > 4
                ? const BoxConstraints(maxHeight: 280)
                : null,
            child: RawScrollbar(
              padding: const EdgeInsets.symmetric(vertical: 10),
              controller: _scrollController,
              thumbVisibility: records.length > 4,
              thickness: 4,
              radius: const Radius.circular(8),
              child: ListView.separated(
                controller: _scrollController,
                shrinkWrap: records.length <= 4,
                physics: records.length > 4
                    ? const AlwaysScrollableScrollPhysics()
                    : const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final record = records[index];
                  return _buildLogEntryItem(record);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntryItem(Reading record) {
    final category = record.category ?? 'Normal';
    final isElevated = category == 'Elevated' || category == 'High';
    final statusColor = isElevated
        ? const Color(0xFFFF9800)
        : const Color(0xFF4CAF50);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFE8F5E9),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText.title(
                      text: '${record.value ?? 0}',
                      size: 16,
                      isBold: true,
                    ),
                    const SizedBox(width: 4),
                    CustomText.title(
                      text: 'mg/dL',
                      size: 12,
                      color: ColorConstant.grayTextColor,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomText.title(
                        text: category,
                        size: 10,
                        isBold: true,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomText.title(
                      text: _formatDate(record.measurementTime),
                      size: 12,
                      color: ColorConstant.grayTextColor,
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

  void _showAddBloodSugarBottomSheet(BuildContext context) {
    final valueController = TextEditingController();
    final notesController = TextEditingController();
    String selectedContext = 'FASTING';

    final contextOptions = [
      {'value': 'FASTING', 'label': 'Fasting'},
      {'value': 'BEFORE_MEAL', 'label': 'Before Meal'},
      {'value': 'AFTER_MEAL', 'label': 'After Meal'},
      {'value': 'BEDTIME', 'label': 'Bedtime'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add Blood Sugar",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Enter your reading",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Input fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        const Text(
                          "Blood Sugar (mg/dL)",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: valueController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "e.g., 120",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Measurement Context",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedContext,
                              isExpanded: true,
                              items: contextOptions
                                  .map(
                                    (opt) => DropdownMenuItem<String>(
                                      value: opt['value'],
                                      child: Text(opt['label']!),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setModalState(() {
                                    selectedContext = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Notes (optional)",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: notesController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "e.g., After breakfast",
                            hintStyle: TextStyle(color: Colors.grey.shade400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
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

                  // Add button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GestureDetector(
                      onTap: () async {
                        final value = int.tryParse(valueController.text);
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (value == null || value <= 0) {
                          CommonWidget.showToast(
                            "Please enter a valid blood sugar value",
                          );
                          return;
                        }

                        Navigator.pop(context);
                        final data = [
                          await bloodSugarController.convertToBloodSugarJson(
                            value: value,
                            measurementContext: selectedContext,
                            notes: notesController.text,
                          ),
                        ];
                        bloodSugarController.addBloodSugar(
                          bloodSugarData: data,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            "Add Reading",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _understandingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE082), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFECB3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.water_drop_outlined,
              color: Colors.orange.shade400,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.title(
                  text: 'Understanding Blood Sugar',
                  size: 14,
                  isBold: true,
                ),
                const SizedBox(height: 4),
                CustomText.title(
                  text:
                      'Normal blood sugar ranges from 70-140 mg/dL. Monitor regularly to detect patterns and maintain healthy levels.',
                  size: 12,
                  color: ColorConstant.grayTextColor,
                  overflow: TextOverflow.visible,
                  maxLine: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard(String emoji, String title, String subtitle, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bgColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 8),
          CustomText.title(text: title, size: 14, isBold: true),
          CustomText.title(
            text: subtitle,
            size: 12,
            color: ColorConstant.grayTextColor,
          ),
        ],
      ),
    );
  }

  Widget _referenceRangesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.title(text: 'Reference Ranges', size: 16, isBold: true),
          const SizedBox(height: 16),

          // Fasting Section
          CustomText.title(text: 'Fasting', size: 14, isBold: true),
          const SizedBox(height: 8),
          _referenceRow("Normal:", "70-100 mg/dL", Colors.green),
          _referenceRow("Prediabetes:", "100-125 mg/dL", Colors.orange),
          _referenceRow("Diabetes:", "\u2265126 mg/dL", Colors.red),

          const SizedBox(height: 16),

          // After Meal Section
          CustomText.title(
            text: 'After Meal (2 hours)',
            size: 14,
            isBold: true,
          ),
          const SizedBox(height: 8),
          _referenceRow("Normal:", "<140 mg/dL", Colors.green),
          _referenceRow("Prediabetes:", "140-199 mg/dL", Colors.orange),
          _referenceRow("Diabetes:", "\u2265200 mg/dL", Colors.red),
        ],
      ),
    );
  }

  Widget _referenceRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
