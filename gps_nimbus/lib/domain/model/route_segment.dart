import 'geo_point.dart';
import 'segment_type.dart';
import 'transit_line.dart';

/// Un tronçon élémentaire d'itinéraire.
///
/// Un itinéraire GPS NIMBUS est une suite ordonnée de tronçons : chacun a
/// un mode unique, une distance, une durée, et éventuellement une ligne.
class RouteSegment {
  const RouteSegment({
    required this.type,
    required this.origin,
    required this.destination,
    required this.distanceMeters,
    required this.duration,
    this.line,
    this.details = const <String, Object?>{},
  });

  final SegmentType type;
  final GeoPoint origin;
  final GeoPoint destination;

  /// Distance parcourue, en mètres. Vaut 0 pour une attente.
  final double distanceMeters;

  final Duration duration;

  /// Ligne empruntée pour un tronçon de transport en commun ; sinon `null`.
  final TransitLine? line;

  /// Informations complémentaires libres (quai, accessibilité, source…).
  final Map<String, Object?> details;

  /// Tronçon d'attente sur place (quai, arrêt de bus).
  factory RouteSegment.waiting({
    required GeoPoint at,
    required Duration duration,
    TransitLine? forLine,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    return RouteSegment(
      type: SegmentType.waiting,
      origin: at,
      destination: at,
      distanceMeters: 0,
      duration: duration,
      line: forLine,
      details: details,
    );
  }

  double get distanceKm => distanceMeters / 1000.0;

  /// Vitesse moyenne du tronçon en km/h (0 si durée nulle).
  double get averageSpeedKmh {
    final hours = duration.inMicroseconds / Duration.microsecondsPerHour;
    if (hours <= 0) return 0;
    return distanceKm / hours;
  }

  @override
  String toString() =>
      '${type.shortLabel}${line != null ? ' ${line!.name}' : ''} '
      '${distanceMeters.round()}m ${duration.inMinutes}min';
}
