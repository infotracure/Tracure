// To parse this JSON data, do
//
//     final bloodPressureSummaryModel = bloodPressureSummaryModelFromJson(jsonString);

import 'dart:convert';

BloodPressureSummaryModel bloodPressureSummaryModelFromJson(String str) => BloodPressureSummaryModel.fromJson(json.decode(str));

String bloodPressureSummaryModelToJson(BloodPressureSummaryModel data) => json.encode(data.toJson());

class BloodPressureSummaryModel {
    final int? code;
    final Data? data;
    final String? message;

    BloodPressureSummaryModel({
        this.code,
        this.data,
        this.message,
    });

    factory BloodPressureSummaryModel.fromJson(Map<String, dynamic> json) => BloodPressureSummaryModel(
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
    final DateTime? date;
    final int? avgSystolic;
    final int? avgDiastolic;
    final int? avgPulse;
    final int? minSystolic;
    final int? maxSystolic;
    final int? minDiastolic;
    final int? maxDiastolic;
    final int? readingsCount;
    final bool? inTargetRange;
    final String? category;

    Data({
        this.date,
        this.avgSystolic,
        this.avgDiastolic,
        this.avgPulse,
        this.minSystolic,
        this.maxSystolic,
        this.minDiastolic,
        this.maxDiastolic,
        this.readingsCount,
        this.inTargetRange,
        this.category,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        avgSystolic: json["avgSystolic"],
        avgDiastolic: json["avgDiastolic"],
        avgPulse: json["avgPulse"],
        minSystolic: json["minSystolic"],
        maxSystolic: json["maxSystolic"],
        minDiastolic: json["minDiastolic"],
        maxDiastolic: json["maxDiastolic"],
        readingsCount: json["readingsCount"],
        inTargetRange: json["inTargetRange"],
        category: json["category"],
    );

    Map<String, dynamic> toJson() => {
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "avgSystolic": avgSystolic,
        "avgDiastolic": avgDiastolic,
        "avgPulse": avgPulse,
        "minSystolic": minSystolic,
        "maxSystolic": maxSystolic,
        "minDiastolic": minDiastolic,
        "maxDiastolic": maxDiastolic,
        "readingsCount": readingsCount,
        "inTargetRange": inTargetRange,
        "category": category,
    };
}
