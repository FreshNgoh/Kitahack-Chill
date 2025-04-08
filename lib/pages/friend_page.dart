import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/models/user_record.dart';
import 'package:flutter_application/services/user/user_service.dart';
import 'package:flutter_application/services/user_record/user_record.dart';
import 'package:photo_view/photo_view.dart';

class FriendPage extends StatefulWidget {
  const FriendPage({super.key});

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  final UserService _userService = UserService();
  final UserRecordService _userRecordService = UserRecordService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<UserModel> _friendsData = [];
  Map<String, UserRecord?> _latestRecords = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendsData();
  }

  Future<void> _loadFriendsData() async {
    setState(() {
      _isLoading = true;
      _friendsData.clear();
      _latestRecords.clear();
    });

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      final currentUserData = await _userService.getUser(currentUser.uid);
      if (currentUserData != null && currentUserData.friends.isNotEmpty) {
        final friendsUids = currentUserData.friends;
        final friendsSnapshots = await _userService.getUsersByUids(friendsUids);

        _friendsData = friendsSnapshots.map((doc) => doc.data()!).toList();

        for (final friend in _friendsData) {
          final latestRecordSnapshot =
              await _userRecordService
                  .getFriendMonthUserRecordsQuery(friend.uid)
                  .limit(1) // Only need the latest one
                  .get();
          _latestRecords[friend.uid] =
              latestRecordSnapshot.docs.isNotEmpty
                  ? latestRecordSnapshot.docs.first.data()
                  : null;
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Color getCalorieColor(int calories) {
    if (calories > 3080) {
      return Colors.red;
    } else if (calories >= 2520) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _header(),
                  const SizedBox(height: 10),
                  Expanded(child: _userList()),
                ],
              ),
    );
  }

  Padding _header() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Friend's Activity",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _userList() {
    if (_friendsData.isEmpty) {
      return const Center(child: Text("No friends yet."));
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _friendsData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final friend = _friendsData[index];
        final latestRecord = _latestRecords[friend.uid];
        final calories = latestRecord?.calories ?? "0";
        final imageUrl = latestRecord?.imageUrl;
        final timeAgo = _formatTimestamp(latestRecord?.createdAt);
        var calorieColor = getCalorieColor(0);
        if (calories != null) {
          calorieColor = getCalorieColor(int.tryParse(calories!) ?? 0);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _showImageDetail(context, friend.imageUrl),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[100],
                  backgroundImage:
                      friend.imageUrl != null
                          ? CachedNetworkImageProvider(friend.imageUrl!)
                          : const AssetImage('assets/img/default_avatar.png')
                              as ImageProvider,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showImageDetail(context, imageUrl),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(
                              friend.username,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (timeAgo != null)
                              Text(
                                timeAgo,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              color: calorieColor,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$calories',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: calorieColor,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'CAL',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showImageDetail(context, imageUrl),
                child: Icon(
                  imageUrl != null
                      ? Icons.remove_red_eye_outlined
                      : Icons.broken_image_outlined,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String? _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return null;
    final DateTime now = DateTime.now();
    final DateTime recordTime = timestamp.toDate();
    final Duration difference = now.difference(recordTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min ago';
    } else {
      return 'Just now';
    }
  }

  void _showImageDetail(BuildContext context, String? imagePath) {
    if (imagePath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => Scaffold(
                appBar: AppBar(
                  backgroundColor: Colors.black87,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
                backgroundColor: Colors.black,
                body: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: PhotoView(
                    imageProvider: CachedNetworkImageProvider(imagePath),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No image available.")));
    }
  }
}
