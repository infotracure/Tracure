// To parse this JSON data, do
//
//     final bloodSugarDayLogModel = bloodSugarDayLogModelFromJson(jsonString);

import 'dart:convert';

BloodSugarDayLogModel bloodSugarDayLogModelFromJson(String str) =>
    BloodSugarDayLogModel.fromJson(json.decode(str));

String bloodSugarDayLogModelToJson(BloodSugarDayLogModel data) =>
    json.encode(data.toJson());

class BloodSugarDayLogModel {
  final int? code;
  final Data? data;
  final String? message;

  BloodSugarDayLogModel({this.code, this.data, this.message});

  factory BloodSugarDayLogModel.fromJson(Map<String, dynamic> json) =>
      BloodSugarDayLogModel(
        code: json["code"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "data": data?.toJson(),
    "message": message,
  };
}

class Data {
  final DateTime? date;
  final List<Reading>? readings;
  final int? count;

  Data({this.date, this.readings, this.count});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    readings: json["readings"] == null
        ? []
        : List<Reading>.from(json["readings"]!.map((x) => Reading.fromJson(x))),
    count: json["count"],
  );

  Map<String, dynamic> toJson() => {
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "readings": readings == null
        ? []
        : List<dynamic>.from(readings!.map((x) => x.toJson())),
    "count": count,
  };
}

class Reading {
  final int? readingId;
  final DateTime? measurementTime;
  final int? value;
  final String? unit;
  final String? measurementContext;
  final String? mealType;
  final String? notes;
  final String? category;

  Reading({
    this.readingId,
    this.measurementTime,
    this.value,
    this.unit,
    this.measurementContext,
    this.mealType,
    this.notes,
    this.category,
  });

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
    readingId: json["readingId"],
    measurementTime: json["measurementTime"] == null
        ? null
        : DateTime.parse(json["measurementTime"]),
    value: json["value"],
    unit: json["unit"],
    measurementContext: json["measurementContext"],
    mealType: json["mealType"],
    notes: json["notes"],
    category: json["category"],
  );

  Map<String, dynamic> toJson() => {
    "readingId": readingId,
    "measurementTime": measurementTime?.toIso8601String(),
    "value": value,
    "unit": unit,
    "measurementContext": measurementContext,
    "mealType": mealType,
    "notes": notes,
    "category": category,
  };
}
