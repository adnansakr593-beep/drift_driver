import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class ActiveTripModel {
  final String id;
  final String requestId;
  final String userId;
  final String userName;
  final String? userPhoto;
  final String driverId;
  final String driverName;
  final String? driverPhoto;
  final String vehicleModel;
  final String vehiclePlate;
  final double driverRating;
  final LatLng originLocation;
  final LatLng destination;
  final String destinationName;
  final LatLng? driverLocation;
  final double offeredPrice;
  final String tripMode;
  final String status; // driverEnRoute | arrived | inProgress | completed | cancelled
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  const ActiveTripModel({
    required this.id,
    required this.requestId,
    required this.userId,
    required this.userName,
    this.userPhoto,
    required this.driverId,
    required this.driverName,
    this.driverPhoto,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.driverRating,
    required this.originLocation,
    required this.destination,
    required this.destinationName,
    this.driverLocation,
    required this.offeredPrice,
    required this.tripMode,
    required this.status,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
  });

  factory ActiveTripModel.fromMap(String id, Map<String, dynamic> map) {
    final GeoPoint originGeo = map['originLocation'] as GeoPoint;
    final GeoPoint destGeo = map['destination'] as GeoPoint;
    final GeoPoint? driverGeo = map['driverLocation'] as GeoPoint?;
    final Timestamp createdTs =
        map['createdAt'] as Timestamp? ?? Timestamp.now();
    final Timestamp? startedTs = map['startedAt'] as Timestamp?;
    final Timestamp? completedTs = map['completedAt'] as Timestamp?;

    return ActiveTripModel(
      id: id,
      requestId: map['requestId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'User',
      userPhoto: map['userPhoto'] as String?,
      driverId: map['driverId'] as String? ?? '',
      driverName: map['driverName'] as String? ?? '',
      driverPhoto: map['driverPhoto'] as String?,
      vehicleModel: map['vehicleModel'] as String? ?? '',
      vehiclePlate: map['vehiclePlate'] as String? ?? '',
      driverRating: (map['driverRating'] as num?)?.toDouble() ?? 5.0,
      originLocation: LatLng(originGeo.latitude, originGeo.longitude),
      destination: LatLng(destGeo.latitude, destGeo.longitude),
      destinationName: map['destinationName'] as String? ?? '',
      driverLocation: driverGeo != null
          ? LatLng(driverGeo.latitude, driverGeo.longitude)
          : null,
      offeredPrice: (map['offeredPrice'] as num?)?.toDouble() ?? 0.0,
      tripMode: map['tripMode'] as String? ?? 'ride',
      status: map['status'] as String? ?? 'driverEnRoute',
      startedAt: startedTs?.toDate(),
      completedAt: completedTs?.toDate(),
      createdAt: createdTs.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'requestId': requestId,
        'userId': userId,
        'userName': userName,
        'userPhoto': userPhoto,
        'driverId': driverId,
        'driverName': driverName,
        'driverPhoto': driverPhoto,
        'vehicleModel': vehicleModel,
        'vehiclePlate': vehiclePlate,
        'driverRating': driverRating,
        'originLocation':
            GeoPoint(originLocation.latitude, originLocation.longitude),
        'destination': GeoPoint(destination.latitude, destination.longitude),
        'destinationName': destinationName,
        'driverLocation': driverLocation != null
            ? GeoPoint(driverLocation!.latitude, driverLocation!.longitude)
            : null,
        'offeredPrice': offeredPrice,
        'tripMode': tripMode,
        'status': status,
        'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
        'completedAt':
            completedAt != null ? Timestamp.fromDate(completedAt!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  ActiveTripModel copyWith({
    LatLng? driverLocation,
    String? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return ActiveTripModel(
      id: id,
      requestId: requestId,
      userId: userId,
      userName: userName,
      userPhoto: userPhoto,
      driverId: driverId,
      driverName: driverName,
      driverPhoto: driverPhoto,
      vehicleModel: vehicleModel,
      vehiclePlate: vehiclePlate,
      driverRating: driverRating,
      originLocation: originLocation,
      destination: destination,
      destinationName: destinationName,
      driverLocation: driverLocation ?? this.driverLocation,
      offeredPrice: offeredPrice,
      tripMode: tripMode,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt,
    );
  }
}
