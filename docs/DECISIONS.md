# DECISIONS — GPS NIMBUS

Dernière consolidation : 2026-09-07

Seules les décisions structurantes sont conservées ici.

---

DECISION: Héberger provisoirement le code dans `gps_nimbus/`, puis le migrer
  vers un dépôt indépendant `spreadzloverz/gps-nimbus`.
CONTEXT: `bazar-organise` contient déjà un portfolio public sans rapport avec
  l'application.
OPTIONS: Mélanger les projets ; rester durablement en sous-dossier ; créer un
  dépôt GPS NIMBUS indépendant.
CHOICE: Sous-dossier uniquement comme transition, dépôt indépendant comme
  cible.
WHY: Réduit le risque qu'un build, une branche Claude ou un réglage Pages
  casse le portfolio.
REVERSIBLE: Oui.
SUPERSEDES: La décision initiale de conserver durablement les deux projets
  dans le même dépôt.

---

DECISION: Ne jamais publier GitHub Pages depuis une branche `claude/*` du
  dépôt `bazar-organise`.
CONTEXT: Pages publierait la racine entière de la branche, pas seulement
  `/nimbus/`.
CHOICE: Construire et publier plus tard depuis le dépôt GPS NIMBUS séparé,
  après format, analyse et tests.
WHY: Le site Bazar Organisé ne doit pas dépendre d'une branche de travail.
REVERSIBLE: Oui ; aucun réglage Pages n'a été modifié.

---

DECISION: Employer six niveaux de réalité.
CHOICE: `MOCKED`, `IMPLEMENTED`, `TESTED`, `DEVICE_TESTED`, `LIVE_DATA`,
  `PRODUCTION`.
WHY: Empêche de confondre code présent, test Chromium redimensionné, données
  réelles et application publiée.
REVERSIBLE: Oui, mais ces distinctions doivent rester au minimum aussi
  précises.

---

DECISION: Les mesures terrain utilisateur compatibles ont priorité sur les
  estimations génériques.
CONTEXT: Une vitesse libre de 27 km/h ne représente pas les feux, traversées,
  relances et accès réels d'un segment connu.
CHOICE: Conserver la durée générique dans les métadonnées, mais utiliser la
  meilleure observation directionnelle lorsqu'origine, destination et mode
  correspondent.
WHY: Une mesure réelle est plus fiable qu'un calcul `distance / vitesse`.
REVERSIBLE: Oui ; l'absence de contexte utilisateur conserve le comportement
  antérieur.

---

DECISION: Une plage terrain reste une plage.
CONTEXT: Certaines observations sont exprimées comme « 7 à 10 minutes ».
CHOICE: Conserver min et max ; utiliser provisoirement leur milieu comme
  valeur représentative tant qu'aucune médiane n'existe.
WHY: Évite d'inventer une précision. Le choix représentatif pourra évoluer
  avec davantage de passages.
REVERSIBLE: Oui.

---

DECISION: Protéger les points d'accès explicitement donnés.
CONTEXT: Une recommandation précédente avait remplacé Ivry-sur-Seine par BFM
  sans justification.
CHOICE: Ajouter tout point explicite existant aux candidats, même hors des
  trois stations les plus proches. S'il manque dans le réseau courant, le
  signaler au lieu de le remplacer.
WHY: Les connaissances terrain utilisateur ne doivent pas disparaître dans
  la génération automatique de candidats.
REVERSIBLE: Oui.

---

DECISION: Ne pas enregistrer les adresses personnelles exactes dans le dépôt
  public.
CHOICE: Tests publics anonymisés ; coordonnées et historique privés sous
  `gps_nimbus/private_data/` ou `test_private/`, ignorés par Git.
WHY: La reproductibilité ne justifie pas la publication d'une adresse privée.
REVERSIBLE: Non pour une donnée déjà publiée, donc prévention obligatoire.

---

DECISION: Gestion d'état Flutter avec `StatefulWidget` et `setState`.
CONTEXT: L'interface actuelle a peu d'état partagé.
CHOICE: Ne pas ajouter Provider, Riverpod ou BLoC maintenant.
WHY: Réduit dépendances et vocabulaire sans bloquer une évolution ultérieure.
REVERSIBLE: Oui.

