// To parse this JSON data, do
//
//     final sleepTrendModel = sleepTrendModelFromJson(jsonString);

import 'dart:convert';

SleepTrendModel sleepTrendModelFromJson(String str) => SleepTrendModel.fromJson(json.decode(str));

String sleepTrendModelToJson(SleepTrendModel data) => json.encode(data.toJson());

class SleepTrendModel {
    final int? code;
    final Data? data;
    final String? message;

    SleepTrendModel({
        this.code,
        this.data,
        this.message,
    });

    factory SleepTrendModel.fromJson(Map<String, dynamic> json) => SleepTrendModel(
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
    final List<Trend>? trends;

    Data({
        this.date,
        this.trends,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        trends: json["trends"] == null ? [] : List<Trend>.from(json["trends"]!.map((x) => Trend.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "trends": trends == null ? [] : List<dynamic>.from(trends!.map((x) => x.toJson())),
    };
}

class Trend {
    final int? sleepId;
    final DateTime? startTime;
    final DateTime? endTime;
    final int? durationMinutes;
    final String? sleepStage;

    Trend({
        this.sleepId,
        this.startTime,
        this.endTime,
        this.durationMinutes,
        this.sleepStage,
    });

    factory Trend.fromJson(Map<String, dynamic> json) => Trend(
        sleepId: json["sleepId"],
        startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
        durationMinutes: json["durationMinutes"],
        sleepStage: json["sleepStage"],
    );

    Map<String, dynamic> toJson() => {
        "sleepId": sleepId,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "durationMinutes": durationMinutes,
        "sleepStage": sleepStage,
    };
}
