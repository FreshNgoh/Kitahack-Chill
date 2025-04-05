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
        title: const Text('Recipe Suggestions'),
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
        const Text(
          'AI Recipe Suggestions:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name'] ?? 'Unnamed Recipe',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingredients:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ...(recipe['ingredients'] as List).map(
                        (ingredient) => Text('• $ingredient'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Instructions:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(recipe['instructions'] ?? ''),
                    ],
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
