// To parse this JSON data, do
//
//     final stepAvgModel = stepAvgModelFromJson(jsonString);

import 'dart:convert';

StepAvgModel stepAvgModelFromJson(String str) => StepAvgModel.fromJson(json.decode(str));

String stepAvgModelToJson(StepAvgModel data) => json.encode(data.toJson());

class StepAvgModel {
    final int? code;
    final Data? data;
    final String? message;

    StepAvgModel({
        this.code,
        this.data,
        this.message,
    });

    factory StepAvgModel.fromJson(Map<String, dynamic> json) => StepAvgModel(
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
    final int? avgSteps;
    final int? avgDistance;
    final String? avgActiveTime;
    final int? avgCaloriesBurned;

    Data({
        this.avgSteps,
        this.avgDistance,
        this.avgActiveTime,
        this.avgCaloriesBurned,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        avgSteps: json["avgSteps"],
        avgDistance: json["avgDistance"],
        avgActiveTime: json["avgActiveTime"],
        avgCaloriesBurned: json["avgCaloriesBurned"],
    );

    Map<String, dynamic> toJson() => {
        "avgSteps": avgSteps,
        "avgDistance": avgDistance,
        "avgActiveTime": avgActiveTime,
        "avgCaloriesBurned": avgCaloriesBurned,
    };
}
