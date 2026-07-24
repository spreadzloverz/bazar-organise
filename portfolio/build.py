#!/usr/bin/env python3
"""Génère le HTML prêt à imprimer du portfolio PDF Bazar Organisé.

Le book est construit à partir de projects.json : une sélection de projets
répartis en trois pôles, plus une planche « autres travaux » pour le reste.
Les champs optionnels role / enjeu / reponse / resultat de projects.json sont
rendus s'ils sont présents.
"""
import json
import os
import re
import html
import hashlib
from PIL import Image

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
BUILD = os.path.join(REPO, "portfolio", ".build")
OUT_HTML = os.path.join(BUILD, "portfolio-print.html")
CACHE = os.path.join(BUILD, "img-cache")
os.makedirs(CACHE, exist_ok=True)

# ── Éditorialisation ────────────────────────────────────────────
# Le projet phare ouvre le book en double page. Les pôles reprennent les trois
# axes de la page « à propos ». Tout projet absent d'ici part en annexe.
HERO = "skate-modulaire"

POLES = [
    {
        "n": "01",
        "titre": "Identité visuelle & graphisme",
        "accroche": "Le système visuel n'est pas livré comme un fichier isolé "
                    "mais comme un langage utilisable dans le réel.",
        "slugs": ["pura-vida", "identite-visuelle"],
    },
    {
        "n": "02",
        "titre": "Scénographie & design d'espace",
        "accroche": "L'espace est traité comme un projet de circulation, "
                    "d'usage et de perception.",
        "slugs": ["scenographie-alice", "design-espace"],
    },
    {
        "n": "03",
        "titre": "Art mural, objet & grand format",
        "accroche": "Du geste sur le mur à l'objet fabriqué : la conception "
                    "va jusqu'à la matière.",
        "slugs": ["cubes-evolutifs", "signature-territoire", "habillage-monumental"],
    },
]

IMG_EXT = (".jpg", ".jpeg", ".png", ".webp")


def natural_key(s):
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r'(\d+)', s)]


def list_images(folder_rel):
    folder_abs = os.path.join(REPO, folder_rel)
    if not os.path.isdir(folder_abs):
        return []
    files = [f for f in os.listdir(folder_abs) if f.lower().endswith(IMG_EXT)]
    files.sort(key=natural_key)
    return [os.path.join(folder_abs, f) for f in files]


def esc(s):
    return html.escape(s, quote=False)


def pick_spread(paths, n):
    """Répartit la sélection sur tout le dossier plutôt que les n premières."""
    if len(paths) <= n:
        return paths
    step = len(paths) / n
    return [paths[int(i * step)] for i in range(n)]


def optimize(path, max_side=1500):
    out = os.path.join(CACHE, hashlib.sha1(path.encode()).hexdigest() + ".jpg")
    if os.path.exists(out):
        return out
    with Image.open(path) as im:
        im = im.convert("RGB")
        im.thumbnail((max_side, max_side), Image.LANCZOS)
        im.save(out, "JPEG", quality=80, optimize=True, progressive=True)
    return out


def img(path):
    return f'<img src="file://{optimize(path)}">'


def mosaic(paths):
    n = len(paths)
    if n == 0:
        return '<div class="no-img">Images à venir</div>'
    tags = "".join(img(p) for p in paths)
    cls = {1: "img-solo", 2: "img-duo", 3: "img-trio"}.get(n, "img-grid")
    return f'<div class="{cls}">{tags}</div>'


with open(os.path.join(REPO, "projects.json"), encoding="utf-8") as f:
    projects = json.load(f)
by_slug = {p["slug"]: p for p in projects}
images_of = {p["slug"]: list_images(p.get("images_folder", "")) for p in projects}

selected = [HERO] + [s for pole in POLES for s in pole["slugs"]]
annexe = [p["slug"] for p in projects if p["slug"] not in selected]

pages = []          # (html, besoin_de_numero)


