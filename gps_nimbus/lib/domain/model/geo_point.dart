import 'dart:math' as math;

/// Un point géographique nommé (départ, arrêt, destination).
class GeoPoint {
  const GeoPoint({
    required this.latitude,
    required this.longitude,
    this.label = '',
  });

  final double latitude;
  final double longitude;

  /// Nom lisible : « Domicile », « Châtelet », « République »…
  final String label;

  /// Distance orthodromique en mètres (formule de haversine).
  ///
  /// Suffisante pour l'Île-de-France : l'erreur reste très inférieure
  /// à l'imprécision d'un tracé réel de rue.
  double distanceTo(GeoPoint other) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);
    final lat1 = _toRadians(latitude);
    final lat2 = _toRadians(other.latitude);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) *
            math.sin(dLon / 2) *
            math.cos(lat1) *
            math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180.0;

  GeoPoint copyWith({double? latitude, double? longitude, String? label}) {
    return GeoPoint(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      label: label ?? this.label,
    );
  }

  @override
  String toString() => label.isEmpty
      ? '($latitude, $longitude)'
      : '$label ($latitude, $longitude)';

  @override
  bool operator ==(Object other) =>
      other is GeoPoint &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.label == label;

  @override
  int get hashCode => Object.hash(latitude, longitude, label);
}
