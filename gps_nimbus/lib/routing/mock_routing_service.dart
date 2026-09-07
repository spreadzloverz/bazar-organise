import '../core/config/mobility_config.dart';
import '../domain/calibration/user_travel_context.dart';
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
/// Il produit aussi les options sans transport : marche seule et skate seul.
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
    final context = request.userContext;
    final directDistance = _groundDistance(origin, destination);

    // 1. Trajets sans transport en commun.
    if (directDistance <= maxWalkOnlyMeters) {
      final genericWalk = _walk.buildSegment(
        origin: origin,
        destination: destination,
        config: config,
        distanceMeters: directDistance,
      );
      routes.add(
        RouteOption(
          id: nextId('marche'),
          segments: [_applyObservation(genericWalk, context)],
        ),
      );
    }

    final genericSkate = _skate.buildSegment(
      origin: origin,
      destination: destination,
      config: config,
      distanceMeters: directDistance,
    );
    routes.add(
      RouteOption(
        id: nextId('skate'),
        segments: [_applyObservation(genericSkate, context)],
      ),
    );

    // 2. Trajets combinant transport en commun et accès marche/skate.
    // Les stations explicitement citées par l'utilisateur sont ajoutées aux
    // plus proches lorsqu'elles existent dans le réseau courant.
    final boardingStations = _candidateStations(
      origin,
      protectedLabels: context.protectedBoardingLabels,
    );
    final alightingStations = _candidateStations(
      destination,
      protectedLabels: context.protectedAlightingLabels,
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
              context: context,
            );
            if (option != null) routes.add(option);
          }
        }
      }
    }

    final deduplicated = _deduplicate(routes);
    final missingProtected = _missingProtectedLabels(context);

    return RouteSearchResult(
      routes: deduplicated,
      notices: [
        'Réseau de transport fictif et simplifié : ${network.sourceLabel}. '
            'Les horaires réels ne sont pas encore branchés, les attentes '
            'sont des moyennes.',
        'Distances marche et skate estimées à vol d\'oiseau avec un facteur '
            'de détour ; aucun tracé de rue réel n\'est encore utilisé.',
        if (_skate.accessPolicy.isProxy) _skate.accessPolicy.proxyNotice!,
        if (context.observedSegments.isNotEmpty)
          'Les durées terrain utilisateur compatibles remplacent les '
              'estimations génériques des tronçons concernés.',
        if (missingProtected.isNotEmpty)
          'Points utilisateur absents du réseau fictif actuel : '
              '${missingProtected.join(', ')}. Ils restent enregistrés mais '
              'ne peuvent pas encore être calculés.',
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
    required UserTravelContext context,
  }) {
    final boardingPoint = boarding.position.copyWith(label: boarding.name);
    final alightingPoint = alighting.position.copyWith(label: alighting.name);

    final accessDistance = _groundDistance(origin, boardingPoint);
    final egressDistance = _groundDistance(alightingPoint, destination);

    if (!accessBySkate && accessDistance > maxWalkingAccessMeters) return null;
    if (!egressBySkate && egressDistance > maxWalkingAccessMeters) return null;

    final segments = <RouteSegment>[];

    if (accessDistance > 0) {
      final genericAccess = (accessBySkate ? _skate : _walk).buildSegment(
        origin: origin,
        destination: boardingPoint,
        config: config,
        distanceMeters: accessDistance,
      );
      segments.add(_applyObservation(genericAccess, context));
    }

    segments.addAll(transitSegments);

    if (egressDistance > 0) {
      final genericEgress = (egressBySkate ? _skate : _walk).buildSegment(
        origin: alightingPoint,
        destination: destination,
        config: config,
        distanceMeters: egressDistance,
      );
      segments.add(_applyObservation(genericEgress, context));
    }

    if (segments.isEmpty) return null;

    final option = RouteOption(id: id, segments: segments);
    if (config.maxSkateDistanceMeters != null &&
        option.skateDistanceMeters > config.maxSkateDistanceMeters!) {
      return null;
    }
    return option;
  }

  RouteSegment _applyObservation(
    RouteSegment generic,
    UserTravelContext context,
  ) {
    if (!generic.type.isSkate && !generic.type.isWalking) return generic;

    final observation = context.bestObservationFor(
      originLabel: generic.origin.label,
      destinationLabel: generic.destination.label,
      mode: generic.type,
    );
    if (observation == null) return generic;

    return RouteSegment(
      type: generic.type,
      origin: generic.origin,
      destination: generic.destination,
      distanceMeters: generic.distanceMeters,
      duration: observation.representativeDuration,
      line: generic.line,
      details: {
        ...generic.details,
        'durationSource': observation.source.name,
        'genericDurationSeconds': generic.duration.inSeconds,
        'observedMinSeconds': observation.minDuration.inSeconds,
        'observedMaxSeconds': observation.maxDuration.inSeconds,
        'observationCount': observation.observationCount,
      },
    );
  }

  List<Station> _candidateStations(
    GeoPoint point, {
    required List<String> protectedLabels,
  }) {
    final candidates = network
        .nearestStations(point, count: candidateStationCount)
        .toList(growable: true);
    final ids = candidates.map((station) => station.id).toSet();

    for (final station in network.stations.values) {
      final protected = protectedLabels.any(
        (label) => _normalize(label) == _normalize(station.name),
      );
      if (protected && ids.add(station.id)) candidates.add(station);
    }

    return candidates;
  }

  List<String> _missingProtectedLabels(UserTravelContext context) {
    final requested = <String>{
      ...context.protectedBoardingLabels,
      ...context.protectedAlightingLabels,
    };
    final available = network.stations.values
        .map((station) => _normalize(station.name))
        .toSet();
    return requested
        .where((label) => !available.contains(_normalize(label)))
        .toList(growable: false);
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

String _normalize(String value) {
  const accents = 'àâäéèêëîïôöùûüçÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ';
  const plain = 'aaaeeeeiioouuucAAAEEEEIIOOUUUC';
  final buffer = StringBuffer();
  for (final rune in value.trim().toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = accents.indexOf(char);
    buffer.write(index >= 0 ? plain[index].toLowerCase() : char);
  }
  return buffer.toString();
}
