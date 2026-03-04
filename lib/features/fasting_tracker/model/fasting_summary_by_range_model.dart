// To parse this JSON data, do
//
//     final fastingSummaryByRangeModel = fastingSummaryByRangeModelFromJson(jsonString);

import 'dart:convert';

FastingSummaryByRangeModel fastingSummaryByRangeModelFromJson(String str) => FastingSummaryByRangeModel.fromJson(json.decode(str));

String fastingSummaryByRangeModelToJson(FastingSummaryByRangeModel data) => json.encode(data.toJson());

class FastingSummaryByRangeModel {
    final int? code;
    final List<Datum>? data;
    final String? message;

    FastingSummaryByRangeModel({
        this.code,
        this.data,
        this.message,
    });

    factory FastingSummaryByRangeModel.fromJson(Map<String, dynamic> json) => FastingSummaryByRangeModel(
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
    final DateTime? fastingDate;
    final int? totalDurationMinutes;
    final String? totalDurationHours;
    final int? recordsCount;

    Datum({
        this.fastingDate,
        this.totalDurationMinutes,
        this.totalDurationHours,
        this.recordsCount,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        fastingDate: json["fastingDate"] == null ? null : DateTime.parse(json["fastingDate"]),
        totalDurationMinutes: json["totalDurationMinutes"],
        totalDurationHours: json["totalDurationHours"],
        recordsCount: json["recordsCount"],
    );

    Map<String, dynamic> toJson() => {
        "fastingDate": "${fastingDate!.year.toString().padLeft(4, '0')}-${fastingDate!.month.toString().padLeft(2, '0')}-${fastingDate!.day.toString().padLeft(2, '0')}",
        "totalDurationMinutes": totalDurationMinutes,
        "totalDurationHours": totalDurationHours,
        "recordsCount": recordsCount,
    };
}
