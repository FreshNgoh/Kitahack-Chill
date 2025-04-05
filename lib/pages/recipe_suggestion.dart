import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application/bloc/chat_bloc_bloc.dart';
import 'package:flutter_application/models/chat_message_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecipeSuggestionScreen extends StatelessWidget {
  final File imageFile;

  const RecipeSuggestionScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recipe Suggestions',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color.fromARGB(255, 112, 110, 110),
                  width: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ChatBlocBloc, ChatBlocState>(
        builder: (context, state) {
          if (state is ChatLoadingState) {
            return _buildLoading();
          }
          if (state is ChatSuccessState) {
            return _buildRecipeContent(state.messages);
          }
          return _buildLoading();
        },
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Generating recipes...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeContent(List<ChatMessageModel> messages) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 240,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15), // Adjust this value
              child: Image.file(imageFile, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 20),
          buildAIResponse(messages),
        ],
      ),
    );
  }

  static Widget buildAIResponse(List<ChatMessageModel> messages) {
    return Column(
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
                        (bounds) => LinearGradient(
                          colors: [
                            Color(0xFF4285f4),
                            Color(0xFF9b72cb),
                            Color(0xFFd96570),
                          ],
                          stops: [0.0, 0.3, 0.60],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ).createShader(bounds),
                    child: Text(
                      'Gemini ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              TextSpan(
                text: 'Recipe Suggestion: ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ...messages.expand((message) {
          final text = message.parts.first.text;
          if (text == null || text.toLowerCase() == 'null') return [];

          try {
            final recipes =
                (jsonDecode(text)['recipes'] as List)
                    .cast<Map<String, dynamic>>();

            return recipes.map(
              (recipe) => Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orange.shade100, width: 1.5),
                ),
                color: const Color(0xFFFFF9F2), // Soft peach background
                margin: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFF9F2), Color(0xFFFEEAE6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe['name'] ?? 'New Recipe Creation',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B4226), // Coffee brown
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_basket,
                              size: 20,
                              color: Color(0xFFE76F51),
                            ), // Coral
                            const SizedBox(width: 8),
                            Text(
                              'Ingredients:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2A9D8F), // Teal
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...(recipe['ingredients'] as List).map(
                          (ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE76F51), // Coral
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '$ingredient',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF264653), // Charcoal
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.list_alt,
                              size: 20,
                              color: Color(0xFFE76F51),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instructions:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2A9D8F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          recipe['instructions'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B4226),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } catch (e) {
            return [Text(text)];
          }
        }),
      ],
    );
  }
}
