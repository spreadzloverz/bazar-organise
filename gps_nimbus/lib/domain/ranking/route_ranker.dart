import '../model/route_option.dart';
import 'ranking_criteria.dart';

/// Résultat complet d'une recherche : les itinéraires trouvés, classés
/// selon chacun des critères obligatoires.
class RankedRoutes {
  const RankedRoutes({required this.all, required this.byCriteria});

  /// Tous les itinéraires trouvés, sans ordre garanti.
  final List<RouteOption> all;

  /// Classement complet pour chaque critère.
  final Map<RankingCriteria, List<RouteOption>> byCriteria;

  bool get isEmpty => all.isEmpty;

  List<RouteOption> ranked(RankingCriteria criteria) =>
      byCriteria[criteria] ?? const <RouteOption>[];

  /// Meilleur itinéraire pour un critère, ou `null` si aucun résultat.
  RouteOption? best(RankingCriteria criteria) {
    final list = ranked(criteria);
    return list.isEmpty ? null : list.first;
  }

  RouteOption? get fastest => best(RankingCriteria.fastest);
  RouteOption? get leastSkate => best(RankingCriteria.leastSkate);

  /// Vrai si les deux recommandations désignent le même itinéraire.
  bool get recommendationsAreIdentical =>
      fastest != null && leastSkate != null && identical(fastest, leastSkate);
}

/// Applique les classements produit à un ensemble d'itinéraires.
class RouteRanker {
  const RouteRanker();

  RankedRoutes rank(List<RouteOption> routes) {
    final all = List<RouteOption>.unmodifiable(routes);
    final byCriteria = <RankingCriteria, List<RouteOption>>{};

    for (final criteria in RankingCriteria.values) {
      final sorted = List<RouteOption>.of(routes)
        ..sort(RouteComparators.forCriteria(criteria));
      byCriteria[criteria] = List<RouteOption>.unmodifiable(sorted);
    }

    return RankedRoutes(all: all, byCriteria: byCriteria);
  }
}
