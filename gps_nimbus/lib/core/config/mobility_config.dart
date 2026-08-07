/// Valeurs de mobilité utilisées par le moteur.
///
/// INVARIANTS PRODUIT (MVP) : skate 27 km/h, marche 5 km/h.
/// Les valeurs restent configurables (préférences utilisateur, tests,
/// calibrage futur) mais les valeurs par défaut ne changent pas sans
/// validation humaine.
class MobilityConfig {
  const MobilityConfig({
    this.skateSpeedKmh = defaultSkateSpeedKmh,
    this.walkingSpeedKmh = defaultWalkingSpeedKmh,
    this.transferWalkSpeedKmh = defaultTransferWalkSpeedKmh,
    this.maxSkateDistanceMeters,
  }) : assert(skateSpeedKmh > 0),
       assert(walkingSpeedKmh > 0),
       assert(transferWalkSpeedKmh > 0);

  /// Vitesse moyenne du skateboard électrique — invariant produit MVP.
  static const double defaultSkateSpeedKmh = 27.0;

  /// Vitesse moyenne de marche — invariant produit MVP.
  static const double defaultWalkingSpeedKmh = 5.0;

  /// Marche de correspondance : même vitesse que la marche normale au MVP.
  /// Le champ existe séparément pour pouvoir la ralentir plus tard
  /// (couloirs, escaliers, foule) sans toucher au reste du moteur.
  static const double defaultTransferWalkSpeedKmh = defaultWalkingSpeedKmh;

  final double skateSpeedKmh;
  final double walkingSpeedKmh;
  final double transferWalkSpeedKmh;

  /// Limite optionnelle de distance en skate sur un itinéraire.
  /// `null` = pas de limite. Ce n'est PAS une estimation de batterie :
  /// tant qu'aucun modèle énergétique fiable n'existe, GPS NIMBUS
  /// ne parle que de « distance skate réduite ».
  final double? maxSkateDistanceMeters;

  static const MobilityConfig defaults = MobilityConfig();

  MobilityConfig copyWith({
    double? skateSpeedKmh,
    double? walkingSpeedKmh,
    double? transferWalkSpeedKmh,
    double? maxSkateDistanceMeters,
  }) {
    return MobilityConfig(
      skateSpeedKmh: skateSpeedKmh ?? this.skateSpeedKmh,
      walkingSpeedKmh: walkingSpeedKmh ?? this.walkingSpeedKmh,
      transferWalkSpeedKmh: transferWalkSpeedKmh ?? this.transferWalkSpeedKmh,
      maxSkateDistanceMeters:
          maxSkateDistanceMeters ?? this.maxSkateDistanceMeters,
    );
  }
}