def add(markup):
    pages.append(markup)


def footer(n):
    return (f'<div class="footer-line"><span>Bazar Organisé — Xavier Talbot</span>'
            f'<span>{n:02d}</span></div>')


def tags_of(p):
    return "".join(f'<span class="tag">{esc(t)}</span>' for t in p.get("tags", []))


def optional_blocks(p):
    """Rend enjeu / réponse / résultat / rôle uniquement s'ils existent."""
    out = []
    for key, label in (("enjeu", "L'enjeu"), ("reponse", "La réponse"),
                       ("resultat", "Le résultat")):
        if p.get(key):
            out.append(f'<div class="case-block"><span class="label">{label}</span>'
                       f'<p>{esc(p[key])}</p></div>')
    return "".join(out)


def project_page(slug, n, layout="a"):
    p = by_slug[slug]
    paths = images_of[slug]
    role = p.get("role") or p["context"]
    head = f'''
    <div class="proj-head">
      <div class="proj-meta">
        <span class="proj-num">{esc(p["id"])}</span>
        <span class="proj-cat">{esc(p["category"])}</span>
        <span class="proj-year">{esc(p["year"])}</span>
      </div>
      <h2 class="proj-title">{esc(p["title"])}</h2>
      <p class="proj-subtitle">{esc(p["subtitle"])}</p>
    </div>'''

    if layout == "b":
        body = f'''
    <div class="proj-body-b">
      <div class="proj-images-b">{mosaic(pick_spread(paths, 3))}</div>
      <div class="proj-cols">
        <div><p class="proj-desc">{esc(p["description"])}</p></div>
        <div>
          <div class="proj-context"><span class="label">Rôle & contexte</span><p>{esc(role)}</p></div>
          {optional_blocks(p)}
        </div>
        <div class="proj-tags">{tags_of(p)}</div>
      </div>
    </div>'''
    else:
        body = f'''
    <div class="proj-body">
      <div class="proj-text">
        <p class="proj-desc">{esc(p["description"])}</p>
        <div class="proj-context"><span class="label">Rôle & contexte</span><p>{esc(role)}</p></div>
        {optional_blocks(p)}
        <div class="proj-tags">{tags_of(p)}</div>
      </div>
      <div class="proj-images">{mosaic(pick_spread(paths, 4))}</div>
    </div>'''

    return f'<section class="page proj-page layout-{layout}">{head}{body}{footer(n)}</section>'


# ── 01 · Couverture ─────────────────────────────────────────────
logo = os.path.join(REPO, "logo-bo.svg")
add(f'''
<section class="page cover">
  <div class="cover-top">
    <img src="file://{logo}">
    <span class="wordmark">Bazar Organisé</span>
  </div>
  <div class="cover-mid">
    <div class="cover-eyebrow">Studio / atelier créatif pluridisciplinaire</div>
    <h1 class="cover-title">Du logo à l'espace,<br>je conçois et réalise<br>des projets qui tiennent dans la <span class="accent">réalité</span>.</h1>
    <p class="cover-sub">Portfolio — identité visuelle, scénographie, design d'espace,
    art mural, mobilier, réalisation et pilotage.</p>
  </div>
  <div class="cover-bottom">
    <div>
      <div class="name">Xavier Talbot</div>
      <div class="role">Concepteur-réalisateur pluridisciplinaire</div>
    </div>
    <div class="contact">
      Alfortville (94) — Île-de-France<br>
      contact@bazarorganise.fr<br>
      bazarorganise.fr
    </div>
  </div>
</section>''')

