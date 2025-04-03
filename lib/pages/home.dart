import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application/bloc/chat_bloc_bloc.dart';
import 'package:flutter_application/pages/recipe_suggestion.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  bool _showCookSection = false;
  bool _showRestaurantSection = false;
  bool _isImageConfirmed = false;

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
            const SizedBox(height: 15),
            _buildCalorieCard(),
            const SizedBox(height: 25),
            _buildNutrientRow(),
            _buildActionButtons(),
            const SizedBox(height: 15),
            if (_showCookSection) ...[
              _selectedImage == null
                  ? Column(
                    children: [
                      _buildIngredientsSection(),
                      _buildUploadButton(),
                    ],
                  )
                  : _buildImagePreviewSection(),
            ],
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
          height: 160,
          child: CircularProgressIndicator(
            value: (totalCalories - remainingCalories) / totalCalories,
            strokeWidth: 20,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
        Column(
          children: [
            Text(
              remainingCalories.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Text(
              'Kcal left',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
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
        margin: const EdgeInsets.symmetric(horizontal: 20),
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
            const SizedBox(height: 3),
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
              icon: Icon(
                Icons.restaurant_menu,
                size: 20,
                color:
                    _showCookSection
                        ? Colors.white
                        : const Color.fromARGB(255, 123, 7, 144),
              ),
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
              label: Text(
                'Cook',
                style: TextStyle(
                  color: _showCookSection ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.storefront,
                size: 20,
                color:
                    _showRestaurantSection
                        ? Colors.white
                        : const Color.fromARGB(255, 123, 7, 144),
              ),
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
              label: Text(
                'Restaurant',
                style: TextStyle(
                  color: _showRestaurantSection ? Colors.white : Colors.black87,
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
              'Let Gemini AI to decide your recipe today',
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
      ],
    );
  }

  Widget _buildImagePreviewSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              height: 150, // Increased height
              width: double.infinity, // Full width
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
                image: DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
            ),
            // Improved close button
            Container(
              margin: const EdgeInsets.all(8),
              height: 28,
              width: 28,
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    _selectedImage = null;
                    _isImageConfirmed = true;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 4,
            shadowColor: Colors.blue[100],
          ),
          onPressed: () {
            if (_selectedImage != null) {
              context.read<ChatBlocBloc>().add(
                ChatGenerateNewRecipeEvent(inputImage: _selectedImage!),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          RecipeSuggestionScreen(imageFile: _selectedImage!),
                ),
              );
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Procced with Gemini AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
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
