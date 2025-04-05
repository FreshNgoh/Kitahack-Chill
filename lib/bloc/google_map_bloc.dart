import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_application/models/google_map_model.dart';
import 'package:flutter_application/repos/google_repo.dart';
import 'package:meta/meta.dart';

part 'google_map_event.dart';
part 'google_map_state.dart';

class GoogleMapBloc extends Bloc<GoogleMapEvent, GoogleMapState> {
  final RestaurantRepo restaurantsRepo;

  GoogleMapBloc(this.restaurantsRepo) : super(GoogleMapInitial()) {
    on<GoogleRestaurantEvent>(_handleGoogleRestaurantEvent); // Add this
  }

  FutureOr<void> _handleGoogleRestaurantEvent(
    GoogleRestaurantEvent event,
    Emitter<GoogleMapState> emit,
  ) async {
    emit(RestaurantLoadingState());

    try {
      final restaurants = await restaurantsRepo.getRestaurants(
        event.lat,
        event.lng,
      );
      emit(RestaurantSuccessState(restaurants: restaurants));
    } catch (e) {
      emit(RestaurantErrorState(message: "Failed to load restaurants"));
    }
  }
}
