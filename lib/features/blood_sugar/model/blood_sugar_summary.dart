// To parse this JSON data, do
//
//     final bloodSugaSummaryModel = bloodSugaSummaryModelFromJson(jsonString);

import 'dart:convert';

BloodSugarSummaryModel bloodSugaSummaryModelFromJson(String str) => BloodSugarSummaryModel.fromJson(json.decode(str));

String bloodSugaSummaryModelToJson(BloodSugarSummaryModel data) => json.encode(data.toJson());

class BloodSugarSummaryModel {
    final int? code;
    final Data? data;
    final String? message;

    BloodSugarSummaryModel({
        this.code,
        this.data,
        this.message,
    });

    factory BloodSugarSummaryModel.fromJson(Map<String, dynamic> json) => BloodSugarSummaryModel(
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
    final int? avgValue;
    final int? minValue;
    final int? maxValue;
    final int? readingsCount;
    final List<ByContext>? byContext;
    final bool? inTargetRange;
    final String? category;

    Data({
        this.date,
        this.avgValue,
        this.minValue,
        this.maxValue,
        this.readingsCount,
        this.byContext,
        this.inTargetRange,
        this.category,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        avgValue: json["avgValue"],
        minValue: json["minValue"],
        maxValue: json["maxValue"],
        readingsCount: json["readingsCount"],
        byContext: json["byContext"] == null ? [] : List<ByContext>.from(json["byContext"]!.map((x) => ByContext.fromJson(x))),
        inTargetRange: json["inTargetRange"],
        category: json["category"],
    );

    Map<String, dynamic> toJson() => {
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "avgValue": avgValue,
        "minValue": minValue,
        "maxValue": maxValue,
        "readingsCount": readingsCount,
        "byContext": byContext == null ? [] : List<dynamic>.from(byContext!.map((x) => x.toJson())),
        "inTargetRange": inTargetRange,
        "category": category,
    };
}

class ByContext {
    final String? context;
    final int? avgValue;
    final int? readingsCount;

    ByContext({
        this.context,
        this.avgValue,
        this.readingsCount,
    });

    factory ByContext.fromJson(Map<String, dynamic> json) => ByContext(
        context: json["context"],
        avgValue: json["avgValue"],
        readingsCount: json["readingsCount"],
    );

    Map<String, dynamic> toJson() => {
        "context": context,
        "avgValue": avgValue,
        "readingsCount": readingsCount,
    };
}
