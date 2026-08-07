# Sources de données

## Règle

Une API réelle n'est jamais simulée. Quand une source manque :
on crée l'interface, on écrit un substitut clairement identifié, on signale
la dépendance manquante, et on continue à construire. Une source absente ne
doit jamais bloquer le MVP.

## État de chaque source

**Réseau de transport — fictif.**
43 stations et 9 lignes écrites à la main, positions approximatives.
Sert à faire fonctionner et tester le moteur.
Cible : le GTFS d'Île-de-France Mobilités (arrêts, lignes, horaires).
Ce qu'il faut : télécharger le jeu de données et écrire son import.

**Horaires temps réel — absents.**
Les temps d'attente sont la moitié de l'intervalle moyen de passage.
L'heure de départ est déjà prévue dans le modèle, mais elle est ignorée
tant qu'il n'y a pas d'horaires réels.

**Tracé des rues — absent.**
Les distances marche et skate sont la distance à vol d'oiseau majorée
de 25 %. Cible : OpenStreetMap.
Ce qu'il faut : un extrait francilien et un moteur de calcul de chemin.

**Calcul multimodal externe — non branché.**
Une interface OpenTripPlanner existe. Elle refuse de répondre tant qu'aucun
serveur n'est renseigné, plutôt que d'inventer un itinéraire.
Ce qu'il faut : un serveur OpenTripPlanner alimenté par le GTFS francilien.

**Règles de circulation du skate — absentes.**
Les règles cyclables servent de substitut, ce qui est affiché à
l'utilisateur.

## Ce qui n'est jamais partagé

Clés d'API, jetons, mots de passe, fichiers `.env`, caches, dépendances
compilées. Ni dans Drive, ni dans NotebookLM, ni dans le dépôt.
