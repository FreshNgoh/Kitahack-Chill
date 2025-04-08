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
              showModalBottomSheet(
                context: context,
                isDismissible: true,
                enableDrag: true,
                backgroundColor: Colors.white,
                isScrollControlled:
                    true, // Allows the sheet to resize for keyboard
                builder: (BuildContext context) {
                  return const InputBottomSheet();
                },
              );
            },
            backgroundColor: currentColor.withOpacity(0.6),
            child: const Icon(Icons.add, color: Colors.white, size: 32),
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

// Add this StatefulWidget class in your widget tree

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
