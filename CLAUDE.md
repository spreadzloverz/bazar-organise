# GPS NIMBUS

Application mobile (Android + iOS) de calcul d'itinéraires multimodaux pour
skateur urbain en Île-de-France.

Le code de l'application vit dans `gps_nimbus/`.
Le reste du dépôt est le site web Bazar Organise : **ne pas y toucher**.

## Objectif

Comparer des trajets porte-à-porte combinant marche, skateboard électrique,
métro, RER, tram et bus, et toujours proposer deux réponses :
**PLUS RAPIDE** et **MOINS DE SKATE**.

## Invariants produit — ne pas modifier sans validation humaine

- Skate : **27 km/h** de moyenne (`MobilityConfig.defaultSkateSpeedKmh`)
- Marche : **5 km/h** de moyenne (`MobilityConfig.defaultWalkingSpeedKmh`)
- Les deux vitesses restent **configurables** via `MobilityConfig`.
- **PLUS RAPIDE** = temps total porte-à-porte minimal (skate + marche +
  attente + transport + correspondances inclus).
  Départages : correspondances, distance skate, distance marche.
- **MOINS DE SKATE** = distance skate minimale.
  Départages : temps total, correspondances, distance à pied.
- Pas d'estimation de batterie. On dit « distance skate réduite ».
- Rien de fictif ne doit être présenté comme réel : le réseau simplifié et
  l'approximation skate/vélo sont affichés dans l'application.

## Architecture

```
UI (lib/ui)  →  DOMAINE (lib/domain)  →  ROUTING (lib/routing)  →  DONNÉES (lib/data)
```

- `lib/core` : configuration, lieux, mise en forme
- `lib/domain/model` : `RouteSegment`, `RouteOption`, `GeoPoint`, `TransitLine`
- `lib/domain/profile` : profils de mobilité + politiques d'accès
- `lib/domain/ranking` : les deux classements produit
- `lib/routing` : réseau de transport, recherche, moteur fictif, planificateur
- `lib/data` : branchements OTP / GTFS / OSM (interfaces prêtes, non branchées)

Détails : `docs/ARCHITECTURE.md`.

## Commandes

Depuis `gps_nimbus/` :

```bash
flutter pub get
flutter analyze
flutter test
dart format lib test tool

# Essayer le moteur sans interface graphique
dart run tool/nimbus_cli.dart --scenarios
dart run tool/nimbus_cli.dart "Châtelet" "La Défense" --all
dart run tool/nimbus_cli.dart --list

# Applications
flutter run
flutter build apk --debug
```

## Règles de travail

- Le dépôt est la mémoire du projet, pas la conversation.
- Avant de déclarer terminé : `dart format`, `flutter analyze`, `flutter test`.
- Ne jamais simuler une API réelle. Interface + mock + dépendance signalée.
- Toute décision structurante va dans `docs/DECISIONS.md`.
- Mettre `docs/STATUS.md` à jour à la fin de chaque lot.

## Documentation

- `docs/STATUS.md` — où en est le projet
- `docs/ARCHITECTURE.md` — comment c'est construit
- `docs/DECISIONS.md` — décisions structurantes et pourquoi
- `docs/BACKLOG.md` — ce qu'il reste à faire
- `docs/notebooklm/` — résumés courts importables dans NotebookLM
- `gps_nimbus/README.md` — prise en main
