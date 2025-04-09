import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/friend_request.dart';
import 'package:flutter_application/services/user/user_service.dart';
import 'package:flutter_application/models/user.dart';

class FriendRequestPage extends StatefulWidget {
  const FriendRequestPage({Key? key}) : super(key: key);

  @override
  _FriendPageState createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendRequestPage> {
  final TextEditingController _friendUidController = TextEditingController();
  final UserService _userService = UserService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _friendUidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text("Friends List"),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
              icon: const Icon(Icons.person_add, size: 25),
              onPressed: () {
                // _showAddFriendDialog(context);
                // Navigate to friend requests page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendRequestsPage()),
                );
              },
            ),
          ),
        ],
      ),
      body:
          _currentUserId == null
              ? const Center(child: Text('Not logged in'))
              : StreamBuilder<DocumentSnapshot<UserModel>>(
                // Specify the correct generic type here
                stream: _userService.getUserDataStream(_currentUserId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Something went wrong: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final UserModel? userData = snapshot.data?.data();
                  final List<String> friendUids = userData?.friends ?? [];

                  if (friendUids.isEmpty) {
                    return const Center(
                      child: Text('Your friends list is empty.'),
                    );
                  }

                  return FutureBuilder<List<DocumentSnapshot<UserModel>>>(
                    // Specify the correct generic type here
                    future: _userService.getUsersByUids(
                      friendUids,
                    ), // No need for casting here
                    builder: (context, friendsSnapshot) {
                      if (friendsSnapshot.hasError) {
                        return Center(
                          child: Text(
                            'Something went wrong loading friends: ${friendsSnapshot.error}',
                          ),
                        );
                      }

                      if (friendsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final List<DocumentSnapshot<UserModel>> friendDocs =
                          friendsSnapshot.data ?? [];

                      return ListView.builder(
                        itemCount: friendDocs.length,
                        itemBuilder: (context, index) {
                          final UserModel? friendData =
                              friendDocs[index].data();
                          final String friendName =
                              friendData?.username ??
                              'No Name'; // Access username property

                          return ListTile(
                            // leading: const Icon(Icons.person),
                            leading: GestureDetector(
                              child: CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.grey[100],
                                backgroundImage:
                                    friendData?.imageUrl != null
                                        ? CachedNetworkImageProvider(
                                          friendData!.imageUrl!,
                                        )
                                        : const AssetImage(
                                              'assets/img/default_avatar.png',
                                            )
                                            as ImageProvider,
                              ),
                            ),
                            title: Text(friendName),
                            // Add more details or actions for each friend if needed
                          );
                        },
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddFriendDialog(context);
        },
        backgroundColor: Color(0xFF191919),
        child: const Icon(Icons.add_circle, color: Colors.white),
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF6F6F6), // Light gray background
          title: const Text(
            'Send Friend Request',
            style: TextStyle(color: Colors.black), // Text color
          ),
          content: TextField(
            controller: _friendUidController,
            decoration: const InputDecoration(
              labelText: 'Enter User ID',
              labelStyle: TextStyle(color: Colors.black54),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.deepPurple),
              ),
            ),
            style: const TextStyle(color: Colors.black),
            cursorColor: Color(0xFFF6F6F6),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _friendUidController.clear();
              },
            ),
            TextButton(
              child: const Text(
                'Send',
                style: TextStyle(color: Color(0xFF191919)),
              ),
              onPressed: () async {
                final String friendUid = _friendUidController.text.trim();
                if (friendUid.isNotEmpty && friendUid != _currentUserId) {
                  bool success = await _userService.sendFriendRequest(
                    friendUid,
                  );
                  Navigator.of(context).pop();
                  _friendUidController.clear();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Friend request sent!')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Failed to send friend request. User might not exist.',
                        ),
                      ),
                    );
                  }
                } else if (friendUid == _currentUserId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You cannot add yourself!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a User ID.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class FriendRequestsPage extends StatelessWidget {
  final UserService _userService = UserService();
  final String? _currentUserId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Friend Requests'),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Send Friend Request",
            style: TextStyle(color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      ),
      body: StreamBuilder<QuerySnapshot<FriendRequest>>(
        // Use QuerySnapshot here
        stream:
            _userService
                .getPendingFriendRequestsAsQuerySnapshot(), // Use the QuerySnapshot stream
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: SelectableText('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending friend requests.'));
          }

          final requestDocs =
              snapshot.data!.docs; // Get the QueryDocumentSnapshots

          return ListView.builder(
            itemCount: requestDocs.length,
            itemBuilder: (context, index) {
              final doc = requestDocs[index];
              final request = doc.data();
              final requestId = doc.id; // Get the document ID

              return FutureBuilder<DocumentSnapshot<UserModel>?>(
                // Specify the correct generic type
                future: _userService.getUserData(request!.senderUid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Loading...'));
                  }
                  if (userSnapshot.hasError ||
                      !userSnapshot.hasData ||
                      userSnapshot.data == null) {
                    // Access data directly
                    return const ListTile(title: Text('Error loading user'));
                  }
                  final UserModel senderData =
                      userSnapshot.data!.data()!; // Get UserModel data
                  final String senderUsername =
                      senderData.username ??
                      'Unknown User'; // Access username property

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Color(0xFFF6F6F6),
                    child: ListTile(
                      title: Text.rich(
                        TextSpan(
                          text: 'Friend request from ',
                          style: const TextStyle(
                            color: Colors.black,
                          ), // Normal text style
                          children: <TextSpan>[
                            TextSpan(
                              text: senderUsername,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191919),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () {
                              if (_currentUserId != null) {
                                _userService.acceptFriendRequest(
                                  requestId,
                                  request.senderUid,
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              _userService.rejectFriendRequest(requestId);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
