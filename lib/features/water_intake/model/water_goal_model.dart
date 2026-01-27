// To parse this JSON data, do
//
//     final waterGoalModel = waterGoalModelFromJson(jsonString);

import 'dart:convert';

WaterGoalModel waterGoalModelFromJson(String str) => WaterGoalModel.fromJson(json.decode(str));

String waterGoalModelToJson(WaterGoalModel data) => json.encode(data.toJson());

class WaterGoalModel {
    final int? code;
    final Data? data;
    final String? message;

    WaterGoalModel({
        this.code,
        this.data,
        this.message,
    });

    factory WaterGoalModel.fromJson(Map<String, dynamic> json) => WaterGoalModel(
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
    final int? dailyTargetMl;
    final int? reminderIntervalMinutes;
    final DateTime? createdOn;
    final DateTime? updatedOn;

    Data({
        this.goalId,
        this.dailyTargetMl,
        this.reminderIntervalMinutes,
        this.createdOn,
        this.updatedOn,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        goalId: json["goalId"],
        dailyTargetMl: json["dailyTargetMl"],
        reminderIntervalMinutes: json["reminderIntervalMinutes"],
        createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
        updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    );

    Map<String, dynamic> toJson() => {
        "goalId": goalId,
        "dailyTargetMl": dailyTargetMl,
        "reminderIntervalMinutes": reminderIntervalMinutes,
        "createdOn": createdOn?.toIso8601String(),
        "updatedOn": updatedOn?.toIso8601String(),
    };
}
