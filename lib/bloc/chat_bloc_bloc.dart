import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_application/models/chat_message_model.dart';
import 'package:flutter_application/repos/chat_repo.dart';
import 'package:meta/meta.dart';

part 'chat_bloc_event.dart';
part 'chat_bloc_state.dart';

class ChatBlocBloc extends Bloc<ChatBlocEvent, ChatBlocState> {
  ChatBlocBloc() : super(ChatSuccessState(messages: [])) {
    on<ChatGenerateNewRecipeEvent>(chatGenerateNewRecipeEvent);
  }
  List<ChatMessageModel> messages = [];

  FutureOr<void> chatGenerateNewRecipeEvent(
    ChatGenerateNewRecipeEvent event,
    Emitter<ChatBlocState> emit,
  ) async {
    try {
      messages = [];

      final imageFile = event.inputImage;
      if (!await imageFile.exists()) throw Exception("Image file not found");

      final bytes = await imageFile.readAsBytes();
      if (bytes.lengthInBytes > 4 * 1024 * 1024) {
        throw Exception("Image size exceeds 4MB limit");
      }
      final base64Image = base64Encode(bytes);

      final userMessage = ChatMessageModel(
        parts: [
          ChatPartModel(
            inlineData: InlineData(mimeType: 'image/jpeg', data: base64Image),
          ),
          ChatPartModel(
            text: "Suggest 3 recipes based on this image in JSON format",
          ),
        ],
      );

      messages.add(userMessage);
      emit(ChatLoadingState());

      final aiResponse = await ChatRepo.chatIRecipeGenerationRepo(messages);
      final aiMessage = ChatMessageModel(
        parts: [ChatPartModel(text: _parseAIResponse(aiResponse))],
      );

      messages.add(aiMessage);
      emit(ChatSuccessState(messages: [...messages]));
    } catch (e) {
      messages.add(
        ChatMessageModel(
          parts: [ChatPartModel(text: "Error: ${e.toString()}")],
        ),
      );
      emit(ChatSuccessState(messages: [...messages]));
    }
  }

  String _parseAIResponse(dynamic response) {
    try {
      return response['candidates'][0]['content']['parts'][0]['text'];
    } catch (e) {
      return "Failed to parse response: ${e.toString()}";
    }
  }
}
