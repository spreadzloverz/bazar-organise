import '../core/config/mobility_config.dart';
import '../domain/model/geo_point.dart';
import '../domain/model/route_segment.dart';
import '../domain/model/segment_type.dart';
import '../domain/model/transit_line.dart';
import '../domain/profile/mobility_profile.dart';

/// Une station / un arrêt du réseau.
class Station {
  const Station({required this.id, required this.name, required this.position});

  final String id;
  final String name;
  final GeoPoint position;

  @override
  String toString() => name;
}

/// Paramètres d'exploitation d'un mode de transport.
///
/// Ce ne sont pas des invariants produit : ce sont des hypothèses de service
/// qui seront remplacées par les horaires GTFS réels.
class TransitServiceProfile {
  const TransitServiceProfile({
    required this.commercialSpeedKmh,
    required this.headway,
  });

  /// Vitesse commerciale moyenne (arrêts compris).
  final double commercialSpeedKmh;

  /// Intervalle moyen entre deux passages.
  final Duration headway;

  /// Attente moyenne à l'arrêt : la moitié de l'intervalle.
  Duration get averageWait =>
      Duration(seconds: (headway.inSeconds / 2).round());

  static const Map<SegmentType, TransitServiceProfile> defaults = {
    SegmentType.metro: TransitServiceProfile(
      commercialSpeedKmh: 25,
      headway: Duration(minutes: 4),
    ),
    SegmentType.rer: TransitServiceProfile(
      commercialSpeedKmh: 45,
      headway: Duration(minutes: 7),
    ),
    SegmentType.tram: TransitServiceProfile(
      commercialSpeedKmh: 18,
      headway: Duration(minutes: 6),
    ),
    SegmentType.bus: TransitServiceProfile(
      commercialSpeedKmh: 12,
      headway: Duration(minutes: 10),
    ),
  };
}

/// Une ligne desservant une suite ordonnée d'arrêts, parcourable dans
/// les deux sens.
class LineRoute {
  const LineRoute({required this.line, required this.stopIds});

  final TransitLine line;
  final List<String> stopIds;

  String get id => '${line.mode.name}_${line.name}';
}

/// Réseau de transport en commun : stations, lignes, et liaisons à pied
/// entre stations voisines (correspondances hors quai).
class TransitNetwork {
  TransitNetwork({
    required List<Station> stations,
    required this.routes,
    Map<SegmentType, TransitServiceProfile>? serviceProfiles,
    this.isMockData = false,
    this.sourceLabel = '',
  }) : stations = {for (final s in stations) s.id: s},
       serviceProfiles = serviceProfiles ?? TransitServiceProfile.defaults;

  final Map<String, Station> stations;
  final List<LineRoute> routes;
  final Map<SegmentType, TransitServiceProfile> serviceProfiles;

  /// Vrai si les données sont fictives. Doit être signalé à l'utilisateur.
  final bool isMockData;

  /// Origine des données (« mock », « GTFS IDFM 2026-01 »…).
  final String sourceLabel;

  /// Distance maximale entre deux stations pour qu'une correspondance
  /// à pied soit possible.
  static const double maxFootConnectionMeters = 450.0;

  /// Facteur de détour appliqué à la distance à vol d'oiseau pour
  /// approcher la longueur réelle d'un tronçon.
  static const double detourFactor = 1.15;

  Station station(String id) {
    final s = stations[id];
    if (s == null) throw ArgumentError('Station inconnue : $id');
    return s;
  }

  /// Les [count] stations les plus proches d'un point.
  List<Station> nearestStations(GeoPoint point, {int count = 3}) {
    final all = stations.values.toList()
      ..sort(
        (a, b) => a.position
            .distanceTo(point)
            .compareTo(b.position.distanceTo(point)),
      );
    return all.take(count).toList(growable: false);
  }

  TransitServiceProfile profileFor(SegmentType mode) =>
      serviceProfiles[mode] ??
      const TransitServiceProfile(
        commercialSpeedKmh: 20,
        headway: Duration(minutes: 6),
      );

