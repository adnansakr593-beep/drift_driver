import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/route_info.dart';

class RoutingService {
  static const _primary = 'http://router.project-osrm.org/route/v1/driving';

  static Future<RouteInfo> getRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      return await _osrmRoute(origin, destination);
    } catch (_) {
      return _straightLineRoute(origin, destination);
    }
  }

  static Future<RouteInfo> _osrmRoute(LatLng origin, LatLng dest) async {
    final url = Uri.parse(
      '$_primary/'
      '${origin.longitude},${origin.latitude};'
      '${dest.longitude},${dest.latitude}'
      '?overview=full&geometries=polyline',
    );

    final res = await http.get(
      url,
      headers: {'User-Agent': 'DriftDriverApp/1.0'},
    ).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    if (json['code'] != 'Ok') throw Exception('OSRM: ${json['code']}');

    final route = json['routes'][0];
    return RouteInfo(
      points: PolylineDecoder.decode(route['geometry'] as String),
      distanceMeters: (route['distance'] as num).toDouble(),
      durationSeconds: (route['duration'] as num).toDouble(),
    );
  }

  static RouteInfo _straightLineRoute(LatLng origin, LatLng dest) {
    const Distance distance = Distance();
    final meters = distance.as(LengthUnit.Meter, origin, dest);
    return RouteInfo(
      points: [origin, dest],
      distanceMeters: meters,
      durationSeconds: meters / 10,
    );
  }
}
