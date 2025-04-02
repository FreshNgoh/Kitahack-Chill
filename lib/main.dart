import 'package:flutter/material.dart';
import 'package:flutter_application/components/bar.dart';
import 'package:flutter_application/pages/avatar_page.dart';
import 'package:flutter_application/pages/camera_page.dart';
import 'package:flutter_application/pages/friend_page.dart';
import 'package:flutter_application/pages/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eat Meh',
      // home: Bar(),
      initialRoute: '/', // Default route
      routes: {
        '/': (context) => Bar(), // Home Page
        '/friends': (context) => FriendPage(),
        '/camera': (context) => CameraPage(),
        '/avatar': (context) => AvatarPage(),
        '/setting': (context) => ProfilePage(),
      },
    );
  }
}
