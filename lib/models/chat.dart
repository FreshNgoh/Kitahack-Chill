import "package:cloud_firestore/cloud_firestore.dart";

class Chat {
  String chatId;
  List<String> participants;

  Chat({required this.chatId, required this.participants});

  Chat.fromJson(Map<String, Object?> json)
    : this(
        chatId: json['chatId']! as String,
        participants: List<String>.from(
          json['participants'] as Iterable<dynamic>,
        ),
      );

  Map<String, Object?> toJson() {
    return {'chatId': chatId, 'participants': participants};
  }
}

class Message {
  String sender;
  String text;
  Timestamp timestamp;

  Message({required this.sender, required this.text, required this.timestamp});

  Message.fromJson(Map<String, Object?> json)
    : this(
        sender: json['sender']! as String,
        text: json['text']! as String,
        timestamp: json['timestamp']! as Timestamp,
      );

  Map<String, Object?> toJson() {
    return {'sender': sender, 'text': text, 'timestamp': timestamp};
  }
}
