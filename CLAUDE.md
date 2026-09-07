# GPS NIMBUS

Application mobile Android + iOS de calcul d'itinéraires multimodaux pour
skateur urbain en Île-de-France.

Le code de l'application vit dans `gps_nimbus/`.
Le reste du dépôt est le site Bazar Organisé : **ne pas y toucher**.

## Objectif

Comparer des trajets porte-à-porte combinant marche, skateboard électrique,
métro, RER, tram et bus, et toujours proposer deux réponses :
**PLUS RAPIDE** et **MOINS DE SKATE**.

## Invariants produit — ne pas modifier sans validation humaine

- Skate : **27 km/h** de référence (`MobilityConfig.defaultSkateSpeedKmh`).
- Marche : **5 km/h** de référence (`MobilityConfig.defaultWalkingSpeedKmh`).
- Les deux vitesses restent configurables via `MobilityConfig`.
- Une durée terrain personnelle compatible peut remplacer l'estimation
  générique du segment ; l'estimation initiale doit rester traçable.
- Un point d'accès explicitement donné reste candidat. Ne jamais remplacer
  silencieusement Ivry-sur-Seine par BFM ou une autre station.
- **PLUS RAPIDE** = temps total porte-à-porte minimal, attentes et
  correspondances comprises.
- **MOINS DE SKATE** = distance skate minimale, puis temps total,
  correspondances et distance à pied.
- Pas d'estimation de batterie : employer « distance skate réduite ».
- Rien de fictif ne doit être présenté comme réel.

## Architecture

```text
UI → DOMAINE → ROUTING → ADAPTATEURS DE DONNÉES
```

- `lib/core` : configuration, lieux, mise en forme
- `lib/domain/model` : segments, itinéraires, points, lignes
- `lib/domain/profile` : profils de mobilité et politiques d'accès
- `lib/domain/ranking` : classements produit
- `lib/domain/calibration` : observations terrain et préférences utilisateur
- `lib/routing` : réseau, recherche, moteur fictif, planificateur
- `lib/data` : adaptateurs OTP / GTFS / OSM non encore branchés
- `assets/fonts` : police embarquée
- `nimbus/` à la racine : ancien artefact web généré, jamais source de vérité

Détails : `docs/ARCHITECTURE.md` et `docs/DEPLOYMENT.md`.

## Commandes

Depuis `gps_nimbus/` :

```bash
flutter pub get
dart format lib test tool
flutter analyze
flutter test

dart run tool/nimbus_cli.dart --scenarios
dart run tool/nimbus_cli.dart "Châtelet" "La Défense" --all

flutter run
flutter build apk --debug
./tool/build_web.sh
```

## Niveaux de réalité

Employer systématiquement :

- `MOCKED` : données ou comportement simulés
- `IMPLEMENTED` : code présent, pas encore validé dans l'environnement courant
- `TESTED` : contrôle automatisé exécuté et traçable
- `DEVICE_TESTED` : vérifié sur un appareil physique identifié
- `LIVE_DATA` : relié à une source réelle et datée
- `PRODUCTION` : publié, surveillé et réversible

Une fenêtre Chromium au format iPhone n'est pas `DEVICE_TESTED`.

## Déploiement verrouillé

- Ne pas utiliser une branche `claude/*` comme source publique GitHub Pages.
- Ne pas modifier les réglages Pages de `bazar-organise`.
- Préparer un dépôt indépendant `spreadzloverz/gps-nimbus` et une CI qui
  construit le web depuis la source après analyse et tests.
- Ne jamais modifier manuellement un build compilé.

## Confidentialité

Le dépôt est public. Ne jamais y committer :

- adresse personnelle exacte ;
- historique privé de trajets ;
- position habituelle identifiable ;
- clé API, token, fichier `.env` ou credential.

Utiliser des identifiants anonymisés dans les tests publics. Les données
privées locales vont dans `gps_nimbus/private_data/` ou `test_private/`,
ignorés par Git.

## Règles de travail

- Le dépôt est la mémoire technique, pas la conversation.
- Avant de déclarer terminé : format, analyse et tests.
- Ne jamais simuler une API réelle. Interface + mock + blocage signalé.
- Toute décision structurante va dans `docs/DECISIONS.md`.
- Mettre `docs/STATUS.md` à jour à la fin de chaque lot.
- Après trois stratégies différentes sans succès, documenter le blocage et
  poursuivre une tâche indépendante.

## Documentation

- `docs/STATUS.md` — état prouvé du projet
- `docs/DEPLOYMENT.md` — stratégie de publication sûre
- `docs/GOLDEN_ROUTES.md` — cas terrain anonymisés
- `docs/ARCHITECTURE.md` — architecture
- `docs/DECISIONS.md` — décisions structurantes
- `docs/BACKLOG.md` — travail restant
- `docs/notebooklm/` — résumés importables dans NotebookLM
- `gps_nimbus/README.md` — prise en main
