import 'package:dio/dio.dart';
import 'package:flutter_application/models/chat_message_model.dart';
import 'package:flutter_application/utils/constant.dart';

class ChatRepo {
  static chatIRecipeGenerationRepo(
    List<ChatMessageModel> previousMessages,
  ) async {
    try {
      Dio dio = Dio();

      final requestData = {
        "contents": previousMessages.map((e) => e.toMap()).toList(),
        "generationConfig": {
          "temperature": 0.1,
          "responseMimeType": "application/json",
        },
      };

      final response = await dio.post(
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey",
        data: requestData,
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("API Error ${response.statusCode}: ${response.data}");
      }

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
