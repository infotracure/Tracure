// To parse this JSON data, do
//
//     final waterSummaryByRangeModel = waterSummaryByRangeModelFromJson(jsonString);

import 'dart:convert';

WaterSummaryByRangeModel waterSummaryByRangeModelFromJson(String str) =>
    WaterSummaryByRangeModel.fromJson(json.decode(str));

String waterSummaryByRangeModelToJson(WaterSummaryByRangeModel data) =>
    json.encode(data.toJson());

class WaterSummaryByRangeModel {
  final int? code;
  final List<Datum>? data;
  final String? message;

  WaterSummaryByRangeModel({this.code, this.data, this.message});

  factory WaterSummaryByRangeModel.fromJson(Map<String, dynamic> json) =>
      WaterSummaryByRangeModel(
        code: json["code"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "message": message,
  };
}

class Datum {
  final DateTime? summaryDate;
  final int? totalMl;
  final int? recordsCount;

  Datum({this.summaryDate, this.totalMl, this.recordsCount});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    summaryDate: json["summaryDate"] == null
        ? null
        : DateTime.parse(json["summaryDate"]),
    totalMl: json["totalMl"],
    recordsCount: json["recordsCount"],
  );

  Map<String, dynamic> toJson() => {
    "summaryDate":
        "${summaryDate!.year.toString().padLeft(4, '0')}-${summaryDate!.month.toString().padLeft(2, '0')}-${summaryDate!.day.toString().padLeft(2, '0')}",
    "totalMl": totalMl,
    "recordsCount": recordsCount,
  };
}
