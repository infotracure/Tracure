// To parse this JSON data, do
//
//     final stepByDateModel = stepByDateModelFromJson(jsonString);

import 'dart:convert';

StepByDateModel stepByDateModelFromJson(String str) => StepByDateModel.fromJson(json.decode(str));

String stepByDateModelToJson(StepByDateModel data) => json.encode(data.toJson());

class StepByDateModel {
    final int? code;
    final List<Datum>? data;
    final String? message;

    StepByDateModel({
        this.code,
        this.data,
        this.message,
    });

    factory StepByDateModel.fromJson(Map<String, dynamic> json) => StepByDateModel(
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
    final DateTime? stepDate;
    final DateTime? startTime;
    final DateTime? endTime;
    final int? steps;

    Datum({
        this.stepDate,
        this.startTime,
        this.endTime,
        this.steps,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        stepDate: json["stepDate"] == null ? null : DateTime.parse(json["stepDate"]),
        startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
        steps: json["steps"],
    );

    Map<String, dynamic> toJson() => {
        "stepDate": stepDate?.toIso8601String(),
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "steps": steps,
    };
}
