// To parse this JSON data, do
//
//     final fastingGoalModel = fastingGoalModelFromJson(jsonString);

import 'dart:convert';

FastingGoalModel fastingGoalModelFromJson(String str) => FastingGoalModel.fromJson(json.decode(str));

String fastingGoalModelToJson(FastingGoalModel data) => json.encode(data.toJson());

class FastingGoalModel {
    final int? code;
    final Data? data;
    final String? message;

    FastingGoalModel({
        this.code,
        this.data,
        this.message,
    });

    factory FastingGoalModel.fromJson(Map<String, dynamic> json) => FastingGoalModel(
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
    final int? goalId;
    final int? targetDurationMinutes;
    final String? fastingType;
    final DateTime? createdOn;
    final DateTime? updatedOn;

    Data({
        this.goalId,
        this.targetDurationMinutes,
        this.fastingType,
        this.createdOn,
        this.updatedOn,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        goalId: json["goalId"],
        targetDurationMinutes: json["targetDurationMinutes"],
        fastingType: json["fastingType"],
        createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
        updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    );

    Map<String, dynamic> toJson() => {
        "goalId": goalId,
        "targetDurationMinutes": targetDurationMinutes,
        "fastingType": fastingType,
        "createdOn": createdOn?.toIso8601String(),
        "updatedOn": updatedOn?.toIso8601String(),
    };
}
