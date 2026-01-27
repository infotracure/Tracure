// To parse this JSON data, do
//
//     final sleepStatsModel = sleepStatsModelFromJson(jsonString);

import 'dart:convert';

SleepStatsModel sleepStatsModelFromJson(String str) => SleepStatsModel.fromJson(json.decode(str));

String sleepStatsModelToJson(SleepStatsModel data) => json.encode(data.toJson());

class SleepStatsModel {
    final int? code;
    final Data? data;
    final String? message;

    SleepStatsModel({
        this.code,
        this.data,
        this.message,
    });

    factory SleepStatsModel.fromJson(Map<String, dynamic> json) => SleepStatsModel(
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
    final String? avgBedtime;
    final String? avgWaketime;
    final int? avgDurationMinutes;
    final String? avgDurationFormatted;
    final int? timeToFallAsleepMinutes;
    final String? sleepEfficiency;
    final int? recordsCount;

    Data({
        this.startDate,
        this.endDate,
        this.avgBedtime,
        this.avgWaketime,
        this.avgDurationMinutes,
        this.avgDurationFormatted,
        this.timeToFallAsleepMinutes,
        this.sleepEfficiency,
        this.recordsCount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        avgBedtime: json["avgBedtime"],
        avgWaketime: json["avgWaketime"],
        avgDurationMinutes: json["avgDurationMinutes"],
        avgDurationFormatted: json["avgDurationFormatted"],
        timeToFallAsleepMinutes: json["timeToFallAsleepMinutes"],
        sleepEfficiency: json["sleepEfficiency"],
        recordsCount: json["recordsCount"],
    );

    Map<String, dynamic> toJson() => {
        "startDate": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "endDate": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "avgBedtime": avgBedtime,
        "avgWaketime": avgWaketime,
        "avgDurationMinutes": avgDurationMinutes,
        "avgDurationFormatted": avgDurationFormatted,
        "timeToFallAsleepMinutes": timeToFallAsleepMinutes,
        "sleepEfficiency": sleepEfficiency,
        "recordsCount": recordsCount,
    };
}
