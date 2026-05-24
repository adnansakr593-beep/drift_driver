import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class RideRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhoto;
  final LatLng userLocation;
  final LatLng destination;
  final String destinationName;
  final double distanceKm;
  final double durationMin;
  final double offeredPrice;
  final String tripMode;
  final String status; // pending | accepted | cancelled | completed
  final String? acceptedBy;
  final DateTime createdAt;

  const RideRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.userLocation,
    required this.destination,
    required this.destinationName,
    required this.distanceKm,
    required this.durationMin,
    required this.offeredPrice,
    required this.tripMode,
    required this.status,
    this.acceptedBy,
    required this.createdAt,
  });

  factory RideRequestModel.fromMap(String id, Map<String, dynamic> map) {
    final GeoPoint userGeo = map['userLocation'] as GeoPoint;
    final GeoPoint destGeo = map['destination'] as GeoPoint;
    final Timestamp ts = map['createdAt'] as Timestamp? ?? Timestamp.now();

    return RideRequestModel(
      id: id,
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'User',
      userPhoto: map['userPhoto'] as String?,
      userLocation: LatLng(userGeo.latitude, userGeo.longitude),
      destination: LatLng(destGeo.latitude, destGeo.longitude),
      destinationName: map['destinationName'] as String? ?? '',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMin: (map['durationMin'] as num?)?.toDouble() ?? 0.0,
      offeredPrice: (map['offeredPrice'] as num?)?.toDouble() ?? 0.0,
      tripMode: map['tripMode'] as String? ?? 'ride',
      status: map['status'] as String? ?? 'pending',
      acceptedBy: map['acceptedBy'] as String?,
      createdAt: ts.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'userPhoto': userPhoto,
        'userLocation':
            GeoPoint(userLocation.latitude, userLocation.longitude),
        'destination': GeoPoint(destination.latitude, destination.longitude),
        'destinationName': destinationName,
        'distanceKm': distanceKm,
        'durationMin': durationMin,
        'offeredPrice': offeredPrice,
        'tripMode': tripMode,
        'status': status,
        'acceptedBy': acceptedBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
