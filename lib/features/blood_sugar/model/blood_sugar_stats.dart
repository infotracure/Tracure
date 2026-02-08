// To parse this JSON data, do
//
//     final bloodSugarStatsModel = bloodSugarStatsModelFromJson(jsonString);

import 'dart:convert';

BloodSugarStatsModel bloodSugarStatsModelFromJson(String str) => BloodSugarStatsModel.fromJson(json.decode(str));

String bloodSugarStatsModelToJson(BloodSugarStatsModel data) => json.encode(data.toJson());

class BloodSugarStatsModel {
    final int? code;
    final Data? data;
    final String? message;

    BloodSugarStatsModel({
        this.code,
        this.data,
        this.message,
    });

    factory BloodSugarStatsModel.fromJson(Map<String, dynamic> json) => BloodSugarStatsModel(
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
    final int? avgValue;
    final int? minValue;
    final int? maxValue;
    final int? totalReadings;
    final int? totalDays;
    final int? daysInRange;
    final List<ByContext>? byContext;

    Data({
        this.startDate,
        this.endDate,
        this.avgValue,
        this.minValue,
        this.maxValue,
        this.totalReadings,
        this.totalDays,
        this.daysInRange,
        this.byContext,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        avgValue: json["avgValue"],
        minValue: json["minValue"],
        maxValue: json["maxValue"],
        totalReadings: json["totalReadings"],
        totalDays: json["totalDays"],
        daysInRange: json["daysInRange"],
        byContext: json["byContext"] == null ? [] : List<ByContext>.from(json["byContext"]!.map((x) => ByContext.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "startDate": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "endDate": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "avgValue": avgValue,
        "minValue": minValue,
        "maxValue": maxValue,
        "totalReadings": totalReadings,
        "totalDays": totalDays,
        "daysInRange": daysInRange,
        "byContext": byContext == null ? [] : List<dynamic>.from(byContext!.map((x) => x.toJson())),
    };
}

class ByContext {
    final String? context;
    final int? avgValue;
    final int? minValue;
    final int? maxValue;
    final int? readingsCount;

    ByContext({
        this.context,
        this.avgValue,
        this.minValue,
        this.maxValue,
        this.readingsCount,
    });

    factory ByContext.fromJson(Map<String, dynamic> json) => ByContext(
        context: json["context"],
        avgValue: json["avgValue"],
        minValue: json["minValue"],
        maxValue: json["maxValue"],
        readingsCount: json["readingsCount"],
    );

    Map<String, dynamic> toJson() => {
        "context": context,
        "avgValue": avgValue,
        "minValue": minValue,
        "maxValue": maxValue,
        "readingsCount": readingsCount,
    };
}