# ── 02 · Sommaire ───────────────────────────────────────────────
toc = [f'''<div class="toc-group">
  <div class="toc-group-head"><span class="toc-group-n">Projet phare</span></div>
  <div class="toc-row"><span class="toc-num">{esc(by_slug[HERO]["id"])}</span>
    <span class="toc-title">{esc(by_slug[HERO]["title"])}</span>
    <span class="toc-cat">{esc(by_slug[HERO]["category"])}</span></div>
</div>''']
for pole in POLES:
    rows = "".join(
        f'<div class="toc-row"><span class="toc-num">{esc(by_slug[s]["id"])}</span>'
        f'<span class="toc-title">{esc(by_slug[s]["title"])}</span>'
        f'<span class="toc-cat">{esc(by_slug[s]["category"])}</span></div>'
        for s in pole["slugs"])
    toc.append(f'''<div class="toc-group">
  <div class="toc-group-head"><span class="toc-group-n">{pole["n"]}</span>
    <span class="toc-group-t">{esc(pole["titre"])}</span></div>
  {rows}
</div>''')
toc.append(f'''<div class="toc-group">
  <div class="toc-group-head"><span class="toc-group-n">Annexe</span>
    <span class="toc-group-t">Autres travaux — {len(annexe)} pratiques</span></div>
</div>''')

add(f'''
<section class="page toc">
  <div class="kicker">Sommaire</div>
  <h2 class="toc-h2">Une sélection de {len(selected)} projets,<br>trois pôles, une seule logique.</h2>
  <div class="toc-list">{"".join(toc)}</div>
  {footer(2)}
</section>''')

# ── 03–04 · À propos ────────────────────────────────────────────
add(f'''
<section class="page about">
  <div class="kicker">À propos</div>
  <h1 class="about-h1">Séduire par l'univers. <span class="accent">Convaincre</span> par la méthode.</h1>
  <p class="about-intro">Je suis Xavier Talbot. Sous la marque Bazar Organisé, je développe
  des projets qui tiennent dans la réalité : identités visuelles, scénographies, fresques
  murales, mobilier design, aménagements d'espaces et pilotage de réalisation. Mon rôle est
  simple : garder la chaîne complète entre intention créative, faisabilité technique et mise
  en œuvre.</p>
  <div class="about-card">
    <div class="label">Positionnement</div>
    <p>Ni street artist pur, ni graphiste freelance classique, ni technicien sans vision.
    Bazar Organisé fonctionne comme une interface unique entre idée graphique et construction
    physique. Du logo au mur, de l'espace à l'objet, un seul interlocuteur du brief à la
    livraison.</p>
  </div>
  <div class="kicker sub">01 — Expertise — Trois pôles, une seule logique de projet</div>
  <div class="poles">
    <article class="pole"><div class="n">Le cerveau</div><h3>Identité visuelle</h3>
      <p>Logos, chartes graphiques, univers visuels complets, édition, signalétique, textile,
      applications grand format.</p></article>
    <article class="pole"><div class="n">La vision</div><h3>Scénographie &amp; espace</h3>
      <p>Aménagements, relevés, modélisations 2D/3D, fresques et dispositifs spatiaux conçus
      pour être compris, fabriqués et utilisés.</p></article>
    <article class="pole"><div class="n">La main</div><h3>Réalisation &amp; pilotage</h3>
      <p>Conduite de projet, coordination chantier, fabrication, adaptation terrain et maîtrise
      des contraintes techniques et budgétaires.</p></article>
  </div>
  {footer(3)}
</section>''')

