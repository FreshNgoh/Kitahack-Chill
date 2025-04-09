import 'package:flutter/material.dart';
import 'package:flutter_application/pages/avatar_page.dart';
import 'package:flutter_application/pages/camera_page.dart';
import 'package:flutter_application/pages/friend_page.dart';
import 'package:flutter_application/pages/home.dart';
import 'package:flutter_application/pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/pages/friend_request_page.dart';

class Bar extends StatelessWidget {
  const Bar({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently signed-in user
    User? user = FirebaseAuth.instance.currentUser;

    // Extract the username (part before '@')
    String? username = "Guest"; // Default if no user is signed in
    if (user != null && user.email != null) {
      username = user.displayName; // Extract username from email
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text("Hi, $username"), //replace
          ),

          // Future implementation of Avatar
          // child: Row(
          //     children: [
          //       CircleAvatar(
          //         radius: 25,
          //         backgroundColor: Colors.grey[100],
          //         backgroundImage:
          //             user?.photoURL != null
          //                 ? CachedNetworkImageProvider(user!.photoURL!)
          //                 : const AssetImage('assets/img/default_avatar.png')
          //                     as ImageProvider,
          //       ),
          //       Text(" $username"),
          //     ],
          //   ), //replace
          // ),
          // backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(Icons.people, size: 25),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FriendRequestPage()),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: IconButton(
                icon: Icon(Icons.notifications_active, size: 25),
                onPressed: () {
                  // Add notification action
                },
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 112, 110, 110),
                    width: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 90,
          padding: EdgeInsets.only(left: 10, right: 10),
          child: TabBar(
            padding: EdgeInsets.only(bottom: 10),
            // Uncomment it if you dont want the onClick effect.
            // splashFactory: NoSplash.splashFactory,
            // overlayColor: MaterialStateProperty.all(Colors.transparent),
            dividerHeight: 0,
            labelColor: Color(0xFF191919),
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.transparent,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.home), text: "Home"),
              Tab(icon: Icon(Icons.group), text: "Friends"),
              Transform.translate(
                offset: const Offset(0, -20), // Lift the tab upward
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Tab(icon: Icon(Icons.camera_alt, size: 25)),
                ),
              ),
              Tab(icon: Icon(Icons.person), text: "Avatar"),
              Tab(icon: Icon(Icons.settings), text: "Profile"),
            ],
          ),
        ),
        // Change the view page
        body: TabBarView(
          children: <Widget>[
            NutritionScreen(),
            FriendPage(),
            CameraPage(),
            AvatarPage(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}
