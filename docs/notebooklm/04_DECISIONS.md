# Décisions structurantes

Version courte. Le détail est dans `docs/DECISIONS.md`.

**L'application vit dans un sous-dossier du dépôt existant.**
Aucun fichier du site web Bazar Organise n'est touché.

**Aucune bibliothèque de gestion d'état.**
Un écran de saisie et deux écrans de lecture ne justifient pas une
dépendance supplémentaire. Le moteur est de toute façon isolé de
l'interface.

**Aucune dépendance externe pour l'instant.**
Le calcul de distance fait dix lignes, le réseau est assez petit pour se
passer d'algorithmes optimisés, et il n'y a encore aucun appel réseau.
Moins de dépendances, moins de risques sur Android et iPhone.

**Le graphe a pour nœuds des couples (station, ligne).**
C'est ce qui permet de compter honnêtement les correspondances et
d'afficher la vraie séquence du trajet — deux exigences produit.

**La pénalité de correspondance n'est pas affichée.**
Elle guide le choix de l'itinéraire, mais gonfler la durée annoncée
reviendrait à mentir sur le temps de trajet.

**Le skate emprunte temporairement les règles cyclables.**
Il n'existe pas de données spécifiques aux engins de déplacement personnel
motorisés. Inventer des règles serait malhonnête, attendre bloquerait tout.
L'emprunt est isolé, visible dans l'application, et désactivable.

**Le réseau du MVP est fictif.**
Le GTFS francilien n'est pas encore importé. Un réseau réduit permet
d'exercer toutes les combinaisons de modes. Le calcul est réel, seules les
données sont approximatives — et l'application le signale.

**Les distances sont estimées à vol d'oiseau majoré de 25 %.**
Grossier mais honnête, en attendant de vrais tracés de rues.
