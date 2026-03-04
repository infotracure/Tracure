// To parse this JSON data, do
//
//     final fastingByDateModel = fastingByDateModelFromJson(jsonString);

import 'dart:convert';

FastingByDateModel fastingByDateModelFromJson(String str) => FastingByDateModel.fromJson(json.decode(str));

String fastingByDateModelToJson(FastingByDateModel data) => json.encode(data.toJson());

class FastingByDateModel {
    final int? code;
    final List<Datum>? data;
    final String? message;

    FastingByDateModel({
        this.code,
        this.data,
        this.message,
    });

    factory FastingByDateModel.fromJson(Map<String, dynamic> json) => FastingByDateModel(
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
    final int? fastingId;
    final String? uuid;
    final DateTime? startTime;
    final DateTime? endTime;
    final int? durationMinutes;
    final String? platform;
    final String? sourceName;

    Datum({
        this.fastingId,
        this.uuid,
        this.startTime,
        this.endTime,
        this.durationMinutes,
        this.platform,
        this.sourceName,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        fastingId: json["fastingId"],
        uuid: json["uuid"],
        startTime: json["startTime"] == null ? null : DateTime.parse(json["startTime"]),
        endTime: json["endTime"] == null ? null : DateTime.parse(json["endTime"]),
        durationMinutes: json["durationMinutes"],
        platform: json["platform"],
        sourceName: json["sourceName"],
    );

    Map<String, dynamic> toJson() => {
        "fastingId": fastingId,
        "uuid": uuid,
        "startTime": startTime?.toIso8601String(),
        "endTime": endTime?.toIso8601String(),
        "durationMinutes": durationMinutes,
        "platform": platform,
        "sourceName": sourceName,
    };
}
