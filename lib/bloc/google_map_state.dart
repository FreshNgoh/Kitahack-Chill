// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'google_map_bloc.dart';

@immutable
sealed class GoogleMapState {}

final class GoogleMapInitial extends GoogleMapState {}

class RestaurantLoadingState extends GoogleMapState {}

class RestaurantSuccessState extends GoogleMapState {
  final List<RestaurantModel> restaurants;
  RestaurantSuccessState({required this.restaurants});
}

class RestaurantErrorState extends GoogleMapState {
  final String message;
  RestaurantErrorState({required this.message});
}
