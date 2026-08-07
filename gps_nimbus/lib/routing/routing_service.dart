import '../core/config/mobility_config.dart';
import '../domain/model/geo_point.dart';
import '../domain/model/route_option.dart';

/// Demande d'itinéraire porte-à-porte.
class RouteRequest {
  const RouteRequest({
    required this.origin,
    required this.destination,
    this.config = MobilityConfig.defaults,
    this.departureTime,
  });

  final GeoPoint origin;
  final GeoPoint destination;
  final MobilityConfig config;

  /// Heure de départ souhaitée. Ignorée tant que les horaires réels
  /// (GTFS) ne sont pas branchés ; les attentes sont alors moyennes.
  final DateTime? departureTime;
}

/// Résultat brut d'un service de routing, avant classement.
class RouteSearchResult {
  const RouteSearchResult({
    required this.routes,
    this.notices = const <String>[],
  });

  final List<RouteOption> routes;

  /// Avertissements honnêtes à afficher : données fictives, profil skate
  /// approché par des données cyclables, etc.
  final List<String> notices;

  static const RouteSearchResult empty = RouteSearchResult(
    routes: <RouteOption>[],
  );
}

/// Contrat commun à toutes les sources d'itinéraires.
///
/// Implémentations prévues : mock (MVP), OpenTripPlanner, GTFS IDFM,
/// OSM pour les tronçons marche/skate.
abstract class RoutingService {
  /// Identifiant lisible de la source (« mock », « otp », …).
  String get name;

  /// Vrai si le service renvoie des données fictives.
  bool get isMock;

  Future<RouteSearchResult> findRoutes(RouteRequest request);
}

/// Erreur remontée par un service de routing indisponible ou mal configuré.
class RoutingUnavailable implements Exception {
  const RoutingUnavailable(this.serviceName, this.reason);

  final String serviceName;
  final String reason;

  @override
  String toString() =>
      'Service de routing « $serviceName » indisponible : $reason';
}
