// To parse this JSON data, do
//
//     final medicineStatusByDateRangeModel = medicineStatusByDateRangeModelFromJson(jsonString);

import 'dart:convert';

MedicineStatusByDateRangeModel medicineStatusByDateRangeModelFromJson(String str) => MedicineStatusByDateRangeModel.fromJson(json.decode(str));

String medicineStatusByDateRangeModelToJson(MedicineStatusByDateRangeModel data) => json.encode(data.toJson());

class MedicineStatusByDateRangeModel {
    final int? code;
    final Data? data;
    final String? message;

    MedicineStatusByDateRangeModel({
        this.code,
        this.data,
        this.message,
    });

    factory MedicineStatusByDateRangeModel.fromJson(Map<String, dynamic> json) => MedicineStatusByDateRangeModel(
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
    final int? totalExpected;
    final int? totalTaken;
    final double? overallAdherence;
    final List<ByDate>? byDate;

    Data({
        this.startDate,
        this.endDate,
        this.totalExpected,
        this.totalTaken,
        this.overallAdherence,
        this.byDate,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
        endDate: json["endDate"] == null ? null : DateTime.parse(json["endDate"]),
        totalExpected: json["totalExpected"],
        totalTaken: json["totalTaken"],
        overallAdherence: json["overallAdherence"]?.toDouble(),
        byDate: json["byDate"] == null ? [] : List<ByDate>.from(json["byDate"]!.map((x) => ByDate.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "startDate": "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
        "endDate": "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}",
        "totalExpected": totalExpected,
        "totalTaken": totalTaken,
        "overallAdherence": overallAdherence,
        "byDate": byDate == null ? [] : List<dynamic>.from(byDate!.map((x) => x.toJson())),
    };
}

class ByDate {
    final DateTime? date;
    final int? expectedDoses;
    final int? takenDoses;
    final double? adherencePct;

    ByDate({
        this.date,
        this.expectedDoses,
        this.takenDoses,
        this.adherencePct,
    });

    factory ByDate.fromJson(Map<String, dynamic> json) => ByDate(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        expectedDoses: json["expectedDoses"],
        takenDoses: json["takenDoses"],
        adherencePct: json["adherencePct"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "expectedDoses": expectedDoses,
        "takenDoses": takenDoses,
        "adherencePct": adherencePct,
    };
}
