import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application/models/user.dart';

const String USER_COLLECTION_REF = "users";

class UserService {
  final _fireStore = FirebaseFirestore.instance;

  late final CollectionReference _usersRef;

  UserService() {
    _usersRef = _fireStore
        .collection(USER_COLLECTION_REF)
        .withConverter<UserModel>(
          // Get snapshot from firebase, returning them as user instance
          fromFirestore:
              (snapshots, _) => UserModel.fromJson(snapshots.data()!),
          toFirestore: (user, _) => user.toJson(),
        );
  }

  Stream<QuerySnapshot> getUsers() {
    return _usersRef.snapshots();
  }

  Future<void> addUser(UserModel user) async {
    print(user.toJson());
    try {
      await _usersRef.add(user);
    } catch (e, stackTrace) {
      print("🔥 Error writing user to Firestore: $e");
      print(stackTrace);
    }
  }
}