add(f'''
<section class="page about2">
  <div class="kicker">02 — Parcours — Un parcours hybride, visuel et opérationnel</div>
  <div class="timeline-item"><div class="timeline-date">2022 → aujourd'hui</div>
    <div class="timeline-body"><h3>Bazar Organisé — Concepteur-réalisateur indépendant</h3>
    <p>Identité visuelle, scénographie, fresques, mobilier sur-mesure, aménagement d'espace et
    coordination de projets pour restaurateurs, collectivités, associations et agences.</p></div></div>
  <div class="timeline-item"><div class="timeline-date">2018 → 2023</div>
    <div class="timeline-body"><h3>Architecte d'intérieur — activité indépendante</h3>
    <p>Métrés, plans 2D/3D, modélisation, photomontages, dossiers de permis et suivi d'exécution.</p></div></div>
  <div class="timeline-item"><div class="timeline-date">2014 → 2018</div>
    <div class="timeline-body"><h3>Paris Habitat + Mairie de Fontenay-sous-Bois</h3>
    <p>Gestion de patrimoine bâti, marchés publics, réception de chantier, dossiers ERP,
    coordination des prestataires.</p></div></div>
  <div class="timeline-item"><div class="timeline-date">2006 → 2013</div>
    <div class="timeline-body"><h3>Infrastructure, architecture, transport</h3>
    <p>Cabinet d'architecte, SNCF, ADP, Colas Rail, Vinci : plans d'exécution, documentation,
    coordination, génie civil.</p></div></div>

  <div class="kicker sub">03 — Principes</div>
  <div class="principles">
    <article class="principle"><div class="n">01</div><h3>Concevoir, c'est anticiper</h3>
      <p>Chaque projet est pensé au-delà de son image : usage réel, maintenance, évolution
      dans le temps.</p></article>
    <article class="principle"><div class="n">02</div><h3>La contrainte est une matière de projet</h3>
      <p>Réglementation, budget, délais et techniques constructives permettent des réponses
      plus justes et plus solides.</p></article>
    <article class="principle"><div class="n">03</div><h3>La justesse avant l'effet</h3>
      <p>Chaque forme, matériau ou couleur répond à une logique d'usage, de contexte ou de
      narration.</p></article>
  </div>

  <div class="kicker sub">04 — Outils</div>
  <div class="tools-grid">
    <div class="item"><div class="small">Design</div><p>Photoshop, Illustrator, suite Adobe,
      direction artistique.</p></div>
    <div class="item"><div class="small">Espace</div><p>SketchUp Pro, AutoCAD, relevés,
      plans 2D/3D, coordination spatiale.</p></div>
    <div class="item"><div class="small">Terrain</div><p>Conduite de travaux TCE, pilotage,
      marchés publics, dialogue avec artisans.</p></div>
  </div>
  {footer(4)}
</section>''')

# ── 05–06 · Projet phare, double page ───────────────────────────
hero = by_slug[HERO]
hero_imgs = images_of[HERO]
add(f'''
<section class="page bleed">
  {img(hero_imgs[0]) if hero_imgs else ""}
  <div class="bleed-caption">
    <div class="kicker light">Projet phare</div>
    <h2>{esc(hero["title"])}</h2>
    <p>{esc(hero["subtitle"])} — {esc(hero["year"])}</p>
  </div>
</section>''')
add(project_page(HERO, 6, layout="a"))

# ── Pôles ───────────────────────────────────────────────────────
n = 7
for pole in POLES:
    listing = "".join(
        f'<div class="divider-row"><span>{esc(by_slug[s]["id"])}</span>'
        f'<span>{esc(by_slug[s]["title"])}</span></div>' for s in pole["slugs"])
    # Bandeau d'images : une vignette par projet du pôle. Les rangées sont
    # explicites — Chrome ne peint pas la dernière rangée implicite d'une
    # grille en position absolue.
    band_imgs = [images_of[s][0] for s in pole["slugs"] if images_of[s]]
    band = "".join(img(p) for p in band_imgs)
    band_rows = f"repeat({len(band_imgs)}, 1fr)"
    add(f'''
<section class="page divider">
  <div class="divider-copy">
    <div class="divider-n">{pole["n"]}</div>
    <h2 class="divider-t">{esc(pole["titre"])}</h2>
    <p class="divider-a">{esc(pole["accroche"])}</p>
    <div class="divider-list">{listing}</div>
  </div>
  <div class="divider-band" style="grid-template-rows:{band_rows}">{band}</div>
  {footer(n)}
</section>''')
    n += 1
    for i, slug in enumerate(pole["slugs"]):
        add(project_page(slug, n, layout="b" if i % 2 else "a"))
        n += 1

