// To parse this JSON data, do
//
//     final waterTrendModel = waterTrendModelFromJson(jsonString);

import 'dart:convert';

WaterTrendModel waterTrendModelFromJson(String str) =>
    WaterTrendModel.fromJson(json.decode(str));

String waterTrendModelToJson(WaterTrendModel data) =>
    json.encode(data.toJson());

class WaterTrendModel {
  final int? code;
  final Data? data;
  final String? message;

  WaterTrendModel({this.code, this.data, this.message});

  factory WaterTrendModel.fromJson(Map<String, dynamic> json) =>
      WaterTrendModel(
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
  final int? dailyTargetMl;
  final int? totalMl;
  // final int? percentageAchieved;
  final List<Record>? records;

  Data({
    this.date,
    this.dailyTargetMl,
    this.totalMl,
    // this.percentageAchieved,
    this.records,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    dailyTargetMl: json["dailyTargetMl"],
    totalMl: json["totalMl"],
    // percentageAchieved: json["percentageAchieved"],
    records: json["records"] == null
        ? []
        : List<Record>.from(json["records"]!.map((x) => Record.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "dailyTargetMl": dailyTargetMl,
    "totalMl": totalMl,
    // "percentageAchieved": percentageAchieved,
    "records": records == null
        ? []
        : List<dynamic>.from(records!.map((x) => x.toJson())),
  };
}

class Record {
  final int? intakeId;
  final DateTime? intakeTime;
  final int? amountMl;
  final String? beverageType;

  Record({this.intakeId, this.intakeTime, this.amountMl, this.beverageType});

  factory Record.fromJson(Map<String, dynamic> json) => Record(
    intakeId: json["intakeId"],
    intakeTime: json["intakeTime"] == null
        ? null
        : DateTime.parse(json["intakeTime"]),
    amountMl: json["amountMl"],
    beverageType: json["beverageType"],
  );

  Map<String, dynamic> toJson() => {
    "intakeId": intakeId,
    "intakeTime": intakeTime?.toIso8601String(),
    "amountMl": amountMl,
    "beverageType": beverageType,
  };
}
