import 'package:gps_nimbus/core/config/mobility_config.dart';
import 'package:gps_nimbus/domain/model/geo_point.dart';
import 'package:gps_nimbus/domain/model/route_option.dart';
import 'package:gps_nimbus/domain/model/route_segment.dart';
import 'package:gps_nimbus/domain/model/segment_type.dart';
import 'package:gps_nimbus/domain/model/transit_line.dart';

/// Point neutre : les tests de classement raisonnent sur des distances et
/// des durées imposées, pas sur des coordonnées.
const anywhere = GeoPoint(latitude: 48.8566, longitude: 2.3522);

/// Tronçon à distance et durée imposées, pour tester le classement.
RouteSegment seg(
  SegmentType type, {
  double meters = 0,
  int minutes = 0,
  TransitLine? line,
}) {
  return RouteSegment(
    type: type,
    origin: anywhere,
    destination: anywhere,
    distanceMeters: meters,
    duration: Duration(minutes: minutes),
    line: line,
  );
}

RouteOption option(String id, List<RouteSegment> segments) =>
    RouteOption(id: id, segments: segments);

const metro1 = TransitLine(name: '1', mode: SegmentType.metro);
const metro4 = TransitLine(name: '4', mode: SegmentType.metro);
const rerA = TransitLine(name: 'A', mode: SegmentType.rer);
const tramT3 = TransitLine(name: 'T3a', mode: SegmentType.tram);
const bus91 = TransitLine(name: '91', mode: SegmentType.bus);

const testConfig = MobilityConfig.defaults;
