import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/blood_pressure/model/blood_pressure_day_log.dart';
import 'package:tracure/utils/extensions.dart';

import '../../../utils/common_widget.dart';
import '../../../utils/constant/color_constants.dart';
import '../../../utils/custom_text.dart';
import '../controller/blood_pressure_controller.dart';
import '../model/blood_pressure_trend_model.dart';

class BloodPressureOverview extends StatefulWidget {
  const BloodPressureOverview({super.key});

  @override
  State<BloodPressureOverview> createState() => _BloodPressureOverviewState();
}

class _BloodPressureOverviewState extends State<BloodPressureOverview> {
  final bloodPressureController = Get.find<BloodPressureController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final summary = bloodPressureController.bloodPressureSummary.value?.data;
      final trendRecords =
          (bloodPressureController.bloodPressureTrend.value?.data?.readings ??
                [])
            ..sort(
              (a, b) => (b.measurementTime ?? DateTime(0)).compareTo(
                a.measurementTime ?? DateTime(0),
              ),
            );

      final avgSystolic = summary?.avgSystolic ?? 0;
      final avgDiastolic = summary?.avgDiastolic ?? 0;
      final avgPulse = summary?.avgPulse ?? 0;
      final category = summary?.category ?? '';
      final lastRecordDate = trendRecords.isNotEmpty
          ? trendRecords.first.measurementTime
          : null;

      // Calculate progress for gauge (normal is 120/80, higher values = higher progress)
      final progress = _calculateGaugeProgress(avgSystolic);

