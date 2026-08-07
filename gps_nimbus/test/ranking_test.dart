import 'package:flutter_test/flutter_test.dart';
import 'package:gps_nimbus/domain/model/segment_type.dart';
import 'package:gps_nimbus/domain/ranking/ranking_criteria.dart';
import 'package:gps_nimbus/domain/ranking/route_ranker.dart';

import 'support/route_builders.dart';

void main() {
  const ranker = RouteRanker();

  group('PLUS RAPIDE', () {
    test('retient le temps total le plus court', () {
      final rapide = option('rapide', [
        seg(SegmentType.skate, meters: 5000, minutes: 11),
        seg(SegmentType.metro, meters: 4000, minutes: 9, line: metro1),
      ]);
      final lent = option('lent', [
        seg(SegmentType.walkingRoute, meters: 4000, minutes: 48),
      ]);

      final result = ranker.rank([lent, rapide]);
      expect(result.fastest, same(rapide));
    });

    test('compte l\'attente et les correspondances dans le total', () {
      // Sans l'attente, « avecAttente » serait le plus rapide.
      final avecAttente = option('avecAttente', [
        seg(SegmentType.waiting, minutes: 12),
        seg(SegmentType.metro, meters: 6000, minutes: 14, line: metro1),
      ]);
      final sansAttente = option('sansAttente', [
        seg(SegmentType.skate, meters: 6000, minutes: 20),
      ]);

      final result = ranker.rank([avecAttente, sansAttente]);
      expect(result.fastest, same(sansAttente));
    });

    test('à durée égale, préfère le moins de correspondances', () {
      final direct = option('direct', [
        seg(SegmentType.metro, meters: 8000, minutes: 30, line: metro1),
      ]);
      final avecCorrespondance = option('correspondance', [
        seg(SegmentType.metro, meters: 4000, minutes: 15, line: metro1),
        seg(SegmentType.metro, meters: 4000, minutes: 15, line: metro4),
      ]);

      final result = ranker.rank([avecCorrespondance, direct]);
      expect(result.fastest, same(direct));
    });

    test('à durée et correspondances égales, préfère le moins de skate', () {
      final peuDeSkate = option('peu', [
        seg(SegmentType.skate, meters: 1000, minutes: 5),
        seg(SegmentType.walkingRoute, meters: 1000, minutes: 15),
      ]);
      final beaucoupDeSkate = option('beaucoup', [
        seg(SegmentType.skate, meters: 5000, minutes: 20),
      ]);

      final result = ranker.rank([beaucoupDeSkate, peuDeSkate]);
      expect(result.fastest, same(peuDeSkate));
    });
  });

  group('MOINS DE SKATE', () {
    test('retient la plus petite distance skate, même si c\'est plus long', () {
      final rapideMaisSkate = option('rapideMaisSkate', [
        seg(SegmentType.skate, meters: 8000, minutes: 18),
      ]);
      final lentSansSkate = option('lentSansSkate', [
        seg(SegmentType.walkingRoute, meters: 800, minutes: 10),
        seg(SegmentType.metro, meters: 7000, minutes: 20, line: metro1),
        seg(SegmentType.walkingRoute, meters: 500, minutes: 6),
      ]);

      final result = ranker.rank([rapideMaisSkate, lentSansSkate]);
      expect(result.leastSkate, same(lentSansSkate));
      expect(result.leastSkate!.skateDistanceMeters, 0);
      // Et le classement rapide, lui, désigne bien l'autre.
      expect(result.fastest, same(rapideMaisSkate));
    });

    test('à skate égal, départage par le temps total', () {
      final court = option('court', [
        seg(SegmentType.skate, meters: 2000, minutes: 5),
        seg(SegmentType.metro, meters: 5000, minutes: 12, line: metro1),
      ]);
      final long = option('long', [
        seg(SegmentType.skate, meters: 2000, minutes: 5),
        seg(SegmentType.bus, meters: 5000, minutes: 25, line: bus91),
      ]);

      final result = ranker.rank([long, court]);
      expect(result.leastSkate, same(court));
    });

    test('à skate et temps égaux, départage par les correspondances', () {
      final direct = option('direct', [
        seg(SegmentType.skate, meters: 1000, minutes: 3),
        seg(SegmentType.rer, meters: 9000, minutes: 20, line: rerA),
      ]);
      final deuxTransports = option('deux', [
        seg(SegmentType.skate, meters: 1000, minutes: 3),
        seg(SegmentType.metro, meters: 4000, minutes: 10, line: metro1),
        seg(SegmentType.metro, meters: 5000, minutes: 10, line: metro4),
      ]);

      final result = ranker.rank([deuxTransports, direct]);
      expect(result.leastSkate, same(direct));
    });

    test(
      'à skate, temps et correspondances égaux, départage par la marche',
      () {
        final peuDeMarche = option('peuMarche', [
          seg(SegmentType.skate, meters: 1000, minutes: 3),
          seg(SegmentType.walkingRoute, meters: 200, minutes: 5),
          seg(SegmentType.metro, meters: 6000, minutes: 15, line: metro1),
        ]);
        final beaucoupDeMarche = option('beaucoupMarche', [
          seg(SegmentType.skate, meters: 1000, minutes: 3),
          seg(SegmentType.walkingRoute, meters: 1400, minutes: 5),
          seg(SegmentType.metro, meters: 6000, minutes: 15, line: metro4),
        ]);

        final result = ranker.rank([beaucoupDeMarche, peuDeMarche]);
        expect(result.leastSkate, same(peuDeMarche));
      },
    );

    test('des itinéraires strictement égaux donnent un ordre stable', () {
      final a = option('a', [seg(SegmentType.skate, meters: 3000, minutes: 7)]);
      final b = option('b', [seg(SegmentType.skate, meters: 3000, minutes: 7)]);

      expect(ranker.rank([a, b]).leastSkate!.id, 'a');
      expect(ranker.rank([b, a]).leastSkate!.id, 'a');
      expect(ranker.rank([b, a]).fastest!.id, 'a');
    });
  });

  group('résultat de classement', () {
    test('les deux classements couvrent tous les itinéraires', () {
      final routes = [
        option('x', [seg(SegmentType.skate, meters: 4000, minutes: 9)]),
        option('y', [seg(SegmentType.walkingRoute, meters: 4000, minutes: 48)]),
      ];
      final result = ranker.rank(routes);
      for (final criteria in RankingCriteria.values) {
        expect(result.ranked(criteria).length, routes.length);
      }
    });

    test('une recherche sans résultat ne renvoie aucune recommandation', () {
      final result = ranker.rank([]);
      expect(result.isEmpty, isTrue);
      expect(result.fastest, isNull);
      expect(result.leastSkate, isNull);
    });

    test('les deux recommandations peuvent désigner le même itinéraire', () {
      final unique = option('u', [
        seg(SegmentType.walkingRoute, meters: 900, minutes: 11),
      ]);
      final result = ranker.rank([unique]);
      expect(result.recommendationsAreIdentical, isTrue);
    });
  });
}
