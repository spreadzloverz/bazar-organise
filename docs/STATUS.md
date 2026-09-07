# STATUS — GPS NIMBUS

Dernière mise à jour : 2026-09-07
Branche contrôlée : `gps-nimbus/hardening-v1`
Commit applicatif contrôlé : `de17b6b00648a09b29d70fc878681ed9a3fd0938`

## État actuel

GPS NIMBUS est un **prototype Flutter fonctionnel sur données fictives**.
Le cœur métier, les classements et la nouvelle calibration terrain sont testés.
Ce n'est pas encore un GPS relié aux transports et aux rues réelles.

Contrôle GitHub Actions exécuté avec Flutter 3.47.2 et Dart 3.13.2 :

- format : **succès** ;
- analyse statique : **succès, aucun problème** ;
- tests : **88 réussis** ;
- build Flutter Web : **succès** ;
- artefact web : **42 fichiers, 14 683 975 octets** ;
- déploiement public : **non effectué**.

Run de preuve : `34140843124`.
Artefact : `10025892847`, conservé temporairement jusqu'au 14 septembre 2026.

## Matrice de réalité

| Fonction | Statut | Limite principale |
|---|---|---|
| Modèles marche, skate, métro, RER, tram, bus | TESTED | Modèles métier uniquement |
| Skate de référence à 27 km/h | TESTED | Vitesse générique, pas vitesse réelle de chaque rue |
| Marche de référence à 5 km/h | TESTED | Vitesse générique |
| Classement PLUS RAPIDE | TESTED | Sur candidats et temps actuellement mockés |
| Classement MOINS DE SKATE | TESTED | Distance skate utilisée comme proxy batterie |
| Routage multimodal | TESTED / MOCKED | Algorithme testé, réseau francilien fictif |
| Observations terrain utilisateur | TESTED | Correspondance actuelle par libellés ; identifiants géographiques à venir |
| Priorité mesure terrain sur estimation générique | TESTED | Pour tronçons marche/skate correspondants |
| Plage 7–10 min conservée | TESTED | Milieu utilisé provisoirement comme valeur représentative |
| Point d'accès explicitement protégé | TESTED | Doit déjà exister dans le réseau chargé |
| Ivry non remplacé silencieusement par BFM | TESTED | Test de non-régression logique |
| GOLDEN-001 Alfortville → Issy | DOCUMENTED | Réseau mock incomplet et données privées non committées |
| Ligne 12 / RER C du cas réel | NOT IMPLEMENTED | Absents du réseau mock actuel |
| GTFS Île-de-France Mobilités | NOT IMPLEMENTED | Aucune donnée horaire réelle |
| Prochains passages / perturbations | NOT IMPLEMENTED | Aucune donnée temps réel |
| Réseau de rues OSM | NOT IMPLEMENTED | Distances encore approximées |
| Géocodage réel | NOT IMPLEMENTED | Catalogue de lieux limité |
| Road Intelligence | PLANNED | Aucune pénalité arbitraire activée |
| Build web reproductible en CI | TESTED | Artefact non publié |
| Test navigateur local antérieur | TESTED selon rapport précédent | Pas revérifié indépendamment dans cette passe |
| Safari sur iPhone réel | NOT DEVICE_TESTED | Action terrain nécessaire |
| APK Android | NOT BUILT dans cette passe | CI actuelle ne construit que le web |
| Application iOS native | NOT BUILT | Mac + Xcode nécessaires |
| GitHub Pages | NOT DEPLOYED | Publication volontairement bloquée ici |
| Application en production | NOT PRODUCTION | Données réelles et essais terrain manquants |

## Réalisé dans le lot de durcissement

- Branche isolée créée sans modifier `main`.
- Aucune modification des fichiers du portfolio Bazar Organisé.
- Déploiement Pages depuis une branche Claude explicitement interdit.
- Architecture de migration vers un dépôt indépendant documentée.
- Données privées exclues du dépôt public par `.gitignore`.
- GOLDEN-001 documenté avec identifiants anonymisés.
- Modèle `ObservedSegment` ajouté avec :
  - sens du trajet ;
  - mode ;
  - durée minimale et maximale ;
  - nombre d'observations ;
  - date et source facultatives.
- Hiérarchie de preuves ajoutée : mesure utilisateur, temps réel, historique,
  réseau, horaire, estimation générique.
- Durées terrain appliquées aux segments marche/skate compatibles.
- Stations explicitement indiquées ajoutées aux candidats quand elles existent.
- Station absente signalée au lieu d'être remplacée.
- Défaut de liste fixe découvert et corrigé avant validation.
- Workflow CI ajouté sans permission de publication.
- Build web généré depuis la source et conservé comme artefact inspectable.

## Confidentialité

Le dépôt est public. Les deux adresses personnelles exactes du cas GOLDEN-001
n'ont pas été publiées. Les tests publics utilisent :

- `GOLDEN-001_ORIGIN_ALFORTVILLE` ;
- `GOLDEN-001_DESTINATION_ISSY`.

Les coordonnées et historiques privés devront rester localement dans
`gps_nimbus/private_data/` ou `test_private/`, tous deux ignorés par Git.

## Ce qui reste bloquant

### 1. Dépôt indépendant

Le connecteur GitHub utilisé dans cette passe peut créer des branches,
modifier le code, lancer les contrôles et ouvrir une pull request, mais il ne
permet pas de créer un nouveau dépôt.

Cible : `spreadzloverz/gps-nimbus`.

Ce blocage n'empêche pas le développement ni les tests sur la branche isolée.
Il empêche seulement la séparation définitive et le déploiement propre.

### 2. Données réelles

Le moteur utilise encore :

- un réseau de transport fictif ;
- des attentes moyennes ;
- des distances à vol d'oiseau corrigées par un facteur.

Aucun itinéraire actuel ne doit être présenté comme un conseil réel de trajet.

### 3. Validation sur appareil

Le build web de CI prouve que les sources compilent. Il ne prouve pas le
comportement de Safari sur un iPhone physique, ni celui d'un build Android ou
iOS natif.

## Prochaine séquence

1. Revue de la pull request de durcissement ; ne pas fusionner vers `main`.
2. Créer le dépôt indépendant GPS NIMBUS et y transférer le projet.
3. Ajouter Quai de la Gare, Pasteur, Mairie d'Issy, Ivry-sur-Seine, ligne 12
   et RER C à un réseau de test contrôlé.
4. Transformer GOLDEN-001 en comparaison automatisée complète.
5. Brancher le GTFS IDFM, puis les prochains passages et perturbations.
6. Remplacer les distances approximatives par un vrai réseau de rues.
7. Tester la version web sur un iPhone réel avant toute qualification
   `DEVICE_TESTED`.
