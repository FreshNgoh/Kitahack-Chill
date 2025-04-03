// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'chat_bloc_bloc.dart';

@immutable
sealed class ChatBlocState {}

final class ChatBlocInitial extends ChatBlocState {}

class ChatSuccessState extends ChatBlocState {
  final List<ChatMessageModel> messages;
  ChatSuccessState({required this.messages});
}

class ChatLoadingState extends ChatBlocState {}
