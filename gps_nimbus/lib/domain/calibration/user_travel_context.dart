import '../model/segment_type.dart';

/// Origine d'une durée utilisée par GPS NIMBUS.
///
/// L'ordre de priorité est volontairement explicite : une mesure terrain
/// personnelle doit pouvoir remplacer une estimation générique, sans donner
/// une fausse précision aux données moins fiables.
enum TravelEvidenceSource {
  userMeasured,
  realtime,
  userHistory,
  routingNetwork,
  scheduled,
  genericEstimate;

  int get priority {
    switch (this) {
      case TravelEvidenceSource.userMeasured:
        return 60;
      case TravelEvidenceSource.realtime:
        return 50;
      case TravelEvidenceSource.userHistory:
        return 40;
      case TravelEvidenceSource.routingNetwork:
        return 30;
      case TravelEvidenceSource.scheduled:
        return 20;
      case TravelEvidenceSource.genericEstimate:
        return 10;
    }
  }
}

/// Observation directionnelle d'un tronçon connu par l'utilisateur.
///
/// Les libellés sont utilisés tant que le géocodage réel n'est pas branché.
/// Une observation A → B ne s'applique jamais automatiquement à B → A.
class ObservedSegment {
  const ObservedSegment({
    required this.originLabel,
    required this.destinationLabel,
    required this.mode,
    required this.minDuration,
    required this.maxDuration,
    this.observationCount = 1,
    this.lastObservedAt,
    this.source = TravelEvidenceSource.userMeasured,
  }) : assert(observationCount > 0);

  final String originLabel;
  final String destinationLabel;
  final SegmentType mode;
  final Duration minDuration;
  final Duration maxDuration;
  final int observationCount;
  final DateTime? lastObservedAt;
  final TravelEvidenceSource source;

  /// Valeur neutre utilisée tant qu'une médiane réelle n'est pas disponible.
  /// La plage min/max reste conservée et pourra être exploitée ultérieurement.
  Duration get representativeDuration {
    final low = minDuration.inMilliseconds;
    final high = maxDuration.inMilliseconds;
    if (high <= low) return minDuration;
    return Duration(milliseconds: low + ((high - low) / 2).round());
  }

  bool matches({
    required String originLabel,
    required String destinationLabel,
    required SegmentType mode,
  }) {
    return this.mode == mode &&
        _normalize(this.originLabel) == _normalize(originLabel) &&
        _normalize(this.destinationLabel) == _normalize(destinationLabel);
  }
}

/// Données personnelles facultatives qui influencent une recherche.
///
/// Elles ne sont jamais obligatoires : sans contexte utilisateur, le moteur
/// conserve son comportement générique actuel.
class UserTravelContext {
  const UserTravelContext({
    this.observedSegments = const <ObservedSegment>[],
    this.protectedBoardingLabels = const <String>[],
    this.protectedAlightingLabels = const <String>[],
  });

  static const empty = UserTravelContext();

  final List<ObservedSegment> observedSegments;

  /// Points d'accès explicitement donnés par l'utilisateur. Ils doivent être
  /// ajoutés aux candidats, même s'ils ne font pas partie des plus proches.
  final List<String> protectedBoardingLabels;

  /// Points de sortie explicitement donnés par l'utilisateur.
  final List<String> protectedAlightingLabels;

  ObservedSegment? bestObservationFor({
    required String originLabel,
    required String destinationLabel,
    required SegmentType mode,
  }) {
    final matches = observedSegments
        .where(
          (observation) => observation.matches(
            originLabel: originLabel,
            destinationLabel: destinationLabel,
            mode: mode,
          ),
        )
        .toList(growable: false);

    if (matches.isEmpty) return null;

    matches.sort((a, b) {
      final sourceOrder = b.source.priority.compareTo(a.source.priority);
      if (sourceOrder != 0) return sourceOrder;

      final countOrder = b.observationCount.compareTo(a.observationCount);
      if (countOrder != 0) return countOrder;

      final aDate = a.lastObservedAt?.millisecondsSinceEpoch ?? -1;
      final bDate = b.lastObservedAt?.millisecondsSinceEpoch ?? -1;
      return bDate.compareTo(aDate);
    });

    return matches.first;
  }

  bool protectsBoarding(String label) => protectedBoardingLabels.any(
    (value) => _normalize(value) == _normalize(label),
  );

  bool protectsAlighting(String label) => protectedAlightingLabels.any(
    (value) => _normalize(value) == _normalize(label),
  );
}

String _normalize(String value) {
  const accents = 'àâäéèêëîïôöùûüçÀÂÄÉÈÊËÎÏÔÖÙÛÜÇ';
  const plain = 'aaaeeeeiioouuucAAAEEEEIIOOUUUC';
  final buffer = StringBuffer();
  for (final rune in value.trim().toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = accents.indexOf(char);
    buffer.write(index >= 0 ? plain[index].toLowerCase() : char);
  }
  return buffer.toString();
}
