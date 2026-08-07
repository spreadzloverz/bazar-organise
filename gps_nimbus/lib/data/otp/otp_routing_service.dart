import '../../routing/routing_service.dart';

/// Configuration d'un serveur OpenTripPlanner.
///
/// Aucune valeur par défaut n'est fournie : GPS NIMBUS ne se connecte pas
/// à un serveur tiers sans que ce soit demandé explicitement.
class OtpConfig {
  const OtpConfig({required this.baseUrl, this.routerId = 'default'});

  /// Racine de l'API, par exemple `https://exemple.org/otp`.
  final String baseUrl;

  final String routerId;

  bool get isValid => baseUrl.trim().isNotEmpty;
}

/// Adaptateur OpenTripPlanner.
///
/// L'interface est prête ; l'appel réseau ne sera écrit que lorsqu'un
/// serveur sera effectivement disponible. En attendant, ce service refuse
/// clairement de répondre au lieu d'inventer un itinéraire : c'est une
/// règle produit, pas une limitation temporaire de l'implémentation.
class OtpRoutingService implements RoutingService {
  const OtpRoutingService({this.config});

  final OtpConfig? config;

  @override
  String get name => 'otp';

  @override
  bool get isMock => false;

  /// Vrai uniquement lorsqu'un serveur a été renseigné.
  bool get isConfigured => config?.isValid ?? false;

  /// Ce qui manque pour activer cette source.
  static const String setupRequirement =
      'Un serveur OpenTripPlanner alimenté par les données GTFS '
      'd\'Île-de-France Mobilités doit être disponible, et son adresse '
      'renseignée dans OtpConfig.';

  @override
  Future<RouteSearchResult> findRoutes(RouteRequest request) async {
    if (!isConfigured) {
      throw const RoutingUnavailable('otp', setupRequirement);
    }
    throw const RoutingUnavailable(
      'otp',
      'L\'appel au serveur OpenTripPlanner n\'est pas encore implémenté. '
          'Aucune réponse n\'est inventée.',
    );
  }
}
