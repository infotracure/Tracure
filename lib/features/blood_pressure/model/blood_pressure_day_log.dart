// To parse this JSON data, do
//
//     final bloodPressureDayLogModel = bloodPressureDayLogModelFromJson(jsonString);

import 'dart:convert';

BloodPressureDayLogModel bloodPressureDayLogModelFromJson(String str) =>
    BloodPressureDayLogModel.fromJson(json.decode(str));

String bloodPressureDayLogModelToJson(BloodPressureDayLogModel data) =>
    json.encode(data.toJson());

class BloodPressureDayLogModel {
  final int? code;
  final Data? data;
  final String? message;

  BloodPressureDayLogModel({this.code, this.data, this.message});

  factory BloodPressureDayLogModel.fromJson(Map<String, dynamic> json) =>
      BloodPressureDayLogModel(
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
  final int? systolic;
  final int? diastolic;
  final int? pulse;
  final String? position;
  final String? arm;
  final dynamic notes;
  final String? category;

  Reading({
    this.readingId,
    this.measurementTime,
    this.systolic,
    this.diastolic,
    this.pulse,
    this.position,
    this.arm,
    this.notes,
    this.category,
  });

  factory Reading.fromJson(Map<String, dynamic> json) => Reading(
    readingId: json["readingId"],
    measurementTime: json["measurementTime"] == null
        ? null
        : DateTime.parse(json["measurementTime"]),
    systolic: json["systolic"],
    diastolic: json["diastolic"],
    pulse: json["pulse"],
    position: json["position"],
    arm: json["arm"],
    notes: json["notes"],
    category: json["category"],
  );

  Map<String, dynamic> toJson() => {
    "readingId": readingId,
    "measurementTime": measurementTime?.toIso8601String(),
    "systolic": systolic,
    "diastolic": diastolic,
    "pulse": pulse,
    "position": position,
    "arm": arm,
    "notes": notes,
    "category": category,
  };
}
