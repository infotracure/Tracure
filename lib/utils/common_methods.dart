import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:tracure/servies/hive_service.dart';
import 'package:uuid/uuid.dart';

void devLog(
  String message, {
  String name = 'APP-LOG',
  Object? error,
  StackTrace? stackTrace,
}) {
  if (kDebugMode) {
    log(message, name: name, error: error, stackTrace: stackTrace);
  }
}

DateTime startOfWeek(DateTime date) {
  return DateTime(
    date.year,
    date.month,
    date.day,
  ).subtract(Duration(days: date.weekday - 1)); // Monday
}

DateTime endOfWeek(DateTime date) {
  return startOfWeek(date).add(const Duration(days: 6));
}

String formatWeekRange(DateTime selected) {
  final start = startOfWeek(selected);
  final end = endOfWeek(selected);

  final monthName = _monthName(start.month);
  // if week spans two months, show both
  if (start.month != end.month) {
    return "${start.day} ${_monthName(start.month)} - ${end.day} ${_monthName(end.month)} ${end.year}";
  } else {
    return "${start.day}-${end.day} $monthName ${end.year}";
  }
}

String _monthName(int month) {
  const months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];
  return months[month - 1];
}

bool isToday(DateTime dateTime) {
  final now = DateTime.now();
  return dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;
}

Future<String> getOrCreateDeviceId() async {
  final existingId = HiveService.instance.getString(HiveService.deviceId);

  if (existingId != null) return existingId;

  final newId = const Uuid().v4();
  await HiveService.instance.save(newId, HiveService.deviceId);
  return newId;
}

String minutesToHours(int minutes) {
  final hours = minutes ~/ 60;
  final remainingMinutes = minutes % 60;

  if (hours > 0 && remainingMinutes > 0) {
    return '$hours hr $remainingMinutes min';
  } else if (hours > 0) {
    return '$hours hr';
  } else {
    return '$remainingMinutes min';
  }
}
