# Vision

## Le produit

GPS NIMBUS calcule et compare des trajets en Île-de-France pour un skateur
urbain qui se déplace tous les jours.

Modes pris en charge : marche, skateboard électrique, métro, RER, tram, bus,
et toutes leurs combinaisons utiles.

## Les deux réponses obligatoires

**PLUS RAPIDE** — minimise le temps total porte à porte. Ce total inclut le
skate, la marche, l'attente sur les quais, le temps à bord, les
correspondances. Rien n'est exclu du compte.

**MOINS DE SKATE** — minimise en priorité la distance parcourue en skate.
En cas d'égalité, on départage par le temps total, puis le nombre de
correspondances, puis la distance à pied.

## Règles verrouillées

- Skate : 27 km/h de moyenne.
- Marche : 5 km/h de moyenne.
- Les deux restent configurables, mais les valeurs par défaut ne changent
  pas sans décision explicite.
- Pas d'estimation de batterie. Tant qu'aucun modèle énergétique fiable
  n'existe, on parle de « distance skate réduite », rien de plus.

## Règle d'honnêteté

Aucune fonctionnalité n'est présentée comme réelle si elle ne l'est pas.
Une API absente n'est jamais simulée : on crée l'interface, on signale la
dépendance manquante, et on continue à construire.

## Volontairement absent du MVP

Compte utilisateur, authentification, paiement, publicité, tracking,
fonctions sociales, backend, IA embarquée. La priorité est le cœur du
calcul de trajet.
