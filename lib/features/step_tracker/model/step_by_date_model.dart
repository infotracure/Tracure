import 'dart:convert';

StepByDateModel stepByDateModelFromJson(String str) =>
    StepByDateModel.fromJson(json.decode(str));

String stepByDateModelToJson(StepByDateModel data) =>
    json.encode(data.toJson());

class StepByDateModel {
  final int? code;
  final List<StepData>? data;
  final String? message;

  StepByDateModel({this.code, this.data, this.message});

  factory StepByDateModel.fromJson(Map<String, dynamic> json) {
    return StepByDateModel(
      code: json['code'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => StepData.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class StepData {
  final String? stepDate;
  final String? startTime;
  final String? endTime;
  final int? steps;

  StepData({this.stepDate, this.startTime, this.endTime, this.steps});

  factory StepData.fromJson(Map<String, dynamic> json) {
    return StepData(
      stepDate: json['stepDate'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      steps: json['steps'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepDate': stepDate,
      'startTime': startTime,
      'endTime': endTime,
      'steps': steps,
    };
  }
}
