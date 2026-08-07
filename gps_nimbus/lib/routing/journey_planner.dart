import '../domain/ranking/route_ranker.dart';
import 'routing_service.dart';

/// Réponse complète présentée à l'interface.
class JourneyResult {
  const JourneyResult({
    required this.ranked,
    required this.notices,
    required this.usesMockData,
  });

  final RankedRoutes ranked;

  /// Avertissements à afficher tels quels (données fictives, approximations).
  final List<String> notices;

  /// Vrai si tout ou partie du résultat provient de données fictives.
  final bool usesMockData;

  bool get isEmpty => ranked.isEmpty;
}

/// Point d'entrée du moteur : cherche les itinéraires puis les classe.
///
/// L'interface graphique ne connaît que cette classe ; changer de source
/// de données ne change rien à l'écran de résultats.
class JourneyPlanner {
  const JourneyPlanner({
    required this.routingService,
    this.ranker = const RouteRanker(),
  });

  final RoutingService routingService;
  final RouteRanker ranker;

  Future<JourneyResult> plan(RouteRequest request) async {
    final search = await routingService.findRoutes(request);
    return JourneyResult(
      ranked: ranker.rank(search.routes),
      notices: search.notices,
      usesMockData: routingService.isMock,
    );
  }
}
