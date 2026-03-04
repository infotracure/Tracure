// To parse this JSON data, do
//
//     final fastingStatsModel = fastingStatsModelFromJson(jsonString);

import 'dart:convert';

FastingStatsModel fastingStatsModelFromJson(String str) => FastingStatsModel.fromJson(json.decode(str));

String fastingStatsModelToJson(FastingStatsModel data) => json.encode(data.toJson());

class FastingStatsModel {
    final int? code;
    final Data? data;
    final String? message;

    FastingStatsModel({
        this.code,
        this.data,
        this.message,
    });

    factory FastingStatsModel.fromJson(Map<String, dynamic> json) => FastingStatsModel(
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
    final int? avgDurationMinutes;
    final String? avgDurationFormatted;
    final int? maxDurationMinutes;
    final int? minDurationMinutes;
    final int? totalDurationMinutes;
    final int? recordsCount;

    Data({
        this.startDate,
        this.endDate,
        this.avgDurationMinutes,
        this.avgDurationFormatted,
        this.maxDurationMinutes,
        this.minDurationMinutes,
        this.totalDurationMinutes,
        this.recordsCount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        avgDurationMinutes: json["avgDurationMinutes"],
        avgDurationFormatted: json["avgDurationFormatted"],
        maxDurationMinutes: json["maxDurationMinutes"],
        minDurationMinutes: json["minDurationMinutes"],
        totalDurationMinutes: json["totalDurationMinutes"],
        recordsCount: json["recordsCount"],
    );

    Map<String, dynamic> toJson() => {
        "startDate": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "endDate": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "avgDurationMinutes": avgDurationMinutes,
        "avgDurationFormatted": avgDurationFormatted,
        "maxDurationMinutes": maxDurationMinutes,
        "minDurationMinutes": minDurationMinutes,
        "totalDurationMinutes": totalDurationMinutes,
        "recordsCount": recordsCount,
    };
}
