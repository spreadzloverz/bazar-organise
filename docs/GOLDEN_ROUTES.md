# GOLDEN ROUTES — GPS NIMBUS

Dernière mise à jour : 2026-09-07

Les Golden Routes sont des cas terrain utilisés pour empêcher les régressions
du moteur. Ce dépôt étant public, les adresses personnelles exactes ne sont
jamais enregistrées ici.

## GOLDEN-001 — Alfortville → Issy-les-Moulineaux

### Identifiants anonymisés

- Départ privé : `GOLDEN-001_ORIGIN_ALFORTVILLE`
- Destination privée : `GOLDEN-001_DESTINATION_ISSY`

Les coordonnées et adresses exactes doivent rester dans un fichier local
ignoré par Git sous `gps_nimbus/private_data/`.

### Observations terrain fournies par l'utilisateur

| Segment | Mode | Observation |
|---|---|---:|
| Départ privé → Quai de la Gare | skate | environ 10 min |
| Départ privé → gare d'Ivry-sur-Seine | skate | environ 7 à 10 min |
| Mairie d'Issy → destination privée | skate | environ 5 min |

Ces mesures ont priorité sur une durée générique calculée uniquement avec
`distance / 27 km/h`, à condition que le sens, le mode et les extrémités du
segment correspondent.

### Itinéraire de référence A

```text
SKATE
→ Quai de la Gare
→ MÉTRO 6
→ Pasteur
→ CORRESPONDANCE À PIED
→ MÉTRO 12
→ Mairie d'Issy
→ SKATE
→ destination privée
```

Cet itinéraire ne doit pas être déclaré meilleur sans horaires réels. Il doit
rester un candidat explicitement protégé et comparable aux autres solutions.

### Itinéraire candidat B

```text
SKATE
→ gare d'Ivry-sur-Seine
→ RER C
→ Issy ou Issy–Val de Seine selon la mission réelle
→ SKATE ou MARCHE
→ destination privée
```

La gare d'Ivry-sur-Seine doit rester candidate lorsqu'elle est explicitement
donnée. Le moteur ne doit jamais la remplacer silencieusement par
Bibliothèque François-Mitterrand.

### Règles de non-régression

1. Les observations utilisateur compatibles remplacent l'estimation générique.
2. Une plage de 7 à 10 min reste une plage ; elle n'est pas transformée en
   mesure prétendument exacte.
3. Une observation A → B ne s'applique pas automatiquement à B → A.
4. Ivry-sur-Seine reste un point d'accès candidat explicite.
5. Une station absente du réseau mock est signalée comme non calculable ; elle
   n'est ni supprimée ni remplacée.
6. Une perturbation temporaire doit être liée à une période de validité ; elle
   ne devient jamais une règle permanente.
7. Le classement final doit distinguer données mockées, horaires prévus,
   données temps réel et mesures terrain.

### État d'implémentation

- Modèle d'observation utilisateur : `IMPLEMENTED`
- Application des durées observées aux tronçons marche/skate : `IMPLEMENTED`
- Protection des stations existant dans le réseau courant : `IMPLEMENTED`
- Tests automatisés : écrits, en attente d'exécution CI
- Ligne 12, RER C et stations de ce cas dans le réseau mock : `NOT IMPLEMENTED`
- Horaires IDFM réels : `NOT IMPLEMENTED`
- Test sur le trajet privé exact : local uniquement, non committé
