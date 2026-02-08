// To parse this JSON data, do
//
//     final bloodSugarTrendModel = bloodSugarTrendModelFromJson(jsonString);

import 'dart:convert';

BloodSugarTrendModel bloodSugarTrendModelFromJson(String str) =>
    BloodSugarTrendModel.fromJson(json.decode(str));

String bloodSugarTrendModelToJson(BloodSugarTrendModel data) =>
    json.encode(data.toJson());

class BloodSugarTrendModel {
  final int? code;
  final Data? data;
  final String? message;

  BloodSugarTrendModel({this.code, this.data, this.message});

  factory BloodSugarTrendModel.fromJson(Map<String, dynamic> json) =>
      BloodSugarTrendModel(
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
  final DateTime? startDate;
  final DateTime? endDate;
  final int? totalDays;
  final List<Record>? records;

  Data({this.startDate, this.endDate, this.totalDays, this.records});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    startDate: json["startDate"] == null
        ? null
        : DateTime.parse(json["startDate"]),
    endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
    totalDays: json["totalDays"],
    records: json["records"] == null
        ? []
        : List<Record>.from(json["records"]!.map((x) => Record.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "startDate":
        "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "endDate":
        "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
    "totalDays": totalDays,
    "records": records == null
        ? []
        : List<dynamic>.from(records!.map((x) => x.toJson())),
  };
}

class Record {
  final DateTime? date;
  final int? avgValue;
  final int? minValue;
  final int? maxValue;
  final int? readingsCount;
  final String? category;

  Record({
    this.date,
    this.avgValue,
    this.minValue,
    this.maxValue,
    this.readingsCount,
    this.category,
  });

  factory Record.fromJson(Map<String, dynamic> json) => Record(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    avgValue: json["avgValue"],
    minValue: json["minValue"],
    maxValue: json["maxValue"],
    readingsCount: json["readingsCount"],
    category: json["category"],
  );

  Map<String, dynamic> toJson() => {
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "avgValue": avgValue,
    "minValue": minValue,
    "maxValue": maxValue,
    "readingsCount": readingsCount,
    "category": category,
  };
}
