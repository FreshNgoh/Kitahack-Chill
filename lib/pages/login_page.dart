import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/components/bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import "../services/user/user_service.dart";

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
  bool _isLogin = true;
  bool _obscurePassword = true;

  void _toggleTab(bool isLoginTab) {
    setState(() {
      _isLogin = isLoginTab;
      _emailController.clear();
      _passwordController.clear();
      _usernameController.clear();
    });
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Bar()),
          );
        }
      } else {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        String uid = userCredential.user!.uid;
        await userCredential.user?.updateDisplayName(username);

        try {
          //Create user in Firestore
          UserModel newUser = UserModel(
            uid: uid,
            username: username,
            email: email,
            userRecordId: "",
            friends: [],
          );

          await _userService.addUser(newUser);
        } catch (e) {
          print("Error creating user in Firestore: $e");
        }

        _showSuccess("Registration successful!");
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _showError("Something went wrong. Please try again.");
    } finally {
      setState(() => _isLoading = false);
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
    return Column(
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
