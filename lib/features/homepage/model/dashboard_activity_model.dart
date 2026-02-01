// To parse this JSON data, do
//
//     final dashboardActivityModel = dashboardActivityModelFromJson(jsonString);

import 'dart:convert';

DashboardActivityModel dashboardActivityModelFromJson(String str) =>
    DashboardActivityModel.fromJson(json.decode(str));

String dashboardActivityModelToJson(DashboardActivityModel data) =>
    json.encode(data.toJson());

class DashboardActivityModel {
  final int? code;
  final Data? data;
  final String? message;

  DashboardActivityModel({this.code, this.data, this.message});

  factory DashboardActivityModel.fromJson(Map<String, dynamic> json) =>
      DashboardActivityModel(
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
  final Steps? steps;
  final Sleep? sleep;
  final Water? water;
  final double? overallScore;

  Data({this.date, this.steps, this.sleep, this.water, this.overallScore});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    steps: json["steps"] == null ? null : Steps.fromJson(json["steps"]),
    sleep: json["sleep"] == null ? null : Sleep.fromJson(json["sleep"]),
    water: json["water"] == null ? null : Water.fromJson(json["water"]),
    overallScore: json["overallScore"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "steps": steps?.toJson(),
    "sleep": sleep?.toJson(),
    "water": water?.toJson(),
    "overallScore": overallScore,
  };
}

class Sleep {
  final int? totalSleepMinutes;
  final String? totalSleepHours;
  final int? qualityScore;
  final String? sleepEfficiency;

  Sleep({
    this.totalSleepMinutes,
    this.totalSleepHours,
    this.qualityScore,
    this.sleepEfficiency,
  });

  factory Sleep.fromJson(Map<String, dynamic> json) => Sleep(
    totalSleepMinutes: json["totalSleepMinutes"],
    totalSleepHours: json["totalSleepHours"],
    qualityScore: json["qualityScore"],
    sleepEfficiency: json["sleepEfficiency"],
  );

  Map<String, dynamic> toJson() => {
    "totalSleepMinutes": totalSleepMinutes,
    "totalSleepHours": totalSleepHours,
    "qualityScore": qualityScore,
    "sleepEfficiency": sleepEfficiency,
  };
}

class Steps {
  final int? totalSteps;
  final int? stepGoal;
  final int? stepsRemaining;
  final double? stepsPercentage;

  Steps({
    this.totalSteps,
    this.stepGoal,
    this.stepsRemaining,
    this.stepsPercentage,
  });

  factory Steps.fromJson(Map<String, dynamic> json) => Steps(
    totalSteps: json["totalSteps"],
    stepGoal: json["stepGoal"],
    stepsRemaining: json["stepsRemaining"],
    stepsPercentage: json["stepsPercentage"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "totalSteps": totalSteps,
    "stepGoal": stepGoal,
    "stepsRemaining": stepsRemaining,
    "stepsPercentage": stepsPercentage,
  };
}

class Water {
  final int? totalMl;
  final int? dailyTargetMl;
  final double? percentageAchieved;
  final int? recordsCount;

  Water({
    this.totalMl,
    this.dailyTargetMl,
    this.percentageAchieved,
    this.recordsCount,
  });

  factory Water.fromJson(Map<String, dynamic> json) => Water(
    totalMl: json["totalMl"],
    dailyTargetMl: json["dailyTargetMl"],
    percentageAchieved: (json["percentageAchieved"] as num?)?.toDouble(),
    recordsCount: json["recordsCount"],
  );

  Map<String, dynamic> toJson() => {
    "totalMl": totalMl,
    "dailyTargetMl": dailyTargetMl,
    "percentageAchieved": percentageAchieved,
    "recordsCount": recordsCount,
  };
}
