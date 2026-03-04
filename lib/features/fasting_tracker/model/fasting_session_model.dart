enum FastingPlan {
  sixteenEight,
  eighteenSix,
  twentyFour,
  twentyFourFull;

  int get fastHours {
    switch (this) {
      case FastingPlan.sixteenEight:
        return 16;
      case FastingPlan.eighteenSix:
        return 18;
      case FastingPlan.twentyFour:
        return 20;
      case FastingPlan.twentyFourFull:
        return 24;
    }
  }

  int get eatHours {
    switch (this) {
      case FastingPlan.sixteenEight:
        return 8;
      case FastingPlan.eighteenSix:
        return 6;
      case FastingPlan.twentyFour:
        return 4;
      case FastingPlan.twentyFourFull:
        return 0;
    }
  }

  String get label {
    switch (this) {
      case FastingPlan.sixteenEight:
        return '16:8';
      case FastingPlan.eighteenSix:
        return '18:6';
      case FastingPlan.twentyFour:
        return '20:4';
      case FastingPlan.twentyFourFull:
        return '24h';
    }
  }

  String get subtitle {
    switch (this) {
      case FastingPlan.sixteenEight:
        return 'Fast 16h, eat 8h';
      case FastingPlan.eighteenSix:
        return 'Fast 18h, eat 6h';
      case FastingPlan.twentyFour:
        return 'Fast 20h, eat 4h';
      case FastingPlan.twentyFourFull:
        return 'One meal a day';
    }
  }

  String get key => name;

  static FastingPlan fromKey(String key) {
    return FastingPlan.values.firstWhere(
      (e) => e.name == key,
      orElse: () => FastingPlan.sixteenEight,
    );
  }
}

class FastingSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final FastingPlan planType;
  final int goalHours;

  FastingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.planType,
    required this.goalHours,
  });

  int get durationMinutes {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inMinutes;
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isCompleted => endTime != null;

  String get durationFormatted {
    final mins = durationMinutes;
    final h = mins ~/ 60;
    final m = mins % 60;
    return '${h}h ${m}m';
  }

  factory FastingSession.fromJson(Map<String, dynamic> json) {
    return FastingSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      planType: FastingPlan.fromKey(json['planType'] as String),
      goalHours: json['goalHours'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'planType': planType.key,
      'goalHours': goalHours,
    };
  }
}

class FastingLogModel {
  final int? code;
  final List<FastingSession>? data;
  final String? message;

  FastingLogModel({this.code, this.data, this.message});

  factory FastingLogModel.fromJson(Map<String, dynamic> json) {
    return FastingLogModel(
      code: json['code'],
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => FastingSession.fromJson(e))
              .toList()
          : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'data': data?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}
