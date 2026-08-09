# Où en est le projet

Au 9 août 2026.

## Ce qui fonctionne

Le cœur de GPS NIMBUS est construit et testé : 81 tests passent, l'analyse
de code ne relève aucun problème.

- Le moteur calcule des trajets combinant marche, skate, métro, RER, tram
  et bus.
- Les deux classements obligatoires fonctionnent, y compris tous leurs cas
  d'égalité.
- L'application Flutter tourne : accueil, résultats, détail étape par étape.
- Un outil en ligne de commande permet d'essayer le moteur sans téléphone.
- Une version navigateur existe et a été vérifiée dans un vrai navigateur
  au format iPhone. C'est le seul moyen actuel d'utiliser l'application
  depuis un iPhone, sans Mac ni compte développeur.
- Les limites du MVP sont affichées dans l'application elle-même.

## Ce qui n'existe pas encore

- **La version web n'est pas encore en ligne.** Elle est construite et
  prête ; il ne manque qu'un hébergement à activer.
- **Aucun APK Android n'a été produit.** L'environnement de développement à
  distance bloque l'accès au serveur de Google, d'où proviennent le SDK
  Android et les outils de compilation. Le projet Android est complet et
  correctement configuré ; il ne manque qu'une machine capable de le
  compiler.
- **Aucun build iPhone natif n'a été produit.** Cela demande un Mac avec
  Xcode. Le projet iOS est prêt. En attendant, la version web tourne sur
  iPhone et peut être ajoutée à l'écran d'accueil.
- Les données réelles de transport, les tracés de rues et la carte
  restent à faire.

## La suite

1. Mettre la version web en ligne, puis compiler les applications natives
   sur une machine qui le permet.
2. Importer les vraies données de transport franciliennes.
3. Remplacer les distances estimées par de vrais trajets de rues.
4. Donner au skate ses propres règles de circulation.
5. Ajouter la carte — seulement une fois les tracés réels disponibles.
