import "package:cloud_firestore/cloud_firestore.dart";

class UserRecord {
  String userUid;
  String imageUrl;
  Timestamp createdAt;
  Timestamp updatedAt;
  int calories;

  UserRecord({
    required this.userUid,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.calories,
  });

  UserRecord.fromJson(Map<String, Object?> json)
    : this(
        userUid: json['userUid']! as String,
        imageUrl: json['imageUrl']! as String,
        createdAt: json['createdAt']! as Timestamp,
        updatedAt: json['updatedAt']! as Timestamp,
        calories: json['calories']! as int,
      );

  Map<String, Object?> toJson() {
    return {
      'userUid': userUid,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'calories': calories,
    };
  }
}
