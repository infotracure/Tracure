// To parse this JSON data, do
//
//     final stepSummaryByDateModel = stepSummaryByDateModelFromJson(jsonString);

import 'dart:convert';

StepSummaryByDateModel stepSummaryByDateModelFromJson(String str) =>
    StepSummaryByDateModel.fromJson(json.decode(str));

String stepSummaryByDateModelToJson(StepSummaryByDateModel data) =>
    json.encode(data.toJson());

class StepSummaryByDateModel {
  final int? code;
  final Data? data;
  final String? message;

  StepSummaryByDateModel({this.code, this.data, this.message});

  factory StepSummaryByDateModel.fromJson(Map<String, dynamic> json) =>
      StepSummaryByDateModel(
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
  final DateTime? stepDate;
  final int? steps;
  final int? stepGoals;
  final int? stepsRemaining;
  final dynamic distance;
  final dynamic activeTime;
  final dynamic caloriesBurned;
  final double? stepsPercentage;

  Data({
    this.stepDate,
    this.steps,
    this.stepGoals,
    this.stepsRemaining,
    this.distance,
    this.activeTime,
    this.caloriesBurned,
    this.stepsPercentage,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    stepDate: json["stepDate"] == null
        ? null
        : DateTime.parse(json["stepDate"]),
    steps: json["steps"],
    stepGoals: json["stepGoals"],
    stepsRemaining: json["stepsRemaining"],
    distance: json["distance"],
    activeTime: json["activeTime"],
    caloriesBurned: json["caloriesBurned"],
    stepsPercentage: (json["stepsPercentage"] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "stepDate":
        "${stepDate!.year.toString().padLeft(4, '0')}-${stepDate!.month.toString().padLeft(2, '0')}-${stepDate!.day.toString().padLeft(2, '0')}",
    "steps": steps,
    "stepGoals": stepGoals,
    "stepsRemaining": stepsRemaining,
    "distance": distance,
    "activeTime": activeTime,
    "caloriesBurned": caloriesBurned,
    "stepsPercentage": stepsPercentage,
  };
}
