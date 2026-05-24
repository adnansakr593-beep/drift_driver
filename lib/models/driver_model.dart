import 'package:cloud_firestore/cloud_firestore.dart';

class DriverModel {
  final String uid;
  final String name;
  final String email;
  final String? photo;
  final String phone;
  final String vehicleModel;
  final String vehiclePlate;
  final bool isOnline;
  final bool isAvailable;
  final double? lat;
  final double? lng;
  final double rating;
  final int totalTrips;
  final double earnings;

  const DriverModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photo,
    required this.phone,
    required this.vehicleModel,
    required this.vehiclePlate,
    this.isOnline = false,
    this.isAvailable = false,
    this.lat,
    this.lng,
    this.rating = 5.0,
    this.totalTrips = 0,
    this.earnings = 0.0,
  });

  factory DriverModel.fromMap(String uid, Map<String, dynamic> map) {
    final GeoPoint? geo = map['currentLocation'] as GeoPoint?;
    return DriverModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      photo: map['photo'] as String?,
      phone: map['phone'] as String? ?? '',
      vehicleModel: map['vehicleModel'] as String? ?? '',
      vehiclePlate: map['vehiclePlate'] as String? ?? '',
      isOnline: map['isOnline'] as bool? ?? false,
      isAvailable: map['isAvailable'] as bool? ?? false,
      lat: geo?.latitude,
      lng: geo?.longitude,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      totalTrips: map['totalTrips'] as int? ?? 0,
      earnings: (map['earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'photo': photo,
        'phone': phone,
        'vehicleModel': vehicleModel,
        'vehiclePlate': vehiclePlate,
        'isOnline': isOnline,
        'isAvailable': isAvailable,
        'rating': rating,
        'totalTrips': totalTrips,
        'earnings': earnings,
      };
}
