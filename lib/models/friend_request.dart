import 'package:cloud_firestore/cloud_firestore.dart';

class FriendRequest {
  final String senderUid;
  final String receiverUid;
  final String status; // 'pending', 'accepted', 'rejected'
  final Timestamp createdAt;

  FriendRequest({
    required this.senderUid,
    required this.receiverUid,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      senderUid: json['senderUid'] as String,
      receiverUid: json['receiverUid'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
