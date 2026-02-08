// To parse this JSON data, do
//
//     final bloodPressureStatsModel = bloodPressureStatsModelFromJson(jsonString);

import 'dart:convert';

BloodPressureStatsModel bloodPressureStatsModelFromJson(String str) => BloodPressureStatsModel.fromJson(json.decode(str));

String bloodPressureStatsModelToJson(BloodPressureStatsModel data) => json.encode(data.toJson());

class BloodPressureStatsModel {
    final int? code;
    final Data? data;
    final String? message;

    BloodPressureStatsModel({
        this.code,
        this.data,
        this.message,
    });

    factory BloodPressureStatsModel.fromJson(Map<String, dynamic> json) => BloodPressureStatsModel(
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
    final int? avgSystolic;
    final int? avgDiastolic;
    final int? avgPulse;
    final int? minSystolic;
    final int? maxSystolic;
    final int? minDiastolic;
    final int? maxDiastolic;
    final int? totalReadings;
    final int? totalDays;
    final int? daysInRange;

    Data({
        this.startDate,
        this.endDate,
        this.avgSystolic,
        this.avgDiastolic,
        this.avgPulse,
        this.minSystolic,
        this.maxSystolic,
        this.minDiastolic,
        this.maxDiastolic,
        this.totalReadings,
        this.totalDays,
        this.daysInRange,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        avgSystolic: json["avgSystolic"],
        avgDiastolic: json["avgDiastolic"],
        avgPulse: json["avgPulse"],
        minSystolic: json["minSystolic"],
        maxSystolic: json["maxSystolic"],
        minDiastolic: json["minDiastolic"],
        maxDiastolic: json["maxDiastolic"],
        totalReadings: json["totalReadings"],
        totalDays: json["totalDays"],
        daysInRange: json["daysInRange"],
    );

    Map<String, dynamic> toJson() => {
        "startDate": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "endDate": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "avgSystolic": avgSystolic,
        "avgDiastolic": avgDiastolic,
        "avgPulse": avgPulse,
        "minSystolic": minSystolic,
        "maxSystolic": maxSystolic,
        "minDiastolic": minDiastolic,
        "maxDiastolic": maxDiastolic,
        "totalReadings": totalReadings,
        "totalDays": totalDays,
        "daysInRange": daysInRange,
    };
}
