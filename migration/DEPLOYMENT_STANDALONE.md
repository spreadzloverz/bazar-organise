# DÉPLOIEMENT GPS NIMBUS

## Principe

Le code Flutter est la source de vérité. Le dossier Web compilé est généré par
la CI à partir d'un commit contrôlé ; il ne doit pas être modifié à la main.

```text
source
→ format
→ analyse
→ tests
→ build web
→ artefact
→ publication explicitement autorisée
```

## Branches

- `main` : version stable validée ;
- `dev` : intégration avant validation ;
- `feature/*` et `fix/*` : travaux courts ;
- aucune branche d'agent n'est une source de production permanente.

## Avant toute publication

- la CI doit être verte ;
- le build doit être inspectable comme artefact ;
- le statut des fonctions doit distinguer MOCKED et LIVE_DATA ;
- aucun secret, fichier `.env` ou historique personnel ne doit être inclus ;
- un retour arrière doit rester possible.

## GitHub Pages

Pages peut héberger la version Web de test une fois le dépôt indépendant créé.
La base Flutter prévue est `/gps-nimbus/`.

L'activation de Pages est une action externe visible. Elle ne doit pas être
faite automatiquement sans validation explicite.

## Limites

Une PWA Flutter est un banc d'essai et un accès rapide depuis un navigateur.
Elle ne remplace pas les validations Android natives, Safari sur iPhone réel
ou iOS natif.

OpenTripPlanner et les éventuels secrets d'API nécessiteront une infrastructure
séparée ; GitHub Pages reste un hébergement statique.
