// To parse this JSON data, do
//
//     final fastingSummaryModel = fastingSummaryModelFromJson(jsonString);

import 'dart:convert';

FastingSummaryModel fastingSummaryModelFromJson(String str) => FastingSummaryModel.fromJson(json.decode(str));

String fastingSummaryModelToJson(FastingSummaryModel data) => json.encode(data.toJson());

class FastingSummaryModel {
    final int? code;
    final Data? data;
    final String? message;

    FastingSummaryModel({
        this.code,
        this.data,
        this.message,
    });

    factory FastingSummaryModel.fromJson(Map<String, dynamic> json) => FastingSummaryModel(
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
    final int? totalDurationMinutes;
    final String? totalDurationHours;
    final int? recordsCount;

    Data({
        this.date,
        this.totalDurationMinutes,
        this.totalDurationHours,
        this.recordsCount,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        totalDurationMinutes: json["totalDurationMinutes"],
        totalDurationHours: json["totalDurationHours"],
        recordsCount: json["recordsCount"],
    );

    Map<String, dynamic> toJson() => {
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "totalDurationMinutes": totalDurationMinutes,
        "totalDurationHours": totalDurationHours,
        "recordsCount": recordsCount,
    };
}
