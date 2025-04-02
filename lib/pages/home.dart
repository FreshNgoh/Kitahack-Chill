import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  bool _showCookSection = false;
  bool _showRestaurantSection = false;

  File? _selectedImage;

  int _selectedDay = DateTime.now().weekday;
  final double totalCalories = 2000;
  double get remainingCalories => 1700;

  final List<String> days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  void _changeDay(int direction) {
    setState(() {
      _selectedDay = (_selectedDay + direction).clamp(1, 7);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _changeDay(-1),
                ),
                Text(
                  days[_selectedDay - 1].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _changeDay(1),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildCalorieCard(),
            const SizedBox(height: 30),
            _buildNutrientRow(),
            _buildActionButtons(),
            const SizedBox(height: 20),
            if (_showCookSection) ...{
              _buildIngredientsSection(),
              _buildUploadButton(),
            },
            if (_showRestaurantSection) ...{_buildRestaurantSection()},
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: CircularProgressIndicator(
            value: (totalCalories - remainingCalories) / totalCalories,
            strokeWidth: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        Column(
          children: [
            Text(
              remainingCalories.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              'Kcal left',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNutrientItem('Carbs', '60g left', 0.4, Colors.green),
        _buildNutrientItem('Protein', '100g left', 0.9, Colors.purple),
        _buildNutrientItem('Fat', '50g left', 0.5, Colors.orange),
      ],
    );
  }

  Widget _buildNutrientItem(
    String title,
    String subtitle,
    double progressValue,
    Color color,
  ) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(Icons.restaurant_menu, size: 20),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _showCookSection ? Colors.blue : Colors.grey[100],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: _showCookSection ? Colors.blue : Colors.grey[300]!,
                  ),
                ),
                elevation: 2,
              ),
              onPressed: () {
                setState(() {
                  _showCookSection = true;
                  _showRestaurantSection = false;
                });
              },
              label: const Text(
                'Cook',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.storefront, size: 20),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _showRestaurantSection ? Colors.blue : Colors.grey[100],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color:
                        _showRestaurantSection
                            ? Colors.blue
                            : Colors.grey[300]!,
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  _showCookSection = false;
                  _showRestaurantSection = true;
                });
              },
              label: const Text(
                'Restaurant',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Let Google AI to decide your recipe today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Find nearby restaurants',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          // Add restaurant list or other content
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Column(
      children: [
        SizedBox(
          width: 250,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.upload_rounded, size: 20),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.blue.withAlpha(60)),
            ),
            onPressed: () {
              _pickImageFromGallery();
            },
            label: const Text(
              'Upload Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _selectedImage != null
            ? Image.file(_selectedImage!, height: 150, fit: BoxFit.cover)
            : const Text(
              "Please select an image",
              style: TextStyle(color: Colors.grey),
            ),
      ],
    );
  }

  Future _pickImageFromGallery() async {
    try {
      final returnedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (returnedImage != null) {
        setState(() {
          _selectedImage = File(returnedImage.path);
        });
      }
    } catch (e) {
      ('Image picker error: $e');
    }
  }
}
