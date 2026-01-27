// To parse this JSON data, do
//
//     final sleepGoalModel = sleepGoalModelFromJson(jsonString);

import 'dart:convert';

SleepGoalModel sleepGoalModelFromJson(String str) => SleepGoalModel.fromJson(json.decode(str));

String sleepGoalModelToJson(SleepGoalModel data) => json.encode(data.toJson());

class SleepGoalModel {
    final int? code;
    final Data? data;
    final String? message;

    SleepGoalModel({
        this.code,
        this.data,
        this.message,
    });

    factory SleepGoalModel.fromJson(Map<String, dynamic> json) => SleepGoalModel(
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
    final String? preferredBedtime;
    final String? preferredWaketime;
    final int? targetDurationMinutes;
    final DateTime? createdOn;
    final DateTime? updatedOn;

    Data({
        this.goalId,
        this.preferredBedtime,
        this.preferredWaketime,
        this.targetDurationMinutes,
        this.createdOn,
        this.updatedOn,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        goalId: json["goalId"],
        preferredBedtime: json["preferredBedtime"],
        preferredWaketime: json["preferredWaketime"],
        targetDurationMinutes: json["targetDurationMinutes"],
        createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
        updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    );

    Map<String, dynamic> toJson() => {
        "goalId": goalId,
        "preferredBedtime": preferredBedtime,
        "preferredWaketime": preferredWaketime,
        "targetDurationMinutes": targetDurationMinutes,
        "createdOn": createdOn?.toIso8601String(),
        "updatedOn": updatedOn?.toIso8601String(),
    };
}