---

DECISION: Zéro dépendance externe au-delà du SDK Flutter pour le cœur actuel.
CONTEXT: Haversine et Dijkstra sur le petit réseau mock restent simples.
CHOICE: Ajouter une dépendance seulement lorsqu'elle résout un besoin réel.
WHY: Compatibilité Android/iOS et maintenance plus simples.
REVERSIBLE: Oui.

---

DECISION: Graphe transport basé sur les couples `(station, ligne)`.
CONTEXT: Il faut distinguer attente, trajet à bord et changement de véhicule.
CHOICE: Graphe station × ligne.
WHY: Permet de compter et afficher honnêtement les correspondances.
REVERSIBLE: Oui, mais sans avantage à revenir à un graphe moins expressif.

---

DECISION: Utiliser la pénalité de correspondance uniquement dans la recherche.
CONTEXT: Elle évite les itinéraires absurdes mais ne représente pas un temps
  réellement écoulé.
CHOICE: Ne pas l'ajouter à la durée affichée.
WHY: La durée annoncée doit rester la somme des tronçons réels.
REVERSIBLE: Oui.

---

DECISION: Utiliser temporairement les règles cyclables comme proxy skate.
CONTEXT: Les données de voirie spécifiques au skateboard électrique ne sont
  pas encore disponibles.
CHOICE: Proxy isolé dans la politique d'accès et explicitement signalé.
WHY: Mieux qu'inventer des règles ou bloquer le MVP.
REVERSIBLE: Oui ; le profil skate ne doit jamais devenir un alias permanent
  du vélo.

---

DECISION: Réseau francilien fictif et simplifié pour exercer le moteur.
CONTEXT: Le GTFS IDFM réel n'est pas encore importé.
CHOICE: Réseau mock clairement marqué, sans fausse API.
WHY: Permet de tester les combinaisons et classements avant les données
  réelles.
REVERSIBLE: Oui via les adaptateurs de données.

---

DECISION: Estimer provisoirement les distances de rue par haversine × facteur
  de détour.
CONTEXT: Aucun graphe OSM routable n'est encore branché.
CHOICE: Approximation unique, visible et remplaçable.
WHY: Plus honnête que prétendre disposer d'un tracé réel.
REVERSIBLE: Oui.

---

DECISION: Départage final déterministe des classements par identifiant.
CONTEXT: Un tri instable pouvait modifier l'ordre de résultats strictement
  égaux.
CHOICE: Dernier critère déterministe.
WHY: Reproductibilité utilisateur et tests stables.
REVERSIBLE: Oui.

---

DECISION: Conserver Flutter Web comme banc d'essai, pas comme équivalent
  définitif des applications natives.
CONTEXT: Le web donne accès rapidement au prototype depuis un iPhone mais a
  des limites de GPS, arrière-plan, stockage et cycle de vie Safari.
CHOICE: Même code Dart pour web/Android/iOS ; validations séparées.
WHY: Évite une réécriture tout en conservant l'objectif natif.
REVERSIBLE: Oui.

---

DECISION: Générer le build web en CI et le conserver comme artefact de test.
CONTEXT: Un dossier compilé committé peut diverger du code source.
CHOICE: Source Dart comme vérité ; workflow sans déploiement pour format,
  analyse, tests et build.
WHY: Un artefact doit être reproductible à partir d'un commit contrôlé.
REVERSIBLE: Oui.

---

DECISION: Embarquer une police libre dans l'application.
CONTEXT: Sans accès au serveur de polices, le texte Flutter Web disparaissait.
CHOICE: Liberation Sans sous SIL Open Font License.
WHY: Affichage autonome et confidentialité améliorée.
REVERSIBLE: Oui.

---

DECISION: Vérifier tous les `TextStyle` créés manuellement.
CONTEXT: Le libellé « CALCULER » n'héritait pas de la police embarquée.
CHOICE: Famille explicite et test anti-régression.
WHY: Empêche un défaut visible uniquement à l'exécution web.
REVERSIBLE: Oui, sans intérêt pratique.
