import 'dart:convert';

StepSummaryRangeModel stepSummaryRangeModelFromJson(String str) =>
    StepSummaryRangeModel.fromJson(json.decode(str));

String stepSummaryRangeModelToJson(StepSummaryRangeModel data) =>
    json.encode(data.toJson());

class StepSummaryRangeModel {
  int? code;
  List<StepData>? data;
  String? message;

  StepSummaryRangeModel({
    this.code,
    this.data,
    this.message,
  });

  factory StepSummaryRangeModel.fromJson(Map<String, dynamic> json) =>
      StepSummaryRangeModel(
        code: json["code"],
        data: json["data"] == null
            ? []
            : List<StepData>.from(
                json["data"].map((x) => StepData.fromJson(x))),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
      };
}

class StepData {
  String? stepDate;
  int? steps;

  StepData({
    this.stepDate,
    this.steps,
  });

  factory StepData.fromJson(Map<String, dynamic> json) => StepData(
        stepDate: json["stepDate"],
        steps: json["steps"],
      );

  Map<String, dynamic> toJson() => {
        "stepDate": stepDate,
        "steps": steps,
      };
}
