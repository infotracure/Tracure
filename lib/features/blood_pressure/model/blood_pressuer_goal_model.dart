// To parse this JSON data, do
//
//     final bloodPressureGoalModel = bloodPressureGoalModelFromJson(jsonString);

import 'dart:convert';

BloodPressureGoalModel bloodPressureGoalModelFromJson(String str) =>
    BloodPressureGoalModel.fromJson(json.decode(str));

String bloodPressureGoalModelToJson(BloodPressureGoalModel data) =>
    json.encode(data.toJson());

class BloodPressureGoalModel {
  final int? code;
  final Data? data;
  final String? message;

  BloodPressureGoalModel({this.code, this.data, this.message});

  factory BloodPressureGoalModel.fromJson(Map<String, dynamic> json) =>
      BloodPressureGoalModel(
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
  final int? targetSystolicMin;
  final int? targetSystolicMax;
  final int? targetDiastolicMin;
  final int? targetDiastolicMax;
  final int? reminderIntervalMinutes;
  final DateTime? createdOn;
  final DateTime? updatedOn;

  Data({
    this.goalId,
    this.targetSystolicMin,
    this.targetSystolicMax,
    this.targetDiastolicMin,
    this.targetDiastolicMax,
    this.reminderIntervalMinutes,
    this.createdOn,
    this.updatedOn,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    goalId: json["goalId"],
    targetSystolicMin: json["targetSystolicMin"],
    targetSystolicMax: json["targetSystolicMax"],
    targetDiastolicMin: json["targetDiastolicMin"],
    targetDiastolicMax: json["targetDiastolicMax"],
    reminderIntervalMinutes: json["reminderIntervalMinutes"],
    createdOn: json["createdOn"] == null
        ? null
        : DateTime.parse(json["createdOn"]),
    updatedOn: json["updatedOn"] == null
        ? null
        : DateTime.parse(json["updatedOn"]),
  );

  Map<String, dynamic> toJson() => {
    "goalId": goalId,
    "targetSystolicMin": targetSystolicMin,
    "targetSystolicMax": targetSystolicMax,
    "targetDiastolicMin": targetDiastolicMin,
    "targetDiastolicMax": targetDiastolicMax,
    "reminderIntervalMinutes": reminderIntervalMinutes,
    "createdOn": createdOn?.toIso8601String(),
    "updatedOn": updatedOn?.toIso8601String(),
  };
}
