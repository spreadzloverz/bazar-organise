# GPS NIMBUS

Application Flutter Android, iOS et Web de comparaison de trajets multimodaux
pour un skateur urbain en Île-de-France.

## Invariants produit

- Modes : marche, skate électrique, métro, RER, tram et bus.
- Vitesse skate de référence : 27 km/h.
- Vitesse marche de référence : 5 km/h.
- Résultats obligatoires : PLUS RAPIDE et MOINS DE SKATE.
- Une mesure terrain compatible peut remplacer une estimation générique ;
  l'estimation initiale reste traçable.
- Un point d'accès explicitement donné reste candidat.
- Ivry-sur-Seine ne doit jamais être remplacé silencieusement par BFM.
- Aucun résultat fictif ne doit être présenté comme réel.

## Architecture

```text
UI → DOMAINE → ROUTING → ADAPTATEURS DE DONNÉES
```

- `lib/core` : configuration et utilitaires
- `lib/domain/model` : points, segments, lignes et itinéraires
- `lib/domain/profile` : profils de mobilité et accès
- `lib/domain/ranking` : classements
- `lib/domain/calibration` : observations terrain
- `lib/routing` : recherche d'itinéraires et réseau mock
- `lib/data` : futurs adaptateurs IDFM, OTP et OSM
- `test` : tests unitaires et fonctionnels
- `docs` : architecture, décisions, état et backlog

## Commandes obligatoires

```bash
flutter pub get
dart format lib test tool
flutter analyze
flutter test
flutter build web --release --base-href /gps-nimbus/
```

## Niveaux de réalité

- `MOCKED` : simulé
- `IMPLEMENTED` : code présent mais non encore validé
- `TESTED` : contrôle automatisé exécuté
- `DEVICE_TESTED` : vérifié sur un appareil physique identifié
- `LIVE_DATA` : relié à une source réelle et datée
- `PRODUCTION` : publié, surveillé et réversible

Une fenêtre Chromium redimensionnée n'est pas un test iPhone physique.

## Confidentialité

Ne jamais committer : adresse personnelle exacte, historique privé de trajet,
position habituelle identifiable, clé API, token, fichier `.env` ou credential.
Les données locales restent dans `private_data/` ou `test_private/`, ignorés
par Git.

## Autonomie

- Décider seul des choix techniques réversibles, gratuits et sans impact
  produit.
- Documenter toute décision structurante dans `docs/DECISIONS.md`.
- Ne pas ajouter de service payant, publier, fusionner ou exposer un secret
  sans validation.
- Ne jamais simuler une API réelle : interface + mock + limite documentée.
- Après toute modification : format, analyse, tests ciblés puis suite complète.
- Après trois stratégies différentes sans succès, documenter le blocage et
  poursuivre une tâche indépendante.
- Mettre `docs/STATUS.md` et `docs/BACKLOG.md` à jour à la fin d'un lot.

## Source de vérité

Le code et les tests du dépôt font foi. Une déclaration dans la conversation
ne vaut pas preuve sans log, test, artefact ou essai appareil correspondant.