# ── Annexe · autres travaux ─────────────────────────────────────
cells = ""
for slug in annexe:
    p = by_slug[slug]
    paths = images_of[slug]
    cover = img(paths[0]) if paths else '<div class="no-img">—</div>'
    cells += f'''<article class="sheet-cell">
      <div class="sheet-img">{cover}</div>
      <div class="sheet-info"><div class="sheet-num">{esc(p["id"])} — {esc(p["category"])}</div>
        <div class="sheet-title">{esc(p["title"])}</div></div>
    </article>'''
add(f'''
<section class="page annexe">
  <div class="kicker">Annexe</div>
  <h2 class="annexe-h2">Autres travaux</h2>
  <p class="annexe-intro">Pratiques continues qui nourrissent les projets de commande :
  dessin, carnets de recherche, photographie argentique, textile et transmission.</p>
  <div class="sheet">{cells}</div>
  {footer(n)}
</section>''')
n += 1

# ── Contact ─────────────────────────────────────────────────────
add(f'''
<section class="page closing">
  <div class="cover-top">
    <img src="file://{logo}">
    <span class="wordmark">Bazar Organisé</span>
  </div>
  <div class="closing-mid">
    <div class="kicker">Contact</div>
    <h2 class="closing-h2">Un projet tient mieux quand vision et réalité
    <span class="accent">avancent ensemble</span>.</h2>
    <p class="closing-p">Pour une identité visuelle, un espace, une fresque, un objet ou un
    projet hybride, le premier échange sert à clarifier le besoin, le contexte et le bon
    niveau d'intervention.</p>
    <div class="contact-grid">
      <div class="item"><div class="small">Email</div><p>contact@bazarorganise.fr</p></div>
      <div class="item"><div class="small">Site</div><p>bazarorganise.fr</p></div>
      <div class="item"><div class="small">Base</div><p>Alfortville (94) — Île-de-France</p></div>
    </div>
  </div>
  <div class="closing-foot">
    <span>Bazar Organisé — Xavier Talbot</span>
    <span>Île-de-France + déplacements France entière</span>
  </div>
</section>''')

