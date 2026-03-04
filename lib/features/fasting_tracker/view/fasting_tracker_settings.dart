import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/features/fasting_tracker/controller/fasting_tracker_controller.dart';
import 'package:tracure/features/fasting_tracker/model/fasting_session_model.dart';
import 'package:tracure/utils/common_widget.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

const Color _fastingRed = Color(0xFFE53935);
const Color _fastingPinkBg = Color(0xFFFCE4EC);

class FastingTrackerSettings extends StatefulWidget {
  const FastingTrackerSettings({super.key});

  @override
  State<FastingTrackerSettings> createState() => _FastingTrackerSettingsState();
}

class _FastingTrackerSettingsState extends State<FastingTrackerSettings> {
  final controller = Get.find<FastingTrackerController>();
  final TextEditingController _targetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGoalData();
  }

  void _loadGoalData() {
    final goalData = controller.fastingGoalModel.value?.data;
    if (goalData != null) {
      final targetMinutes = goalData.targetDurationMinutes ?? 0;
      _targetController.text =
          targetMinutes > 0 ? (targetMinutes ~/ 60).toString() : '';

      // Sync plan from API goal
      final fastingType = goalData.fastingType;
      if (fastingType != null) {
        final plan = _planFromType(fastingType);
        if (plan != null && !controller.isFasting.value) {
          controller.changePlan(plan);
        }
      }
    } else {
      _targetController.text = controller.goalHours.toString();
    }
  }

  FastingPlan? _planFromType(String type) {
    switch (type.toLowerCase()) {
      case '16:8':
        return FastingPlan.sixteenEight;
      case '18:6':
        return FastingPlan.eighteenSix;
      case '20:4':
        return FastingPlan.twentyFour;
      case '24h':
      case '24:0':
        return FastingPlan.twentyFourFull;
      default:
        return null;
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _updateGoal() {
    final currentPlan = controller.selectedPlan.value;
    final targetHours = int.tryParse(_targetController.text);
    final targetMinutes = targetHours != null && targetHours > 0
        ? targetHours * 60
        : currentPlan.fastHours * 60;

    controller.saveFastingSettings(
      targetDurationMinutes: targetMinutes,
      fastingType: currentPlan.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(() {
        final currentPlan = controller.selectedPlan.value;
        final fasting = controller.isFasting.value;

        return Column(
          spacing: 16,
          children: [
            // Fasting Plan card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: CommonWidget.containerDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _fastingPinkBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.track_changes,
                          color: _fastingRed,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CustomText.title(
                        text: 'Fasting Plan',
                        size: 18,
                        isBold: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomText.title(
                    text: 'Select your preferred fasting schedule',
                    size: 13,
                    color: _fastingRed,
                  ),
                  const SizedBox(height: 16),

                  // Plan grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: FastingPlan.values.map((plan) {
                      final isSelected = currentPlan == plan;
                      return GestureDetector(
                        onTap: fasting
                            ? null
                            : () {
                                controller.changePlan(plan);
                                _targetController.text =
                                    plan.fastHours.toString();
                              },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? _fastingRed
                                  : Colors.grey.shade300,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomText.title(
                                text: plan.label,
                                size: 20,
                                isBold: true,
                                color: isSelected
                                    ? _fastingRed
                                    : Colors.black87,
                              ),
                              const SizedBox(height: 4),
                              CustomText.title(
                                text: plan.subtitle,
                                size: 11,
                                color: Colors.black54,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (fasting) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: CustomText.title(
                        text: 'End current fast to change plan',
                        size: 13,
                        color: _fastingRed,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Target Duration Input
                  Text(
                    "Target Fasting Duration (hours)",
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    enabled: !fasting,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '${currentPlan.fastHours}',
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
                        borderSide: const BorderSide(color: _fastingRed),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: fasting ? null : _updateGoal,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: fasting
                              ? Colors.grey.shade400
                              : _fastingRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            "Update Target",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reference Ranges
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD).withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Fasting Plan Guide",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildReferenceRow(
                          "16:8",
                          "Most popular, beginner-friendly",
                          Colors.green.shade700,
                        ),
                        const SizedBox(height: 6),
                        _buildReferenceRow(
                          "18:6",
                          "Intermediate, enhanced benefits",
                          Colors.amber.shade700,
                        ),
                        const SizedBox(height: 6),
                        _buildReferenceRow(
                          "20:4",
                          "Advanced, warrior diet",
                          Colors.orange.shade700,
                        ),
                        const SizedBox(height: 6),
                        _buildReferenceRow(
                          "24h",
                          "OMAD, one meal a day",
                          Colors.red.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).padSymm(horizontal: 16, vertical: 16);
      }),
    );
  }

  Widget _buildReferenceRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
