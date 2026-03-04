import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracure/utils/custom_text.dart';
import 'package:tracure/utils/extensions.dart';

import '../controller/medicine_tracker_controller.dart';
import '../model/all_medicine_model.dart';
import '../model/create_medicine_model.dart';
import 'medicine_tracker_screen.dart';

class AddMedicineBottomSheet {
  /// Pass [existing] to open in edit mode pre-filled with that medicine's data.
  static void show(BuildContext context, {Datum? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (ctx, _) => _AddMedicineContent(existing: existing),
      ),
    );
  }
}

// ---------- helpers ----------

class _TimeEntry {
  String hour;
  String minute;
  String period;
  _TimeEntry({this.hour = '9', this.minute = '00', this.period = 'AM'});
}

/// "08:30" → _TimeEntry(hour:'8', minute:'30', period:'AM')
_TimeEntry _parseTime24(String t) {
  final parts = t.split(':');
  final h24 = int.tryParse(parts.first) ?? 9;
  final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
  final period = h24 >= 12 ? 'PM' : 'AM';
  final h12 = h24 > 12 ? h24 - 12 : (h24 == 0 ? 12 : h24);
  return _TimeEntry(hour: '$h12', minute: m, period: period);
}

/// _TimeEntry → "08:30"
String _to24h(_TimeEntry e) {
  var h = int.tryParse(e.hour) ?? 9;
  if (e.period == 'PM' && h != 12) h += 12;
  if (e.period == 'AM' && h == 12) h = 0;
  return '${h.toString().padLeft(2, '0')}:${e.minute}';
}

class _MedicineTypeOption {
  final String label;
  final String emoji;
  final String apiValue; // lowercase sent to API
  const _MedicineTypeOption(this.label, this.emoji, this.apiValue);
}

// ---------- widget ----------

class _AddMedicineContent extends StatefulWidget {
  final Datum? existing;
  const _AddMedicineContent({this.existing});

  @override
  State<_AddMedicineContent> createState() => _AddMedicineContentState();
}

class _AddMedicineContentState extends State<_AddMedicineContent> {
  static const List<_MedicineTypeOption> _typeOptions = [
    _MedicineTypeOption('Pill', '💊', 'pill'),
    _MedicineTypeOption('Ointment', '🧴', 'Ointment'),
    _MedicineTypeOption('Syrup', '🍶', 'syrup'),
    _MedicineTypeOption('Injection', '💉', 'injection'),
    _MedicineTypeOption('Drops', '💧', 'drops'),
    _MedicineTypeOption('Other', '🏥', 'Other'),
  ];

