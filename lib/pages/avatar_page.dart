import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Row 1: Header + Info | 3D Viewer
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column 1: Header and Info
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text(
                                  'Calories',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '/week',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '1000',
                              style: TextStyle(
                                fontSize: 55,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        _buildMetricItem(
                          icon: Icons.local_fire_department,
                          iconColor:
                              Colors.deepOrangeAccent, // Custom icon color
                          value: '1,840',
                          label: 'calories',
                        ),
                        const SizedBox(height: 25),
                        _buildMetricItem(
                          icon: Icons.directions_walk,
                          iconColor: Colors.green,
                          value: '3,248',
                          label: 'steps',
                        ),
                        const SizedBox(height: 25),
                        _buildMetricItem(
                          icon: Icons.access_time,
                          iconColor: Colors.blueAccent,
                          value: '6.5',
                          label: 'hours',
                        ),
                      ],
                    ),
                  ),

                  // Column 2: 3D
                  Expanded(
                    flex: 6,
                    child: const Flutter3DViewer(
                      src: "assets/3d/human_body.glb",
                    ),
                  ),
                ],
              ),
            ),

            // Row 2: Action Boxes
            Container(
              height: 100,
              padding: const EdgeInsets.all(0),
              margin: EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionBox(Colors.blue, 'Exercise'),
                  _buildActionBox(Colors.green, 'Diet'),
                  _buildActionBox(Colors.orange, 'Sleep'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBox(Color color, String label) {
    return Flexible(
      child: InkWell(
        splashColor: color.withOpacity(0.3),
        highlightColor: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // click handler here
        },
        child: Container(
          width: 110,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    double labelSize = 15,
  }) {
    return Row(
      children: [
        Icon(icon, size: 40, color: iconColor),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: labelSize,
                fontWeight: FontWeight.w500,
                color: Colors.grey, // Constant gray color
              ),
            ),
          ],
        ),
      ],
    );
  }
}
