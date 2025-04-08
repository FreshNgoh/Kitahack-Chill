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


// class AvatarPage extends StatelessWidget {
//   const AvatarPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // Row 1: Header + Info | 3D Viewer
//             Expanded(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Column 1: Header and Info
//                   Expanded(
//                     flex: 4,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.baseline,
//                               textBaseline: TextBaseline.alphabetic,
//                               children: [
//                                 const Text(
//                                   'Calories',
//                                   style: TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 3),
//                                 Text(
//                                   '/week',
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Text(
//                               '1000',
//                               style: TextStyle(
//                                 fontSize: 55,
//                                 fontWeight: FontWeight.w500,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 25),

//                         _buildMetricItem(
//                           icon: Icons.local_fire_department,
//                           iconColor:
//                               Colors.deepOrangeAccent, // Custom icon color
//                           value: '1,840',
//                           label: 'calories',
//                         ),
//                         const SizedBox(height: 25),
//                         _buildMetricItem(
//                           icon: Icons.directions_walk,
//                           iconColor: Colors.green,
//                           value: '3,248',
//                           label: 'steps',
//                         ),
//                         const SizedBox(height: 25),
//                         _buildMetricItem(
//                           icon: Icons.access_time,
//                           iconColor: Colors.blueAccent,
//                           value: '6.5',
//                           label: 'hours',
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Column 2: 3D
//                   Expanded(
//                     flex: 6,
//                     child: const Flutter3DViewer(
//                       src: "assets/3d/human_body.glb",
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Row 2: Action Boxes
//             Container(
//               height: 100,
//               padding: const EdgeInsets.all(0),
//               margin: EdgeInsets.only(bottom: 20),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   _buildActionBox(Colors.blue, 'Exercise'),
//                   _buildActionBox(Colors.green, 'Diet'),
//                   _buildActionBox(Colors.orange, 'Sleep'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionBox(Color color, String label) {
//     return Flexible(
//       child: InkWell(
//         splashColor: color.withOpacity(0.3),
//         highlightColor: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // click handler here
//         },
//         child: Container(
//           width: 110,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           padding: const EdgeInsets.all(12),
//           child: Center(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: color,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildMetricItem({
//     required IconData icon,
//     required Color iconColor,
//     required String value,
//     required String label,
//     double labelSize = 15,
//   }) {
//     return Row(
//       children: [
//         Icon(icon, size: 40, color: iconColor),
//         const SizedBox(width: 15),
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               value,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: labelSize,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey, // Constant gray color
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }



