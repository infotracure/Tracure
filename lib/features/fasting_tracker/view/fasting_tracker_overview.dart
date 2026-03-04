import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/features/fasting_tracker/controller/fasting_tracker_controller.dart';
import 'package:tracure/features/fasting_tracker/view/fasting_tracker_Progress_widget.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../model/fasting_by_date_model.dart';

const Color _fastingRed = Color(0xFFE53935);
const Color _fastingPinkBg = Color(0xFFFCE4EC);

class FastingTrackerOverview extends StatefulWidget {
  const FastingTrackerOverview({super.key});

  @override
  State<FastingTrackerOverview> createState() => _FastingTrackerOverviewState();
}

class _FastingTrackerOverviewState extends State<FastingTrackerOverview> {
  final controller = Get.find<FastingTrackerController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final fasting = controller.isFasting.value;
      final summary = controller.fastingSummaryModel.value?.data;
      final records = controller.fastingByDateModel.value?.data ?? [];
      final totalDurationHours = summary?.totalDurationHours ?? '0';
      return SingleChildScrollView(
        child: Column(
          spacing: 16,
          children: [
            // Progress widget
            FastingProgressWidget(
              elapsedHours: fasting
                  ? controller.elapsedDuration.inHours
                  : (summary?.totalDurationMinutes ?? 0) ~/ 60,
              goalHours: fasting ? controller.goalHours : 0,
              timerText: fasting
                  ? controller.elapsedFormatted
                  : '${totalDurationHours}h today',
              isFasting: fasting,
              progress: controller.progressPercent,
            ),

            // Start / End button
            if (!fasting) _startFastingButton() else _endFastButton(),

            // Current status card (only when fasting)
            if (fasting) _currentStatusCard(),

            // Fasting Log from API
            _fastingLogSection(records),

            // Key Health Benefits
            _keyHealthBenefits(),
          ],
        ).padSymm(horizontal: 16, vertical: 16),
      );
    });
  }

  Widget _startFastingButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.startFasting,
        icon: const Icon(Icons.play_arrow, color: Colors.white),
        label: CustomText.title(
          text: 'Start Fasting',
          color: Colors.white,
          size: 16,
          isBold: true,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _fastingRed,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _endFastButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: controller.endFasting,
        icon: const Icon(Icons.stop_circle_outlined, color: _fastingRed),
        label: CustomText.title(
          text: 'End Fast',
          color: _fastingRed,
          size: 16,
          isBold: true,
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _fastingRed, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _currentStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _fastingRed,
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
                  color: Colors.white70,
                  size: 12,
                ),
                const SizedBox(height: 4),
                CustomText.title(
                  text: 'IN PROGRESS',
                  color: Colors.white,
                  size: 22,
                  isBold: true,
                ),
                const SizedBox(height: 4),
                CustomText.title(
                  text: 'Target: ${controller.goalHours} hours',
                  color: Colors.white70,
                  size: 14,
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/ic_fasting.png',
            height: 48,
            width: 48,
            color: Colors.white70,
            errorBuilder: (_, _, _) =>
                const Icon(Icons.timer, color: Colors.white70, size: 48),
          ),
        ],
      ),
    );
  }

  Widget _fastingLogSection(List<Datum> records) {
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
                      text: 'Fasting Log',
                      size: 18,
                      isBold: true,
                    ),
                    CustomText.title(
                      text: '${records.length} entries',
                      size: 13,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (records.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: CustomText.title(
                text: 'No fasting sessions yet.\nStart your first fast!',
                size: 14,
                color: Colors.black45,
              ),
            )
          else
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: records.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => _recordCard(records[index]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _recordCard(Datum record) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    final startTime = record.startTime;
    final endTime = record.endTime;
    final dateStr = startTime != null ? dateFormat.format(startTime) : '';
    final startStr = startTime != null ? timeFormat.format(startTime) : '';
    final endStr = endTime != null ? timeFormat.format(endTime) : 'In progress';
    final durationMins = record.durationMinutes ?? 0;
    final h = durationMins ~/ 60;
    final m = durationMins % 60;
    final durationFormatted = '${h}h ${m}m';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _fastingPinkBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText.title(text: dateStr, size: 14, isBold: true),
                const SizedBox(height: 4),
                CustomText.title(
                  text: '$startStr - $endStr',
                  size: 12,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText.title(
                text: durationFormatted,
                size: 16,
                isBold: true,
                color: _fastingRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyHealthBenefits() {
    final benefits = [
      {
        'icon': Icons.favorite_border,
        'title': 'Heart Health',
        'desc': 'Improves cardiovascular health',
      },
      {
        'icon': Icons.psychology,
        'title': 'Mental Clarity',
        'desc': 'Enhances focus and cognition',
      },
      {
        'icon': Icons.bolt,
        'title': 'Energy Boost',
        'desc': 'Increases metabolic efficiency',
      },
      {
        'icon': Icons.shield_outlined,
        'title': 'Cell Protection',
        'desc': 'Activates autophagy process',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CommonWidget.containerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText.title(text: 'Key Health Benefits', size: 16, isBold: true),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: benefits.length,
            itemBuilder: (context, index) {
              final b = benefits[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        b['icon'] as IconData,
                        size: 20,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomText.title(
                      text: b['title'] as String,
                      size: 13,
                      isBold: true,
                    ),
                    CustomText.title(
                      text: b['desc'] as String,
                      size: 11,
                      color: Colors.black54,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