  /// Meilleur trajet en transport en commun entre deux stations, exprimé
  /// directement en tronçons (attente, trajet, correspondance à pied).
  ///
  /// Renvoie `null` si aucun trajet n'existe.
  /// L'optimisation porte sur le temps, avec une pénalité de correspondance
  /// pour éviter les itinéraires théoriquement rapides mais pénibles.
  List<RouteSegment>? findTransitSegments({
    required String fromStationId,
    required String toStationId,
    required MobilityConfig config,
    Duration transferPenalty = const Duration(minutes: 2),
  }) {
    if (!stations.containsKey(fromStationId) ||
        !stations.containsKey(toStationId)) {
      return null;
    }
    if (fromStationId == toStationId) return const <RouteSegment>[];

    final search = _TransitSearch(
      network: this,
      config: config,
      transferPenalty: transferPenalty,
    );
    return search.run(fromStationId, toStationId);
  }
}

/// Un nœud du graphe : « je suis à la station S, à bord de la ligne L ».
/// [lineId] vide signifie « à pied sur place / pas encore embarqué ».
class _Node {
  const _Node(this.stationId, this.lineId);

  final String stationId;
  final String lineId;

  String get key => '$stationId|$lineId';

  @override
  bool operator ==(Object other) =>
      other is _Node && other.stationId == stationId && other.lineId == lineId;

  @override
  int get hashCode => Object.hash(stationId, lineId);
}

enum _EdgeKind { board, alight, ride, footConnection }

class _Edge {
  const _Edge({
    required this.from,
    required this.to,
    required this.kind,
    required this.cost,
    this.segment,
  });

  final _Node from;
  final _Node to;
  final _EdgeKind kind;

  /// Coût d'optimisation (durée + pénalités).
  final Duration cost;

  /// Tronçon réellement produit ; `null` pour une descente de véhicule.
  final RouteSegment? segment;
}

/// Dijkstra sur le graphe (station, ligne).
///
/// Le réseau du MVP est petit ; une file de priorité à extraction linéaire
/// est amplement suffisante et évite une dépendance externe.
class _TransitSearch {
  _TransitSearch({
    required this.network,
    required this.config,
    required this.transferPenalty,
  });

  final TransitNetwork network;
  final MobilityConfig config;
  final Duration transferPenalty;

  static const _transferWalkProfile = TransferWalkProfile();

  late final Map<String, List<LineRoute>> _routesByStation = _indexRoutes();

  Map<String, List<LineRoute>> _indexRoutes() {
    final index = <String, List<LineRoute>>{};
    for (final route in network.routes) {
      for (final stopId in route.stopIds) {
        index.putIfAbsent(stopId, () => <LineRoute>[]).add(route);
      }
    }
    return index;
  }

  List<RouteSegment>? run(String fromStationId, String toStationId) {
    final start = _Node(fromStationId, '');
    final goal = _Node(toStationId, '');

    final best = <String, Duration>{start.key: Duration.zero};
    final cameFrom = <String, _Edge>{};
    final open = <_Node>[start];
    final closed = <String>{};

    while (open.isNotEmpty) {
      open.sort((a, b) => best[a.key]!.compareTo(best[b.key]!));
      final current = open.removeAt(0);
      if (!closed.add(current.key)) continue;
      if (current == goal) return _rebuild(cameFrom, goal);

      for (final edge in _edgesFrom(current)) {
        if (closed.contains(edge.to.key)) continue;
        final tentative = best[current.key]! + edge.cost;
        final known = best[edge.to.key];
        if (known == null || tentative < known) {
          best[edge.to.key] = tentative;
          cameFrom[edge.to.key] = edge;
          open.add(edge.to);
        }
      }
    }
    return null;
  }

