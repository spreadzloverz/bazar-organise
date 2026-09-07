import 'package:flutter_test/flutter_test.dart';
import 'package:gps_nimbus/core/config/mobility_config.dart';
import 'package:gps_nimbus/domain/calibration/user_travel_context.dart';
import 'package:gps_nimbus/domain/model/geo_point.dart';
import 'package:gps_nimbus/domain/model/route_option.dart';
import 'package:gps_nimbus/domain/model/segment_type.dart';
import 'package:gps_nimbus/routing/mock_idf_network.dart';
import 'package:gps_nimbus/routing/mock_routing_service.dart';
import 'package:gps_nimbus/routing/routing_service.dart';

void main() {
  final network = MockIdfNetwork.build();
  const config = MobilityConfig.defaults;

  group('GOLDEN-001 — corridors publics du réseau fictif', () {
    test('les stations publiques nécessaires existent', () {
      for (final stationId in [
        'quai_de_la_gare',
        'pasteur',
        'mairie_issy',
        'ivry_sur_seine',
        'issy_val_de_seine',
      ]) {
        expect(network.stations.containsKey(stationId), isTrue);
      }
    });

    test('la ligne 6 relie Quai de la Gare à Pasteur', () {
      final segments = network.findTransitSegments(
        fromStationId: 'quai_de_la_gare',
        toStationId: 'pasteur',
        config: config,
      );

      expect(segments, isNotNull);
      final rides = segments!
          .where((segment) => segment.type.isTransit)
          .toList();
      expect(rides.length, 1);
      expect(rides.single.line!.name, '6');
      expect(rides.single.origin.label, 'Quai de la Gare');
      expect(rides.single.destination.label, 'Pasteur');
    });

    test("la ligne 12 relie Pasteur à Mairie d'Issy", () {
      final segments = network.findTransitSegments(
        fromStationId: 'pasteur',
        toStationId: 'mairie_issy',
        config: config,
      );

      expect(segments, isNotNull);
      final rides = segments!
          .where((segment) => segment.type.isTransit)
          .toList();
      expect(rides.length, 1);
      expect(rides.single.line!.name, '12');
      expect(rides.single.origin.label, 'Pasteur');
      expect(rides.single.destination.label, "Mairie d'Issy");
    });

    test('M6 puis M12 forme la variante utilisateur de référence', () {
      final segments = network.findTransitSegments(
        fromStationId: 'quai_de_la_gare',
        toStationId: 'mairie_issy',
        config: config,
      );

      expect(segments, isNotNull);
      final route = RouteOption(id: 'golden-001-metro', segments: segments!);
      final lineNames = route.transitLines.map((line) => line.name).toList();

      expect(lineNames, ['6', '12']);
      expect(route.transferCount, 1);
    });

    test('le RER C relie Ivry-sur-Seine à Issy–Val de Seine', () {
      final segments = network.findTransitSegments(
        fromStationId: 'ivry_sur_seine',
        toStationId: 'issy_val_de_seine',
        config: config,
      );

      expect(segments, isNotNull);
      final rides = segments!
          .where((segment) => segment.type.isTransit)
          .toList();
      expect(rides.length, 1);
      expect(rides.single.line!.name, 'C');
      expect(rides.single.origin.label, 'Ivry-sur-Seine');
      expect(rides.single.destination.label, 'Issy–Val de Seine');
    });
  });

  group('GOLDEN-001 — données terrain anonymisées', () {
    const origin = GeoPoint(
      latitude: 48.8,
      longitude: 2.42,
      label: 'GOLDEN-001_ORIGIN_ALFORTVILLE',
    );
    const destination = GeoPoint(
      latitude: 48.82,
      longitude: 2.265,
      label: 'GOLDEN-001_DESTINATION_ISSY',
    );

    test('la variante M6 + M12 conserve les deux temps terrain', () async {
      final result = await MockRoutingService(network: network).findRoutes(
        const RouteRequest(
          origin: origin,
          destination: destination,
          userContext: UserTravelContext(
            protectedBoardingLabels: ['Quai de la Gare'],
            protectedAlightingLabels: ["Mairie d'Issy"],
            observedSegments: [
              ObservedSegment(
                originLabel: 'GOLDEN-001_ORIGIN_ALFORTVILLE',
                destinationLabel: 'Quai de la Gare',
                mode: SegmentType.skate,
                minDuration: Duration(minutes: 10),
                maxDuration: Duration(minutes: 10),
              ),
              ObservedSegment(
                originLabel: "Mairie d'Issy",
                destinationLabel: 'GOLDEN-001_DESTINATION_ISSY',
                mode: SegmentType.skate,
                minDuration: Duration(minutes: 5),
                maxDuration: Duration(minutes: 5),
              ),
            ],
          ),
        ),
      );

      final route = result.routes.firstWhere(
        (candidate) =>
            candidate.segments.first.type == SegmentType.skate &&
            candidate.segments.first.destination.label == 'Quai de la Gare' &&
            candidate.segments.last.type == SegmentType.skate &&
            candidate.segments.last.origin.label == "Mairie d'Issy" &&
            candidate.transitLines.map((line) => line.name).join(',') == '6,12',
      );

      expect(route.segments.first.duration, const Duration(minutes: 10));
      expect(route.segments.last.duration, const Duration(minutes: 5));
      expect(
        route.segments.first.details['durationSource'],
        TravelEvidenceSource.userMeasured.name,
      );
      expect(
        route.segments.last.details['durationSource'],
        TravelEvidenceSource.userMeasured.name,
      );
    });

    test('la variante Ivry conserve la plage terrain 7–10 min', () async {
      final result = await MockRoutingService(network: network).findRoutes(
        const RouteRequest(
          origin: origin,
          destination: destination,
          userContext: UserTravelContext(
            protectedBoardingLabels: ['Ivry-sur-Seine'],
            protectedAlightingLabels: ['Issy–Val de Seine'],
            observedSegments: [
              ObservedSegment(
                originLabel: 'GOLDEN-001_ORIGIN_ALFORTVILLE',
                destinationLabel: 'Ivry-sur-Seine',
                mode: SegmentType.skate,
                minDuration: Duration(minutes: 7),
                maxDuration: Duration(minutes: 10),
              ),
            ],
          ),
        ),
      );

      final route = result.routes.firstWhere(
        (candidate) =>
            candidate.segments.first.type == SegmentType.skate &&
            candidate.segments.first.destination.label == 'Ivry-sur-Seine' &&
            candidate.transitLines.any((line) => line.name == 'C'),
      );

      expect(
        route.segments.first.duration,
        const Duration(minutes: 8, seconds: 30),
      );
      expect(route.segments.first.details['observedMinSeconds'], 7 * 60);
      expect(route.segments.first.details['observedMaxSeconds'], 10 * 60);
    });
  });
}
