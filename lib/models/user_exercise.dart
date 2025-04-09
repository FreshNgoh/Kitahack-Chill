// models/user_exercise.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum Exercise {
  jogging,
  running,
  walking,
  weightTraining,
  swimming,
  cycling,
  other,
}

extension ExerciseExtension on Exercise {
  double get metValue {
    switch (this) {
      case Exercise.jogging:
        return 7.0;
      case Exercise.running:
        return 10.0;
      case Exercise.walking:
        return 3.5;
      case Exercise.weightTraining:
        return 5.0;
      case Exercise.swimming:
        return 6.0;
      case Exercise.cycling:
        return 6.0;
      case Exercise.other:
      default:
        return 3.0;
    }
  }
}

class UserExercise {
  String uid;
  String title;
  Exercise exerciseName;
  int duration;
  double caloriesBurnt;
  DateTime timestamp;
  Timestamp? createdAt;

  UserExercise({
    required this.uid,
    required this.title,
    required this.exerciseName,
    required this.duration,
    required this.caloriesBurnt,
    required this.timestamp,
    this.createdAt,
  });

  UserExercise.fromJson(Map<String, Object?> json)
    : this(
        uid: json['uid']! as String,
        title: json['title']! as String,
        exerciseName: _exerciseFromString(json['exerciseName']! as String),
        duration: json['duration']! as int,
        caloriesBurnt: (json['caloriesBurnt']! as num).toDouble(),
        timestamp: (json['timestamp']! as Timestamp).toDate(),
        createdAt: json['createdAt'] as Timestamp?,
      );

  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'title': title,
      'exerciseName': exerciseName.name,
      'duration': duration,
      'caloriesBurnt': caloriesBurnt,
      'timestamp': timestamp,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  static Exercise _exerciseFromString(String value) {
    try {
      return Exercise.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return Exercise.other;
    }
  }
}
