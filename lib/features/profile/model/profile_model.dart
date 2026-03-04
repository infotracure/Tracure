class ProfileModel {
  final int? code;
  final String? message;
  final ProfileData? data;

  ProfileModel({this.code, this.message, this.data});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }
}

class ProfileData {
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? dateOfBirth;
  final String? email;
  final String? mobileNumber;
  final String? profileImage;
  final String? memberSince;

  ProfileData({
    this.firstName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.email,
    this.mobileNumber,
    this.profileImage,
    this.memberSince,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      firstName: json['firstName'],
      lastName: json['lastName'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      email: json['email'],
      mobileNumber: json['mobileNumber'],
      profileImage: json['profileImage'],
      memberSince: json['memberSince'],
    );
  }
}