  static const List<String> _typeDropdownItems = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Drops',
    'Inhaler',
    'Ointment',
  ];

  late int _selectedTypeIndex;
  late List<bool> _selectedDays; // index 0=Mon…6=Sun
  late bool _reminderEnabled;
  late List<_TimeEntry> _timeEntries;

  late final TextEditingController _nameController;
  late final TextEditingController _dosageController;
  String? _medicineType;

  bool get _isEditing => widget.existing != null;

  /// Unit suffix based on the selected medicine type grid tile.
  String get _dosageSuffix {
    switch (_typeOptions[_selectedTypeIndex].apiValue) {
      case 'pill':
        return 'tablet';
      case 'syrup':
        return 'ml';
      case 'injection':
        return 'ml';
      case 'drops':
        return 'drops';
      case 'Ointment':
        return 'mg';
      default:
        return '';
    }
  }

  /// Extracts just the numeric/quantity part from a stored value like "2 tablet".
  String _extractQuantity(String stored) {
    if (stored.isEmpty) return '';
    final first = stored.trim().split(RegExp(r'\s+')).first;
    return first;
  }

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    _nameController = TextEditingController(text: ex?.medicineName ?? '');
    _dosageController = TextEditingController(
      text: _extractQuantity(ex?.quantityPerDose ?? ''),
    );
    _medicineType = _capitalize(ex?.medicationType ?? '');
    if (!_typeDropdownItems.contains(_medicineType)) _medicineType = null;

    // Pre-select grid type
    _selectedTypeIndex = _typeOptions.indexWhere(
      (o) => o.apiValue == ex?.medicationType?.toLowerCase(),
    );
    if (_selectedTypeIndex < 0) _selectedTypeIndex = 0;

    // Pre-select days (API: 0=Mon…6=Sun, same as chip index)
    final apiDays = ex?.daysOfWeek ?? [];
    _selectedDays = List.generate(
      7,
      (i) => apiDays.isEmpty ? true : apiDays.contains(i),
    );

    // Pre-fill time entries
    final slots = ex?.doseSchedule ?? [];
    _timeEntries = slots.isEmpty
        ? [_TimeEntry()]
        : slots.map(_parseTime24).toList();

    _reminderEnabled = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // Build CreateMedicineModel from form state
  CreateMedicineModel _buildModel() {
    final selectedDayIndices = List.generate(
      7,
      (i) => i,
    ).where((i) => _selectedDays[i]).toList();
    final doseSchedule = _timeEntries.map(_to24h).toList();
    final typeFromGrid = _typeOptions[_selectedTypeIndex].apiValue;

    return CreateMedicineModel(
      medicineName: _nameController.text.trim(),
      medicationType: _medicineType?.toLowerCase() ?? typeFromGrid,
      quantityPerDose: _dosageSuffix.isNotEmpty
          ? '${_dosageController.text.trim()} $_dosageSuffix'
          : _dosageController.text.trim(),
      daysOfWeek: selectedDayIndices,
      doseSchedule: doseSchedule,
      timesPerDay: doseSchedule.length,
      notes: '',
    );
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter medicine name')),
      );
      return;
    }

    final controller = Get.find<MedicineTrackerController>();
    final model = _buildModel();
    bool success;

    if (_isEditing) {
      success = await controller.updateMedicineSchedule(
        widget.existing!.scheduleId!,
        model,
      );
    } else {
      success = await controller.createMedicineSchedule(model);
    }

    if (success && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medicine For grid
                  CustomText.title(
                    text: 'Medicine For',
                    size: 14,
                    isBold: true,
                  ),
                  const SizedBox(height: 12),
                  _buildTypeGrid(),
                  const SizedBox(height: 20),

                  // Medicine Name
                  _buildLabel('Medicine Name *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g., Dolo 650',
                  ),
                  const SizedBox(height: 16),

                  // Dosage
                  _buildLabel('Dosage *'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _dosageController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    hint: 'e.g., 1',
                    suffixText: _dosageSuffix.isNotEmpty ? _dosageSuffix : null,
                  ),
                  const SizedBox(height: 16),

                  // // Medicine Type dropdown
                  // _buildLabel('Medicine Type *'),
                  // const SizedBox(height: 8),
                  // _buildDropdown(),
                  const SizedBox(height: 16),

                  // Select Days
                  _buildLabel('Select Days *'),
                  const SizedBox(height: 12),
                  _buildDaySelector(),
                  const SizedBox(height: 16),

                  // Dose Schedule
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Dose Schedule *'),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _timeEntries.add(_TimeEntry())),
                        child: Text(
                          '+ Add Time',
                          style: TextStyle(
                            color: medicineGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ..._timeEntries.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildTimeRow(e.key),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reminder toggle
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText.title(
                                text: 'Medication Reminder',
                                size: 14,
                                isBold: true,
                              ),
                              const SizedBox(height: 2),
                              CustomText.title(
                                text: "Get notified when it's time",
                                size: 12,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _reminderEnabled,
                          onChanged: (v) =>
                              setState(() => _reminderEnabled = v),
                          activeColor: medicineGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: medicineGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isEditing ? 'Update Medicine' : 'Add Medicine',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
      decoration: BoxDecoration(
        color: medicineGreen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isEditing ? 'Edit Medicine' : 'Add New Medicine',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Text(
            _isEditing
                ? 'Update your medication schedule'
                : 'Set up your medication schedule',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _typeOptions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (_, index) {
        final isSelected = _selectedTypeIndex == index;
        final option = _typeOptions[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedTypeIndex = index),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? medicineGreen : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(option.emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 4),
                Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? medicineGreen : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) =>
      CustomText.title(text: text, size: 13, isBold: true);

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        suffixText: suffixText,
        suffixStyle: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: medicineGreen),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _medicineType,
      hint: Text(
        'Select type',
        style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      ),
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: medicineGreen),
        ),
      ),
      items: _typeDropdownItems
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (v) => setState(() => _medicineType = v),
    );
  }

  Widget _buildDaySelector() {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final isActive = _selectedDays[i];
        return GestureDetector(
          onTap: () => setState(() => _selectedDays[i] = !_selectedDays[i]),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isActive ? medicineGreen : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeRow(int index) {
    final entry = _timeEntries[index];
    return Row(
      children: [
        _timeDropdown(
          value: entry.hour,
          items: List.generate(12, (i) => '${i + 1}'),
          onChanged: (v) => setState(() => entry.hour = v ?? entry.hour),
          width: 65,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            ':',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _timeDropdown(
          value: entry.minute,
          items: ['00', '15', '30', '45'],
          onChanged: (v) => setState(() => entry.minute = v ?? entry.minute),
          width: 70,
        ),
        const SizedBox(width: 10),
        _timeDropdown(
          value: entry.period,
          items: ['AM', 'PM'],
          onChanged: (v) => setState(() => entry.period = v ?? entry.period),
          width: 72,
        ),
        if (_timeEntries.length > 1) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _timeEntries.removeAt(index)),
            child: Icon(
              Icons.remove_circle_outline,
              color: Colors.red.shade400,
              size: 22,
            ),
          ),
        ],
      ],
    );
  }

  Widget _timeDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        isDense: true,
        isExpanded: true,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ---------- kept for backward compat ----------

class TitledTextField extends StatelessWidget {
  final String title;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  const TitledTextField({
    super.key,
    required this.title,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(
          text: title,
          size: 16,
        ).visible(isVisible: title.isNotEmpty),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }
}

class TitledDropdown extends StatelessWidget {
  final String title;
  final String? hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final double fontSize;

  const TitledDropdown({
    super.key,
    required this.title,
    this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText.title(
          text: title,
          size: fontSize,
        ).visible(isVisible: title.isNotEmpty),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
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
