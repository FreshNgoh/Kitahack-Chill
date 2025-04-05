import 'package:dio/dio.dart';
import 'package:flutter_application/models/google_map_model.dart';
import 'package:flutter_application/utils/constants.dart';

class RestaurantRepo {
  Dio dio = Dio();

  static const String baseUrl =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json";

  Future<List<RestaurantModel>> getRestaurants(double lat, double lng) async {
    try {
      final response = await dio.get(
        baseUrl,
        queryParameters: {
          "location": "$lat,$lng",
          "radius": 5000,
          "type": "restaurant",
          "keyword": "healthy cuisine",
          'key': googleAPI,
        },
      );

      if (response.statusCode == 200) {
        final googleMapResponse = GoogleMapModel.fromMap(response.data);
        if (googleMapResponse.status == 'OK') {
          return googleMapResponse.results;
        } else if (googleMapResponse.status == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('API Error: ${googleMapResponse.status}');
        }
      }
      throw Exception('HTTP Error ${response.statusCode}');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
