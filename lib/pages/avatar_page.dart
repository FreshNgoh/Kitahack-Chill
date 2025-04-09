import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application/models/user_exercise.dart';
import 'package:flutter_application/models/user_record.dart';
import 'package:flutter_application/services/user_record/user_record.dart';
import 'package:flutter_application/services/user_services/user_service.dart';
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
  final ExerciseService _exerciseService = ExerciseService();
  final UserRecordService _userRecordService = UserRecordService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey _avatarKey = GlobalKey();
  final Random _random = Random();
  bool _isUploading = false;
  bool _isAvatarRandomized = false; // Track if the avatar has been randomized
  bool _isRandomizingAvatar = false;
  int _randomizeCount = 0;
  Map<String, int>? _randomizedAvatarIndices;

  int caloriesTaken = 2000;
  int caloriesBurnt = 3200;

  int get netCalories => caloriesTaken - caloriesBurnt;

  List<int> _thinnestFaces = [3, 2, 14]; // Highest to lowest
  List<int> _fattestFaces = [13, 9, 11]; // Highest to lowest
  int _normalFace = 10;

  int _getFaceIndexBasedOnCalories() {
    if (netCalories > 1000) {
      // Example threshold for fattest
      return _fattestFaces.first; // Highest of fattest
    } else if (netCalories > 500) {
      // Example threshold for middle fattest
      return _fattestFaces[1];
    } else if (netCalories > 100) {
      // Example threshold for lowest fattest
      return _fattestFaces.last;
    } else if (netCalories < -1000) {
      // Example threshold for thinnest
      return _thinnestFaces.first; // Highest of thinnest
    } else if (netCalories < -500) {
      // Example threshold for middle thinnest
      return _thinnestFaces[1];
    } else if (netCalories < -100) {
      // Example threshold for lowest thinnest
      return _thinnestFaces.last;
    } else {
      return _normalFace;
    }
  }

  Color getCalorieColor(int calories) {
    if (calories > 700) {
      return Colors.red[400]!;
    } else if (calories >= 400) {
      return Colors.orange[400]!;
    } else {
      return Colors.green[400]!;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndUpdateAvatar();
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

  Future<void> _loadDailyCaloriesBurnt() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DateTime now = DateTime.now();
      final DateTime startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
        0,
        0,
        0,
      );
      final DateTime endOfDay = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      );

      try {
        final QuerySnapshot<UserExercise> snapshot = await _exerciseService
            .getUserExercisesForDateRange(user.uid, startOfDay, endOfDay);

        int totalBurnt = 0;
        for (final doc in snapshot.docs) {
          totalBurnt += doc.data().caloriesBurnt.toInt();
        }

        setState(() {
          caloriesBurnt = totalBurnt;
        });
      } catch (e) {
        print("Error fetching today's exercises: $e");
        // Handle error appropriately
      }
    }
  }

  Future<void> _loadDailyCaloriesTaken() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      final DateTime now = DateTime.now();
      final DateTime startOfDay = DateTime(
        now.year,
        now.month,
        now.day,
        0,
        0,
        0,
      );
      final DateTime endOfDay = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
      );

      try {
        final QuerySnapshot<UserRecord> snapshot = await _userRecordService
            .getUserRecordsForDateRange(user.uid, startOfDay, endOfDay);

        double totalCaloriesTaken = 0;
        for (final doc in snapshot.docs) {
          final userRecord = doc.data();
          if (userRecord != null && userRecord.calories != null) {
            if (userRecord.calories is String) {
              // Try parsing the string to a double
              double? parsedCalories = double.tryParse(
                userRecord.calories as String,
              );
              if (parsedCalories != null) {
                totalCaloriesTaken += parsedCalories;
              } else {
                print(
                  "Warning: Could not parse calories string: ${userRecord.calories}",
                );
                // Optionally handle the error, e.g., skip this record or set to 0
              }
            } else if (userRecord.calories is double) {
              totalCaloriesTaken += userRecord.calories as double;
            } else if (userRecord.calories is int) {
              totalCaloriesTaken += (userRecord.calories as int).toDouble();
            } else {
              print(
                "Warning: Unexpected type for calories: ${userRecord.calories.runtimeType}",
              );
              // Optionally handle unexpected types
            }
          }
        }

        setState(() {
          caloriesTaken = totalCaloriesTaken.toInt();
        });
      } catch (e) {
        print("Error fetching today's calorie records: $e");
        // Handle error appropriately
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadDailyCaloriesBurnt();
    await _loadDailyCaloriesTaken();
  }

  Future<void> _updateAvatarBasedOnCalories() async {
    if (_currentUser != null) {
      final newFaceIndex = _getFaceIndexBasedOnCalories();
      if (_currentUser?.faceIndex != newFaceIndex) {
        await _userService.updateUser(_currentUser!.uid, {
          'faceIndex': newFaceIndex,
        });
        await _regenerateAvatarWithNewFace(newFaceIndex);
        // Introduce a small delay to allow the UI to update
        await Future.delayed(const Duration(milliseconds: 200));
        // await _uploadCurrentAvatar(); // Upload the new calorie-based avatar
        await _loadCurrentUser(); // Reload to reflect the new imageUrl
      } else if (_currentUser?.imageUrl == null) {
        // If faceIndex is the same but no image, capture and update
        // Ensure NotionAvatar is visible here
        setState(
          () {},
        ); // Trigger a rebuild to make sure Visibility allows NotionAvatar
        await Future.delayed(const Duration(milliseconds: 200));
        // await _uploadCurrentAvatar();
        await _loadCurrentUser();
      } else if (_avatarController == null &&
          _currentUser?.avatarOptions != null &&
          _currentUser?.faceIndex != null) {
        // Initial avatar setup if controller is null
        _setAvatarFromCurrentUser();
      }
    }
  }

  Future<void> _regenerateAvatarWithNewFace(int newFaceIndex) async {
    if (_currentUser?.avatarOptions != null) {
      setState(() {
        _avatarController?.setFace(newFaceIndex);
        _avatarController?.setAccessories(
          _currentUser!.avatarOptions!['accessoriesIndex']!,
        );
        _avatarController?.setEyes(_currentUser!.avatarOptions!['eyesIndex']!);
        _avatarController?.setEyebrows(
          _currentUser!.avatarOptions!['eyebrowsIndex']!,
        );
        _avatarController?.setGlasses(
          _currentUser!.avatarOptions!['glassesIndex']!,
        );
        _avatarController?.setHair(_currentUser!.avatarOptions!['hairIndex']!);
        _avatarController?.setMouth(
          _currentUser!.avatarOptions!['mouthIndex']!,
        );
        _avatarController?.setNose(_currentUser!.avatarOptions!['noseIndex']!);
        _avatarController?.setDetails(
          _currentUser!.avatarOptions!['detailsIndex']!,
        );
        _avatarController?.setFestival(
          _currentUser!.avatarOptions!['festivalIndex']!,
        );
      });
    }
  }

  Future<void> _loadCurrentUserAndUpdateAvatar() async {
    await _loadCurrentUser();
    await _loadDailyCaloriesBurnt();
    await _loadDailyCaloriesTaken();
    if (_currentUser?.avatarOptions != null &&
        _currentUser?.faceIndex != null) {
      _setAvatarFromCurrentUser();
    }
    await _updateAvatarBasedOnCalories();
  }

  void _setAvatarFromCurrentUser() {
    if (_currentUser?.avatarOptions != null &&
        _currentUser?.faceIndex != null) {
      setState(() {
        _avatarController?.setFace(_currentUser!.faceIndex!);
        _avatarController?.setAccessories(
          _currentUser!.avatarOptions!['accessoriesIndex']!,
        );
        _avatarController?.setEyes(_currentUser!.avatarOptions!['eyesIndex']!);
        _avatarController?.setEyebrows(
          _currentUser!.avatarOptions!['eyebrowsIndex']!,
        );
        _avatarController?.setGlasses(
          _currentUser!.avatarOptions!['glassesIndex']!,
        );
        _avatarController?.setHair(_currentUser!.avatarOptions!['hairIndex']!);
        _avatarController?.setMouth(
          _currentUser!.avatarOptions!['mouthIndex']!,
        );
        _avatarController?.setNose(_currentUser!.avatarOptions!['noseIndex']!);
        _avatarController?.setDetails(
          _currentUser!.avatarOptions!['detailsIndex']!,
        );
        _avatarController?.setFestival(
          _currentUser!.avatarOptions!['festivalIndex']!,
        );
      });
    }
  }

  void _randomizeAvatar() {
    int? _accessoriesIndex;
    int? _eyesIndex;
    int? _eyebrowsIndex;
    int? _faceIndex; // Fixed face
    int? _glassesIndex;
    int? _hairIndex;
    int? _mouthIndex;
    int? _noseIndex;
    int? _detailsIndex;
    int? _festivalIndex; // Assuming these exist in NotionAvatarController

    setState(() {
      _isRandomizingAvatar = true;
      _randomizeCount++; // Increment count immediately
    });

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
    _faceIndex =
        _currentUser?.faceIndex ??
        10; // Fixed face, to follow the user database one
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

    _randomizedAvatarIndices = {
      'accessoriesIndex': _accessoriesIndex!,
      'eyesIndex': _eyesIndex!,
      'eyebrowsIndex': _eyebrowsIndex!,
      'glassesIndex': _glassesIndex!,
      'hairIndex': _hairIndex!,
      'mouthIndex': _mouthIndex!,
      'noseIndex': _noseIndex!,
      'detailsIndex': _detailsIndex!,
      'festivalIndex': _festivalIndex!,
    };

    setState(() {
      // Trigger a rebuild to reflect the changes
      _isAvatarRandomized = true;
      _isRandomizingAvatar = false;
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
      return null;
    }
  }

  Future<void> _uploadCurrentAvatar() async {
    setState(() {
      _isUploading = true;
    });

    final Uint8List? avatarBytes = await _captureAvatarAsBytes();
    if (avatarBytes != null) {
      File? tempFile;
      try {
        final tempDir = await getTemporaryDirectory();
        tempFile = File(
          '${tempDir.path}/avatar_calorie_${DateTime.now().millisecondsSinceEpoch}.png', // Corrected interpolation
        );
        await tempFile.writeAsBytes(avatarBytes);

        final String? avatarUrl = await UploadService.uploadImageToFirebase(
          tempFile,
        );

        if (avatarUrl != null && _currentUser != null) {
          await _userService.updateUser(_currentUser!.uid, {
            'imageUrl': avatarUrl,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Avatar updated based on calories.'),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update avatar.')),
            );
          }
        }
      } catch (e) {
        print('Error updating avatar: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error updating avatar: $e')));
        }
      } finally {
        await tempFile?.delete();
        setState(() {
          _isUploading = false;
        });
      }
    } else {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to capture avatar.')),
        );
      }
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
          if (user != null && _randomizedAvatarIndices != null) {
            final currentFaceIndex = _currentUser?.faceIndex ?? 10;

            await _userService.updateUser(user.uid, {
              'imageUrl': avatarUrl,
              'avatarOptions': _randomizedAvatarIndices,
              'faceIndex': currentFaceIndex,
            });
            _loadCurrentUser(); // Reload user data to show the new avatar and options
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Avatar updated successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update avatar data.')),
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
          _isAvatarRandomized = false;
          _randomizedAvatarIndices = null; // Reset after upload
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
                                    child: Stack(
                                      children: [
                                        // Conditionally display the Image.network
                                        if (_currentUser?.imageUrl != null &&
                                            !_isRandomizingAvatar &&
                                            !_isAvatarRandomized)
                                          Positioned.fill(
                                            child: Image.network(
                                              _currentUser!.imageUrl!,
                                              fit: BoxFit.cover,
                                              // ... (your loading and error builders)
                                            ),
                                          ),
                                        // Conditionally display the NotionAvatar
                                        Visibility(
                                          visible:
                                              _isRandomizingAvatar ||
                                              _isAvatarRandomized ||
                                              _currentUser?.imageUrl == null,
                                          child: StatefulBuilder(
                                            builder: (context, setState) {
                                              return NotionAvatar(
                                                onCreated: (controller) {
                                                  _avatarController =
                                                      controller;
                                                  // Perform initial setup if needed
                                                  if (_currentUser?.faceIndex !=
                                                      null) {
                                                    _avatarController?.setFace(
                                                      _currentUser!.faceIndex!,
                                                    );
                                                  }
                                                  if (_currentUser
                                                          ?.avatarOptions !=
                                                      null) {
                                                    _avatarController
                                                        ?.setAccessories(
                                                          _currentUser!
                                                              .avatarOptions!['accessoriesIndex']!,
                                                        );
                                                    _avatarController?.setEyes(
                                                      _currentUser!
                                                          .avatarOptions!['eyesIndex']!,
                                                    );
                                                    _avatarController?.setFace(
                                                      _currentUser!.faceIndex!,
                                                    );
                                                    _avatarController?.setEyebrows(
                                                      _currentUser!
                                                          .avatarOptions!['eyebrowsIndex']!,
                                                    );
                                                    _avatarController?.setGlasses(
                                                      _currentUser!
                                                          .avatarOptions!['glassesIndex']!,
                                                    );
                                                    _avatarController?.setHair(
                                                      _currentUser!
                                                          .avatarOptions!['hairIndex']!,
                                                    );
                                                    _avatarController?.setMouth(
                                                      _currentUser!
                                                          .avatarOptions!['mouthIndex']!,
                                                    );
                                                    _avatarController?.setNose(
                                                      _currentUser!
                                                          .avatarOptions!['noseIndex']!,
                                                    );
                                                    _avatarController?.setDetails(
                                                      _currentUser!
                                                          .avatarOptions!['detailsIndex']!,
                                                    );
                                                    _avatarController?.setFestival(
                                                      _currentUser!
                                                          .avatarOptions!['festivalIndex']!,
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
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
                        child: const Text('Update Avatar'),
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
                        showModalBottomSheet(
                          context: context,
                          isDismissible: true,
                          enableDrag: true,
                          backgroundColor: Colors.white,
                          isScrollControlled:
                              true, // Allows the sheet to resize for keyboard
                          builder: (BuildContext context) {
                            return InputBottomSheet(
                              onExerciseSaved:
                                  _refreshData, // Pass the callback
                            );
                          },
                        );
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
  final Future<void> Function()? onExerciseSaved; // Callback function

  const InputBottomSheet({Key? key, this.onExerciseSaved}) : super(key: key);

  @override
  _InputBottomSheetState createState() => _InputBottomSheetState();
}

class _InputBottomSheetState extends State<InputBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _energyController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Exercise? _selectedExercise; // Make it nullable initially

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ExerciseService _exerciseService = ExerciseService();

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _energyController.dispose();
    _weightController.dispose();
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

  Future<void> _saveExercise() async {
    final String title = _titleController.text.trim();
    final String durationText = _durationController.text.trim();
    final String energyText = _energyController.text.trim();
    final String weightText = _weightController.text.trim();

    if (title.isEmpty ||
        _selectedExercise == null ||
        _selectedDate == null ||
        _selectedTime == null ||
        weightText.isEmpty ||
        durationText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    final int duration = int.tryParse(durationText) ?? 0;
    final double? manualCalories = double.tryParse(energyText);
    final double weight = double.tryParse(weightText) ?? 70.0; // Default weight
    final DateTime combinedDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final User? user = _auth.currentUser;
    if (user != null) {
      double caloriesBurnt;

      if (manualCalories != null) {
        caloriesBurnt = manualCalories;
      } else {
        caloriesBurnt = _calculateCaloriesBurnt(
          exercise: _selectedExercise!,
          duration: duration,
          weight: weight,
        );
      }

      final UserExercise newExercise = UserExercise(
        uid: user.uid,
        title: title,
        exerciseName: _selectedExercise!,
        duration: duration,
        caloriesBurnt: caloriesBurnt,
        timestamp: combinedDateTime,
      );

      try {
        await _exerciseService.saveExercise(newExercise);
        Navigator.pop(context);
        if (widget.onExerciseSaved != null) {
          widget.onExerciseSaved!();
        }
      } catch (e) {
        print('Error saving exercise: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save exercise.')),
        );
      }
    }
  }

  // Logic to calculate calories burnt using Exercise enum
  double _calculateCaloriesBurnt({
    required Exercise exercise,
    required int duration,
    required double weight,
  }) {
    final double metValue = exercise.metValue;
    final double caloriesPerMinute = (metValue * 3.5 * weight) / 200;
    return caloriesPerMinute * duration;
  }

  Widget build(BuildContext context) {
    final Color primaryColor = Colors.black87;
    final Color accentColor = Colors.black54;

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
            const SizedBox(height: 20),
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
            DropdownButtonFormField<Exercise>(
              decoration: InputDecoration(
                labelText: 'Exercise',
                labelStyle: TextStyle(color: accentColor),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.directions_run, color: accentColor),
              ),
              value: _selectedExercise,
              items:
                  Exercise.values.map((Exercise value) {
                    return DropdownMenuItem<Exercise>(
                      value: value,
                      child: Text(
                        value.name.toUpperCase(),
                      ), // Display enum name
                    );
                  }).toList(),
              onChanged: (Exercise? newValue) {
                setState(() {
                  _selectedExercise = newValue;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
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
            TextField(
              controller: _energyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Energy Expended (Optional)',
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
            const SizedBox(height: 20),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight',
                labelStyle: TextStyle(color: accentColor),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.accessibility_new, color: accentColor),
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
              ),
              onPressed: _saveExercise,
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
