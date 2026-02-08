// To parse this JSON data, do
//
//     final bloodSugarGoalModel = bloodSugarGoalModelFromJson(jsonString);

import 'dart:convert';

BloodSugarGoalModel bloodSugarGoalModelFromJson(String str) => BloodSugarGoalModel.fromJson(json.decode(str));

String bloodSugarGoalModelToJson(BloodSugarGoalModel data) => json.encode(data.toJson());

class BloodSugarGoalModel {
    final int? code;
    final Data? data;
    final String? message;

    BloodSugarGoalModel({
        this.code,
        this.data,
        this.message,
    });

    factory BloodSugarGoalModel.fromJson(Map<String, dynamic> json) => BloodSugarGoalModel(
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
    final int? fastingMin;
    final int? fastingMax;
    final int? beforeMealMin;
    final int? beforeMealMax;
    final int? afterMealMin;
    final int? afterMealMax;
    final int? bedtimeMin;
    final int? bedtimeMax;
    final int? reminderIntervalMinutes;
    final DateTime? createdOn;
    final DateTime? updatedOn;

    Data({
        this.goalId,
        this.fastingMin,
        this.fastingMax,
        this.beforeMealMin,
        this.beforeMealMax,
        this.afterMealMin,
        this.afterMealMax,
        this.bedtimeMin,
        this.bedtimeMax,
        this.reminderIntervalMinutes,
        this.createdOn,
        this.updatedOn,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        goalId: json["goalId"],
        fastingMin: json["fastingMin"],
        fastingMax: json["fastingMax"],
        beforeMealMin: json["beforeMealMin"],
        beforeMealMax: json["beforeMealMax"],
        afterMealMin: json["afterMealMin"],
        afterMealMax: json["afterMealMax"],
        bedtimeMin: json["bedtimeMin"],
        bedtimeMax: json["bedtimeMax"],
        reminderIntervalMinutes: json["reminderIntervalMinutes"],
        createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
        updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    );

    Map<String, dynamic> toJson() => {
        "goalId": goalId,
        "fastingMin": fastingMin,
        "fastingMax": fastingMax,
        "beforeMealMin": beforeMealMin,
        "beforeMealMax": beforeMealMax,
        "afterMealMin": afterMealMin,
        "afterMealMax": afterMealMax,
        "bedtimeMin": bedtimeMin,
        "bedtimeMax": bedtimeMax,
        "reminderIntervalMinutes": reminderIntervalMinutes,
        "createdOn": createdOn?.toIso8601String(),
        "updatedOn": updatedOn?.toIso8601String(),
    };
}
