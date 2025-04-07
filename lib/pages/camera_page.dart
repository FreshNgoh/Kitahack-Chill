import 'dart:io';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  File? _imageFile;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_imageFile == null) {
        _showBottomSheet();
      }
    });
  }

  Future<void> _openCameraAndHandleResult() async {
    final picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Bar()),
        (route) => false,
      );
      return;
    }

    File file = File(image.path);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    if (!mounted) return;

    final userUid = FirebaseAuth.instance.currentUser?.uid;

    if (userUid == null) {
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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DisplayPhotoPage(imageFile: file),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildOptionButton(
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  onTap: () => _handleImageSelection(ImageSource.camera),
                ),
                const SizedBox(height: 16),
                _buildOptionButton(
                  icon: Icons.photo_library,
                  label: 'Choose from Gallery',
                  onTap: () => _handleImageSelection(ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> _handleImageSelection(ImageSource source) async {
    Navigator.pop(context);
    final image = await ImagePicker().pickImage(source: source);

    if (!mounted) return;

    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      // 🧠 Ask Gemini for analysis
      context.read<ChatBlocBloc>().add(
        AnalyzeMealImageEvent(inputImage: _imageFile!),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DisplayPhotoPage(imageFile: _imageFile!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _imageFile != null
        ? Column(
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => setState(() => _imageFile = null),
                        style: IconButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.send,
                            onPressed: () {
                              /* Add send logic */
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.save,
                            onPressed: () {
                              /* Add save logic */
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: getCalorieColor(
                              2520,
                            ), // Use actual calorie value
                            size: 28,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '2520', // Use actual value
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: getCalorieColor(
                                2520,
                              ), // Use actual calorie value
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'cal',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Transform.translate(
                                      offset: const Offset(0, -2),
                                      child: ShaderMask(
                                        shaderCallback:
                                            (bounds) => const LinearGradient(
                                              colors: [
                                                Color(0xFF4285f4),
                                                Color(0xFF9b72cb),
                                                Color(0xFFd96570),
                                              ],
                                              stops: [0.0, 0.3, 0.60],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ).createShader(bounds),
                                        child: const Text(
                                          'Gemini ',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'Suggestion: ',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Smart Kid is a private kindergarten located in Hartamas, Kuala Lumpur, primarily focused on nurturing children aged 3 to 6 years. They are dedicated to developing well-rounded and diverse students, emphasizing not only academics but also emotional and physical growth.To ensure personalized attention, they have structured programs for pre-kindergarten (ages 3–4) and pre-school (ages 5–6). Each intake is limited to 50 students per group (PK/2021 and PS/2021). However, they lack an efficient education system. Teachers and administrative staff currently manage complex schedules, student performance tracking, and parent engagement using manual spreadsheet-based systems, which are time-consuming and inefficient.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
        : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: _showBottomSheet,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No photo selected',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Click the picture to select photo',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onPressed,
        splashColor: Colors.white.withOpacity(0.3),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
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
      final analysis = _extractFirstValidAnalysis(messages);

      if (analysis == null) {
        throw Exception("No valid analysis data found.");
      }

      final calories = analysis['calories'];
      final recommendation = analysis['recommendation'];

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final downloadUrl = await UploadService.uploadImageToFirebase(
        _imageFile!,
      );

      if (downloadUrl == null) {
        Navigator.pop(context);
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

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Saved successfully!")));
    } catch (e) {
      Navigator.pop(context);
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
              child: Image.file(_imageFile!, fit: BoxFit.cover),
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
              child: Image.file(_imageFile!, fit: BoxFit.cover),
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

class DisplayPhotoPage extends StatelessWidget {
  final File imageFile;

  const DisplayPhotoPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBlocBloc, ChatBlocState>(
      builder: (context, state) {
        if (state is ChatLoadingState) {
          return _buildInitialPhoto(context);
        } else if (state is ChatSuccessState) {
          return _buildAnalysisContent(context, state.messages);
        } else if (state is AnalyzeMealErrorState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Analysis Error')),
            body: Center(child: Text('Error: ${state.error}')),
          );
        }
        return _buildInitialPhoto(context);
      },
    );
  }

  Widget _buildInitialPhoto(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analyzing Photo')),
      body: SingleChildScrollView(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.read<ChatBlocBloc>().add(
            AnalyzeMealImageEvent(inputImage: imageFile),
          );
        },
        label: const Text('Re-analyze'),
        icon: const Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAnalysisContent(
    BuildContext context,
    List<ChatMessageModel> messages,
  ) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: SingleChildScrollView(
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final userUid = FirebaseAuth.instance.currentUser?.uid;
          if (userUid == null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("User not logged in")));
            return;
          }
          try {
            final analysis = _extractFirstValidAnalysis(messages);
            if (analysis == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No analysis found")),
              );
              return;
            }
            final calories = analysis['calories'];
            final recommendation = analysis['recommendation'];

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const Center(child: CircularProgressIndicator()),
            );

            final downloadUrl = await UploadService.uploadImageToFirebase(
              imageFile,
            );

            Navigator.pop(context); // Close loader

            if (downloadUrl == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Failed to upload image")),
              );
              return;
            }

            final userRecord = UserRecord(
              userUid: userUid,
              imageUrl: downloadUrl,
              calories: calories,
              recommendation: recommendation,
            );
            await UserRecordService().addUserRecord(userRecord);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Saved to records!")));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Bar()),
            );
          } catch (e) {
            Navigator.pop(context); // Close loader
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Failed to save: $e")));
          }
        },
        icon: const Icon(Icons.save),
        label: const Text('Save Record'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
