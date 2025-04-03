import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ChatMessageModel {
  final List<ChatPartModel> parts;
  ChatMessageModel({required this.parts});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'parts': parts.map((x) => x.toMap()).toList()};
  }

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      parts: List<ChatPartModel>.from(
        (map['parts'] as List<dynamic>).map<ChatPartModel>(
          (x) => ChatPartModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessageModel.fromJson(String source) =>
      ChatMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class InlineData {
  final String mimeType;
  final String data;

  InlineData({required this.mimeType, required this.data});

  Map<String, dynamic> toMap() {
    return {'mimeType': mimeType, 'data': data};
  }

  factory InlineData.fromMap(Map<String, dynamic> map) {
    return InlineData(
      mimeType: map['mimeType'] as String,
      data: map['data'] as String,
    );
  }
}

class ChatPartModel {
  final InlineData? inlineData;
  final String? text;

  ChatPartModel({this.inlineData, this.text})
    : assert(
        (inlineData != null && text == null) ||
            (inlineData == null && text != null),
        'Part must contain either inlineData OR text',
      );

  Map<String, dynamic> toMap() {
    return {
      if (inlineData != null) 'inlineData': inlineData!.toMap(),
      if (text != null) 'text': text,
    };
  }

  factory ChatPartModel.fromMap(Map<String, dynamic> map) {
    return ChatPartModel(
      inlineData:
          map['inlineData'] != null
              ? InlineData.fromMap(map['inlineData'] as Map<String, dynamic>)
              : null,
      text: map['text'] as String?,
    );
  }

  String toJson() => json.encode(toMap());
  factory ChatPartModel.fromJson(String source) =>
      ChatPartModel.fromMap(json.decode(source));
}
