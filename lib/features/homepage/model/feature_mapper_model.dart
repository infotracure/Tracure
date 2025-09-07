// To parse this JSON data, do
//
//     final featureMapperModel = featureMapperModelFromJson(jsonString);

import 'dart:convert';

FeatureMapperModel featureMapperModelFromJson(String str) => FeatureMapperModel.fromJson(json.decode(str));

String featureMapperModelToJson(FeatureMapperModel data) => json.encode(data.toJson());

class FeatureMapperModel {
    final int? code;
    final Data? data;
    final String? message;

    FeatureMapperModel({
        this.code,
        this.data,
        this.message,
    });

    factory FeatureMapperModel.fromJson(Map<String, dynamic> json) => FeatureMapperModel(
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
    final String? planName;
    final List<Feature>? features;

    Data({
        this.planName,
        this.features,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        planName: json["planName"],
        features: json["features"] == null ? [] : List<Feature>.from(json["features"]!.map((x) => Feature.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "planName": planName,
        "features": features == null ? [] : List<dynamic>.from(features!.map((x) => x.toJson())),
    };
}

class Feature {
    final String? sectionName;
    final String? featureName;
    final String? featureKey;
    final bool? enabled;

    Feature({
        this.sectionName,
        this.featureName,
        this.featureKey,
        this.enabled,
    });

    factory Feature.fromJson(Map<String, dynamic> json) => Feature(
        sectionName: json["sectionName"],
        featureName: json["featureName"],
        featureKey: json["featureKey"],
        enabled: json["enabled"],
    );

    Map<String, dynamic> toJson() => {
        "sectionName": sectionName,
        "featureName": featureName,
        "featureKey": featureKey,
        "enabled": enabled,
    };
}
