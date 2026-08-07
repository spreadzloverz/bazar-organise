import 'geo_point.dart';
import 'route_segment.dart';
import 'segment_type.dart';

/// Un itinéraire complet porte-à-porte, composé de plusieurs tronçons.
///
/// Toutes les grandeurs agrégées (durée, distances, correspondances) sont
/// dérivées des tronçons : il n'existe pas de valeur saisie à la main qui
/// pourrait diverger de la séquence réelle.
class RouteOption {
  RouteOption({required this.id, required List<RouteSegment> segments})
    : segments = List<RouteSegment>.unmodifiable(segments),
      assert(
        segments.isNotEmpty,
        'Un itinéraire doit avoir au moins un tronçon',
      );

  final String id;
  final List<RouteSegment> segments;

  GeoPoint get origin => segments.first.origin;
  GeoPoint get destination => segments.last.destination;

  /// Durée totale porte-à-porte : marche + skate + attente + transport
  /// + correspondances. Aucun temps n'est exclu.
  Duration get totalDuration =>
      segments.fold(Duration.zero, (sum, s) => sum + s.duration);

  /// Distance totale réellement parcourue, tous modes confondus.
  double get totalDistanceMeters =>
      segments.fold(0.0, (sum, s) => sum + s.distanceMeters);

  /// Distance parcourue en skateboard électrique. Critère principal du
  /// classement « MOINS DE SKATE ».
  double get skateDistanceMeters => _distanceWhere((t) => t.isSkate);

  /// Distance parcourue à pied, marche de déplacement et correspondances
  /// à pied confondues.
  double get walkDistanceMeters => _distanceWhere((t) => t.isWalking);

  /// Marche de déplacement seule (hors correspondances).
  double get walkingRouteDistanceMeters =>
      _distanceWhere((t) => t == SegmentType.walkingRoute);

  /// Marche de correspondance seule.
  double get transferWalkDistanceMeters =>
      _distanceWhere((t) => t == SegmentType.transferWalk);

  /// Distance parcourue en transport en commun.
  double get transitDistanceMeters => _distanceWhere((t) => t.isTransit);

  /// Temps passé à bord des transports en commun (hors attente et
  /// hors correspondances).
  Duration get transitDuration => _durationWhere((t) => t.isTransit);

  Duration get skateDuration => _durationWhere((t) => t.isSkate);
  Duration get walkDuration => _durationWhere((t) => t.isWalking);

  /// Temps d'attente cumulé (quais, arrêts de bus).
  Duration get waitingDuration => _durationWhere((t) => t.isWaiting);

  /// Nombre de tronçons de transport en commun empruntés.
  int get transitLegCount => segments.where((s) => s.type.isTransit).length;

  /// Nombre de correspondances : un changement de véhicule entre deux
  /// tronçons de transport. Trois transports enchaînés = 2 correspondances.
  int get transferCount => transitLegCount == 0 ? 0 : transitLegCount - 1;

  /// Vrai si l'itinéraire n'utilise aucun transport en commun.
  bool get isDirectMode => transitLegCount == 0;

  /// Lignes empruntées, dans l'ordre.
  List<String> get lineNames => segments
      .where((s) => s.type.isTransit && s.line != null)
      .map((s) => s.line!.displayName)
      .toList(growable: false);

  /// Séquence lisible du trajet : « SKATE → RER → MARCHE ».
  ///
  /// Les répétitions consécutives d'un même mode sont fusionnées, et
  /// l'attente est omise (elle est déjà comptée dans la durée totale).
  String get sequenceLabel => sequenceSteps.join(' → ');

  List<String> get sequenceSteps {
    final steps = <String>[];
    for (final segment in segments) {
      if (segment.type.isWaiting) continue;
      final label = segment.type.shortLabel;
      if (steps.isNotEmpty && steps.last == label) continue;
      steps.add(label);
    }
    return steps;
  }

  double _distanceWhere(bool Function(SegmentType) predicate) => segments
      .where((s) => predicate(s.type))
      .fold(0.0, (sum, s) => sum + s.distanceMeters);

  Duration _durationWhere(bool Function(SegmentType) predicate) => segments
      .where((s) => predicate(s.type))
      .fold(Duration.zero, (sum, s) => sum + s.duration);

  @override
  String toString() =>
      '$id [$sequenceLabel] ${totalDuration.inMinutes}min '
      'skate=${skateDistanceMeters.round()}m marche=${walkDistanceMeters.round()}m';
}
