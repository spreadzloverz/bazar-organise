# STATUS — GPS NIMBUS

Dernière mise à jour : 2026-09-07
Branche : `gps-nimbus/hardening-v1`
Commit contrôlé : `8a56b4cc9b33ee375f4d4e8107825a747b427388`

## Verdict actuel

GPS NIMBUS est un **prototype Flutter fonctionnel sur données fictives**.
Le moteur, les classements, la calibration terrain et les corridors de test
Alfortville → Issy sont validés automatiquement. Les rues, horaires et
perturbations réels ne sont pas encore branchés.

## Contrôle automatique

GitHub Actions, run `34142788873` :

- format : succès ;
- analyse statique : succès ;
- tests : **95 réussis** ;
- build Flutter Web : succès ;
- contrôle de confidentialité du paquet : succès ;
- paquet autonome : succès ;
- déploiement public : non effectué.

Artefacts :

- Web : `10026555789`, 14 684 408 octets, expiration 2026-09-14 ;
- dépôt autonome : `10026556285`, 810 840 octets, expiration 2026-09-21 ;
- empreinte du paquet autonome :
  `sha256:aa3f09a997914e5b5e0e8d22a301d7cf02d5d010584f45c8b85012aebdb7d64d`.

## Matrice de réalité

| Élément | Statut | Limite |
|---|---|---|
| Marche 5 km/h | TESTED | Valeur générique |
| Skate 27 km/h | TESTED | Valeur générique |
| PLUS RAPIDE | TESTED | Candidats et temps mockés |
| MOINS DE SKATE | TESTED | Distance skate comme proxy batterie |
| Métro, RER, tram, bus | TESTED / MOCKED | Réseau simplifié |
| Calibration par temps terrain | TESTED | Correspondance actuelle par libellés |
| Point d'accès explicite conservé | TESTED | Doit être présent dans le réseau chargé |
| Ivry distinct de BFM | TESTED | Régression couverte |
| M6 Quai de la Gare → Pasteur | TESTED / MOCKED | Tracé et temps simplifiés |
| M12 Pasteur → Mairie d'Issy | TESTED / MOCKED | Tracé et temps simplifiés |
| RER C Ivry → Issy–Val de Seine | TESTED / MOCKED | Tracé et temps simplifiés |
| GOLDEN-001 | PARTIALLY TESTED / MOCKED | Points de test anonymisés et synthétiques |
| GTFS IDFM | NOT IMPLEMENTED | Aucun horaire réel |
| Temps réel et perturbations | NOT IMPLEMENTED | Aucune source live |
| Réseau de rues OSM | NOT IMPLEMENTED | Distances approximatives |
| Road Intelligence | PLANNED | Aucun coefficient arbitraire activé |
| Build web CI | TESTED | Non publié |
| Paquet autonome reproductible | TESTED | Nouveau dépôt non encore créé |
| Safari sur iPhone | NOT DEVICE_TESTED | Appareil physique nécessaire |
| APK Android | NOT BUILT | Non produit dans ce lot |
| Build iOS | NOT BUILT | Mac et Xcode nécessaires |
| Production | NOT PRODUCTION | Données réelles et essais terrain manquants |

## Réalisé

- Travail isolé de la branche principale du portfolio.
- Aucun réglage GitHub Pages modifié.
- Déploiement depuis une branche Claude interdit par la documentation.
- Pull request de revue ouverte en brouillon vers la branche Claude.
- CI sans permission de publication ajoutée.
- Modèle directionnel `ObservedSegment` ajouté.
- Hiérarchie des sources temporelles ajoutée.
- Durée terrain appliquée aux tronçons marche/skate compatibles.
- Plage 7–10 minutes conservée avec bornes et valeur représentative.
- Stations explicites ajoutées aux candidats au lieu d'être remplacées.
- Signalement d'une station absente conservé.
- Quai de la Gare, Pasteur, Mairie d'Issy, Ivry-sur-Seine et
  Issy–Val de Seine ajoutés au réseau de test.
- Corridors M6, M12 et RER C ajoutés et testés.
- Deux défauts découverts par les contrôles puis corrigés : liste de candidats
  non extensible et test d'absence devenu obsolète après l'ajout d'Ivry.
- Build web reconstruit depuis les sources.
- Paquet autonome créé avec règles Claude, documentation, CI racine,
  guide de migration, provenance et manifeste SHA-256.
- Le script de paquetage exclut caches, builds, données locales, fichiers de
  signature et secrets, puis bloque si les adresses exactes du cas terrain
  apparaissent dans l'archive.

## Données de test

Les extrémités non publiques de GOLDEN-001 sont représentées par :

- `GOLDEN-001_ORIGIN_ALFORTVILLE`
- `GOLDEN-001_DESTINATION_ISSY`

Les valeurs utilisées dans le test public sont synthétiques. Les informations
locales complémentaires restent hors du dépôt via `private_data/` ou
`test_private/`, tous deux ignorés par Git.

## Blocages réels

### Dépôt indépendant

La cible reste `spreadzloverz/gps-nimbus`. Le connecteur disponible ne sait pas
créer un nouveau dépôt. Le paquet est prêt ; la séparation définitive demande
uniquement la création du dépôt vide.

### Données réelles

Le prototype utilise encore un réseau fictif, des attentes moyennes et des
distances approximatives. Il ne doit pas être présenté comme un calculateur de
trajet réel à ce stade.

### Appareils

Le build web de CI prouve la compilation, pas le comportement sur un iPhone,
un téléphone Android ou une application iOS native.

## Prochaine séquence

1. Créer le dépôt privé vide `gps-nimbus`.
2. Y transférer le paquet autonome et relancer la CI.
3. Importer le GTFS IDFM.
4. Ajouter prochains passages et perturbations datées.
5. Remplacer les distances approximatives par un vrai réseau OSM.
6. Comparer GOLDEN-001 sur une heure de départ et des données réelles.
7. Tester la version Web sur un iPhone physique.