CSS = """
/* A4 exprimé en pixels CSS entiers (794 × 1123 ≈ 210 × 297 mm) : en millimètres,
   Chrome arrondit la hauteur de page à quelques pixels de moins que la feuille et
   laisse un liseré blanc en bas des pages à fond coloré. */
@page { size: 794px 1123px; margin: 0; }
* { box-sizing: border-box; margin:0; padding:0; }
body { font-family: 'Helvetica Neue', Arial, sans-serif; color:#111; background:#FFF;
  -webkit-print-color-adjust: exact; print-color-adjust: exact; }
:root { --noir:#111; --gris1:#444; --gris2:#888; --gris3:#BBB; --border:#E5E5E5;
  --orange:#C46A2D; --paper:#F3F1ED; }

.page { width:794px; height:1123px; position:relative; page-break-after:always;
  overflow:hidden; padding:18mm; }
.page:last-child { page-break-after:auto; }
.footer-line { position:absolute; bottom:10mm; left:18mm; right:18mm; display:flex;
  justify-content:space-between; font-size:9px; color:var(--gris3);
  border-top:1px solid var(--border); padding-top:6px; }
.kicker { font-size:11px; font-weight:700; letter-spacing:.16em; text-transform:uppercase;
  color:var(--gris2); margin-bottom:26px; }
.kicker.sub { margin:22px 0 10px; font-size:10px; letter-spacing:.14em; }
.kicker.light { color:rgba(255,255,255,.75); margin-bottom:10px; }
.accent { color:var(--orange); }
.label { display:block; font-size:9px; font-weight:700; letter-spacing:.1em;
  text-transform:uppercase; color:var(--gris2); margin-bottom:6px; }

/* Couverture */
.cover { background:var(--paper); display:flex; flex-direction:column; justify-content:space-between; }
.cover-top { display:flex; align-items:center; gap:14px; }
.cover-top img { width:46px; height:46px; }
.wordmark { font-size:13px; font-weight:700; letter-spacing:.16em; text-transform:uppercase; }
.cover-eyebrow { display:inline-block; font-size:11px; font-weight:600; letter-spacing:.16em;
  text-transform:uppercase; color:var(--gris2); border:1px solid var(--border);
  border-radius:999px; padding:8px 16px; margin-bottom:26px; background:rgba(255,255,255,.6); }
.cover-title { font-size:46px; font-weight:700; letter-spacing:-.03em; line-height:1.08; margin-bottom:22px; }
.cover-sub { font-size:15px; color:var(--gris1); line-height:1.8; max-width:120mm; }
.cover-bottom { display:flex; justify-content:space-between; align-items:flex-end;
  border-top:1px solid var(--border); padding-top:18px; }
.cover-bottom .name { font-size:13px; font-weight:600; }
.cover-bottom .role { font-size:11px; color:var(--gris2); margin-top:4px; }
.cover-bottom .contact { font-size:11px; color:var(--gris2); text-align:right; line-height:1.7; }

/* Sommaire */
.toc-h2 { font-size:30px; font-weight:700; letter-spacing:-.03em; line-height:1.15; margin-bottom:30px; }
.toc-group { margin-bottom:20px; }
.toc-group-head { display:flex; align-items:baseline; gap:12px; padding-bottom:8px;
  border-bottom:1px solid var(--noir); margin-bottom:4px; }
.toc-group-n { font-size:10px; font-weight:700; letter-spacing:.14em; text-transform:uppercase;
  color:var(--orange); }
.toc-group-t { font-size:13px; font-weight:600; }
.toc-row { display:grid; grid-template-columns:34px minmax(0,1fr) auto; gap:14px;
  padding:9px 0; border-bottom:1px solid var(--border); align-items:center; }
.toc-num { font-size:11px; color:var(--gris3); font-weight:600; }
.toc-title { font-size:14px; font-weight:600; }
.toc-cat { font-size:11px; color:var(--gris2); text-align:right; }

/* À propos */
.about-h1 { font-size:30px; font-weight:700; letter-spacing:-.03em; line-height:1.12;
  max-width:15ch; margin-bottom:18px; }
.about-intro { font-size:13.5px; color:var(--gris1); line-height:1.8; max-width:150mm; margin-bottom:22px; }
.about-card { border:1px solid var(--border); border-radius:14px; padding:16px 18px;
  background:rgba(255,255,255,.6); }
.about-card p { font-size:12px; color:var(--gris1); line-height:1.7; }
.poles, .principles, .tools-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; }
.pole, .principle, .tools-grid .item { border:1px solid var(--border); border-radius:12px; padding:14px; }
.pole .n, .principle .n, .tools-grid .small { font-size:9px; font-weight:700; letter-spacing:.12em;
  text-transform:uppercase; color:var(--gris2); margin-bottom:8px; }
.pole h3, .principle h3 { font-size:15px; margin-bottom:6px; letter-spacing:-.02em; }
.pole p, .principle p, .tools-grid p { font-size:10.5px; color:var(--gris1); line-height:1.6; }
.timeline-item { display:grid; grid-template-columns:34mm minmax(0,1fr); gap:12px; padding:10px 0;
  border-top:1px solid var(--border); }
.timeline-date { font-size:10px; font-weight:700; letter-spacing:.08em; text-transform:uppercase;
  color:var(--gris2); }
.timeline-body h3 { font-size:13px; margin-bottom:4px; }
.timeline-body p { font-size:11px; color:var(--gris1); line-height:1.6; }

/* Page pleine image */
.bleed { padding:0; background:#111; }
.bleed img { width:100%; height:100%; object-fit:cover; display:block; }
.bleed-caption { position:absolute; left:0; right:0; bottom:0; padding:22mm 18mm 16mm;
  color:#fff; background:linear-gradient(to top, rgba(0,0,0,.78), rgba(0,0,0,0)); }
.bleed-caption h2 { font-size:34px; font-weight:700; letter-spacing:-.03em; line-height:1.05; }
.bleed-caption p { font-size:12px; color:rgba(255,255,255,.8); margin-top:8px; }

/* Pages projet */
.proj-page { background:#fff; display:flex; flex-direction:column; padding-bottom:22mm; }
.proj-head { flex:0 0 auto; }
.proj-meta { display:flex; gap:10px; align-items:center; margin-bottom:12px; }
.proj-num { font-size:11px; font-weight:700; color:var(--gris3); }
.proj-cat { font-size:10px; font-weight:600; letter-spacing:.1em; text-transform:uppercase;
  color:var(--gris2); border:1px solid var(--border); border-radius:999px; padding:4px 10px; }
.proj-year { font-size:10px; color:var(--gris3); margin-left:auto; }
.proj-title { font-size:27px; font-weight:700; letter-spacing:-.03em; line-height:1.08; margin-bottom:6px; }
.proj-subtitle { font-size:12.5px; color:var(--gris2); margin-bottom:20px; }
.proj-body { display:grid; grid-template-columns:62mm minmax(0,1fr); gap:12mm; flex:1 1 auto; min-height:0; }
.proj-desc { font-size:11.5px; line-height:1.75; color:var(--gris1); margin-bottom:16px; }
.proj-context p, .case-block p { font-size:11px; color:var(--gris1); line-height:1.65; margin-bottom:14px; }
.proj-tags { display:flex; flex-wrap:wrap; gap:6px; }
.tag { font-size:9px; font-weight:600; letter-spacing:.06em; text-transform:uppercase;
  color:var(--gris2); border:1px solid var(--border); border-radius:999px; padding:3px 9px; }
.proj-images, .proj-images-b { position:relative; overflow:hidden; border-radius:14px; background:#EFEFEF; }
.proj-images img, .proj-images-b img { width:100%; height:100%; object-fit:cover; display:block; }
.img-solo { width:100%; height:100%; }
.img-duo { display:grid; grid-template-rows:1fr 1fr; gap:4px; height:100%; }
.img-trio { display:grid; grid-template-columns:1fr 1fr; grid-template-rows:1fr 1fr; gap:4px; height:100%; }
.img-trio img:first-child { grid-row:1 / 3; }
.img-grid { display:grid; grid-template-columns:1fr 1fr; grid-template-rows:1fr 1fr; gap:4px; height:100%; }
.no-img { height:100%; display:flex; align-items:center; justify-content:center; color:var(--gris3);
  font-size:11px; letter-spacing:.1em; text-transform:uppercase; }

/* Variante B : bandeau image en haut, texte en trois colonnes */
.proj-body-b { display:flex; flex-direction:column; flex:1 1 auto; min-height:0; gap:10mm; }
.proj-images-b { flex:1 1 auto; min-height:0; }
.proj-images-b .img-trio { grid-template-columns:1.4fr 1fr; }
.proj-cols { flex:0 0 auto; display:grid; grid-template-columns:repeat(3,1fr); gap:10mm;
  border-top:1px solid var(--border); padding-top:12px; }
.proj-cols .proj-desc { margin-bottom:0; }
.proj-cols .tag { font-size:8px; padding:3px 7px; }
.proj-cols .proj-tags { align-content:flex-start; }

/* Intercalaires de pôle */
.divider { background:var(--paper); display:flex; flex-direction:column; justify-content:center; }
.divider-copy { max-width:110mm; }
.divider-band { position:absolute; top:0; right:0; bottom:0; width:68mm;
  display:grid; gap:4px; overflow:hidden; }
.divider .footer-line { right:82mm; }
.divider-band img { width:100%; height:100%; object-fit:cover; display:block; }
.divider-n { font-size:13px; font-weight:700; letter-spacing:.2em; color:var(--orange); margin-bottom:18px; }
.divider-t { font-size:44px; font-weight:700; letter-spacing:-.04em; line-height:1.02;
  max-width:14ch; margin-bottom:18px; }
.divider-a { font-size:15px; color:var(--gris1); line-height:1.8; max-width:90mm; margin-bottom:34px; }
.divider-list { border-top:1px solid var(--noir); max-width:120mm; }
.divider-row { display:grid; grid-template-columns:34px minmax(0,1fr); gap:14px; padding:10px 0;
  border-bottom:1px solid var(--border); font-size:13px; }
.divider-row span:first-child { color:var(--gris3); font-weight:600; font-size:11px; }

/* Annexe */
.annexe-h2 { font-size:30px; font-weight:700; letter-spacing:-.03em; margin-bottom:12px; }
.annexe-intro { font-size:12.5px; color:var(--gris1); line-height:1.75; max-width:130mm; margin-bottom:22px; }
.annexe { display:flex; flex-direction:column; padding-bottom:22mm; }
.sheet { display:grid; grid-template-columns:repeat(3,1fr); grid-auto-rows:1fr; gap:10px;
  flex:1 1 auto; min-height:0; }
.sheet-cell { border:1px solid var(--border); border-radius:12px; overflow:hidden; background:#fff;
  display:flex; flex-direction:column; min-height:0; }
.sheet-img { flex:1 1 auto; min-height:0; background:#EFEFEF; }
.sheet-img img { width:100%; height:100%; object-fit:cover; display:block; }
.sheet-info { padding:10px 12px 12px; }
.sheet-num { font-size:9px; font-weight:600; letter-spacing:.1em; text-transform:uppercase;
  color:var(--gris3); margin-bottom:4px; }
.sheet-title { font-size:12.5px; font-weight:600; letter-spacing:-.02em; }

/* Clôture */
.closing { background:var(--paper); display:flex; flex-direction:column; justify-content:space-between; }
.closing-mid { margin-top:auto; margin-bottom:auto; }
.closing-h2 { font-size:34px; font-weight:700; letter-spacing:-.03em; line-height:1.1;
  max-width:16ch; margin-bottom:18px; }
.closing-p { font-size:14px; color:var(--gris1); line-height:1.8; max-width:120mm; margin-bottom:30px; }
.contact-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:12px; max-width:150mm; }
.contact-grid .item { border:1px solid var(--border); border-radius:12px; padding:14px;
  background:rgba(255,255,255,.6); }
.contact-grid .small { font-size:9px; font-weight:700; letter-spacing:.1em; text-transform:uppercase;
  color:var(--gris2); margin-bottom:8px; }
.contact-grid p { font-size:12px; }
.closing-foot { display:flex; justify-content:space-between; font-size:10px; color:var(--gris2);
  border-top:1px solid var(--border); padding-top:14px; }
"""

doc = (f'<!DOCTYPE html>\n<html lang="fr">\n<head>\n<meta charset="UTF-8">\n'
       f'<title>Bazar Organisé — Portfolio</title>\n<style>{CSS}</style>\n</head>\n'
       f'<body>{"".join(pages)}</body>\n</html>\n')

with open(OUT_HTML, "w", encoding="utf-8") as f:
    f.write(doc)

print(f"wrote {OUT_HTML}")
print(f"sélection: {len(selected)} projets · annexe: {len(annexe)} · pages: {len(pages)}")
print("PDF : chromium --headless --no-pdf-header-footer "
      f"--print-to-pdf={os.path.join(REPO, 'portfolio', 'Bazar-Organise-Portfolio.pdf')} "
      f"file://{OUT_HTML}")