  List<_Edge> _edgesFrom(_Node node) {
    final edges = <_Edge>[];
    final station = network.station(node.stationId);

    if (node.lineId.isEmpty) {
      // Monter dans un véhicule : on paie l'attente moyenne.
      for (final route
          in _routesByStation[node.stationId] ?? const <LineRoute>[]) {
        final wait = network.profileFor(route.line.mode).averageWait;
        edges.add(
          _Edge(
            from: node,
            to: _Node(node.stationId, route.id),
            kind: _EdgeKind.board,
            cost: wait + transferPenalty,
            segment: RouteSegment.waiting(
              at: station.position.copyWith(label: station.name),
              duration: wait,
              forLine: route.line,
            ),
          ),
        );
      }
      // Rejoindre une station voisine à pied (correspondance de surface).
      for (final other in network.stations.values) {
        if (other.id == node.stationId) continue;
        final distance = station.position.distanceTo(other.position);
        if (distance > TransitNetwork.maxFootConnectionMeters) continue;
        edges.add(
          _Edge(
            from: node,
            to: _Node(other.id, ''),
            kind: _EdgeKind.footConnection,
            cost: _transferWalkProfile.durationFor(distance, config),
            segment: _transferWalkProfile.buildSegment(
              origin: station.position.copyWith(label: station.name),
              destination: other.position.copyWith(label: other.name),
              config: config,
              distanceMeters: distance,
            ),
          ),
        );
      }
      return edges;
    }

    // À bord d'un véhicule : descendre, ou continuer d'un arrêt.
    edges.add(
      _Edge(
        from: node,
        to: _Node(node.stationId, ''),
        kind: _EdgeKind.alight,
        cost: Duration.zero,
      ),
    );

    final route = network.routes.firstWhere((r) => r.id == node.lineId);
    final index = route.stopIds.indexOf(node.stationId);
    if (index < 0) return edges;

    for (final next in <int>[index - 1, index + 1]) {
      if (next < 0 || next >= route.stopIds.length) continue;
      final from = network.station(node.stationId);
      final to = network.station(route.stopIds[next]);
      final distance =
          from.position.distanceTo(to.position) * TransitNetwork.detourFactor;
      final speed = network.profileFor(route.line.mode).commercialSpeedKmh;
      final seconds = (distance / 1000.0) / speed * 3600.0;
      final duration = Duration(milliseconds: (seconds * 1000).round());

      edges.add(
        _Edge(
          from: node,
          to: _Node(to.id, route.id),
          kind: _EdgeKind.ride,
          cost: duration,
          segment: RouteSegment(
            type: route.line.mode,
            origin: from.position.copyWith(label: from.name),
            destination: to.position.copyWith(label: to.name),
            distanceMeters: distance,
            duration: duration,
            line: route.line,
          ),
        ),
      );
    }
    return edges;
  }

  /// Remonte le chemin puis fusionne les arrêts successifs d'une même ligne
  /// en un seul tronçon lisible.
  List<RouteSegment> _rebuild(Map<String, _Edge> cameFrom, _Node goal) {
    final raw = <RouteSegment>[];
    var node = goal;
    while (cameFrom.containsKey(node.key)) {
      final edge = cameFrom[node.key]!;
      if (edge.segment != null) raw.add(edge.segment!);
      node = edge.from;
    }
    return _mergeConsecutiveRides(raw.reversed.toList());
  }

  List<RouteSegment> _mergeConsecutiveRides(List<RouteSegment> segments) {
    final merged = <RouteSegment>[];
    for (final segment in segments) {
      final previous = merged.isEmpty ? null : merged.last;
      final sameLine =
          previous != null &&
          previous.type.isTransit &&
          segment.type.isTransit &&
          previous.line == segment.line;
      if (sameLine) {
        final stops = (previous.details['stopCount'] as int? ?? 1) + 1;
        merged[merged.length - 1] = RouteSegment(
          type: previous.type,
          origin: previous.origin,
          destination: segment.destination,
          distanceMeters: previous.distanceMeters + segment.distanceMeters,
          duration: previous.duration + segment.duration,
          line: previous.line,
          details: {...previous.details, 'stopCount': stops},
        );
      } else {
        merged.add(
          segment.type.isTransit
              ? RouteSegment(
                  type: segment.type,
                  origin: segment.origin,
                  destination: segment.destination,
                  distanceMeters: segment.distanceMeters,
                  duration: segment.duration,
                  line: segment.line,
                  details: {...segment.details, 'stopCount': 1},
                )
              : segment,
        );
      }
    }
    return merged;
  }
}
