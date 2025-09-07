import 'dart:developer';

import 'package:flutter/foundation.dart';

class CommonMethods {}

void devLog(
  String message, {
  String name = 'APP-LOG',
  Object? error,
  StackTrace? stackTrace,
}) {
  if (kDebugMode) {
    log(message, name: name, error: error, stackTrace: stackTrace);
  }
}
