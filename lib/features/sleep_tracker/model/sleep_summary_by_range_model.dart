// To parse this JSON data, do
//
//     final sleepSummaryByRangeModel = sleepSummaryByRangeModelFromJson(jsonString);

import 'dart:convert';

SleepSummaryByRangeModel sleepSummaryByRangeModelFromJson(String str) => SleepSummaryByRangeModel.fromJson(json.decode(str));

String sleepSummaryByRangeModelToJson(SleepSummaryByRangeModel data) => json.encode(data.toJson());

class SleepSummaryByRangeModel {
    final int? code;
    final List<Datum>? data;
    final String? message;

    SleepSummaryByRangeModel({
        this.code,
        this.data,
        this.message,
    });

    factory SleepSummaryByRangeModel.fromJson(Map<String, dynamic> json) => SleepSummaryByRangeModel(
        code: json["code"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class Datum {
    final DateTime? summaryDate;
    final int? totalSleepMinutes;
    final String? totalSleepHours;
    final int? avgQualityScore;
    final String? avgSleepEfficiency;
    final int? recordsCount;

    Datum({
        this.summaryDate,
        this.totalSleepMinutes,
        this.totalSleepHours,
        this.avgQualityScore,
        this.avgSleepEfficiency,
        this.recordsCount,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        summaryDate: json["summaryDate"] == null ? null : DateTime.parse(json["summaryDate"]),
        totalSleepMinutes: json["totalSleepMinutes"],
        totalSleepHours: json["totalSleepHours"],
        avgQualityScore: json["avgQualityScore"],
        avgSleepEfficiency: json["avgSleepEfficiency"],
        recordsCount: json["recordsCount"],
    );

    Map<String, dynamic> toJson() => {
        "summaryDate": "${summaryDate!.year.toString().padLeft(4, '0')}-${summaryDate!.month.toString().padLeft(2, '0')}-${summaryDate!.day.toString().padLeft(2, '0')}",
        "totalSleepMinutes": totalSleepMinutes,
        "totalSleepHours": totalSleepHours,
        "avgQualityScore": avgQualityScore,
        "avgSleepEfficiency": avgSleepEfficiency,
        "recordsCount": recordsCount,
    };
}
