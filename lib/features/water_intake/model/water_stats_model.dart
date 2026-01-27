// To parse this JSON data, do
//
//     final waterStatsModel = waterStatsModelFromJson(jsonString);

import 'dart:convert';

WaterStatsModel waterStatsModelFromJson(String str) => WaterStatsModel.fromJson(json.decode(str));

String waterStatsModelToJson(WaterStatsModel data) => json.encode(data.toJson());

class WaterStatsModel {
    final int? code;
    final Data? data;
    final String? message;

    WaterStatsModel({
        this.code,
        this.data,
        this.message,
    });

    factory WaterStatsModel.fromJson(Map<String, dynamic> json) => WaterStatsModel(
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
    final int? avgDailyMl;
    final int? dailyTargetMl;
    final double? avgPercentageAchieved;
    final int? totalDays;
    final int? daysGoalMet;

    Data({
        this.startDate,
        this.endDate,
        this.avgDailyMl,
        this.dailyTargetMl,
        this.avgPercentageAchieved,
        this.totalDays,
        this.daysGoalMet,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        avgDailyMl: json["avgDailyMl"],
        dailyTargetMl: json["dailyTargetMl"],
        avgPercentageAchieved: json["avgPercentageAchieved"]?.toDouble(),
        totalDays: json["totalDays"],
        daysGoalMet: json["daysGoalMet"],
    );

    Map<String, dynamic> toJson() => {
        "startDate": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "endDate": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "avgDailyMl": avgDailyMl,
        "dailyTargetMl": dailyTargetMl,
        "avgPercentageAchieved": avgPercentageAchieved,
        "totalDays": totalDays,
        "daysGoalMet": daysGoalMet,
    };
}
