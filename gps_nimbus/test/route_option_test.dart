import 'package:flutter_test/flutter_test.dart';
import 'package:gps_nimbus/domain/model/segment_type.dart';

import 'support/route_builders.dart';

void main() {
  group('agrégats d\'un itinéraire', () {
    final route = option('r', [
      seg(SegmentType.skate, meters: 1800, minutes: 4),
      seg(SegmentType.transferWalk, meters: 150, minutes: 2),
      seg(SegmentType.waiting, minutes: 3),
      seg(SegmentType.rer, meters: 12000, minutes: 16, line: rerA),
      seg(SegmentType.transferWalk, meters: 200, minutes: 3),
      seg(SegmentType.waiting, minutes: 2),
      seg(SegmentType.metro, meters: 2500, minutes: 6, line: metro1),
      seg(SegmentType.walkingRoute, meters: 600, minutes: 7),
    ]);

    test('la durée totale inclut skate, marche, attente et transport', () {
      expect(route.totalDuration, const Duration(minutes: 43));
    });

    test('la distance totale additionne tous les tronçons', () {
      expect(route.totalDistanceMeters, 17250);
    });

    test('la distance skate est isolée', () {
      expect(route.skateDistanceMeters, 1800);
    });

    test('la distance marche inclut les correspondances à pied', () {
      expect(route.walkDistanceMeters, 950);
      expect(route.walkingRouteDistanceMeters, 600);
      expect(route.transferWalkDistanceMeters, 350);
    });

    test('le temps de transport exclut attente et correspondances', () {
      expect(route.transitDuration, const Duration(minutes: 22));
      expect(route.waitingDuration, const Duration(minutes: 5));
    });

    test('le nombre de transports et de correspondances est correct', () {
      expect(route.transitLegCount, 2);
      expect(route.transferCount, 1);
    });

    test('la séquence est lisible et sans attente', () {
      expect(
        route.sequenceLabel,
        'SKATE → MARCHE → RER → MARCHE → MÉTRO → MARCHE',
      );
    });

    test('les lignes empruntées sont listées dans l\'ordre', () {
      expect(route.lineNames, ['RER A', 'MÉTRO 1']);
    });
  });

  group('cas particuliers', () {
    test('un trajet à pied seul n\'a ni skate ni correspondance', () {
      final route = option('marche', [
        seg(SegmentType.walkingRoute, meters: 2000, minutes: 24),
      ]);
      expect(route.skateDistanceMeters, 0);
      expect(route.transitLegCount, 0);
      expect(route.transferCount, 0);
      expect(route.isDirectMode, isTrue);
      expect(route.sequenceLabel, 'MARCHE');
    });

    test('trois transports enchaînés font deux correspondances', () {
      final route = option('multi', [
        seg(SegmentType.skate, meters: 900, minutes: 2),
        seg(SegmentType.tram, meters: 3000, minutes: 10, line: tramT3),
        seg(SegmentType.metro, meters: 4000, minutes: 10, line: metro4),
        seg(SegmentType.bus, meters: 2000, minutes: 10, line: bus91),
        seg(SegmentType.skate, meters: 700, minutes: 2),
      ]);
      expect(route.transitLegCount, 3);
      expect(route.transferCount, 2);
      expect(route.skateDistanceMeters, 1600);
      expect(route.sequenceLabel, 'SKATE → TRAM → MÉTRO → BUS → SKATE');
    });

    test(
      'les modes identiques consécutifs sont fusionnés dans la séquence',
      () {
        final route = option('fusion', [
          seg(SegmentType.walkingRoute, meters: 300, minutes: 4),
          seg(SegmentType.transferWalk, meters: 100, minutes: 1),
          seg(SegmentType.metro, meters: 3000, minutes: 8, line: metro1),
        ]);
        expect(route.sequenceLabel, 'MARCHE → MÉTRO');
      },
    );

    test('un itinéraire vide est refusé', () {
      expect(() => option('vide', []), throwsA(isA<AssertionError>()));
    });
  });
}
