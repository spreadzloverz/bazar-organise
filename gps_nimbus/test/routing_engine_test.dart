import 'package:flutter_test/flutter_test.dart';
import 'package:gps_nimbus/core/config/mobility_config.dart';
import 'package:gps_nimbus/core/places.dart';
import 'package:gps_nimbus/domain/model/route_option.dart';
import 'package:gps_nimbus/domain/model/segment_type.dart';
import 'package:gps_nimbus/routing/journey_planner.dart';
import 'package:gps_nimbus/routing/mock_idf_network.dart';
import 'package:gps_nimbus/routing/mock_routing_service.dart';
import 'package:gps_nimbus/routing/routing_service.dart';

void main() {
  final planner = JourneyPlanner(routingService: MockRoutingService());

  Future<JourneyResult> planBetween(String from, String to) {
    final origin = Places.byLabel(from);
    final destination = Places.byLabel(to);
    expect(origin, isNotNull, reason: 'lieu inconnu : $from');
    expect(destination, isNotNull, reason: 'lieu inconnu : $to');
    return planner.plan(
      RouteRequest(origin: origin!, destination: destination!),
    );
  }

  group('cohérence générale du moteur', () {
    test('un trajet urbain produit plusieurs itinéraires', () async {
      final result = await planBetween('Châtelet', 'La Défense');
      expect(result.isEmpty, isFalse);
      expect(result.ranked.all.length, greaterThan(3));
    });

    test('PLUS RAPIDE est réellement le plus rapide de tous', () async {
      for (final pair in _scenarios) {
        final result = await planBetween(pair.$1, pair.$2);
        final fastest = result.ranked.fastest!;
        for (final route in result.ranked.all) {
          expect(
            fastest.totalDuration <= route.totalDuration,
            isTrue,
            reason:
                '${pair.$1} → ${pair.$2} : ${route.id} est plus rapide '
                'que la recommandation ${fastest.id}',
          );
        }
      }
    });

    test('MOINS DE SKATE a réellement le moins de skate de tous', () async {
      for (final pair in _scenarios) {
        final result = await planBetween(pair.$1, pair.$2);
        final leastSkate = result.ranked.leastSkate!;
        for (final route in result.ranked.all) {
          expect(
            leastSkate.skateDistanceMeters <= route.skateDistanceMeters + 1,
            isTrue,
            reason:
                '${pair.$1} → ${pair.$2} : ${route.id} a moins de skate '
                'que la recommandation ${leastSkate.id}',
          );
        }
      }
    });

    test(
      'chaque itinéraire part du départ et arrive à la destination',
      () async {
        final origin = Places.byLabel('Montparnasse')!;
        final destination = Places.byLabel('Gare du Nord')!;
        final result = await planner.plan(
          RouteRequest(origin: origin, destination: destination),
        );
        for (final route in result.ranked.all) {
          expect(route.origin.latitude, origin.latitude);
          expect(route.destination.latitude, destination.latitude);
        }
      },
    );

    test('les durées sont cohérentes avec les vitesses configurées', () async {
      final result = await planBetween('Châtelet', 'Bastille');
      for (final route in result.ranked.all) {
        for (final segment in route.segments) {
          if (segment.distanceMeters <= 0) continue;
          final expected = segment.type.isSkate
              ? MobilityConfig.defaults.skateSpeedKmh
              : segment.type.isWalking
              ? MobilityConfig.defaults.walkingSpeedKmh
              : null;
          if (expected == null) continue;
          expect(segment.averageSpeedKmh, closeTo(expected, 0.05));
        }
      }
    });

    test(
      'les avertissements signalent honnêtement les données fictives',
      () async {
        final result = await planBetween('Châtelet', 'Bastille');
        expect(result.usesMockData, isTrue);
        expect(result.notices, isNotEmpty);
        expect(
          result.notices.any((n) => n.toLowerCase().contains('fictif')),
          isTrue,
        );
        expect(
          result.notices.any((n) => n.toLowerCase().contains('cyclable')),
          isTrue,
        );
      },
    );
  });

  group('combinaisons de modes attendues au MVP', () {
    late List<RouteOption> corpus;

    setUpAll(() async {
      corpus = <RouteOption>[];
      for (final pair in _scenarios) {
        final result = await planBetween(pair.$1, pair.$2);
        corpus.addAll(result.ranked.all);
      }
    });

    bool exists(bool Function(RouteOption) predicate) => corpus.any(predicate);

    test('marche seule', () {
      expect(
        exists(
          (r) =>
              r.isDirectMode &&
              r.skateDistanceMeters == 0 &&
              r.walkDistanceMeters > 0,
        ),
        isTrue,
      );
    });

    test('skate seul', () {
      expect(
        exists(
          (r) =>
              r.isDirectMode &&
              r.skateDistanceMeters > 0 &&
              r.walkDistanceMeters == 0,
        ),
        isTrue,
      );
    });

    test('marche + transport', () {
      expect(
        exists(
          (r) =>
              r.transitLegCount >= 1 &&
              r.walkDistanceMeters > 0 &&
              r.skateDistanceMeters == 0,
        ),
        isTrue,
      );
    });

    test('skate + transport', () {
      expect(
        exists((r) => r.transitLegCount >= 1 && r.skateDistanceMeters > 0),
        isTrue,
      );
    });

    test('skate + plusieurs transports', () {
      expect(
        exists((r) => r.transitLegCount >= 2 && r.skateDistanceMeters > 0),
        isTrue,
      );
    });

    test('marche + skate sur un même itinéraire', () {
      expect(
        exists((r) => r.skateDistanceMeters > 0 && r.walkDistanceMeters > 0),
        isTrue,
      );
    });

    test('les quatre modes de transport sont représentables', () {
      for (final mode in [
        SegmentType.metro,
        SegmentType.rer,
        SegmentType.tram,
      ]) {
        expect(
          exists((r) => r.segments.any((s) => s.type == mode)),
          isTrue,
          reason: 'aucun itinéraire n\'utilise ${mode.shortLabel}',
        );
      }
    });
  });

  group('réseau de transport', () {
    final network = MockIdfNetwork.build();
    const config = MobilityConfig.defaults;

    test('le bus est utilisable quand il est le seul lien disponible', () {
      // Gare d'Austerlitz n'est desservie que par le bus 91 dans le réseau
      // simplifié : tout trajet à son départ commence donc en bus.
      final segments = network.findTransitSegments(
        fromStationId: 'austerlitz',
        toStationId: 'bastille',
        config: config,
      );
      expect(segments, isNotNull);
      expect(segments!.any((s) => s.type == SegmentType.bus), isTrue);
    });

    test('un trajet multi-lignes produit des correspondances', () {
      final segments = network.findTransitSegments(
        fromStationId: 'clignancourt',
        toStationId: 'marne_la_vallee',
        config: config,
      );
      expect(segments, isNotNull);
      final route = RouteOption(id: 'test', segments: segments!);
      expect(route.transitLegCount, greaterThanOrEqualTo(2));
      expect(route.transferCount, route.transitLegCount - 1);
    });

    test('chaque embarquement est précédé d\'une attente', () {
      final segments = network.findTransitSegments(
        fromStationId: 'clignancourt',
        toStationId: 'massy_palaiseau',
        config: config,
      )!;
      final waits = segments.where((s) => s.type.isWaiting).length;
      final rides = segments.where((s) => s.type.isTransit).length;
      expect(waits, rides);
    });

    test('les arrêts successifs d\'une même ligne sont fusionnés', () {
      // Châtelet → Bastille : deux inter-stations consécutives sur la
      // ligne 1, qui doivent donner un seul tronçon lisible.
      final segments = network.findTransitSegments(
        fromStationId: 'chatelet',
        toStationId: 'bastille',
        config: config,
      )!;
      final rides = segments.where((s) => s.type.isTransit).toList();
      expect(rides.length, 1);
      expect(rides.single.line!.name, '1');
      expect(rides.single.details['stopCount'], 2);
      expect(rides.single.origin.label, 'Châtelet');
      expect(rides.single.destination.label, 'Bastille');
    });

    test('un même itinéraire peut réemprunter une ligne après un détour', () {
      // La Défense → Château de Vincennes : le moteur peut choisir la
      // ligne 1, puis le RER A plus rapide, puis de nouveau la ligne 1.
      // Chaque portion reste un tronçon distinct.
      final segments = network.findTransitSegments(
        fromStationId: 'la_defense',
        toStationId: 'vincennes_metro',
        config: config,
      )!;
      final route = RouteOption(id: 'detour', segments: segments);
      expect(route.transitLegCount, greaterThanOrEqualTo(1));
      for (var i = 1; i < segments.length; i++) {
        final previous = segments[i - 1];
        final current = segments[i];
        final sameLineTwice =
            previous.type.isTransit &&
            current.type.isTransit &&
            previous.line == current.line;
        expect(
          sameLineTwice,
          isFalse,
          reason:
              'deux tronçons consécutifs de la même ligne '
              'auraient dû être fusionnés',
        );
      }
    });

    test('une station inconnue ne fait pas planter le moteur', () {
      expect(
        network.findTransitSegments(
          fromStationId: 'station_inexistante',
          toStationId: 'chatelet',
          config: config,
        ),
        isNull,
      );
    });

    test('le réseau se déclare fictif', () {
      expect(network.isMockData, isTrue);
      expect(network.sourceLabel, isNotEmpty);
    });
  });

  group('cas limites', () {
    test('départ et arrivée identiques donnent un trajet quasi nul', () async {
      final result = await planBetween('Châtelet', 'Châtelet');
      expect(result.isEmpty, isFalse);
      expect(
        result.ranked.fastest!.totalDuration,
        lessThan(const Duration(minutes: 1)),
      );
    });

    test(
      'une limite de distance skate écarte les itinéraires trop longs',
      () async {
        final origin = Places.byLabel('Issy-les-Moulineaux')!;
        final destination = Places.byLabel('Nation')!;
        final limited = await planner.plan(
          RouteRequest(
            origin: origin,
            destination: destination,
            config: const MobilityConfig(maxSkateDistanceMeters: 1500),
          ),
        );
        for (final route in limited.ranked.all) {
          // Le trajet « skate seul » reste proposé (il n'a pas d'alternative),
          // mais aucun itinéraire combiné ne dépasse la limite.
          if (route.transitLegCount == 0) continue;
          expect(route.skateDistanceMeters, lessThanOrEqualTo(1500));
        }
      },
    );

    test(
      'des vitesses différentes changent les durées, pas les distances',
      () async {
        final origin = Places.byLabel('Denfert-Rochereau')!;
        final destination = Places.byLabel("Porte d'Orléans")!;
        final normal = await planner.plan(
          RouteRequest(origin: origin, destination: destination),
        );
        final lent = await planner.plan(
          RouteRequest(
            origin: origin,
            destination: destination,
            config: const MobilityConfig(skateSpeedKmh: 10),
          ),
        );

        final normalSkate = normal.ranked.all.firstWhere(
          (r) => r.isDirectMode && r.skateDistanceMeters > 0,
        );
        final lentSkate = lent.ranked.all.firstWhere(
          (r) => r.isDirectMode && r.skateDistanceMeters > 0,
        );

        expect(
          lentSkate.skateDistanceMeters,
          closeTo(normalSkate.skateDistanceMeters, 1),
        );
        expect(lentSkate.totalDuration > normalSkate.totalDuration, isTrue);
      },
    );
  });

  group('catalogue de lieux', () {
    test('la recherche ignore la casse et les accents', () {
      expect(Places.search('chatelet').single.label, 'Châtelet');
      expect(Places.search('ETOILE').single.label, 'Étoile');
    });

    test('un lieu inconnu ne renvoie rien', () {
      expect(Places.byLabel('Marseille'), isNull);
      expect(Places.search('Marseille'), isEmpty);
    });

    test('tous les lieux sont en Île-de-France', () {
      for (final place in Places.all) {
        expect(place.latitude, inInclusiveRange(48.1, 49.3));
        expect(place.longitude, inInclusiveRange(1.4, 3.6));
      }
    });
  });
}

const _scenarios = <(String, String)>[
  ('Châtelet', 'Bastille'),
  ('Châtelet', 'La Défense'),
  ('Montparnasse', 'Gare du Nord'),
  ('Denfert-Rochereau', "Porte d'Orléans"),
  ('Issy-les-Moulineaux', 'Nation'),
  ('Bourg-la-Reine', 'Étoile'),
  ('Porte de Versailles', 'Vincennes'),
];
