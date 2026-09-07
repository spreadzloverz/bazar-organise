# GPS NIMBUS

Application Flutter Android, iPhone et Web destinée à comparer des trajets
combinant **skateboard électrique, marche et transports en commun** en
Île-de-France.

Pour chaque recherche, GPS NIMBUS doit toujours distinguer :

- **PLUS RAPIDE** — temps total porte à porte minimal, attente et
  correspondances comprises ;
- **MOINS DE SKATE** — distance skate minimale, puis temps total,
  correspondances et marche.

## État vérifié

Le projet est actuellement un **prototype fonctionnel sur réseau fictif**.

Fonctions testées :

- marche, skate, métro, RER, tram et bus ;
- classements PLUS RAPIDE et MOINS DE SKATE ;
- accueil, résultats et détail étape par étape ;
- prise en compte de durées terrain directionnelles ;
- conservation d'un point d'accès explicitement indiqué ;
- corridors fictifs M6 → M12 et RER C du cas GOLDEN-001 ;
- build Flutter Web reproductible.

Dernier contrôle GitHub Actions :

- format : succès ;
- analyse statique : aucun problème ;
- **95 tests réussis** ;
- build web : succès.

Voir `../docs/STATUS.md` pour la preuve et la matrice complète.

## Ce qui n'est pas encore réel

- Le réseau de transport est simplifié et écrit à la main.
- Les horaires, prochains passages et perturbations IDFM ne sont pas branchés.
- Les distances marche et skate sont estimées à vol d'oiseau avec un facteur
  de détour ; aucun vrai tracé de rue n'est utilisé.
- Le profil skate utilise temporairement certaines règles cyclables comme
  proxy clairement signalé.
- Les positions ajoutées au réseau mock sont approximatives.

Les résultats actuels servent à tester le moteur. Ils ne doivent pas être
présentés comme des conseils de trajet en temps réel.

## Tester le moteur

Depuis ce dossier :

```bash
flutter pub get

# Scénarios de démonstration
dart run tool/nimbus_cli.dart --scenarios

# Une recherche parmi les lieux du catalogue
dart run tool/nimbus_cli.dart "Châtelet" "La Défense" --all

# Lieux disponibles
dart run tool/nimbus_cli.dart --list
```

## Vérifier le projet

```bash
dart format lib test tool
flutter analyze
flutter test
```

La CI exécute aussi un build web. Aucun déploiement public n'est automatique.

## Construire la version Web

```bash
./tool/build_web.sh ../nimbus
```

Le chemin d'hébergement doit être pris en compte lors du build. La CI de ce
lot compile avec la base `/gps-nimbus/` et conserve le résultat comme artefact
de contrôle.

La version Web est un banc d'essai rapide. Elle ne remplace pas les validations
sur Safari iPhone, Android natif et iOS natif.

## Construire les versions natives

```bash
flutter run
flutter build apk --debug
```

Aucun APK n'a été produit dans le dernier contrôle. Un build iOS réel nécessite
un Mac avec Xcode ; aucun build iOS n'est validé à ce stade.

## Architecture

```text
lib/
├── core/          configuration, lieux, mise en forme
├── domain/        modèles, profils, classements et calibration terrain
├── routing/       réseau, recherche de chemin et planificateur
├── data/          adaptateurs OTP / GTFS / OSM non branchés
└── ui/            écrans et widgets

tool/nimbus_cli.dart
```

Documentation :

- `../docs/ARCHITECTURE.md`
- `../docs/GOLDEN_ROUTES.md`
- `../docs/DEPLOYMENT.md`
- `../docs/STATUS.md`

## Réglages de mobilité

| Réglage | Valeur de référence | Fichier |
|---|---:|---|
| Skate | 27 km/h | `lib/core/config/mobility_config.dart` |
| Marche | 5 km/h | `lib/core/config/mobility_config.dart` |

Ces valeurs restent configurables. Une durée terrain compatible peut remplacer
l'estimation générique du tronçon sans effacer cette estimation des
métadonnées.
