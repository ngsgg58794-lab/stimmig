#!/usr/bin/env python3
"""Renders App Store marketing screenshots (1320x2868, 6.9") from raw app screenshots.

Usage: python3 render.py            # all slides
       python3 render.py 03-frage   # single slide
Raw screenshots go into raw/<id>.png (any iPhone portrait size); output lands in out/.
Slides without a raw screenshot use their fallback (older 1.0 shot) or a visible placeholder.
"""
import json, pathlib, subprocess, sys, html

ROOT = pathlib.Path(__file__).resolve().parent
W, H = 1320, 2868
CHROME = "/opt/pw-browsers/chromium-1194/chrome-linux/chrome"

TEMPLATE = """<!doctype html><html><head><meta charset="utf-8"><style>
@font-face {{ font-family: "Bricolage"; src: url("fonts/bricolage.woff2") format("woff2"); font-weight: 200 800; }}
@font-face {{ font-family: "DM Sans"; src: url("fonts/dmsans.woff2") format("woff2"); font-weight: 100 1000; }}
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
html, body {{ width: {W}px; height: {H}px; overflow: hidden; }}
body {{ background: {bg}; position: relative; font-family: "DM Sans", sans-serif; }}
.blob {{ position: absolute; border-radius: 50%; filter: blur(140px); opacity: {blob_opacity}; }}
.b1 {{ width: 1100px; height: 1100px; background: {c1}; left: -380px; top: -260px; }}
.b2 {{ width: 1000px; height: 1000px; background: {c2}; right: -420px; top: 1100px; }}
.head {{ position: absolute; top: 170px; left: 0; right: 0; text-align: center; padding: 0 90px; }}
.eyebrow {{ display: inline-block; font-weight: 700; font-size: 38px; letter-spacing: 4px; text-transform: uppercase;
  color: #FF2D78; background: {pill}; padding: 16px 34px; border-radius: 999px; }}
h1 {{ font-family: "Bricolage"; font-weight: 800; font-size: 124px; line-height: 1.02; letter-spacing: -4px;
  color: {ink}; margin-top: 44px; }}
p {{ font-weight: 500; font-size: 50px; line-height: 1.3; color: {muted}; margin: 34px auto 0; max-width: 1040px; }}
.phone {{ position: absolute; left: 50%; top: 920px; width: 1010px; height: 2186px; transform: translateX(-50%);
  background: #16130F; border-radius: 150px; padding: 26px;
  box-shadow: 0 60px 120px rgba(22,19,15,.28), 0 0 0 4px rgba(255,255,255,.35) inset; }}
.screen {{ width: 100%; height: 100%; border-radius: 126px; overflow: hidden; background: #FBFAF7; position: relative; }}
.screen img {{ width: 100%; height: 100%; object-fit: cover; object-position: top; display: block; }}
.island {{ position: absolute; top: 34px; left: 50%; transform: translateX(-50%); width: 300px; height: 88px;
  background: #000; border-radius: 60px; }}
.placeholder {{ position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; text-align: center;
  font: 700 54px "DM Sans"; color: #FF2D78; background: repeating-linear-gradient(45deg,#FFE3EE 0 40px,#FFF 40px 80px); padding: 80px; }}
</style></head><body>
<div class="blob b1"></div><div class="blob b2"></div>
<div class="head">
  <span class="eyebrow">{eyebrow}</span>
  <h1>{title}</h1>
  <p>{sub}</p>
</div>
<div class="phone"><div class="screen">{screen}<div class="island"></div></div></div>
</body></html>"""


def render(slide):
    shot = ROOT / slide["shot"]
    if not shot.exists() and slide.get("fallback"):
        shot = ROOT / slide["fallback"]
    if shot.exists():
        screen = f'<img src="{shot.resolve().as_uri()}">'
        status = shot.relative_to(ROOT.parent) if shot.is_relative_to(ROOT.parent) else shot
    else:
        screen = f'<div class="placeholder">Screenshot fehlt:<br>{html.escape(slide["shot"])}</div>'
        status = "PLATZHALTER"
    dark = slide.get("dark", False)
    page = TEMPLATE.format(
        W=W, H=H,
        bg="#141110" if dark else "#FBFAF7",
        ink="#F3EFE9" if dark else "#16130F",
        muted="#9D958B" if dark else "#7A736B",
        pill="#3D1A28" if dark else "#FFE3EE",
        blob_opacity=0.35 if dark else 0.55,
        c1=slide["colors"][0], c2=slide["colors"][1],
        eyebrow=html.escape(slide["eyebrow"]), title=slide["title"], sub=html.escape(slide["sub"]),
        screen=screen,
    )
    src = ROOT / f".{slide['id']}.html"
    src.write_text(page, encoding="utf-8")
    out = ROOT / "out" / f"{slide['id']}.png"
    subprocess.run([
        CHROME, "--headless=new", "--no-sandbox", "--hide-scrollbars", "--disable-gpu",
        "--allow-file-access-from-files", "--force-device-scale-factor=1",
        f"--window-size={W},{H}", "--virtual-time-budget=3000",
        f"--screenshot={out}", src.as_uri(),
    ], check=True, capture_output=True)
    src.unlink()
    print(f"{out.name:24} ← {status}")


if __name__ == "__main__":
    slides = json.loads((ROOT / "slides.json").read_text(encoding="utf-8"))
    wanted = set(sys.argv[1:])
    for s in slides:
        if not wanted or s["id"] in wanted:
            render(s)
