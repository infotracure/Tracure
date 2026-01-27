// To parse this JSON data, do
//
//     final gymCheckInModel = gymCheckInModelFromJson(jsonString);

import 'dart:convert';

GymCheckInModel gymCheckInModelFromJson(String str) => GymCheckInModel.fromJson(json.decode(str));

String gymCheckInModelToJson(GymCheckInModel data) => json.encode(data.toJson());

class GymCheckInModel {
    final int? code;
    final List<Datum>? data;
    final String? message;

    GymCheckInModel({
        this.code,
        this.data,
        this.message,
    });

    factory GymCheckInModel.fromJson(Map<String, dynamic> json) => GymCheckInModel(
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
    final int? checkinId;
    final DateTime? checkinDate;
    final bool? checkedIn;
    final DateTime? createdOn;
    final DateTime? updatedOn;

    Datum({
        this.checkinId,
        this.checkinDate,
        this.checkedIn,
        this.createdOn,
        this.updatedOn,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        checkinId: json["checkinId"],
        checkinDate: json["checkinDate"] == null ? null : DateTime.parse(json["checkinDate"]),
        checkedIn: json["checkedIn"],
        createdOn: json["createdOn"] == null ? null : DateTime.parse(json["createdOn"]),
        updatedOn: json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
    );

    Map<String, dynamic> toJson() => {
        "checkinId": checkinId,
        "checkinDate": "${checkinDate!.year.toString().padLeft(4, '0')}-${checkinDate!.month.toString().padLeft(2, '0')}-${checkinDate!.day.toString().padLeft(2, '0')}",
        "checkedIn": checkedIn,
        "createdOn": createdOn?.toIso8601String(),
        "updatedOn": updatedOn?.toIso8601String(),
    };
}
