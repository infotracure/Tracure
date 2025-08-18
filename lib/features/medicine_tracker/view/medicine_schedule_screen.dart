import 'package:flutter/material.dart';
import 'package:tracure/utils/common_appbar.dart';
import 'package:tracure/utils/common_widget.dart';

import '../../../utils/custom_text.dart';
import 'add_medicine_bottom_sheet.dart';

class MedicineScheduleScreen extends StatelessWidget {
  const MedicineScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: "Schedule"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListView.separated(
              itemBuilder: (context, index) {
                return MedicineCard(
                  name: "Paracetamol",
                  type: "Tablet",
                  img: "assets/images/ic_med_tablet.png",
                  enabled: true,
                  days: [1, 2, 3, 4, 5], // Mon-Fri
                  times: const [
                    TimeSlot("Morning", "09:30am", true),
                    TimeSlot("Afternoon", "02:30pm", true),
                    TimeSlot("Evening", "09:30pm", true),
                  ],
                );
              },
              itemCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: 16),
            ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => AddMedicineBottomSheet.show(context),
              icon: const Icon(Icons.add, color: Colors.green, size: 24),
              label: CustomText.title(
                text: "Add New Medicine",
                size: 16,
                isBold: true,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: CommonWidget.containerDecoration(),
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Medicines Selected: ",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextSpan(
                    text: "02",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
            Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              label: CustomText.title(
                text: "Create",
                size: 16,
                isBold: true,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- COMPONENTS --------------------
class MedicineCard extends StatelessWidget {
  final String name;
  final String type;
  final String img;
  final bool enabled;
  final List<int> days; // 1=Mon, ... 7=Sun
  final List<TimeSlot> times;

  const MedicineCard({
    super.key,
    required this.name,
    required this.type,
    required this.img,
    required this.enabled,
    required this.days,
    required this.times,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CommonWidget.containerDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Header
            Row(
              children: [
                Image.asset(img, height: 30),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(type, style: const TextStyle(fontSize: 14)),
                  ],
                ),
                Spacer(),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: enabled,
                    onChanged: (_) {},
                    activeColor: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Days
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                return Expanded(
                  child: DaySelector(
                    label: ["M", "T", "W", "T", "F", "S", "S"][index],
                    selected: days.contains(index + 1),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),

            // Time Slots
            Column(
              children: times
                  .map(
                    (t) => TimeRow(
                      label: t.label,
                      time: t.time,
                      checked: t.checked,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------- DAY SELECTOR --------------------
class DaySelector extends StatelessWidget {
  final String label;
  final bool selected;

  const DaySelector({super.key, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 35,
      decoration: BoxDecoration(
        color: selected ? Colors.green : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(label, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

// -------------------- TIME ROW --------------------
class TimeRow extends StatelessWidget {
  final String label;
  final String time;
  final bool checked;

  const TimeRow({
    super.key,
    required this.label,
    required this.time,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (_) {},
              activeColor: Colors.green,
            ),
            Text(label),
          ],
        ),
        Text(time),
      ],
    );
  }
}

// -------------------- TIME MODEL --------------------
class TimeSlot {
  final String label;
  final String time;
  final bool checked;

  const TimeSlot(this.label, this.time, this.checked);
}
