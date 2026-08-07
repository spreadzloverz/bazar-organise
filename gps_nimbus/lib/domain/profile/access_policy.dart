/// Nature du support sur lequel on circule, tel qu'il ressort des données
/// routières (OSM à terme).
enum WayKind {
  footway,
  cycleway,
  residentialStreet,
  mainRoad,
  expressway,
  pedestrianZone,
  stairs,
  unknown,
}

/// Décision d'accès pour un mode donné sur un type de voie donné.
enum AccessDecision { allowed, discouraged, forbidden }

/// Politique d'accès : « ce mode a-t-il le droit d'emprunter cette voie ? »
///
/// Cette couche est volontairement séparée du profil de mobilité (vitesse,
/// coût) afin que le skateboard électrique ne soit pas réduit à un alias
/// permanent du vélo : quand de vraies règles skate seront disponibles,
/// seule cette classe change.
abstract class AccessPolicy {
  const AccessPolicy();

  AccessDecision decide(WayKind way);

  /// Vrai si la politique s'appuie encore sur des données/règles empruntées
  /// à un autre mode (proxy). Doit être affiché honnêtement dans l'app.
  bool get isProxy => false;

  /// Explication courte du proxy, à afficher quand [isProxy] est vrai.
  String? get proxyNotice => null;
}

/// Politique piétonne.
class WalkingAccessPolicy extends AccessPolicy {
  const WalkingAccessPolicy();

  @override
  AccessDecision decide(WayKind way) {
    switch (way) {
      case WayKind.footway:
      case WayKind.pedestrianZone:
      case WayKind.residentialStreet:
      case WayKind.stairs:
        return AccessDecision.allowed;
      case WayKind.mainRoad:
      case WayKind.cycleway:
      case WayKind.unknown:
        return AccessDecision.discouraged;
      case WayKind.expressway:
        return AccessDecision.forbidden;
    }
  }
}

/// Politique skateboard électrique.
///
/// MVP : les règles s'inspirent de l'infrastructure cyclable, faute de
/// données spécifiques aux EDPM en Île-de-France. C'est un PROXY assumé,
/// isolé ici et remplaçable sans toucher au moteur.
class SkateAccessPolicy extends AccessPolicy {
  const SkateAccessPolicy({this.useBicycleProxy = true});

  /// Quand vrai, l'infrastructure cyclable sert de substitut aux données
  /// skate manquantes.
  final bool useBicycleProxy;

  @override
  AccessDecision decide(WayKind way) {
    switch (way) {
      case WayKind.cycleway:
        return AccessDecision.allowed;
      case WayKind.residentialStreet:
        return AccessDecision.allowed;
      case WayKind.pedestrianZone:
        // Circulation tolérée mais à vitesse très réduite : à éviter.
        return AccessDecision.discouraged;
      case WayKind.mainRoad:
        return AccessDecision.discouraged;
      case WayKind.footway:
      case WayKind.stairs:
      case WayKind.expressway:
        return AccessDecision.forbidden;
      case WayKind.unknown:
        return AccessDecision.discouraged;
    }
  }

  @override
  bool get isProxy => useBicycleProxy;

  @override
  String? get proxyNotice => useBicycleProxy
      ? 'Itinéraire skate estimé à partir des données cyclables : '
            'aucune donnée spécifique aux engins de déplacement personnel '
            'motorisés n\'est encore disponible.'
      : null;
}
