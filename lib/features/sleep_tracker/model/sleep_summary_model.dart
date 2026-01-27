// To parse this JSON data, do
//
//     final sleepSummaryModel = sleepSummaryModelFromJson(jsonString);

import 'dart:convert';

SleepSummaryModel sleepSummaryModelFromJson(String str) => SleepSummaryModel.fromJson(json.decode(str));

String sleepSummaryModelToJson(SleepSummaryModel data) => json.encode(data.toJson());

class SleepSummaryModel {
    final int? code;
    final Data? data;
    final String? message;

    SleepSummaryModel({
        this.code,
        this.data,
        this.message,
    });

    factory SleepSummaryModel.fromJson(Map<String, dynamic> json) => SleepSummaryModel(
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
    final int? totalSleepMinutes;
    final String? totalSleepHours;
    final int? qualityScore;
    final String? sleepEfficiency;
    final int? awakenings;
    final int? timeToFallAsleepMinutes;
    final int? recordsCount;

    Data({
        this.date,
        this.totalSleepMinutes,
        this.totalSleepHours,
        this.qualityScore,
        this.sleepEfficiency,
        this.awakenings,
        this.timeToFallAsleepMinutes,
        this.recordsCount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        totalSleepMinutes: json["totalSleepMinutes"],
        totalSleepHours: json["totalSleepHours"],
        qualityScore: json["qualityScore"],
        sleepEfficiency: json["sleepEfficiency"],
        awakenings: json["awakenings"],
        timeToFallAsleepMinutes: json["timeToFallAsleepMinutes"],
        recordsCount: json["recordsCount"],
    );

    Map<String, dynamic> toJson() => {
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "totalSleepMinutes": totalSleepMinutes,
        "totalSleepHours": totalSleepHours,
        "qualityScore": qualityScore,
        "sleepEfficiency": sleepEfficiency,
        "awakenings": awakenings,
        "timeToFallAsleepMinutes": timeToFallAsleepMinutes,
        "recordsCount": recordsCount,
    };
}
