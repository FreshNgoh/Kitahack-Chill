import "package:cloud_firestore/cloud_firestore.dart";

class UserRecord {
  String userUid;
  String imageUrl;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  String calories;
  String? recommendation;

  UserRecord({
    required this.userUid,
    required this.imageUrl,
    this.createdAt,
    this.updatedAt,
    required this.calories,
    this.recommendation,
  });

  UserRecord.fromJson(Map<String, Object?> json)
    : this(
        userUid: json['userUid']! as String,
        imageUrl: json['imageUrl']! as String,
        calories: json['calories']! as String,
        recommendation: json['recommendation'] as String?,
        createdAt: json['createdAt'] as Timestamp,
        updatedAt: json['updatedAt'] as Timestamp,
      );

  Map<String, Object?> toJson() {
    return {
      'userUid': userUid,
      'imageUrl': imageUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'calories': calories,
      'recommendation': recommendation,
    };
  }
}
