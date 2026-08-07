import '../../domain/model/geo_point.dart';
import '../../domain/profile/access_policy.dart';

/// Un tronçon de rue tel que le fournirait OpenStreetMap.
class StreetLeg {
  const StreetLeg({
    required this.points,
    required this.distanceMeters,
    required this.wayKind,
  });

  /// Tracé réel, utile plus tard pour l'affichage cartographique.
  final List<GeoPoint> points;

  final double distanceMeters;
  final WayKind wayKind;
}

/// Calcul d'un chemin réel dans la rue pour un mode donné.
///
/// Tant que cette source n'existe pas, le moteur utilise la distance à vol
/// d'oiseau multipliée par un facteur de détour, et le signale dans
/// l'application. Aucun tracé n'est inventé.
abstract class StreetNetworkSource {
  String get name;

  bool get isConfigured;

  String get missingRequirement;

  /// Chemin entre deux points pour un mode soumis à [policy].
  Future<List<StreetLeg>> findPath({
    required GeoPoint origin,
    required GeoPoint destination,
    required AccessPolicy policy,
  });
}

/// Adaptateur OpenStreetMap.
///
/// C'est ici que le profil skate cessera d'être approché par des données
/// cyclables : la politique d'accès ([SkateAccessPolicy]) est déjà séparée
/// du reste du moteur, il suffira de lui fournir de vraies règles.
class OsmStreetNetworkSource implements StreetNetworkSource {
  const OsmStreetNetworkSource({this.extractPath});

  /// Chemin vers un extrait OSM local (fichier .pbf), s'il existe.
  final String? extractPath;

  @override
  String get name => 'osm';

  @override
  bool get isConfigured => (extractPath ?? '').trim().isNotEmpty;

  @override
  String get missingRequirement =>
      'Un extrait OpenStreetMap de l\'Île-de-France doit être disponible '
      'localement, ainsi qu\'un moteur de calcul de chemin capable de '
      'l\'exploiter.';

  @override
  Future<List<StreetLeg>> findPath({
    required GeoPoint origin,
    required GeoPoint destination,
    required AccessPolicy policy,
  }) {
    throw UnsupportedError(
      'Calcul de chemin OSM non implémenté. $missingRequirement',
    );
  }
}
