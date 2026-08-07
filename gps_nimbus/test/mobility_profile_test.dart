import 'package:flutter_test/flutter_test.dart';
import 'package:gps_nimbus/core/config/mobility_config.dart';
import 'package:gps_nimbus/domain/model/geo_point.dart';
import 'package:gps_nimbus/domain/model/segment_type.dart';
import 'package:gps_nimbus/domain/profile/access_policy.dart';
import 'package:gps_nimbus/domain/profile/mobility_profile.dart';

void main() {
  const config = MobilityConfig.defaults;

  group('invariants produit', () {
    test('la vitesse skate par défaut est 27 km/h', () {
      expect(config.skateSpeedKmh, 27.0);
    });

    test('la vitesse de marche par défaut est 5 km/h', () {
      expect(config.walkingSpeedKmh, 5.0);
    });

    test('les vitesses restent configurables', () {
      final custom = config.copyWith(skateSpeedKmh: 20, walkingSpeedKmh: 4.5);
      expect(custom.skateSpeedKmh, 20);
      expect(custom.walkingSpeedKmh, 4.5);
      // La configuration par défaut n'est pas modifiée.
      expect(MobilityConfig.defaults.skateSpeedKmh, 27.0);
    });
  });

  group('durées calculées', () {
    test('27 km en skate prennent 1 heure', () {
      const skate = SkateProfile();
      expect(skate.durationFor(27000, config).inSeconds, 3600);
    });

    test('5 km à pied prennent 1 heure', () {
      const walk = WalkingProfile();
      expect(walk.durationFor(5000, config).inSeconds, 3600);
    });

    test('1 km à pied prend 12 minutes', () {
      const walk = WalkingProfile();
      expect(walk.durationFor(1000, config).inSeconds, 720);
    });

    test('1 km en skate prend environ 2 min 13 s', () {
      const skate = SkateProfile();
      expect(skate.durationFor(1000, config).inSeconds, 133);
    });

    test('une distance nulle donne une durée nulle', () {
      const skate = SkateProfile();
      expect(skate.durationFor(0, config), Duration.zero);
    });

    test('le skate est plus rapide que la marche sur la même distance', () {
      const skate = SkateProfile();
      const walk = WalkingProfile();
      expect(
        skate.durationFor(3000, config) < walk.durationFor(3000, config),
        isTrue,
      );
    });
  });

  group('construction de tronçons', () {
    const origin = GeoPoint(latitude: 48.8566, longitude: 2.3522, label: 'A');
    const destination = GeoPoint(
      latitude: 48.8738,
      longitude: 2.2950,
      label: 'B',
    );

    test('la marche produit un tronçon walkingRoute cohérent', () {
      const walk = WalkingProfile();
      final segment = walk.buildSegment(
        origin: origin,
        destination: destination,
        config: config,
      );
      expect(segment.type, SegmentType.walkingRoute);
      expect(segment.distanceMeters, greaterThan(0));
      expect(segment.averageSpeedKmh, closeTo(5.0, 0.01));
    });

    test('le skate produit un tronçon skate à 27 km/h', () {
      const skate = SkateProfile();
      final segment = skate.buildSegment(
        origin: origin,
        destination: destination,
        config: config,
        distanceMeters: 4500,
      );
      expect(segment.type, SegmentType.skate);
      expect(segment.distanceMeters, 4500);
      expect(segment.averageSpeedKmh, closeTo(27.0, 0.01));
    });

    test('la marche de correspondance est un type distinct', () {
      const transfer = TransferWalkProfile();
      final segment = transfer.buildSegment(
        origin: origin,
        destination: destination,
        config: config,
        distanceMeters: 120,
      );
      expect(segment.type, SegmentType.transferWalk);
      expect(segment.type.isWalking, isTrue);
      expect(segment.type, isNot(SegmentType.walkingRoute));
    });
  });

  group('politique d\'accès skate', () {
    test('le proxy vélo est signalé explicitement', () {
      const policy = SkateAccessPolicy();
      expect(policy.isProxy, isTrue);
      expect(policy.proxyNotice, isNotNull);
    });

    test('le proxy peut être désactivé sans changer le reste du moteur', () {
      const policy = SkateAccessPolicy(useBicycleProxy: false);
      expect(policy.isProxy, isFalse);
      expect(policy.proxyNotice, isNull);
    });

    test('le skate est interdit sur voie rapide et dans les escaliers', () {
      const policy = SkateAccessPolicy();
      expect(policy.decide(WayKind.expressway), AccessDecision.forbidden);
      expect(policy.decide(WayKind.stairs), AccessDecision.forbidden);
      expect(policy.decide(WayKind.cycleway), AccessDecision.allowed);
    });

    test('les règles skate diffèrent des règles piétonnes', () {
      const skate = SkateAccessPolicy();
      const walk = WalkingAccessPolicy();
      expect(
        skate.decide(WayKind.footway),
        isNot(walk.decide(WayKind.footway)),
      );
    });
  });

  group('distance géographique', () {
    test('la distance à soi-même est nulle', () {
      expect(origin0.distanceTo(origin0), 0);
    });

    test('Châtelet → Étoile fait environ 4 km à vol d\'oiseau', () {
      const chatelet = GeoPoint(latitude: 48.8583, longitude: 2.3470);
      const etoile = GeoPoint(latitude: 48.8738, longitude: 2.2950);
      expect(chatelet.distanceTo(etoile), closeTo(4050, 200));
    });
  });
}

const origin0 = GeoPoint(latitude: 48.8566, longitude: 2.3522);
