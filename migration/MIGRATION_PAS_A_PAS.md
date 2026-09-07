# MIGRATION GPS NIMBUS — PAS À PAS

Ce paquet est une copie autonome de GPS NIMBUS. Il ne contient pas le site
Bazar Organisé et ne modifie aucun réglage de publication.

## Action humaine nécessaire une seule fois

Le connecteur actuellement utilisé ne peut pas créer un nouveau dépôt GitHub.

1. Dans GitHub, clique sur **New repository**.
2. Nom du dépôt : `gps-nimbus`.
3. Choisis **Private** pendant la phase de développement.
4. Ne coche pas l'ajout automatique d'un README, d'une licence ou d'un
   `.gitignore` : le dépôt doit rester vide.
5. Clique sur **Create repository**.
6. Reviens dans la conversation et écris : `dépôt gps-nimbus créé`.

À partir de là, le projet pourra être transféré sans te demander de manipuler
les fichiers un par un.

## Ce qu'il ne faut pas faire

- Ne fusionne pas GPS NIMBUS dans la branche `main` du portfolio.
- N'active pas GitHub Pages sur une branche `claude/*` de `bazar-organise`.
- Ne publie pas le prototype comme s'il utilisait déjà les données réelles.
- Ne copie aucune clé API dans un fichier Git.

## Vérification après transfert

Le nouveau dépôt devra lancer automatiquement :

1. format Dart ;
2. analyse Flutter ;
3. tests ;
4. build Web ;
5. création d'un artefact téléchargeable.

La référence avant migration est :

- 95 tests réussis ;
- analyse statique sans problème ;
- build Web réussi ;
- données de transport encore fictives.
