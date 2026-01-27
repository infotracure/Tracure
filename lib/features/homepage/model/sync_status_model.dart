// To parse this JSON data, do
//
//     final syncStatusModel = syncStatusModelFromJson(jsonString);

import 'dart:convert';

SyncStatusModel syncStatusModelFromJson(String str) =>
    SyncStatusModel.fromJson(json.decode(str));

String syncStatusModelToJson(SyncStatusModel data) =>
    json.encode(data.toJson());

class SyncStatusModel {
  final int? code;
  final Data? data;
  final String? message;

  SyncStatusModel({this.code, this.data, this.message});

  factory SyncStatusModel.fromJson(Map<String, dynamic> json) =>
      SyncStatusModel(
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
  final Sleep? steps;
  final Sleep? sleep;

  Data({this.steps, this.sleep});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    steps: json["steps"] == null ? null : Sleep.fromJson(json["steps"]),
    sleep: json["sleep"] == null ? null : Sleep.fromJson(json["sleep"]),
  );

  Map<String, dynamic> toJson() => {
    "steps": steps?.toJson(),
    "sleep": sleep?.toJson(),
  };
}

class Sleep {
  final DateTime? lastSyncTime;
  final int? syncCount;

  Sleep({this.lastSyncTime, this.syncCount});

  factory Sleep.fromJson(Map<String, dynamic> json) => Sleep(
    lastSyncTime: json["lastSyncTime"] == null
        ? null
        : DateTime.parse(json["lastSyncTime"]),
    syncCount: json["syncCount"],
  );

  Map<String, dynamic> toJson() => {
    "lastSyncTime": lastSyncTime?.toIso8601String(),
    "syncCount": syncCount,
  };
}
