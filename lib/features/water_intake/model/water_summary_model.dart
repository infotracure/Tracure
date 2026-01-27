// To parse this JSON data, do
//
//     final waterSummaryModel = waterSummaryModelFromJson(jsonString);

import 'dart:convert';

WaterSummaryModel waterSummaryModelFromJson(String str) =>
    WaterSummaryModel.fromJson(json.decode(str));

String waterSummaryModelToJson(WaterSummaryModel data) =>
    json.encode(data.toJson());

class WaterSummaryModel {
  final int? code;
  final Data? data;
  final String? message;

  WaterSummaryModel({this.code, this.data, this.message});

  factory WaterSummaryModel.fromJson(Map<String, dynamic> json) =>
      WaterSummaryModel(
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
  final int? totalMl;
  final int? dailyTargetMl;
  // final int? percentageAchieved;
  final int? recordsCount;

  Data({
    this.date,
    this.totalMl,
    this.dailyTargetMl,
    // this.percentageAchieved,
    this.recordsCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    totalMl: json["totalMl"],
    dailyTargetMl: json["dailyTargetMl"],
    // percentageAchieved: json["percentageAchieved"],
    recordsCount: json["recordsCount"],
  );

  Map<String, dynamic> toJson() => {
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "totalMl": totalMl,
    "dailyTargetMl": dailyTargetMl,
    // "percentageAchieved": percentageAchieved,
    "recordsCount": recordsCount,
  };
}
