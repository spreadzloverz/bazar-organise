# Déploiement — GPS NIMBUS

Dernière mise à jour : 2026-09-07

## Décision verrouillée

Ne pas utiliser une branche `claude/*` comme source publique GitHub Pages du dépôt `bazar-organise`.

Ce dépôt contient déjà le site Bazar Organisé. Publier sa racine depuis une branche de développement couplerait inutilement :

- le portfolio Bazar Organisé ;
- le prototype GPS NIMBUS ;
- une branche de travail réversible ;
- l'hébergement public.

Aucun réglage GitHub Pages ne doit être modifié depuis cette branche.

## Architecture cible

Dépôt indépendant recommandé :

```text
spreadzloverz/gps-nimbus
├── main          version stable
├── dev           intégration
├── claude/*      travaux autonomes
└── GitHub Actions
    ├── analyse
    ├── tests
    ├── build web
    └── publication Pages
```

Chaîne attendue :

```text
code source
→ analyse et tests
→ build généré automatiquement
→ artefact vérifié
→ déploiement web
```

Le dossier compilé ne doit pas devenir la source de vérité. La source de vérité reste le code Flutter sous `gps_nimbus/`.

## Solution provisoire autorisée

Tant que le dépôt indépendant n'existe pas :

1. développer uniquement sur une branche GPS NIMBUS dédiée ;
2. lancer les contrôles automatisés sur cette branche ;
3. ne pas modifier le site Bazar Organisé ;
4. ne pas activer Pages sur une branche de développement ;
5. préparer une migration reproductible vers le futur dépôt.

## Statuts de validation

- `MOCKED` : données ou comportement simulés.
- `IMPLEMENTED` : code présent, non encore prouvé par un test exécuté.
- `TESTED` : contrôlé automatiquement dans l'environnement indiqué.
- `DEVICE_TESTED` : vérifié sur un appareil physique identifié.
- `LIVE_DATA` : relié à une source réelle et datée.
- `PRODUCTION` : publié, surveillé et réversible.

Un test Chromium avec une fenêtre de taille iPhone n'est pas un test sur iPhone réel.

## Blocage externe

Le connecteur GitHub utilisé pour cette passe permet de créer des branches et modifier les fichiers, mais pas de créer un nouveau dépôt. La création de `spreadzloverz/gps-nimbus` restera une action humaine ou une action Claude Code/GitHub CLI explicitement autorisée.

Cette limite ne bloque ni le durcissement du code, ni les tests, ni la préparation de la migration.
