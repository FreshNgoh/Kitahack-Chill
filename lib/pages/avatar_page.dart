import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_notion_avatar/flutter_notion_avatar.dart';
import 'package:flutter_notion_avatar/flutter_notion_avatar_controller.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user.dart';
import '../services/storage/upload_service.dart';
import '../services/user/user_service.dart';

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  NotionAvatarController? _avatarController;
  UserModel? _currentUser;
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey _avatarKey = GlobalKey();
  bool _isUploading = false;
  bool _isAvatarRandomized = false; // Track if the avatar has been randomized
  bool _isRandomizingAvatar = false;

  int caloriesTaken = 2000;
  int caloriesBurnt = 50;

  int get netCalories => caloriesTaken - caloriesBurnt;

  Color getCalorieColor(int calories) {
    if (calories > 3080) {
      return Colors.red[400]!;
    } else if (calories >= 2520) {
      return Colors.orange[400]!;
    } else {
      return Colors.green[400]!;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {});
    final User? user = _auth.currentUser;
    if (user != null) {
      final UserModel? fetchedUser = await _userService.getUser(user.uid);
      if (fetchedUser != null) {
        setState(() {
          _currentUser = fetchedUser;
        });
      }
    }
  }

  void _randomizeAvatar() {
    setState(() {
      _isRandomizingAvatar = true;
    });
    // Optionally, you might want to immediately trigger the first random avatar:
    _avatarController?.random();
    setState(() {
      _isAvatarRandomized = true;
    });
  }

  Future<void> _confirmAndUploadAvatar() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Save Avatar'),
          content: const Text('Do you want to update your avatar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _uploadNewAvatar();
    }
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
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing avatar: $e");
      return null;
    }
  }

  Future<void> _uploadNewAvatar() async {
    setState(() {
      _isUploading = true;
    });
    final Uint8List? avatarBytes = await _captureAvatarAsBytes();
    if (avatarBytes != null) {
      File? tempFile;
      try {
        final tempDir = await getTemporaryDirectory();
        tempFile = File(
          '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await tempFile.writeAsBytes(avatarBytes);

        final String? avatarUrl = await UploadService.uploadImageToFirebase(
          tempFile,
        );

        if (avatarUrl != null) {
          final User? user = _auth.currentUser;
          if (user != null) {
            await _userService.updateUser(user.uid, {'imageUrl': avatarUrl});
            _loadCurrentUser(); // Reload user data to show the new avatar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avatar updated successfully!')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload new avatar.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading avatar: $e')));
        print('Error uploading avatar: $e');
      } finally {
        await tempFile?.delete();
        setState(() {
          _isUploading = false;
          _isAvatarRandomized = false; // Reset state after upload
        });
      }
    } else {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture avatar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = getCalorieColor(netCalories);
    return Scaffold(
      body:
          _currentUser == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // ... (Your existing calorie widgets) ...
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: currentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: currentColor,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _getStatusIcon(),
                                        color: currentColor,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Net Calories',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: currentColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${netCalories}cal', // Replace with actual netCalories
                                    style: TextStyle(
                                      fontSize: 32,
                                      color: currentColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildSecondaryStat(
                                  'Calories Taken',
                                  caloriesTaken,
                                  Icons.local_dining,
                                  currentColor,
                                ),
                                _buildVerticalDivider(currentColor),
                                _buildSecondaryStat(
                                  'Calories Burnt',
                                  caloriesBurnt,
                                  Icons.directions_run,
                                  currentColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Avatar Container
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(150),
                                border: Border.all(
                                  color: currentColor,
                                  width: 4,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(150),
                                child: RepaintBoundary(
                                  key: _avatarKey,
                                  child: SizedBox(
                                    width: 225,
                                    height: 225,
                                    child:
                                        _isRandomizingAvatar
                                            ? StatefulBuilder(
                                              builder: (context, setState) {
                                                return NotionAvatar(
                                                  useRandom: true,
                                                  onCreated: (controller) {
                                                    _avatarController =
                                                        controller;
                                                  },
                                                );
                                              },
                                            )
                                            : _currentUser?.imageUrl != null
                                            ? Image.network(
                                              _currentUser!.imageUrl!,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (
                                                BuildContext context,
                                                Widget child,
                                                ImageChunkEvent?
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child: CircularProgressIndicator(
                                                    value:
                                                        loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                  ),
                                                );
                                              },
                                              errorBuilder: (
                                                BuildContext context,
                                                Object error,
                                                StackTrace? stackTrace,
                                              ) {
                                                return const Icon(Icons.error);
                                              },
                                            )
                                            : const SizedBox(), // Or a default placeholder if no image and not randomizing
                                  ),
                                ),
                              ),
                            ),
                            if (_isUploading)
                              const Positioned.fill(
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isUploading ? null : _randomizeAvatar,
                        child: const Text('Randomize Avatar'),
                      ),
                      const SizedBox(height: 10),
                      if (_isAvatarRandomized)
                        ElevatedButton(
                          onPressed:
                              _isUploading ? null : _confirmAndUploadAvatar,
                          child: const Text('Save Avatar'),
                        ),
                    ],
                  ),
                  // Add Button (Keep if you need it)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: () {
                        /* Add action */
                      },
                      backgroundColor: currentColor.withOpacity(0.7),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  IconData _getStatusIcon() {
    if (netCalories > 3080) return Icons.warning;
    if (netCalories >= 2520) return Icons.info;
    return Icons.emoji_emotions_outlined;
  }

  Widget _buildSecondaryStat(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '$value cal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(Color color) {
    return Container(
      height: 30,
      width: 1,
      color: color.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}

// Input Area start here
class InputBottomSheet extends StatefulWidget {
  const InputBottomSheet({super.key});

  @override
  _InputBottomSheetState createState() => _InputBottomSheetState();
}

class _InputBottomSheetState extends State<InputBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _exerciseController =
      TextEditingController(); // New controller
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _energyController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _energyController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  Widget build(BuildContext context) {
    final Color primaryColor = Colors.indigo;
    final Color accentColor = Colors.indigoAccent;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // const Icon(Icons.fitness_center, size: 40, color: Colors.blueGrey),
            const SizedBox(height: 20),

            // Title input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: accentColor),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.title, color: accentColor),
              ),
            ),

            const SizedBox(height: 20),

            // Exercise input
            TextField(
              controller: _exerciseController,
              decoration: InputDecoration(
                labelText: 'Exercise',
                labelStyle: TextStyle(color: accentColor),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'e.g., Morning Jog, Weight Training',
                prefixIcon: Icon(Icons.directions_run, color: accentColor),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                // Date picker
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    label: Text(
                      _selectedDate == null
                          ? 'Pick Date'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _selectDate,
                  ),
                ),

                const SizedBox(width: 15),

                // Time picker
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.access_time, color: Colors.white),
                    label: Text(
                      _selectedTime == null
                          ? 'Pick Time'
                          : _selectedTime!.format(context),
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _selectTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Duration input
            TextField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Duration',
                labelStyle: TextStyle(color: accentColor),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.timer, color: accentColor),
                suffixText: 'min',
              ),
            ),

            const SizedBox(height: 20),

            //  Energy Expended input
            TextField(
              controller: _energyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Energy Expended',
                labelStyle: TextStyle(color: accentColor),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(
                  Icons.local_fire_department,
                  color: accentColor,
                ),
                suffixText: 'kcal',
              ),
            ),

            const SizedBox(height: 30),

            //  Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
              onPressed: () {
                // Save logic
              },
              child: const Text(
                'SAVE WORKOUT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
