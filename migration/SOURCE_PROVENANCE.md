# SOURCE ET PROVENANCE

Date de préparation : 2026-09-07

## Origine

- Dépôt temporaire : `spreadzloverz/bazar-organise`
- Branche source initiale : `claude/gps-nimbus-mobile-app-p8iqf0`
- Branche de durcissement : `gps-nimbus/hardening-v1`
- Pull request de revue : numéro 1, maintenue en brouillon

Le dépôt d'origine contient également le portfolio Bazar Organisé. Celui-ci
n'est pas inclus dans le paquet autonome.

## Dernière preuve fonctionnelle avant paquetage

- GitHub Actions : run `34141968781`
- Commit applicatif : `090a83fab9c8713d12d3a285c76c2d1f81900e33`
- Flutter : 3.47.2
- Dart : 3.13.2
- Format : succès
- Analyse statique : aucun problème
- Tests : 95 réussis
- Build Web : succès
- Artefact Web : `10026265555`

Des changements documentaires ont ensuite été ajoutés sans modification du
cœur testé.

## Limites au moment de la migration

- réseau de transport fictif et simplifié ;
- aucune donnée horaire IDFM réelle ;
- aucun prochain passage ni incident temps réel ;
- aucune géométrie routable OSM ;
- aucun test Safari sur iPhone physique ;
- aucun APK Android produit dans ce lot ;
- aucun build iOS produit ;
- aucune publication en production.

## Confidentialité

Les points de départ et d'arrivée non publics du cas GOLDEN-001 sont remplacés
par des identifiants de test. Les détails de localisation et historiques
personnels ne doivent jamais être ajoutés au dépôt public ou à un artefact de
CI.
