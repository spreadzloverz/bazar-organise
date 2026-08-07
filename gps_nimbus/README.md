# GPS NIMBUS

Application mobile Android et iPhone qui calcule des trajets combinant
**skateboard électrique, marche et transports en commun** en Île-de-France.

Pour chaque recherche, GPS NIMBUS propose toujours deux réponses :

- **PLUS RAPIDE** — le temps total le plus court, porte à porte, attente et
  correspondances comprises ;
- **MOINS DE SKATE** — le trajet qui réduit au maximum la distance parcourue
  en skate.

## Ce qui marche aujourd'hui

- Calcul de trajets combinant marche, skate, métro, RER, tram et bus.
- Les deux classements, avec tous leurs cas d'égalité.
- Écran d'accueil, écran de résultats, détail étape par étape.
- 76 tests automatiques.

## Ce qui n'est pas encore réel — et l'application le dit

- **Le réseau de transport est fictif et simplifié** : 43 stations et
  9 lignes écrites à la main. Les horaires réels ne sont pas branchés,
  les temps d'attente sont des moyennes.
- **Les distances marche et skate sont estimées** à vol d'oiseau avec un
  facteur de détour. Aucun tracé de rue réel n'est utilisé.
- **Le trajet en skate s'appuie sur les données cyclables**, faute de
  données spécifiques aux engins de déplacement personnel motorisés.

Ces trois limites sont affichées dans l'application, sous « À SAVOIR ».
Rien n'est présenté comme plus abouti qu'il ne l'est.

## Essayer le moteur sans téléphone

Depuis ce dossier :

```bash
flutter pub get

# Les sept trajets de référence
dart run tool/nimbus_cli.dart --scenarios

# Un trajet précis, avec tous les itinéraires calculés
dart run tool/nimbus_cli.dart "Châtelet" "La Défense" --all

# La liste des lieux disponibles
dart run tool/nimbus_cli.dart --list
```

## Lancer l'application

```bash
flutter run                 # sur un téléphone branché ou un émulateur
flutter build apk --debug   # fabriquer un APK Android
```

Un APK Android **n'a pas encore été produit** : voir `../docs/STATUS.md`,
section « Blocages », pour les étapes à suivre.

Un build iPhone demande un Mac avec Xcode. Le projet iOS est prêt, mais
**aucun build iOS n'a été produit**.

## Vérifier que tout est sain

```bash
dart format lib test tool
flutter analyze
flutter test
```

## Comment c'est construit

```
lib/
├── core/          configuration (vitesses), lieux, mise en forme
├── domain/        le métier : tronçons, itinéraires, profils, classements
├── routing/       réseau de transport, recherche de chemin, planificateur
├── data/          branchements OTP / GTFS / OSM (interfaces, non branchées)
└── ui/            écrans et widgets
tool/nimbus_cli.dart   essayer le moteur sans interface graphique
```

Explications complètes : `../docs/ARCHITECTURE.md`.

## Réglages de mobilité

| Réglage | Valeur | Où |
|---------|--------|-----|
| Vitesse skate | 27 km/h | `lib/core/config/mobility_config.dart` |
| Vitesse marche | 5 km/h | idem |

Ces deux valeurs sont des règles produit : elles ne changent pas sans
décision explicite. Elles restent configurables dans le code.
