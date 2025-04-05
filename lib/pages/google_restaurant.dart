import 'package:flutter/material.dart';
import 'package:flutter_application/bloc/google_map_bloc.dart';
import 'package:flutter_application/services/location_handler.dart';
import 'package:flutter_application/utils/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  late final Future<Position> currentPosition;

  @override
  void initState() {
    super.initState();
    currentPosition = LocationHandler.getCurrentLocation();

    currentPosition
        .then((position) {
          if (mounted) {
            BlocProvider.of<GoogleMapBloc>(context).add(
              GoogleRestaurantEvent(
                lat: position.latitude,
                lng: position.longitude,
              ),
            );
          }
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Location error: $error')));
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GoogleMapBloc, GoogleMapState>(
        builder: (context, state) {
          if (state is RestaurantLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RestaurantErrorState) {
            return Center(child: Text(state.message));
          } else if (state is RestaurantSuccessState) {
            if (state.restaurants.isEmpty) {
              return const Center(child: Text("No restaurants found."));
            }
            return ListView.builder(
              itemCount: state.restaurants.length,
              itemBuilder: (context, index) {
                final restaurant = state.restaurants[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Restaurant Image
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              restaurant.photos.isNotEmpty
                                  ? Image.network(
                                    "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${restaurant.photos.first.photoReference}&key=$googleAPI",
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.restaurant),
                                  )
                                  : const Icon(Icons.restaurant),
                        ),
                        const SizedBox(width: 16),

                        // Restaurant Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Name and Rating
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      restaurant.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    restaurant.rating?.toStringAsFixed(1) ??
                                        '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    ' (${restaurant.userRatingsTotal ?? 0})',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Price and Category
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _getPriceRange(
                                        restaurant.priceLevel ?? 0,
                                      ),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  // Open Now status
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color:
                                            restaurant.openingHours.isOpenNow
                                                ? Colors.green
                                                : Colors.red,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        restaurant.openingHours.isOpenNow
                                            ? 'Open Now'
                                            : 'Closed',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("No restaurant found"));
        },
      ),
    );
  }

  String _getPriceRange(int priceLevel) {
    switch (priceLevel) {
      case 1:
        return 'RM 10–30';
      case 2:
        return 'RM 20–40';
      case 3:
        return 'RM 30–50';
      case 4:
        return 'RM 40–60';
      default:
        return 'RM 10–30';
    }
  }
}
