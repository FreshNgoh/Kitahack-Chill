import 'package:flutter/material.dart';
import 'package:flutter_notion_avatar/flutter_notion_avatar.dart';
import 'package:flutter_notion_avatar/flutter_notion_avatar_controller.dart';

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  NotionAvatarController? controller;
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
  Widget build(BuildContext context) {
    final currentColor = getCalorieColor(netCalories);

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Net Calories Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: currentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: currentColor, width: 2),
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
                          '${netCalories}cal',
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

                  // Taken and Burnt Row
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

            SizedBox(height: 20),
            // Avatar Container
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  border: Border.all(color: currentColor, width: 4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(150),
                  child: NotionAvatar(
                    useRandom: true,
                    onCreated: (controller) => this.controller = controller,
                  ),
                ),
              ),
            ),

            // Random Button
            TextButton(
              onPressed: () => controller?.random(),
              child: Text(
                'Randomize Avatar',
                style: TextStyle(
                  color: currentColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        // Add Button
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton(
            onPressed: () {
              /* Add action */
            },
            backgroundColor: currentColor.withOpacity(0.7),
            child: Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ],
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


