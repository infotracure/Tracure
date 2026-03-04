// To parse this JSON data, do
//
//     final createMedicineModel = createMedicineModelFromJson(jsonString);

import 'dart:convert';

CreateMedicineModel createMedicineModelFromJson(String str) => CreateMedicineModel.fromJson(json.decode(str));

String createMedicineModelToJson(CreateMedicineModel data) => json.encode(data.toJson());

class CreateMedicineModel {
    final String? medicationType;
    final String? medicineName;
    final List<String>? doseSchedule;
    final int? timesPerDay;
    final String? quantityPerDose;
    final List<int>? daysOfWeek;
    final String? notes;

    CreateMedicineModel({
        this.medicationType,
        this.medicineName,
        this.doseSchedule,
        this.timesPerDay,
        this.quantityPerDose,
        this.daysOfWeek,
        this.notes,
    });

    factory CreateMedicineModel.fromJson(Map<String, dynamic> json) => CreateMedicineModel(
        medicationType: json["medicationType"],
        medicineName: json["medicineName"],
        doseSchedule: json["doseSchedule"] == null ? [] : List<String>.from(json["doseSchedule"]!.map((x) => x)),
        timesPerDay: json["timesPerDay"],
        quantityPerDose: json["quantityPerDose"],
        daysOfWeek: json["daysOfWeek"] == null ? [] : List<int>.from(json["daysOfWeek"]!.map((x) => x)),
        notes: json["notes"],
    );

    Map<String, dynamic> toJson() => {
        "medicationType": medicationType,
        "medicineName": medicineName,
        "doseSchedule": doseSchedule == null ? [] : List<dynamic>.from(doseSchedule!.map((x) => x)),
        "timesPerDay": timesPerDay,
        "quantityPerDose": quantityPerDose,
        "daysOfWeek": daysOfWeek == null ? [] : List<dynamic>.from(daysOfWeek!.map((x) => x)),
        "notes": notes,
    };
}
