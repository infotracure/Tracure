import 'dart:convert';

StepSettingModel stepSettingModelFromJson(String str) => StepSettingModel.fromJson(json.decode(str));

String stepSettingModelToJson(StepSettingModel data) => json.encode(data.toJson());

class StepSettingModel {
  int? code;
  Data? data;
  String? message;

  StepSettingModel({
    this.code,
    this.data,
    this.message,
  });

  factory StepSettingModel.fromJson(Map<String, dynamic> json) => StepSettingModel(
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
  int? goals;

  Data({
    this.goals,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    goals: json["goals"],
  );

  Map<String, dynamic> toJson() => {
    "goals": goals,
  };
}