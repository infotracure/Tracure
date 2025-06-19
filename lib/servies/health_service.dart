import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:permission_handler/permission_handler.dart';

class GoogleFitService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      'https://www.googleapis.com/auth/fitness.activity.read',
    ],
  );

  GoogleSignInAccount? _currentUser;
  String? _accessToken;

  Future<void> requestActivityPermission() async {
    if (await Permission.activityRecognition.isDenied) {
      await Permission.activityRecognition.request();
    }

    if (await Permission.activityRecognition.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> signIn() async {
    try {
      await requestActivityPermission();
      _currentUser = await _googleSignIn.signIn().onError((error, stackTrace) {
        log('Uncaught async error: $error');
        log('Stack trace: $stackTrace');
      });
      final auth = await _currentUser?.authentication;
      _accessToken = auth?.accessToken;

      print("Access Token: $_accessToken");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetchTodaySteps() async {
    if (_accessToken == null) {
      print("Not signed in.");
      return;
    }

    final now = DateTime.now();
    final startTime = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;
    final endTime = now.millisecondsSinceEpoch;

    final url =
        'https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate';

    final body = {
      "aggregateBy": [
        {
          "dataTypeName": "com.google.step_count.delta",
          "dataSourceId":
              "derived:com.google.step_count.delta:com.google.android.gms:estimated_steps",
        },
      ],
      "bucketByTime": {"durationMillis": 86400000},
      "startTimeMillis": startTime,
      "endTimeMillis": endTime,
    };

    final dio = Dio();

    final response = await dio.post(
      url,
      data: jsonEncode(body),
      options: Options(
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      ),
    );

    print("Google Fit Response:");
    print(response.data);
  }
}
