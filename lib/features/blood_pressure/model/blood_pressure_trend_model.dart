// To parse this JSON data, do
//
//     final bloodPressureTrendModel = bloodPressureTrendModelFromJson(jsonString);

import 'dart:convert';

BloodPressureTrendModel bloodPressureTrendModelFromJson(String str) => BloodPressureTrendModel.fromJson(json.decode(str));

String bloodPressureTrendModelToJson(BloodPressureTrendModel data) => json.encode(data.toJson());

class BloodPressureTrendModel {
    final int? code;
    final Data? data;
    final String? message;

    BloodPressureTrendModel({
        this.code,
        this.data,
        this.message,
    });

    factory BloodPressureTrendModel.fromJson(Map<String, dynamic> json) => BloodPressureTrendModel(
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
    final DateTime? startDate;
    final DateTime? endDate;
    final int? totalDays;
    final List<Record>? records;

    Data({
        this.startDate,
        this.endDate,
        this.totalDays,
        this.records,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        totalDays: json["totalDays"],
        records: json["records"] == null ? [] : List<Record>.from(json["records"]!.map((x) => Record.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "startDate": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "endDate": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "totalDays": totalDays,
        "records": records == null ? [] : List<dynamic>.from(records!.map((x) => x.toJson())),
    };
}

class Record {
    final DateTime? date;
    final int? avgSystolic;
    final int? avgDiastolic;
    final int? avgPulse;
    final int? readingsCount;
    final String? category;

    Record({
        this.date,
        this.avgSystolic,
        this.avgDiastolic,
        this.avgPulse,
        this.readingsCount,
        this.category,
    });

    factory Record.fromJson(Map<String, dynamic> json) => Record(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        avgSystolic: json["avgSystolic"],
        avgDiastolic: json["avgDiastolic"],
        avgPulse: json["avgPulse"],
        readingsCount: json["readingsCount"],
        category: json["category"],
    );

    Map<String, dynamic> toJson() => {
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "avgSystolic": avgSystolic,
        "avgDiastolic": avgDiastolic,
        "avgPulse": avgPulse,
        "readingsCount": readingsCount,
        "category": category,
    };
}
