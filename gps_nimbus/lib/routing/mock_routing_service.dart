import '../core/config/mobility_config.dart';
import '../domain/model/geo_point.dart';
import '../domain/model/route_option.dart';
import '../domain/model/route_segment.dart';
import '../domain/profile/mobility_profile.dart';
import 'mock_idf_network.dart';
import 'routing_service.dart';
import 'transit_network.dart';

/// Moteur d'itinéraires du MVP.
///
/// Il combine :
///  - un accès (marche ou skate) entre le point de départ et une station ;
///  - un trajet en transport en commun calculé sur le réseau ;
///  - une sortie (marche ou skate) vers la destination.
///
/// Il produit aussi les options sans transport : marche seule, skate seul,
/// et skate + marche.
///
/// Le calcul est réel ; seules les données de réseau sont fictives, ce que
/// le service signale via [isMock] et les avertissements du résultat.
class MockRoutingService implements RoutingService {
  MockRoutingService({TransitNetwork? network})
    : network = network ?? MockIdfNetwork.build();

  final TransitNetwork network;

  static const _walk = WalkingProfile();
  static const _skate = SkateProfile();

  /// Nombre de stations candidates testées de chaque côté du trajet.
  static const int candidateStationCount = 3;

  /// Au-delà, un accès à pied n'est plus proposé (trop long pour être utile).
  static const double maxWalkingAccessMeters = 2500;

  /// Au-delà, un trajet entièrement à pied n'est plus proposé.
  static const double maxWalkOnlyMeters = 6000;

  /// Facteur de détour appliqué aux distances à vol d'oiseau, faute de
  /// tracé de rues réel. Sera remplacé par les distances OSM/OTP.
  static const double detourFactor = 1.25;

  @override
  String get name => 'mock';

  @override
  bool get isMock => true;

  @override
  Future<RouteSearchResult> findRoutes(RouteRequest request) async {
    final routes = <RouteOption>[];
    var index = 0;
    String nextId(String prefix) => '${prefix}_${index++}';

    final origin = request.origin;
    final destination = request.destination;
    final config = request.config;
    final directDistance = _groundDistance(origin, destination);

    // 1. Trajets sans transport en commun.
    if (directDistance <= maxWalkOnlyMeters) {
      routes.add(
        RouteOption(
          id: nextId('marche'),
          segments: [
            _walk.buildSegment(
              origin: origin,
              destination: destination,
              config: config,
              distanceMeters: directDistance,
            ),
          ],
        ),
      );
    }
    routes.add(
      RouteOption(
        id: nextId('skate'),
        segments: [
          _skate.buildSegment(
            origin: origin,
            destination: destination,
            config: config,
            distanceMeters: directDistance,
          ),
        ],
      ),
    );

    // 2. Trajets combinant transport en commun et accès marche/skate.
    final boardingStations = network.nearestStations(
      origin,
      count: candidateStationCount,
    );
    final alightingStations = network.nearestStations(
      destination,
      count: candidateStationCount,
    );

    for (final boarding in boardingStations) {
      for (final alighting in alightingStations) {
        if (boarding.id == alighting.id) continue;

        final transitSegments = network.findTransitSegments(
          fromStationId: boarding.id,
          toStationId: alighting.id,
          config: config,
        );
        if (transitSegments == null || transitSegments.isEmpty) continue;

        for (final accessBySkate in const [false, true]) {
          for (final egressBySkate in const [false, true]) {
            final option = _buildCombinedRoute(
              id: nextId('combi'),
              origin: origin,
              destination: destination,
              boarding: boarding,
              alighting: alighting,
              transitSegments: transitSegments,
              accessBySkate: accessBySkate,
              egressBySkate: egressBySkate,
              config: config,
            );
            if (option != null) routes.add(option);
          }
        }
      }
    }

    final deduplicated = _deduplicate(routes);
    return RouteSearchResult(
      routes: deduplicated,
      notices: [
        'Réseau de transport fictif et simplifié : ${network.sourceLabel}. '
            'Les horaires réels ne sont pas encore branchés, les attentes '
            'sont des moyennes.',
        'Distances marche et skate estimées à vol d\'oiseau avec un facteur '
            'de détour ; aucun tracé de rue réel n\'est encore utilisé.',
        if (_skate.accessPolicy.isProxy) _skate.accessPolicy.proxyNotice!,
      ],
    );
  }

  RouteOption? _buildCombinedRoute({
    required String id,
    required GeoPoint origin,
    required GeoPoint destination,
    required Station boarding,
    required Station alighting,
    required List<RouteSegment> transitSegments,
    required bool accessBySkate,
    required bool egressBySkate,
    required MobilityConfig config,
  }) {
    final boardingPoint = boarding.position.copyWith(label: boarding.name);
    final alightingPoint = alighting.position.copyWith(label: alighting.name);

    final accessDistance = _groundDistance(origin, boardingPoint);
    final egressDistance = _groundDistance(alightingPoint, destination);

    if (!accessBySkate && accessDistance > maxWalkingAccessMeters) return null;
    if (!egressBySkate && egressDistance > maxWalkingAccessMeters) return null;

    final segments = <RouteSegment>[];

    if (accessDistance > 0) {
      segments.add(
        (accessBySkate ? _skate : _walk).buildSegment(
          origin: origin,
          destination: boardingPoint,
          config: config,
          distanceMeters: accessDistance,
        ),
      );
    }
    segments.addAll(transitSegments);
    if (egressDistance > 0) {
      segments.add(
        (egressBySkate ? _skate : _walk).buildSegment(
          origin: alightingPoint,
          destination: destination,
          config: config,
          distanceMeters: egressDistance,
        ),
      );
    }

    if (segments.isEmpty) return null;

    final option = RouteOption(id: id, segments: segments);
    if (config.maxSkateDistanceMeters != null &&
        option.skateDistanceMeters > config.maxSkateDistanceMeters!) {
      return null;
    }
    return option;
  }

  /// Distance au sol estimée : vol d'oiseau × facteur de détour.
  double _groundDistance(GeoPoint from, GeoPoint to) =>
      from.distanceTo(to) * detourFactor;

  /// Supprime les itinéraires strictement équivalents (même suite de modes,
  /// mêmes lignes, mêmes durées), qui n'apporteraient rien à l'utilisateur.
  List<RouteOption> _deduplicate(List<RouteOption> routes) {
    final seen = <String>{};
    final unique = <RouteOption>[];
    for (final route in routes) {
      final signature = route.segments
          .map(
            (s) =>
                '${s.type.name}:${s.line?.displayName ?? ''}:'
                '${s.distanceMeters.round()}:${s.duration.inSeconds}',
          )
          .join('|');
      if (seen.add(signature)) unique.add(route);
    }
    return unique;
  }
}
