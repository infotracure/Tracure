// To parse this JSON data, do
//
//     final stepSummaryByRangeModel = stepSummaryByRangeModelFromJson(jsonString);

import 'dart:convert';

StepSummaryByRangeModel stepSummaryByRangeModelFromJson(String str) =>
    StepSummaryByRangeModel.fromJson(json.decode(str));

String stepSummaryByRangeModelToJson(StepSummaryByRangeModel data) =>
    json.encode(data.toJson());

class StepSummaryByRangeModel {
  final int? code;
  final List<Datum>? data;
  final String? message;

  StepSummaryByRangeModel({this.code, this.data, this.message});

  factory StepSummaryByRangeModel.fromJson(Map<String, dynamic> json) =>
      StepSummaryByRangeModel(
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
  final DateTime? stepDate;
  final int? steps;

  Datum({this.stepDate, this.steps});

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    stepDate: json["stepDate"] == null
        ? null
        : DateTime.parse(json["stepDate"]),
    steps: json["steps"],
  );

  Map<String, dynamic> toJson() => {
    "stepDate": stepDate?.toIso8601String(),
    "steps": steps,
  };
}
