// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'google_map_bloc.dart';

@immutable
sealed class GoogleMapEvent {}

class GoogleRestaurantEvent extends GoogleMapEvent {
  final double lat;
  final double lng;
  GoogleRestaurantEvent({required this.lat, required this.lng});
}
