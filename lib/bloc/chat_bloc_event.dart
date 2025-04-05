// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc_bloc.dart';

@immutable
sealed class ChatBlocEvent {}

class ChatGenerateNewRecipeEvent extends ChatBlocEvent {
  final File inputImage;
  ChatGenerateNewRecipeEvent({required this.inputImage});
}
