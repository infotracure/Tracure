import 'dart:convert';

StepAverageModel stepAverageModelModelFromJson(String str) =>
    StepAverageModel.fromJson(json.decode(str));

String stepAverageModelModelToJson(StepAverageModel data) =>
    json.encode(data.toJson());

class StepAverageModel {
  int? code;
  Data? data;
  String? message;

  StepAverageModel({
    this.code,
    this.data,
    this.message,
  });

  factory StepAverageModel.fromJson(Map<String, dynamic> json) => StepAverageModel(
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
  int? avgSteps;
  int? avgDistance;
  String? avgActiveTime;
  int? avgCaloriesBurned;

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