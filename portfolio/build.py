#!/usr/bin/env python3
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

with open(os.path.join(REPO, "projects.json"), encoding="utf-8") as f:
    projects = json.load(f)

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

def img_block(paths):
    n = len(paths)
    if n == 0:
        return '<div class="no-img">Images à venir</div>'
    tags = "".join(f'<img src="file://{optimize(p)}">' for p in paths)
    if n == 1:
        return f'<div class="img-solo">{tags}</div>'
    if n == 2:
        return f'<div class="img-duo">{tags}</div>'
    if n == 3:
        return f'<div class="img-trio">{tags}</div>'
    return f'<div class="img-grid">{tags}</div>'

project_pages = []
page_no = 5
for p in projects:
    imgs = p.get("images_folder")
    paths = list_images(imgs) if imgs else []
    block = img_block(pick_spread(paths, 4))

    tags = "".join(f'<span class="tag">{esc(t)}</span>' for t in p.get("tags", []))

    project_pages.append(f'''
  <section class="page proj-page">
    <div class="proj-head">
      <div class="proj-meta">
        <span class="proj-num">{esc(p["id"])}</span>
        <span class="proj-cat">{esc(p["category"])}</span>
        <span class="proj-year">{esc(p["year"])}</span>
      </div>
      <h2 class="proj-title">{esc(p["title"])}</h2>
      <p class="proj-subtitle">{esc(p["subtitle"])}</p>
    </div>
    <div class="proj-body">
      <div class="proj-text">
        <p class="proj-desc">{esc(p["description"])}</p>
        <div class="proj-context"><span class="label">Contexte</span><p>{esc(p["context"])}</p></div>
        <div class="proj-tags">{tags}</div>
      </div>
      <div class="proj-images">{block}</div>
    </div>
    <div class="footer-line"><span>Bazar Organisé — Portfolio</span><span>{page_no:02d}</span></div>
  </section>
''')
    page_no += 1

toc_rows = "".join(
    f'<div class="toc-row"><span class="toc-num">{esc(p["id"])}</span>'
    f'<span class="toc-title">{esc(p["title"])}</span>'
    f'<span class="toc-cat">{esc(p["category"])}</span></div>'
    for p in projects
)

logo_path = os.path.join(REPO, "logo-bo.svg")

