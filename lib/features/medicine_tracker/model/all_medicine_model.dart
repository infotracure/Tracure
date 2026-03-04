// To parse this JSON data, do
//
//     final allMedicineModel = allMedicineModelFromJson(jsonString);

import 'dart:convert';

AllMedicineModel allMedicineModelFromJson(String str) => AllMedicineModel.fromJson(json.decode(str));

String allMedicineModelToJson(AllMedicineModel data) => json.encode(data.toJson());

class AllMedicineModel {
    final int? code;
    final List<Datum>? data;
    final String? message;

    AllMedicineModel({
        this.code,
        this.data,
        this.message,
    });

    factory AllMedicineModel.fromJson(Map<String, dynamic> json) => AllMedicineModel(
        code: json["code"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "code": code,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
        "message": message,
    };
}

class Datum {
    final int? scheduleId;
    final String? medicationType;
    final String? medicineName;
    final List<String>? doseSchedule;
    final int? timesPerDay;
    final String? quantityPerDose;
    final List<int>? daysOfWeek;
    final String? notes;
    final DateTime? createdOn;

    Datum({
        this.scheduleId,
        this.medicationType,
        this.medicineName,
        this.doseSchedule,
        this.timesPerDay,
        this.quantityPerDose,
        this.daysOfWeek,
        this.notes,
        this.createdOn,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        scheduleId: json["scheduleId"],
        medicationType: json["medicationType"],
        medicineName: json["medicineName"],
        doseSchedule: json["doseSchedule"] == null ? [] : List<String>.from(json["doseSchedule"]!.map((x) => x)),
        timesPerDay: json["timesPerDay"],
        quantityPerDose: json["quantityPerDose"],
        daysOfWeek: json["daysOfWeek"] == null ? [] : List<int>.from(json["daysOfWeek"]!.map((x) => x)),
        notes: json["notes"],
        createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
    );

    Map<String, dynamic> toJson() => {
        "scheduleId": scheduleId,
        "medicationType": medicationType,
        "medicineName": medicineName,
        "doseSchedule": doseSchedule == null ? [] : List<dynamic>.from(doseSchedule!.map((x) => x)),
        "timesPerDay": timesPerDay,
        "quantityPerDose": quantityPerDose,
        "daysOfWeek": daysOfWeek == null ? [] : List<dynamic>.from(daysOfWeek!.map((x) => x)),
        "notes": notes,
        "createdOn": createdOn?.toIso8601String(),
    };
}
