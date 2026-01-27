import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tracure/utils/common_widget.dart';

import '../controller/home_controller.dart';

void showCheckInDialog(BuildContext context, DateTime date) {
  final homeController = Get.find<HomeController>();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Check in for today?"),
        content: Text(
          "You’re about to check in for\n"
          "${_formatDate(date)}",
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          CommonWidget.roundedButton(
            context: context,
            title: "Check-in",
            onTap: () {
              Navigator.of(context).pop(); // close dialog
              homeController.setGymCheckIn(
                date: DateFormat('yyyy-MM-dd').format(date),
              );
              // 👉 perform check-in logic here
            },
          ),
          // ElevatedButton(
          //   onPressed: () {
          //     Navigator.of(context).pop(); // close dialog
          //     homeController.setGymCheckIn(
          //       date: DateFormat('yyyy-MM-dd').format(date),
          //     );
          //     // 👉 perform check-in logic here
          //   },
          //   child: const Text("Check in 💪"),
          // ),
        ],
      );
    },
  );
}

String _formatDate(DateTime date) {
  return "${date.day}-${date.month}-${date.year}";
}
