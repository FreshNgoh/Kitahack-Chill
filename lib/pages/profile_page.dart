import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/pages/login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_application/services/user/user_service.dart';
import 'package:flutter_application/models/user.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _currentUser = null;
    });
    final User? user = _auth.currentUser;
    if (user != null) {
      final UserModel? fetchedUser = await _userService.getUser(user.uid);
      if (fetchedUser != null) {
        setState(() {
          _currentUser = fetchedUser;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    ProfilePic(imageUrl: _currentUser?.imageUrl),
                    const SizedBox(height: 20),
                    UIDRow(uid: _currentUser?.uid ?? "N/A"),
                    const SizedBox(height: 20),
                    ProfileMenu(
                      text: "Log Out",
                      icon: Icons.logout, // Use IconData
                      isSvg: false, // Indicate it's not an SVG
                      press: _logout,
                    ),
                  ],
                ),
              ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            backgroundImage:
                imageUrl != null
                    ? CachedNetworkImageProvider(imageUrl!)
                    : const AssetImage("assets/img/avatar.jpeg"),
          ),
          Positioned(
            right: -16,
            bottom: 0,
            child: SizedBox(
              height: 46,
              width: 46,
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFFF5F6F9),
                ),
                onPressed: () {
                  // To be implemented: open image picker or edit profile
                },
                child: Icon(
                  Icons.camera_alt,
                  //Black Icon
                  color: const Color(0xFF757575),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UIDRow extends StatelessWidget {
  final String uid;

  const UIDRow({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () async {
          await Clipboard.setData(ClipboardData(text: uid));
          Fluttertoast.showToast(
            msg: "UID copied to clipboard",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 14,
          );
        },
        child: Text(
          "uid: $uid",
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    super.key,
    required this.text,
    required this.icon,
    this.press,
    this.isSvg = true, // Default to true for backward compatibility
  });

  final String text;
  final dynamic icon; // Can be String (asset path) or IconData
  final VoidCallback? press;
  final bool isSvg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF757575),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: const Color(0xFFF5F6F9),
        ),
        onPressed: press,
        child: Row(
          children: [
            if (isSvg && icon is String)
              SvgPicture.asset(
                icon as String,
                colorFilter: const ColorFilter.mode(
                  Color(0xFFFF7643),
                  BlendMode.srcIn,
                ),
                width: 22,
              )
            else if (!isSvg && icon is IconData)
              Icon(icon as IconData, color: const Color(0xFF757575), size: 22),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Color(0xFF757575)),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF757575)),
          ],
        ),
      ),
    );
  }
}
