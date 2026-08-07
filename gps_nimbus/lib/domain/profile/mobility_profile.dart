import '../../core/config/mobility_config.dart';
import '../model/geo_point.dart';
import '../model/route_segment.dart';
import '../model/segment_type.dart';
import 'access_policy.dart';

/// Un profil de mobilité sait, pour un mode donné :
///  - à quelle vitesse on avance ;
///  - où l'on a le droit de circuler ([AccessPolicy]) ;
///  - comment fabriquer un tronçon cohérent entre deux points.
abstract class MobilityProfile {
  const MobilityProfile();

  SegmentType get segmentType;
  AccessPolicy get accessPolicy;

  /// Vitesse moyenne retenue, en km/h.
  double speedKmh(MobilityConfig config);

  /// Durée nécessaire pour parcourir [distanceMeters].
  Duration durationFor(double distanceMeters, MobilityConfig config) {
    final speed = speedKmh(config);
    if (speed <= 0 || distanceMeters <= 0) return Duration.zero;
    final seconds = (distanceMeters / 1000.0) / speed * 3600.0;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  /// Construit un tronçon entre deux points.
  ///
  /// [distanceMeters] permet de fournir une distance réelle (issue du
  /// routing) ; sans elle, la distance à vol d'oiseau est utilisée.
  RouteSegment buildSegment({
    required GeoPoint origin,
    required GeoPoint destination,
    required MobilityConfig config,
    double? distanceMeters,
    Map<String, Object?> details = const <String, Object?>{},
  }) {
    final distance = distanceMeters ?? origin.distanceTo(destination);
    final mergedDetails = <String, Object?>{
      ...details,
      if (accessPolicy.isProxy) 'proxyNotice': accessPolicy.proxyNotice,
    };
    return RouteSegment(
      type: segmentType,
      origin: origin,
      destination: destination,
      distanceMeters: distance,
      duration: durationFor(distance, config),
      details: mergedDetails,
    );
  }
}

/// Marche de déplacement réel (domicile → station).
class WalkingProfile extends MobilityProfile {
  const WalkingProfile();

  @override
  SegmentType get segmentType => SegmentType.walkingRoute;

  @override
  AccessPolicy get accessPolicy => const WalkingAccessPolicy();

  @override
  double speedKmh(MobilityConfig config) => config.walkingSpeedKmh;
}

/// Marche interne à une correspondance (quai → quai).
class TransferWalkProfile extends MobilityProfile {
  const TransferWalkProfile();

  @override
  SegmentType get segmentType => SegmentType.transferWalk;

  @override
  AccessPolicy get accessPolicy => const WalkingAccessPolicy();

  @override
  double speedKmh(MobilityConfig config) => config.transferWalkSpeedKmh;
}

/// Skateboard électrique.
class SkateProfile extends MobilityProfile {
  const SkateProfile({this.useBicycleProxy = true});

  final bool useBicycleProxy;

  @override
  SegmentType get segmentType => SegmentType.skate;

  @override
  AccessPolicy get accessPolicy =>
      SkateAccessPolicy(useBicycleProxy: useBicycleProxy);

  @override
  double speedKmh(MobilityConfig config) => config.skateSpeedKmh;
}
