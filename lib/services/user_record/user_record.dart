import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Stream<QuerySnapshot<UserRecord>> getCurrentMonthUserRecords(
    String userUid, {
    DateTime? selectedMonth, // Added the optional selectedMonth parameter
  }) {
    DateTime now = selectedMonth ?? DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return _userRecordRef
        .where('userUid', isEqualTo: userUid)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfMonth))
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Modified to return a Query
  Query<UserRecord> getFriendMonthUserRecordsQuery(
    String userUid, {
    DateTime? selectedMonth,
  }) {
    DateTime now = selectedMonth ?? DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);

    return _userRecordRef
        .where('userUid', isEqualTo: userUid)
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(endOfMonth))
        .orderBy('createdAt', descending: true);
  }

  Future<void> addUserRecord(UserRecord userRecord) async {
    try {
      await _userRecordRef.add(userRecord);
    } catch (e, stackTrace) {
      print("🔥 Error writing user record to Firestore: $e");
      print(stackTrace);
    }
  }

  Future<QuerySnapshot<UserRecord>> getUserRecordsForDateRange(
    String uid,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _userRecordRef
        .where('userUid', isEqualTo: uid)
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThanOrEqualTo: endDate)
        .get();
  }
}
