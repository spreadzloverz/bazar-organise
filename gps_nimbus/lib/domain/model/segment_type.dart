/// Nature d'un tronçon de trajet.
///
/// La marche est volontairement scindée en deux types distincts
/// (cf. règle produit « profil piéton ») :
///  - [walkingRoute] : marche de déplacement réel (domicile → station) ;
///  - [transferWalk] : marche interne à une correspondance (quai → quai).
/// Ils pourront recevoir des vitesses ou des pénalités différentes.
enum SegmentType {
  walkingRoute,
  transferWalk,
  skate,
  metro,
  rer,
  tram,
  bus,
  waiting;

  /// Vrai pour les tronçons effectués à pied, quelle qu'en soit la raison.
  bool get isWalking =>
      this == SegmentType.walkingRoute || this == SegmentType.transferWalk;

  /// Vrai pour les tronçons en transport en commun.
  bool get isTransit =>
      this == SegmentType.metro ||
      this == SegmentType.rer ||
      this == SegmentType.tram ||
      this == SegmentType.bus;

  /// Vrai pour les tronçons parcourus en skateboard électrique.
  bool get isSkate => this == SegmentType.skate;

  /// Vrai lorsque le tronçon ne fait pas avancer (attente sur un quai).
  bool get isWaiting => this == SegmentType.waiting;

  /// Libellé court affiché dans la séquence du trajet (« SKATE → RER → MARCHE »).
  String get shortLabel {
    switch (this) {
      case SegmentType.walkingRoute:
      case SegmentType.transferWalk:
        return 'MARCHE';
      case SegmentType.skate:
        return 'SKATE';
      case SegmentType.metro:
        return 'MÉTRO';
      case SegmentType.rer:
        return 'RER';
      case SegmentType.tram:
        return 'TRAM';
      case SegmentType.bus:
        return 'BUS';
      case SegmentType.waiting:
        return 'ATTENTE';
    }
  }

  /// Libellé détaillé pour l'écran de résultats.
  String get longLabel {
    switch (this) {
      case SegmentType.walkingRoute:
        return 'Marche';
      case SegmentType.transferWalk:
        return 'Correspondance à pied';
      case SegmentType.skate:
        return 'Skateboard électrique';
      case SegmentType.metro:
        return 'Métro';
      case SegmentType.rer:
        return 'RER';
      case SegmentType.tram:
        return 'Tramway';
      case SegmentType.bus:
        return 'Bus';
      case SegmentType.waiting:
        return 'Attente';
    }
  }
}
