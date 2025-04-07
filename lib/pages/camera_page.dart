import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application/bloc/chat_bloc_bloc.dart';
import 'package:flutter_application/components/bar.dart';
import 'package:flutter_application/services/storage/upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application/models/user_record.dart';
import 'package:flutter_application/services/user_record/user_record.dart';
import 'package:flutter_application/pages/login_page.dart';
import 'package:flutter_application/repos/chat_repo.dart';
import 'package:flutter_application/models/chat_message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCameraAndHandleResult();
    });
  }

  Future<void> _openCameraAndHandleResult() async {
    final picker = ImagePicker();
    // XFile? image = await picker.pickImage(source: ImageSource.camera);

    // if (!mounted) return;
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      // // Camera canceled, fallback to gallery
      // image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        // If still no image, return to main page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Bar()),
          (route) => false,
        );
        return;
      }
    }

    // Convert XFile to File
    File file = File(image.path);

    // Show loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (!mounted) return;

    // ✅ Create UserRecord and upload to Firestore
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    if (userUid == null) {
      // User is not logged in, handle accordingly
      AlertDialog(
        title: const Text("Error"),
        content: const Text("User is not logged in."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("OK"),
          ),
        ],
      );
      return;
    }

    // 🧠 Ask Gemini for analysis
    context.read<ChatBlocBloc>().add(AnalyzeMealImageEvent(inputImage: file));

    // Then only upload image to Firebase Storage
    // String? downloadUrl = await UploadService.uploadImageToFirebase(file);

    // final userRecord = UserRecord(
    //   userUid: userUid,
    //   imageUrl: downloadUrl,
    //   calories: analysis['calories'],
    //   recommendation: analysis['recommendation'],
    // );

    // await UserRecordService().addUserRecord(userRecord);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DisplayPhotoPage(imageFile: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}

class DisplayPhotoPage extends StatelessWidget {
  final File imageFile;

  const DisplayPhotoPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meal Analysis')),
      body: BlocBuilder<ChatBlocBloc, ChatBlocState>(
        builder: (context, state) {
          if (state is AnalyzeMealLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChatSuccessState && state.messages.isNotEmpty) {
            return _buildAnalysisContent(context, state.messages);
          } else if (state is AnalyzeMealErrorState) {
            return Center(child: Text('Error analyzing meal: ${state.error}'));
          } else {
            return _buildInitialPhoto(context);
          }
        },
      ),
      floatingActionButton: BlocBuilder<ChatBlocBloc, ChatBlocState>(
        builder: (context, state) {
          if (state is ChatSuccessState && state.messages.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () => _handleSave(context, state.messages),
              icon: const Icon(Icons.save),
              label: const Text("Save"),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    List<ChatMessageModel> messages,
  ) async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;

    if (userUid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    try {
      // Parse analysis
      final analysis = _extractFirstValidAnalysis(messages);

      if (analysis == null) {
        throw Exception("No valid analysis data found.");
      }

      final calories = analysis['calories'];
      final recommendation = analysis['recommendation'];

      // Show loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Upload image
      final downloadUrl = await UploadService.uploadImageToFirebase(imageFile);

      if (downloadUrl == null) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Failed to upload image")));
        return;
      }

      final userRecord = UserRecord(
        userUid: userUid,
        imageUrl: downloadUrl,
        calories: calories,
        recommendation: recommendation,
      );

      await UserRecordService().addUserRecord(userRecord);

      Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Saved successfully!")));
    } catch (e) {
      Navigator.pop(context); // Close loader
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
    }
  }

  Widget _buildInitialPhoto(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 240,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(imageFile, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Analyzing meal...', style: TextStyle(fontSize: 16)),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent(
    BuildContext context,
    List<ChatMessageModel> messages,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 240,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.file(imageFile, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          _buildAnalysisResponse(messages),
        ],
      ),
    );
  }

  Widget _buildAnalysisResponse(List<ChatMessageModel> messages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gemini Analysis:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...messages.expand((message) {
          final text = message.parts.first.text;
          if (text == null || text.toLowerCase() == 'null') return [];

          try {
            final analysis = jsonDecode(text) as Map<String, dynamic>;
            final calories = analysis['calories'];
            final recommendation = analysis['recommendation'];

            return [
              Text(
                'Calories: $calories CAL',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Recommendation: $recommendation',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
            ];
          } catch (e) {
            return [
              Text(
                'Error parsing analysis response: $e',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
            ];
          }
        }),
      ],
    );
  }

  //Helper Function
  Map<String, dynamic>? _extractFirstValidAnalysis(
    List<ChatMessageModel> messages,
  ) {
    for (final message in messages) {
      for (final part in message.parts) {
        final text = part.text;
        if (text != null && text.toLowerCase() != 'null') {
          try {
            final decoded = jsonDecode(text);
            if (decoded is Map<String, dynamic>) {
              return decoded;
            }
          } catch (_) {
            // Ignore and try next part
          }
        }
      }
    }
    return null;
  }
}