html_doc = f'''<!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="UTF-8">
<title>Bazar Organisé — Portfolio</title>
<style>
@page {{ size: A4; margin: 0; }}
* {{ box-sizing: border-box; margin:0; padding:0; }}
html {{ font-size: 16px; }}
body {{
  font-family: 'Helvetica Neue', Arial, -apple-system, sans-serif;
  color: #111111;
  background: #FAFAFA;
  -webkit-print-color-adjust: exact;
  print-color-adjust: exact;
}}
:root {{
  --noir:#111111; --gris1:#444444; --gris2:#888888; --gris3:#BBBBBB;
  --border:#E5E5E5; --orange:#C46A2D; --paper:#F3F1ED;
}}
.page {{
  width: 210mm;
  height: 297mm;
  position: relative;
  page-break-after: always;
  overflow: hidden;
  padding: 18mm;
}}
.page:last-child {{ page-break-after: auto; }}

/* ---- COVER ---- */
.cover {{
  background: var(--paper);
  display: flex;
  flex-direction: column;
  justify-content: space-between;
}}
.cover-top {{ display:flex; align-items:center; gap:14px; }}
.cover-top img {{ width: 46px; height: 46px; }}
.cover-top .wordmark {{ font-size: 13px; font-weight:700; letter-spacing:.16em; text-transform:uppercase; }}
.cover-mid {{ max-width: 150mm; }}
.cover-eyebrow {{
  display:inline-block; font-size: 11px; font-weight:600; letter-spacing:.16em; text-transform:uppercase;
  color: var(--gris2); border:1px solid var(--border); border-radius:999px; padding:8px 16px; margin-bottom:26px;
  background: rgba(255,255,255,.6);
}}
.cover-title {{ font-size: 46px; font-weight:700; letter-spacing:-.03em; line-height:1.08; margin-bottom:22px; }}
.cover-title .accent {{ color: var(--orange); }}
.cover-sub {{ font-size: 15px; color: var(--gris1); line-height:1.8; max-width: 120mm; }}
.cover-bottom {{ display:flex; justify-content:space-between; align-items:flex-end; border-top:1px solid var(--border); padding-top:18px; }}
.cover-bottom .name {{ font-size: 13px; font-weight:600; }}
.cover-bottom .role {{ font-size: 11px; color:var(--gris2); margin-top:4px; }}
.cover-bottom .contact {{ font-size: 11px; color:var(--gris2); text-align:right; line-height:1.7; }}

/* ---- TOC ---- */
.toc-title-h {{ font-size: 12px; font-weight:700; letter-spacing:.16em; text-transform:uppercase; color:var(--gris2); margin-bottom: 34px; }}
.toc-h2 {{ font-size: 32px; font-weight:700; letter-spacing:-.03em; max-width: 12ch; margin-bottom: 30px; }}
.toc-list {{ margin-top: 10px; }}
.toc-row {{ display:grid; grid-template-columns: 34px minmax(0,1fr) auto; gap: 14px; padding: 11px 0; border-top:1px solid var(--border); align-items:center; }}
.toc-row:last-child {{ border-bottom:1px solid var(--border); }}
.toc-num {{ font-size: 11px; color: var(--gris3); font-weight:600; }}
.toc-title {{ font-size: 14px; font-weight:600; }}
.toc-cat {{ font-size: 11px; color: var(--gris2); text-align:right; }}

/* ---- ABOUT ---- */
.about-h1 {{ font-size: 30px; font-weight:700; letter-spacing:-.03em; line-height:1.12; max-width: 15ch; margin-bottom:18px; }}
.about-h1 .accent {{ color: var(--orange); }}
.about-intro {{ font-size: 13.5px; color: var(--gris1); line-height:1.8; max-width: 150mm; margin-bottom: 22px; }}
.about-card {{ border:1px solid var(--border); border-radius:14px; padding:16px 18px; background: rgba(255,255,255,.6); margin-bottom: 22px; }}
.about-card .label {{ font-size: 10px; font-weight:700; letter-spacing:.12em; text-transform:uppercase; color:var(--gris2); margin-bottom:8px; }}
.about-card p {{ font-size: 12px; color: var(--gris1); line-height:1.7; }}
.poles {{ display:grid; grid-template-columns: repeat(3,1fr); gap:12px; margin-top: 6px; }}
.pole {{ border:1px solid var(--border); border-radius:12px; padding:14px; }}
.pole .n {{ font-size: 9px; font-weight:700; letter-spacing:.12em; text-transform:uppercase; color: var(--gris2); margin-bottom:8px; }}
.pole h3 {{ font-size: 15px; margin-bottom:6px; letter-spacing:-.02em; }}
.pole p {{ font-size: 10.5px; color: var(--gris1); line-height:1.6; }}
.section-kicker-sm {{ font-size: 10px; font-weight:700; letter-spacing:.14em; text-transform:uppercase; color:var(--gris2); margin: 20px 0 8px; }}

/* ---- ABOUT PAGE 2 ---- */
.timeline-item {{ display:grid; grid-template-columns: 34mm minmax(0,1fr); gap: 12px; padding: 10px 0; border-top:1px solid var(--border); }}
.timeline-item:last-child {{ border-bottom: 1px solid var(--border); }}
.timeline-date {{ font-size: 10px; font-weight:700; letter-spacing:.08em; text-transform:uppercase; color: var(--gris2); }}
.timeline-body h3 {{ font-size: 13px; margin-bottom:4px; }}
.timeline-body p {{ font-size: 11px; color: var(--gris1); line-height:1.6; }}
.principles {{ display:grid; grid-template-columns: repeat(3,1fr); gap:12px; }}
.principle {{ border:1px solid var(--border); border-radius:12px; padding:14px; }}
.principle .n {{ font-size: 9px; font-weight:700; color:var(--gris2); margin-bottom:8px; }}
.principle h3 {{ font-size: 13.5px; margin-bottom:6px; letter-spacing:-.02em; }}
.principle p {{ font-size: 10.5px; color:var(--gris1); line-height:1.6; }}
.contact-grid {{ display:grid; grid-template-columns: repeat(3,1fr); gap:12px; }}
.contact-grid .item {{ border:1px solid var(--border); border-radius:12px; padding:14px; }}
.contact-grid .small {{ font-size: 9px; font-weight:700; letter-spacing:.1em; text-transform:uppercase; color:var(--gris2); margin-bottom:8px; }}
.contact-grid p, .contact-grid a {{ font-size: 12px; color: var(--noir); text-decoration:none; }}

/* ---- PROJECT PAGES ---- */
.proj-page {{ background: #fff; display:flex; flex-direction:column; padding-bottom: 22mm; }}
.proj-head {{ flex: 0 0 auto; }}
.proj-meta {{ display:flex; gap: 10px; align-items:center; margin-bottom: 12px; }}
.proj-num {{ font-size: 11px; font-weight:700; color: var(--gris3); }}
.proj-cat {{ font-size: 10px; font-weight:600; letter-spacing:.1em; text-transform:uppercase; color: var(--gris2); border:1px solid var(--border); border-radius:999px; padding:4px 10px; }}
.proj-year {{ font-size: 10px; color: var(--gris3); margin-left:auto; }}
.proj-title {{ font-size: 27px; font-weight:700; letter-spacing:-.03em; line-height:1.08; margin-bottom: 6px; }}
.proj-subtitle {{ font-size: 12.5px; color: var(--gris2); margin-bottom: 20px; }}
.proj-body {{ display:grid; grid-template-columns: 62mm minmax(0,1fr); gap: 12mm; flex: 1 1 auto; min-height: 0; }}
.proj-desc {{ font-size: 11.5px; line-height:1.75; color: var(--gris1); margin-bottom: 16px; }}
.proj-context .label {{ font-size: 9px; font-weight:700; letter-spacing:.1em; text-transform:uppercase; color:var(--gris2); margin-bottom:6px; }}
.proj-context p {{ font-size: 11px; color: var(--gris1); margin-bottom: 16px; }}
.proj-tags {{ display:flex; flex-wrap:wrap; gap:6px; }}
.tag {{ font-size: 9px; font-weight:600; letter-spacing:.06em; text-transform:uppercase; color: var(--gris2); border:1px solid var(--border); border-radius:999px; padding:3px 9px; }}
.proj-images {{ position:relative; overflow:hidden; border-radius: 14px; background:#EFEFEF; }}
.proj-images img {{ width:100%; height:100%; object-fit:cover; display:block; }}
.img-solo {{ width:100%; height:100%; }}
.img-duo {{ display:grid; grid-template-rows: 1fr 1fr; gap:4px; height:100%; }}
.img-trio {{ display:grid; grid-template-columns: 1fr 1fr; grid-template-rows: 1fr 1fr; gap:4px; height:100%; }}
.img-trio img:first-child {{ grid-row: 1 / 3; }}
.img-grid {{ display:grid; grid-template-columns: 1fr 1fr; grid-template-rows: 1fr 1fr; gap:4px; height:100%; }}
.no-img {{ height:100%; display:flex; align-items:center; justify-content:center; color:var(--gris3); font-size:11px; letter-spacing:.1em; text-transform:uppercase; }}

/* ---- FOOTER (running) ---- */
.footer-line {{ position:absolute; bottom: 10mm; left: 18mm; right: 18mm; display:flex; justify-content:space-between; font-size: 9px; color: var(--gris3); border-top:1px solid var(--border); padding-top: 6px; }}
</style>
</head>
<body>

<!-- COVER -->
<section class="page cover">
  <div class="cover-top">
    <img src="file://{logo_path}">
    <span class="wordmark">Bazar Organisé</span>
  </div>
  <div class="cover-mid">
    <div class="cover-eyebrow">Studio / atelier créatif pluridisciplinaire</div>
    <h1 class="cover-title">Du logo à l'espace,<br>je conçois et réalise<br>des projets qui tiennent dans la <span class="accent">réalité</span>.</h1>
    <p class="cover-sub">Portfolio — identité visuelle, scénographie, design d'espace, art mural, mobilier, réalisation et pilotage.</p>
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
</section>

<!-- TOC -->
<section class="page toc">
  <div class="toc-title-h">Sommaire</div>
  <h2 class="toc-h2">14 projets sélectionnés</h2>
  <div class="toc-list">
    {toc_rows}
  </div>
  <div class="footer-line"><span>Bazar Organisé — Portfolio</span><span>02</span></div>
</section>

<!-- ABOUT 1 -->
<section class="page about">
  <div class="toc-title-h">À propos</div>
  <h1 class="about-h1">Séduire par l'univers. <span class="accent">Convaincre</span> par la méthode.</h1>
  <p class="about-intro">Je suis Xavier Talbot. Sous la marque Bazar Organisé, je développe des projets qui tiennent dans la réalité : identités visuelles, scénographies, fresques murales, mobilier design, aménagements d'espaces et pilotage de réalisation. Mon rôle est simple : garder la chaîne complète entre intention créative, faisabilité technique et mise en œuvre.</p>
  <div class="about-card">
    <div class="label">Positionnement</div>
    <p>Ni street artist pur, ni graphiste freelance classique, ni technicien sans vision. Bazar Organisé fonctionne comme une interface unique entre idée graphique et construction physique. Du logo au mur, de l'espace à l'objet, un seul interlocuteur du brief à la livraison.</p>
  </div>
  <div class="section-kicker-sm">01 — Expertise — Trois pôles, une seule logique de projet</div>
  <div class="poles">
    <article class="pole">
      <div class="n">Le cerveau</div>
      <h3>Identité visuelle</h3>
      <p>Logos, chartes graphiques, univers visuels complets, édition, signalétique, textile, applications grand format.</p>
    </article>
    <article class="pole">
      <div class="n">La vision</div>
      <h3>Scénographie & espace</h3>
      <p>Aménagements, relevés, modélisations 2D/3D, fresques et dispositifs spatiaux conçus pour être compris, fabriqués et utilisés.</p>
    </article>
    <article class="pole">
      <div class="n">La main</div>
      <h3>Réalisation & pilotage</h3>
      <p>Conduite de projet, coordination chantier, fabrication, adaptation terrain et maîtrise des contraintes techniques et budgétaires.</p>
    </article>
  </div>
  <div class="footer-line"><span>Bazar Organisé — Portfolio</span><span>03</span></div>
</section>

<!-- ABOUT 2 -->
<section class="page about2">
  <div class="section-kicker-sm" style="margin-top:0;">02 — Parcours — Un parcours hybride, visuel et opérationnel</div>
  <div class="timeline-item">
    <div class="timeline-date">2022 → aujourd'hui</div>
    <div class="timeline-body"><h3>Bazar Organisé — Concepteur-réalisateur indépendant</h3><p>Identité visuelle, scénographie, fresques, mobilier sur-mesure, aménagement d'espace et coordination de projets pour restaurateurs, collectivités, associations et agences.</p></div>
  </div>
  <div class="timeline-item">
    <div class="timeline-date">2018 → 2023</div>
    <div class="timeline-body"><h3>Architecte d'intérieur — activité indépendante</h3><p>Métrés, plans 2D/3D, modélisation, photomontages, dossiers de permis et suivi d'exécution.</p></div>
  </div>
  <div class="timeline-item">
    <div class="timeline-date">2014 → 2018</div>
    <div class="timeline-body"><h3>Paris Habitat + Mairie de Fontenay-sous-Bois</h3><p>Gestion de patrimoine bâti, marchés publics, réception de chantier, dossiers ERP, coordination des prestataires.</p></div>
  </div>
  <div class="timeline-item">
    <div class="timeline-date">2006 → 2013</div>
    <div class="timeline-body"><h3>Infrastructure, architecture, transport</h3><p>Cabinet d'architecte, SNCF, ADP, Colas Rail, Vinci : plans d'exécution, documentation, coordination, génie civil.</p></div>
  </div>

  <div class="section-kicker-sm">03 — Principes</div>
  <div class="principles">
    <article class="principle"><div class="n">01</div><h3>Concevoir, c'est anticiper</h3><p>Chaque projet est pensé au-delà de son image : usage réel, maintenance, évolution dans le temps.</p></article>
    <article class="principle"><div class="n">02</div><h3>La contrainte est une matière de projet</h3><p>Réglementation, budget, délais et techniques constructives permettent des réponses plus justes et plus solides.</p></article>
    <article class="principle"><div class="n">03</div><h3>La justesse avant l'effet</h3><p>Chaque forme, matériau ou couleur répond à une logique d'usage, de contexte ou de narration.</p></article>
  </div>

  <div class="section-kicker-sm">04 — Contact</div>
  <div class="contact-grid">
    <div class="item"><div class="small">Email</div><a href="mailto:contact@bazarorganise.fr">contact@bazarorganise.fr</a></div>
    <div class="item"><div class="small">Base</div><p>Alfortville (94) — Île-de-France</p></div>
    <div class="item"><div class="small">Périmètre</div><p>Île-de-France + déplacements France entière</p></div>
  </div>
  <div class="footer-line"><span>Bazar Organisé — Portfolio</span><span>04</span></div>
</section>

{"".join(project_pages)}

</body>
</html>
'''

with open(OUT_HTML, "w", encoding="utf-8") as f:
    f.write(html_doc)

print("wrote", OUT_HTML, "projects:", len(projects))
print("PDF : chromium --headless --no-pdf-header-footer "
      f"--print-to-pdf={os.path.join(REPO, 'portfolio', 'Bazar-Organise-Portfolio.pdf')} "
      f"file://{OUT_HTML}")
