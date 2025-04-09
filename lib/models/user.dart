import "package:cloud_firestore/cloud_firestore.dart";

class UserModel {
  String username;
  String email;
  String uid;
  String? imageUrl;
  Timestamp? createdAt;
  Timestamp? updatedAt;
  String userRecordId;
  List<String> friends;

  UserModel({
    required this.username,
    required this.email,
    required this.uid,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
    this.userRecordId = "",
    this.friends = const [],
  });

  UserModel.fromJson(Map<String, Object?> json)
    : this(
        username: json['username']! as String,
        email: json['email']! as String,
        uid: json['uid']! as String,
        imageUrl: json['imageUrl'] as String?,
        userRecordId: json['userRecordId']! as String,
        friends:
            (json['friends'] as List<dynamic>).map((e) => e as String).toList(),
      );

  UserModel copyWith({
    String? username,
    String? email,
    String? password,
    String? uid,
    String? imageUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    String? userRecordId,
    List<String>? friends,
  }) {
    return UserModel(
      username: username ?? this.username,
      email: email ?? this.email,
      uid: uid ?? this.uid,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userRecordId: userRecordId ?? this.userRecordId,
      friends: friends ?? this.friends,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'username': username,
      'email': email,
      'uid': uid,
      'imageUrl': imageUrl,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'userRecordId': userRecordId,
      'friends': friends,
    };
  }
}