      return SingleChildScrollView(
        child: Column(
          children: [
            // Circular Blood Pressure Gauge
            _buildCircularGauge(
              systolic: avgSystolic,
              diastolic: avgDiastolic,
              pulse: avgPulse,
              progress: progress,
              lastEntryDate: lastRecordDate,
            ),
            const SizedBox(height: 20),

            // Current Status Card
            _buildStatusCard(
              category: category,
              systolic: avgSystolic,
              diastolic: avgDiastolic,
              pulse: avgPulse,
            ),
            const SizedBox(height: 20),

            // Blood Pressure Log Section
            _buildLogSection(trendRecords),
            const SizedBox(height: 16),

            // Understanding Blood Pressure Card
            _buildInfoCard(),
            const SizedBox(height: 16),

            // Bottom Cards (Healthy Diet & Exercise)
            _buildBottomCards(),
            const SizedBox(height: 16),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      );
    });
  }

  double _calculateGaugeProgress(int systolic) {
    // Normal < 120, Elevated 120-129, Stage 1 130-139, Stage 2 >= 140
    if (systolic <= 0) return 0.0;
    if (systolic < 120) return systolic / 160; // Normal
    if (systolic < 130) return 0.75; // Elevated
    if (systolic < 140) return 0.85; // Stage 1
    return 0.95; // Stage 2+
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Widget _buildCircularGauge({
    required int systolic,
    required int diastolic,
    required int pulse,
    required double progress,
    DateTime? lastEntryDate,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress
              CustomPaint(
                size: const Size(200, 200),
                painter: _BloodPressureGaugePainter(progress: progress),
              ),
              // Heart icon at top

              // Center text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$systolic',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        const TextSpan(
                          text: ' / ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                        TextSpan(
                          text: '$diastolic',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText.title(
                        text: 'SYS',
                        size: 12,
                        color: ColorConstant.grayTextColor,
                      ),
                      const SizedBox(width: 24),
                      CustomText.title(
                        text: 'DIA',
                        size: 12,
                        color: ColorConstant.grayTextColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.show_chart,
                        color: Color(0xFFE53935),
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      CustomText.title(
                        text: '$pulse bpm',
                        size: 14,
                        isBold: true,
                        color: const Color(0xFFE53935),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  CustomText.title(
                    text: 'Last Entry',
                    size: 10,
                    color: ColorConstant.grayTextColor,
                  ),
                  CustomText.title(
                    text: _formatDate(lastEntryDate),
                    size: 10,
                    color: ColorConstant.grayTextColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required String category,
    required int systolic,
    required int diastolic,
    required int pulse,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFE53935), Color(0xFFEC407A)],
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
                  text: category,
                  size: 24,
                  isBold: true,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                CustomText.title(
                  text: '$systolic/$diastolic mmHg \u2022 $pulse bpm',
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
            child: const Icon(Icons.show_chart, color: Colors.white, size: 28),
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
                      text: 'Blood Pressure Log',
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
                  onPressed: () => _showAddBloodPressureBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
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
    final isStage1 = category == 'Stage 1' || category == 'Stage 2';
    final statusColor = isStage1
        ? const Color(0xFFE53935)
        : const Color(0xFFFF7043);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFFFF0F0),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText.title(
                      text: '${record.systolic ?? 0}/${record.diastolic ?? 0}',
                      size: 16,
                      isBold: true,
                    ),
                    const SizedBox(width: 4),
                    CustomText.title(
                      text: 'mmHg',
                      size: 12,
                      color: ColorConstant.grayTextColor,
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.show_chart,
                      size: 14,
                      color: Color(0xFFE53935),
                    ),
                    const SizedBox(width: 2),
                    CustomText.title(
                      text: '${record.pulse ?? 0}',
                      size: 14,
                      isBold: true,
                    ),
                    const SizedBox(width: 2),
                    CustomText.title(
                      text: 'bpm',
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

  void _showAddBloodPressureBottomSheet(BuildContext context) {
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final pulseController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
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
                      colors: [Color(0xFFE53935), Color(0xFFEC407A)],
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
                            "Add Blood Pressure",
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
                        "Systolic (mmHg)",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: systolicController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "e.g., 120",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Diastolic (mmHg)",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: diastolicController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "e.g., 80",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Pulse (bpm)",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: pulseController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "e.g., 72",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
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
                      final systolic = int.tryParse(systolicController.text);
                      final diastolic = int.tryParse(diastolicController.text);
                      final pulse = int.tryParse(pulseController.text);
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (systolic == null || systolic <= 0) {
                        CommonWidget.showToast(
                          "Please enter a valid systolic value",
                        );
                        return;
                      }
                      if (diastolic == null || diastolic <= 0) {
                        CommonWidget.showToast(
                          "Please enter a valid diastolic value",
                        );
                        return;
                      }
                      if (systolic <= diastolic) {
                        CommonWidget.showToast(
                          "Systolic must be greater than diastolic",
                        );
                        return;
                      }

                      Navigator.pop(context);
                      final data = [
                        await bloodPressureController
                            .convertToBloodPressureJson(
                              systolic: systolic,
                              diastolic: diastolic,
                              pulse: pulse ?? 0,
                            ),
                      ];
                      bloodPressureController.addBloodPressure(
                        bloodPressureData: data,
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE53935), Color(0xFFEC407A)],
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
    );
  }

  Widget _buildInfoCard() {
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
            child: const Icon(
              Icons.favorite_border,
              color: Color(0xFFFF8A65),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.title(
                  text: 'Understanding Blood Pressure',
                  size: 14,
                  isBold: true,
                ),
                const SizedBox(height: 4),
                CustomText.title(
                  text:
                      'Normal blood pressure is below 120/80 mmHg. Regular monitoring helps detect hypertension early and prevent heart disease.',
                  size: 12,
                  color: ColorConstant.grayTextColor,
                  overflow: TextOverflow.visible,
                  maxLine: 4,
                ),
                const SizedBox(height: 8),
                // Row(
                //   children: [
                //     CustomText.title(
                //       text: 'Learn More',
                //       size: 12,
                //       isBold: true,
                //       color: const Color(0xFFFF7043),
                //     ),
                //     const SizedBox(width: 4),
                //     const Icon(
                //       Icons.arrow_forward,
                //       size: 14,
                //       color: Color(0xFFFF7043),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallCard(
            icon: '\u{1F957}',
            title: 'Healthy Diet',
            subtitle: 'Reduce sodium intake',
            color: const Color.fromARGB(255, 221, 240, 223),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSmallCard(
            icon: '\u{1F3C3}',
            title: 'Exercise',
            subtitle: '30 min daily activity',
            color: const Color.fromARGB(255, 214, 232, 245),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
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
}

class _BloodPressureGaugePainter extends CustomPainter {
  final double progress;

  _BloodPressureGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final bgPaint = Paint()
      ..color = const Color(0xFFfee2e2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = const Color(0xfff6a812)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    const startAngle = -1.5708; // -90 degrees in radians
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
