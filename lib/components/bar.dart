import 'package:flutter/material.dart';
import 'package:flutter_application/pages/home.dart';
import 'package:flutter_application/pages/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      initialIndex: 1,
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text("Hi, $username"), //replace
          ),
          // backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_active, size: 25),
              onPressed: () {
                // Add notification action
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.3),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: TabBar(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.transparent,
          tabs: <Widget>[
            Tab(icon: Icon(Icons.home), text: "Home"),
            Tab(icon: Icon(Icons.group), text: "Friends"),
            Transform.translate(
              offset: const Offset(0, -15), // Lift the tab upward
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(blue: 0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Tab(icon: Icon(Icons.camera_alt, size: 25)),
              ),
            ),
            Tab(icon: Icon(Icons.person), text: "Avatarss"),
            Tab(icon: Icon(Icons.settings), text: "Profile"),
          ],
        ),
        // Change the view page
        body: const TabBarView(
          children: <Widget>[
            NutritionScreen(),
            Center(child: Text("Friend")),
            Center(child: Text("Camera")),
            Center(child: Text("Avatar")),
            ProfileScreen(), // Profile page
          ],
        ),
      ),
    );
  }
}
