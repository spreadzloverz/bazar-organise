import 'segment_type.dart';

/// Une ligne de transport en commun (métro 1, RER A, tram T3a, bus 91…).
class TransitLine {
  const TransitLine({
    required this.name,
    required this.mode,
    this.direction = '',
    this.operator = '',
  });

  /// Nom court affiché : « 1 », « A », « T3a », « 91 ».
  final String name;

  /// Mode associé ; doit être un [SegmentType] de transport.
  final SegmentType mode;

  /// Direction / terminus, si connu.
  final String direction;

  /// Exploitant (RATP, SNCF…), si connu.
  final String operator;

  /// Libellé complet : « RER A », « MÉTRO 1 ».
  String get displayName => '${mode.shortLabel} $name';

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      other is TransitLine &&
      other.name == name &&
      other.mode == mode &&
      other.direction == direction &&
      other.operator == operator;

  @override
  int get hashCode => Object.hash(name, mode, direction, operator);
}
