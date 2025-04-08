import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application/components/bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import "../services/user/user_service.dart";
import 'package:flutter_notion_avatar/flutter_notion_avatar.dart';
import 'package:flutter_application/services/storage/upload_service.dart';
import 'package:flutter_notion_avatar/flutter_notion_avatar_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  final Random _random = Random();
  bool _isLogin = true;
  bool _obscurePassword = true;
  final GlobalKey _avatarKey = GlobalKey(); // Key for RepaintBoundary
  NotionAvatarController? _avatarController; // To access the controller

  void _toggleTab(bool isLoginTab) {
    setState(() {
      _isLogin = isLoginTab;
      _emailController.clear();
      _passwordController.clear();
      _usernameController.clear();
    });
  }

  Future<void> _randomizeAvatar() async {
    int? _accessoriesIndex;
    int? _eyesIndex;
    int? _eyebrowsIndex;
    int? _faceIndex; // Fixed face for registration
    int? _glassesIndex;
    int? _hairIndex;
    int? _mouthIndex;
    int? _noseIndex;
    int? _detailsIndex;
    int? _festivalIndex; // Assuming these exist in NotionAvatarController

    // Optionally, you might want to immediately trigger the first random avatar:
    // _avatarController?.random();
    const int accessoriesMax = 14;
    const int eyesMax = 13;
    const int eyebrowsMax = 15;
    const int glassesMax = 14;
    const int hairMax = 58;
    const int mouthMax = 19;
    const int noseMax = 13;
    const int detailsMax = 13;
    const int festivalMax = 2; // Example

    _accessoriesIndex = _random.nextInt(accessoriesMax);
    _eyesIndex = _random.nextInt(eyesMax);
    _eyebrowsIndex = _random.nextInt(eyebrowsMax);
    _faceIndex = 10; // Fixed face, to be follow the user database one
    _glassesIndex = _random.nextInt(glassesMax);
    _hairIndex = _random.nextInt(hairMax);
    _mouthIndex = _random.nextInt(mouthMax);
    _noseIndex = _random.nextInt(noseMax);
    _detailsIndex = _random.nextInt(detailsMax);
    _festivalIndex = _random.nextInt(festivalMax);

    _avatarController?.setAccessories(_accessoriesIndex!);
    _avatarController?.setEyes(_eyesIndex!);
    _avatarController?.setEyebrows(_eyebrowsIndex!);
    _avatarController?.setFace(_faceIndex!);
    _avatarController?.setGlasses(_glassesIndex!);
    _avatarController?.setHair(_hairIndex!);
    _avatarController?.setMouth(_mouthIndex!);
    _avatarController?.setNose(_noseIndex!);
    _avatarController?.setDetails(_detailsIndex!);
    _avatarController?.setFestival(_festivalIndex!);
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && username.isEmpty)) {
      _showError("Please fill in all fields.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (_auth.currentUser != null) {
          print("User is logged in: ${_auth.currentUser?.email}");
          // Navigate to the home page
          if (mounted) {
            // Check if the widget is still in the tree
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Bar()),
            );
          }
        }
      } else {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        final User? user = userCredential.user;
        if (user != null) {
          final String uid = user.uid;
          await user.updateDisplayName(username);

          await _randomizeAvatar();

          WidgetsBinding.instance.addPostFrameCallback((_) async {
            final Uint8List? avatarBytes = await _captureAvatarAsBytes();

            if (avatarBytes != null) {
              File? tempFile;
              try {
                final tempDir = await getTemporaryDirectory();
                tempFile = File(
                  '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png',
                );
                await tempFile.writeAsBytes(avatarBytes);

                final String? avatarUrl =
                    await UploadService.uploadImageToFirebase(tempFile);

                if (avatarUrl != null) {
                  try {
                    UserModel newUser = UserModel(
                      uid: uid,
                      username: username,
                      email: email,
                      imageUrl: avatarUrl,
                      userRecordId: "",
                      friends: [],
                    );
                    await _userService.addUser(newUser);
                    _showSuccess("Registration successful!");
                    // Do NOT redirect to Bar() here
                    if (mounted) {
                      setState(() {
                        _isLogin = true; // Switch to the login tab
                      });
                    }
                  } catch (e) {
                    print("Error creating user in Firestore: $e");
                    _showError("Error creating user profile.");
                    await user.delete();
                  }
                } else {
                  _showError("Failed to upload avatar.");
                  await user.delete();
                }
              } catch (e) {
                _showError("Error creating temporary avatar file.");
                print("Error creating temporary file: $e");
                await user.delete();
              } finally {
                await tempFile?.delete();
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            } else {
              _showError("Failed to capture avatar.");
              await user.delete();
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          });
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError("Something went wrong. Please try again.");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } finally {
      if (_isLogin && mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _handleAuthError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'invalid-email':
        errorMessage = 'Invalid email format.';
        break;
      case 'user-not-found':
        errorMessage = 'User not found.';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password.';
        break;
      case 'email-already-in-use':
        errorMessage = 'Email already registered.';
        break;
      case 'weak-password':
        errorMessage = 'Password must be at least 6 characters.';
        break;
      default:
        errorMessage = 'Authentication failed. Please try again.';
    }
    _showError(errorMessage);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<Uint8List?> _captureAvatarAsBytes() async {
    try {
      final boundary =
          _avatarKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) {
        print("Error: RenderRepaintBoundary not found.");
        return null;
      }
      final image = await boundary.toImage(
        pixelRatio: 3.0,
      ); // Adjust for quality
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing avatar: $e");
      return null;
    }
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: "Email"),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: "Password",
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Stack(
      children: [
        Column(
          mainAxisSize:
              MainAxisSize.min, // Ensure Column only takes necessary height
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // No visible placeholder for the avatar anymore
          ],
        ),
        Positioned(
          left: -1000, // Position far off-screen to the left
          top: 0,
          child: RepaintBoundary(
            key: _avatarKey,
            child: SizedBox(
              width: 100,
              height: 100,
              child: NotionAvatar(
                onCreated: (controller) {
                  _avatarController = controller;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🖼️ App logo
                Image.asset(
                  'assets/logo.png', // Replace with your actual image path
                  height: 150,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Eat Meh",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // 🔁 Login/Register Toggle
                ToggleButtons(
                  borderRadius: BorderRadius.circular(10),
                  isSelected: [_isLogin, !_isLogin],
                  onPressed: (index) => _toggleTab(index == 0),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Login"),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Register"),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 👇 Dynamic Form
                _isLogin ? _buildLoginForm() : _buildRegisterForm(),

                const SizedBox(height: 20),

                // ✅ Submit Button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                      onPressed: _submit,
                      child: Text(_isLogin ? "Login" : "Register"),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
