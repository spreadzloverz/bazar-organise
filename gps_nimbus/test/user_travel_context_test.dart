import 'package:flutter_test/flutter_test.dart';
import 'package:gps_nimbus/core/places.dart';
import 'package:gps_nimbus/domain/calibration/user_travel_context.dart';
import 'package:gps_nimbus/domain/model/segment_type.dart';
import 'package:gps_nimbus/routing/mock_routing_service.dart';
import 'package:gps_nimbus/routing/routing_service.dart';

void main() {
  group('observations terrain', () {
    test('une plage conserve ses bornes et utilise un milieu neutre', () {
      const observation = ObservedSegment(
        originLabel: 'GOLDEN-001_ORIGIN_ALFORTVILLE',
        destinationLabel: 'Ivry-sur-Seine',
        mode: SegmentType.skate,
        minDuration: Duration(minutes: 7),
        maxDuration: Duration(minutes: 10),
      );

      expect(observation.representativeDuration, const Duration(minutes: 8, seconds: 30));
      expect(observation.minDuration, const Duration(minutes: 7));
      expect(observation.maxDuration, const Duration(minutes: 10));
    });

    test('une mesure utilisateur gagne sur une estimation générique', () {
      final context = UserTravelContext(
        observedSegments: [
          const ObservedSegment(
            originLabel: 'A',
            destinationLabel: 'B',
            mode: SegmentType.skate,
            minDuration: Duration(minutes: 4),
            maxDuration: Duration(minutes: 4),
            observationCount: 20,
            source: TravelEvidenceSource.genericEstimate,
          ),
          const ObservedSegment(
            originLabel: 'A',
            destinationLabel: 'B',
            mode: SegmentType.skate,
            minDuration: Duration(minutes: 10),
            maxDuration: Duration(minutes: 10),
            observationCount: 1,
            source: TravelEvidenceSource.userMeasured,
          ),
        ],
      );

      final selected = context.bestObservationFor(
        originLabel: 'A',
        destinationLabel: 'B',
        mode: SegmentType.skate,
      );

      expect(selected, isNotNull);
      expect(selected!.source, TravelEvidenceSource.userMeasured);
      expect(selected.representativeDuration, const Duration(minutes: 10));
    });

    test('une observation reste directionnelle', () {
      const observation = ObservedSegment(
        originLabel: 'A',
        destinationLabel: 'B',
        mode: SegmentType.skate,
        minDuration: Duration(minutes: 5),
        maxDuration: Duration(minutes: 5),
      );

      expect(
        observation.matches(
          originLabel: 'B',
          destinationLabel: 'A',
          mode: SegmentType.skate,
        ),
        isFalse,
      );
    });

    test('Ivry reste protégé et ne devient pas BFM silencieusement', () {
      const context = UserTravelContext(
        protectedBoardingLabels: ['Ivry-sur-Seine'],
      );

      expect(context.protectsBoarding('Ivry-sur-Seine'), isTrue);
      expect(
        context.protectsBoarding('Bibliothèque François-Mitterrand'),
        isFalse,
      );
    });
  });

  group('intégration au moteur mock', () {
    test('la durée observée remplace le calcul générique du skate direct', () async {
      final origin = Places.byLabel('Châtelet')!;
      final destination = Places.byLabel('Bastille')!;
      final service = MockRoutingService();

      final result = await service.findRoutes(
        RouteRequest(
          origin: origin,
          destination: destination,
          userContext: const UserTravelContext(
            observedSegments: [
              ObservedSegment(
                originLabel: 'Châtelet',
                destinationLabel: 'Bastille',
                mode: SegmentType.skate,
                minDuration: Duration(minutes: 12),
                maxDuration: Duration(minutes: 12),
                observationCount: 3,
              ),
            ],
          ),
        ),
      );

      final directSkate = result.routes.firstWhere(
        (route) => route.id.startsWith('skate_'),
      );

      expect(directSkate.totalDuration, const Duration(minutes: 12));
      expect(
        directSkate.segments.single.details['durationSource'],
        TravelEvidenceSource.userMeasured.name,
      );
      expect(
        directSkate.segments.single.details['genericDurationSeconds'],
        isA<int>(),
      );
    });

    test('un point explicite existant est ajouté aux stations candidates', () async {
      final origin = Places.byLabel('Châtelet')!;
      final destination = Places.byLabel('Bastille')!;
      final service = MockRoutingService();

      final result = await service.findRoutes(
        RouteRequest(
          origin: origin,
          destination: destination,
          userContext: const UserTravelContext(
            protectedBoardingLabels: ["Gare d'Austerlitz"],
          ),
        ),
      );

      expect(
        result.routes.any(
          (route) => route.segments.any(
            (segment) =>
                segment.origin.label == "Gare d'Austerlitz" ||
                segment.destination.label == "Gare d'Austerlitz",
          ),
        ),
        isTrue,
      );
    });

    test('un point absent reste signalé au lieu d'être remplacé', () async {
      final origin = Places.byLabel('Châtelet')!;
      final destination = Places.byLabel('Bastille')!;
      final service = MockRoutingService();

      final result = await service.findRoutes(
        RouteRequest(
          origin: origin,
          destination: destination,
          userContext: const UserTravelContext(
            protectedBoardingLabels: ['Ivry-sur-Seine'],
          ),
        ),
      );

      expect(
        result.notices.any(
          (notice) =>
              notice.contains('Ivry-sur-Seine') &&
              notice.contains('absents du réseau fictif'),
        ),
        isTrue,
      );
    });
  });
}
