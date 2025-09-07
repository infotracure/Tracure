// To parse this JSON data, do
//
//     final userConfigurationModel = userConfigurationModelFromJson(jsonString);

import 'dart:convert';

UserConfigurationModel userConfigurationModelFromJson(String str) => UserConfigurationModel.fromJson(json.decode(str));

String userConfigurationModelToJson(UserConfigurationModel data) => json.encode(data.toJson());

class UserConfigurationModel {
    final int? code;
    final Data? data;
    final String? message;

    UserConfigurationModel({
        this.code,
        this.data,
        this.message,
    });

    factory UserConfigurationModel.fromJson(Map<String, dynamic> json) => UserConfigurationModel(
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
    final String? sleepStartTime;
    final String? sleepStopTime;
    final String? sleepHardStopTime;
    final String? lastSyncTimeSteps;

    Data({
        this.sleepStartTime,
        this.sleepStopTime,
        this.sleepHardStopTime,
        this.lastSyncTimeSteps,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        sleepStartTime: json["sleepStartTime"],
        sleepStopTime: json["sleepStopTime"],
        sleepHardStopTime: json["sleepHardStopTime"],
        lastSyncTimeSteps: json["lastSyncTimeSteps"],
    );

    Map<String, dynamic> toJson() => {
        "sleepStartTime": sleepStartTime,
        "sleepStopTime": sleepStopTime,
        "sleepHardStopTime": sleepHardStopTime,
        "lastSyncTimeSteps": lastSyncTimeSteps,
    };
}
