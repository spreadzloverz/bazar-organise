import '../model/route_option.dart';

/// Les deux classements obligatoires de GPS NIMBUS.
enum RankingCriteria {
  /// Minimise le temps total porte-à-porte.
  fastest,

  /// Minimise en priorité la distance parcourue en skateboard.
  leastSkate;

  String get title {
    switch (this) {
      case RankingCriteria.fastest:
        return 'PLUS RAPIDE';
      case RankingCriteria.leastSkate:
        return 'MOINS DE SKATE';
    }
  }

  String get explanation {
    switch (this) {
      case RankingCriteria.fastest:
        return 'Temps total le plus court, attente et correspondances comprises.';
      case RankingCriteria.leastSkate:
        return 'Distance skate réduite au minimum.';
    }
  }
}

/// Comparateurs correspondant à chaque critère.
///
/// Les départages sont figés par les règles produit :
///
/// PLUS RAPIDE   : durée totale, puis correspondances, puis distance skate,
///                 puis distance à pied.
/// MOINS DE SKATE: distance skate, puis durée totale, puis correspondances,
///                 puis distance à pied.
class RouteComparators {
  const RouteComparators._();

  /// Tolérance de comparaison des distances, en mètres. En dessous, deux
  /// itinéraires sont considérés à égalité : une différence de quelques
  /// mètres n'a aucun sens sur un trajet réel.
  static const double distanceEpsilonMeters = 1.0;

  static int Function(RouteOption, RouteOption) forCriteria(
    RankingCriteria criteria,
  ) {
    switch (criteria) {
      case RankingCriteria.fastest:
        return fastest;
      case RankingCriteria.leastSkate:
        return leastSkate;
    }
  }

  static int fastest(RouteOption a, RouteOption b) {
    final byDuration = a.totalDuration.compareTo(b.totalDuration);
    if (byDuration != 0) return byDuration;

    final byTransfers = a.transferCount.compareTo(b.transferCount);
    if (byTransfers != 0) return byTransfers;

    final bySkate = _compareDistance(
      a.skateDistanceMeters,
      b.skateDistanceMeters,
    );
    if (bySkate != 0) return bySkate;

    final byWalk = _compareDistance(a.walkDistanceMeters, b.walkDistanceMeters);
    if (byWalk != 0) return byWalk;

    return a.id.compareTo(b.id);
  }

  static int leastSkate(RouteOption a, RouteOption b) {
    final bySkate = _compareDistance(
      a.skateDistanceMeters,
      b.skateDistanceMeters,
    );
    if (bySkate != 0) return bySkate;

    final byDuration = a.totalDuration.compareTo(b.totalDuration);
    if (byDuration != 0) return byDuration;

    final byTransfers = a.transferCount.compareTo(b.transferCount);
    if (byTransfers != 0) return byTransfers;

    final byWalk = _compareDistance(a.walkDistanceMeters, b.walkDistanceMeters);
    if (byWalk != 0) return byWalk;

    return a.id.compareTo(b.id);
  }

  static int _compareDistance(double a, double b) {
    if ((a - b).abs() < distanceEpsilonMeters) return 0;
    return a.compareTo(b);
  }
}
