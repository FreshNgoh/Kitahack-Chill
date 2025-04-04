import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class GoogleMapModel {
  final List<RestaurantModel> results;
  final String status;
  GoogleMapModel({required this.results, required this.status});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'results': results.map((x) => x.toMap()).toList(),
      'status': status,
    };
  }

  factory GoogleMapModel.fromMap(Map<String, dynamic> map) {
    return GoogleMapModel(
      results: List<RestaurantModel>.from(
        (map['results'] as List<dynamic>).map<RestaurantModel>(
          (x) => RestaurantModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoogleMapModel.fromJson(String source) =>
      GoogleMapModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class RestaurantModel {
  // final String businessStatus;
  final Geometry geometry;
  final String name;
  final List<Photo> photos;
  final double? rating;
  // final String vicinity;
  final int? userRatingsTotal;
  final int? priceLevel;
  final OpeningHours openingHours;
  RestaurantModel({
    // required this.businessStatus,
    required this.geometry,
    required this.name,
    required this.photos,
    this.rating,
    required this.userRatingsTotal,
    this.priceLevel,
    required this.openingHours,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'geometry': geometry.toMap(),
      'name': name,
      'photos': photos.map((x) => x.toMap()).toList(),
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'priceLevel': priceLevel,
      'openingHours': openingHours.toMap(),
    };
  }

  factory RestaurantModel.fromMap(Map<String, dynamic> map) {
    return RestaurantModel(
      geometry: Geometry.fromMap(map['geometry'] as Map<String, dynamic>),
      name: map['name'] as String,
      photos: List<Photo>.from(
        (map['photos'] as List<dynamic>).map<Photo>(
          (x) => Photo.fromMap(x as Map<String, dynamic>),
        ),
      ),
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      userRatingsTotal:
          map['user_ratings_total'] != null
              ? map['user_ratings_total'] as int
              : null,
      priceLevel: map['priceLevel'] != null ? map['priceLevel'] as int : null,
      openingHours:
          map['opening_hours'] != null
              ? OpeningHours.fromMap(
                map['opening_hours'] as Map<String, dynamic>,
              )
              : OpeningHours.fallback(),
    );
  }

  String toJson() => json.encode(toMap());

  factory RestaurantModel.fromJson(String source) =>
      RestaurantModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Geometry {
  final Location location;
  Geometry({required this.location});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'location': location.toMap()};
  }

  factory Geometry.fromMap(Map<String, dynamic> map) {
    return Geometry(
      location: Location.fromMap(map['location'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory Geometry.fromJson(String source) =>
      Geometry.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Location {
  final double lat;
  Location({required this.lat, required this.lng});
  final double lng;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'lat': lat, 'lng': lng};
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(lat: map['lat'] as double, lng: map['lng'] as double);
  }

  String toJson() => json.encode(toMap());

  factory Location.fromJson(String source) =>
      Location.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Photo {
  final String photoReference;
  final int width;
  final int height;
  // final List<String> htmlAttributions;
  Photo({
    required this.photoReference,
    required this.width,
    required this.height,
    // required this.htmlAttributions,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'photo_reference': photoReference,
      'width': width,
      'height': height,
      // 'html_attributions': htmlAttributions,
    };
  }

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      photoReference: map['photo_reference'] as String,
      width: map['width'] as int,
      height: map['height'] as int,
      // htmlAttributions: List<String>.from(
      //   (map['html_attributions'] as List<String>),
      // ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Photo.fromJson(String source) =>
      Photo.fromMap(json.decode(source) as Map<String, dynamic>);
}

class OpeningHours {
  final bool isOpenNow;
  OpeningHours({required this.isOpenNow});

  factory OpeningHours.fallback() => OpeningHours(isOpenNow: false);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'isOpenNow': isOpenNow};
  }

  factory OpeningHours.fromMap(Map<String, dynamic> map) {
    return OpeningHours(isOpenNow: map['open_now'] as bool);
  }

  String toJson() => json.encode(toMap());

  factory OpeningHours.fromJson(String source) =>
      OpeningHours.fromMap(json.decode(source) as Map<String, dynamic>);
}
