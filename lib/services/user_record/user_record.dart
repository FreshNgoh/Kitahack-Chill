import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/user_record.dart';

const String USER_RECORD_COLLECTION_REF = "user_records";

class UserRecordService {
  final _fireStore = FirebaseFirestore.instance;

  late final CollectionReference<UserRecord>
  _userRecordRef; // Specify the generic type here

  UserRecordService() {
    _userRecordRef = _fireStore
        .collection(USER_RECORD_COLLECTION_REF)
        .withConverter<UserRecord>(
          // Get snapshot from firebase, returning them as user instance
          fromFirestore:
              (snapshots, _) => UserRecord.fromJson(snapshots.data()!),
          toFirestore: (user, _) => user.toJson(),
        );
  }

  Stream<QuerySnapshot> getUserRecords() {
    return _userRecordRef.snapshots();
  }

  Stream<QuerySnapshot<UserRecord>> getCurrentMonthUserRecords(String userUid) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return _userRecordRef
        .where('userUid', isEqualTo: userUid)
        .where('createdAt', isGreaterThanOrEqualTo: startOfMonth)
        .where('createdAt', isLessThan: endOfMonth)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addUserRecord(UserRecord userRecord) async {
    try {
      await _userRecordRef.add(userRecord);
    } catch (e, stackTrace) {
      print("🔥 Error writing user record to Firestore: $e");
      print(stackTrace);
    }
  }
}
