// To parse this JSON data, do
//
//     final medicineStatusByDateModel = medicineStatusByDateModelFromJson(jsonString);

import 'dart:convert';

MedicineStatusByDateModel medicineStatusByDateModelFromJson(String str) => MedicineStatusByDateModel.fromJson(json.decode(str));

String medicineStatusByDateModelToJson(MedicineStatusByDateModel data) => json.encode(data.toJson());

class MedicineStatusByDateModel {
    final int? code;
    final List<Datum>? data;
    final String? message;

    MedicineStatusByDateModel({
        this.code,
        this.data,
        this.message,
    });

    factory MedicineStatusByDateModel.fromJson(Map<String, dynamic> json) => MedicineStatusByDateModel(
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
    final int? timesPerDay;
    final String? quantityPerDose;
    final List<int>? daysOfWeek;
    final String? notes;
    final List<TimeSlot>? timeSlots;

    Datum({
        this.scheduleId,
        this.medicationType,
        this.medicineName,
        this.timesPerDay,
        this.quantityPerDose,
        this.daysOfWeek,
        this.notes,
        this.timeSlots,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        scheduleId: json["scheduleId"],
        medicationType: json["medicationType"],
        medicineName: json["medicineName"],
        timesPerDay: json["timesPerDay"],
        quantityPerDose: json["quantityPerDose"],
        daysOfWeek: json["daysOfWeek"] == null ? [] : List<int>.from(json["daysOfWeek"]!.map((x) => x)),
        notes: json["notes"],
        timeSlots: json["timeSlots"] == null ? [] : List<TimeSlot>.from(json["timeSlots"]!.map((x) => TimeSlot.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "scheduleId": scheduleId,
        "medicationType": medicationType,
        "medicineName": medicineName,
        "timesPerDay": timesPerDay,
        "quantityPerDose": quantityPerDose,
        "daysOfWeek": daysOfWeek == null ? [] : List<dynamic>.from(daysOfWeek!.map((x) => x)),
        "notes": notes,
        "timeSlots": timeSlots == null ? [] : List<dynamic>.from(timeSlots!.map((x) => x.toJson())),
    };
}

class TimeSlot {
    final String? scheduledTime;
    final bool? taken;

    TimeSlot({
        this.scheduledTime,
        this.taken,
    });

    factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
        scheduledTime: json["scheduledTime"],
        taken: json["taken"],
    );

    Map<String, dynamic> toJson() => {
        "scheduledTime": scheduledTime,
        "taken": taken,
    };
}
