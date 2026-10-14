#!/usr/bin/env python3
"""Generate the layout and schematic pictures of every cell and keep them in the READMEs.

  update_images.py <cell|all> [--no-readme] [--dry-run] [--check] [--staged] [--labels]

Pictures (docs/<cell>/media/, one canonical place; files are only rewritten when their bytes change):
  <cell>_schematic.svg/.png   xschem schematic, light colour scheme, cropped, WITHOUT the SPICE code blocks (.param, simulator commands:
                              every instance of type netlist_commands is deleted from the in-memory copy, the .sch file is not touched)
  <cell>_symbol.svg           the symbol
  <cell>_layout.png           KLayout rendering of the GDS with the PDK layer properties (texts hidden, --labels shows them)
README blocks (skipped with --no-readme): text between `<!-- AUTO:<kind>:<cell> -->` and `<!-- /AUTO -->` belongs to this script and is
replaced; nothing else in a README is touched. A block that does not exist yet is created at the first sensible place:
  gds/<dir>/README.md      under the heading named by `title:` in cells.yaml: the first picture there is replaced by the layout, and the
                           `Dimension:` / `Physical Spec` fence by the measured W/L
  xschem/<cell>/README.md  the first picture under a heading containing topology|schematic|circuit is replaced (or the block goes right
                           below that heading); without such a heading it goes below the first `# ` title; a missing README is created
--dry-run prints what would change, --check does the same and exits 1 if anything is out of date (CI), --staged only handles cells whose
.sch/.sym/.gds are staged in git (pre-commit hook, scripts/install_hooks.sh). Needs: xschem, klayout (python), cairosvg, pillow.
"""
import argparse
import io
import os
import re
import subprocess
import sys
import tempfile

import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PDK = "ihp-sg13cmos5l"   # not $PDK: the container default is ihp-sg13g2 (same reason the shell scripts export it)
PDK_ROOT = os.environ.get("PDK_ROOT", "/foss/pdks")
LYP = os.path.join(PDK_ROOT, PDK, "libs.tech", "klayout", "tech", "sg13cmos5l.lyp")
IMG_LINE = re.compile(r"^\s*(<img\b.*>|!\[[^\]]*\]\([^)]*\)|Insert image)\s*$", re.I)
HEADING = re.compile(r"^(#{1,6})\s+(.*?)\s*$")
BLOCK = re.compile(r"<!-- AUTO:(\w+):([\w.-]+) -->.*?<!-- /AUTO -->", re.S)

stats = dict(updated=0, unchanged=0, errors=0, warnings=0)
WRITE = True
LOG = []


def log(msg):
    LOG.append(msg)
    print(msg)


# ------------------------------------------------------------------------------------------------ files
def put(path, data, what=None):
    """write bytes/str only when different; honour --dry-run/--check"""
    if isinstance(data, str):
        data = data.encode()
    old = open(path, "rb").read() if os.path.isfile(path) else None
    rel = os.path.relpath(path, ROOT)
    if old == data:
        stats["unchanged"] += 1
        return False
    stats["updated"] += 1
    log(f"  {'would update' if not WRITE else 'updated'}: {rel}" + (f" ({what})" if what else ""))
    if WRITE:
        os.makedirs(os.path.dirname(path), exist_ok=True)
        open(path, "wb").write(data)
    return True


# ------------------------------------------------------------------------------------------------ schematic
TCL = """\
set ::dark_colorscheme 0
catch {{xschem build_colors}}
foreach {{name sym type}} [xschem instance_list] {{
  if {{$type eq "netlist_commands"}} {{
    xschem select instance $name
    xschem delete
  }}
}}
xschem zoom_full
xschem print svg {out}
"""


def render_schematic(sch, tmp, strip_code=True):
    """-> (svg_text, png_bytes) or None. The sheet is a fixed canvas: crop to the drawing and give the SVG a matching viewBox."""
    from PIL import Image, ImageChops
    import cairosvg

    d = os.path.dirname(sch)
    out = os.path.join(tmp, "out.svg")
    script = os.path.join(tmp, "draw.tcl")
    open(script, "w").write((TCL if strip_code else TCL.replace('$type eq "netlist_commands"', "0")).format(out=out))
    rc = os.path.join(d, "xschemrc")
    if not os.path.isfile(rc):
        rc = os.path.join(PDK_ROOT, PDK, "libs.tech", "xschem", "xschemrc")
    env = dict(os.environ, PDK=PDK, PDK_ROOT=PDK_ROOT, HOME=tmp, PATH=os.path.join(ROOT, "scripts", "bin") + ":" + os.environ["PATH"])
    env.pop("DISPLAY", None)   # headless: with DISPLAY set xschem first tries the X server (see scripts/run_cace.sh)
    p = subprocess.run(["xschem", "-x", "-q", "-r", "--rcfile", rc, "--script", script, os.path.basename(sch)], cwd=d, env=env,
                       capture_output=True, text=True, timeout=120)
    if not os.path.isfile(out):
        log(f"  ERROR xschem produced no svg for {os.path.relpath(sch, ROOT)}: {p.stdout[-300:]}{p.stderr[-300:]}")
        return None
    missing = sorted({l.split("Symbol not found:")[-1].strip() for l in (p.stdout + p.stderr).splitlines() if "Symbol not found" in l})
    if missing:
        stats["warnings"] += 1
        log(f"  WARNING {os.path.relpath(sch, ROOT)}: symbol(s) not found, drawn as ---MISSING SYMBOL---: {', '.join(missing)[:300]}")
    svg = open(out).read()
    m = re.search(r'<svg[^>]*width="([\d.]+)" height="([\d.]+)"', svg)
    w0, h0 = float(m.group(1)), float(m.group(2))
    S = 2.0
    png = cairosvg.svg2png(bytestring=svg.encode(), scale=S)
    im = Image.open(io.BytesIO(png)).convert("RGB")
    bbox = ImageChops.difference(im, Image.new("RGB", im.size, (255, 255, 255))).getbbox()
    if not bbox:
        log(f"  ERROR empty drawing for {os.path.relpath(sch, ROOT)}")
        return None
    pad = 24
    x0, y0 = max(0, bbox[0] - pad), max(0, bbox[1] - pad)
    x1, y1 = min(im.width, bbox[2] + pad), min(im.height, bbox[3] + pad)
    buf = io.BytesIO()
    im.crop((x0, y0, x1, y1)).save(buf, "PNG", optimize=True)
    w, h = (x1 - x0) / S, (y1 - y0) / S
    svg = re.sub(r'(<svg[^>]*?)width="[\d.]+" height="[\d.]+"', lambda m: f'{m.group(1)}width="{w:.0f}" height="{h:.0f}" viewBox="{x0 / S:.1f} {y0 / S:.1f} {w:.1f} {h:.1f}"', svg, count=1)
    return svg, buf.getvalue()


# ------------------------------------------------------------------------------------------------ layout
def render_layout(gds, top, png_path, labels=False):
    """-> (png_bytes, (W, H) um) or None"""
    import klayout.lay as lay

    lv = lay.LayoutView()
    lv.load_layout(gds, True)
    if os.path.isfile(LYP):
        lv.load_layer_props(LYP)
    ly = lv.active_cellview().layout()
    ci = ly.cell_by_name(top) if top in [c.name for c in ly.each_cell()] else None
    if ci is None:
        tops = list(ly.each_top_cell())
        if not tops:
            log(f"  ERROR no cell in {os.path.relpath(gds, ROOT)}")
            return None
        ci = tops[0]
        log(f"  note: top cell '{top}' not in {os.path.basename(gds)}, using '{ly.cell(ci).name}'")
    lv.select_cell(ci, 0)
    lv.max_hier()
    bb = ly.cell(ci).dbbox()
    W, H = bb.width(), bb.height()
    lv.set_config("background-color", "#ffffff")
    lv.set_config("grid-visible", "false")
    lv.set_config("text-visible", "true" if labels else "false")
    lv.zoom_fit()
    width = 1600
    height = int(max(300, min(1600, width * H / W + 20))) if W else 800
    lv.resize(width, height)
    lv.zoom_box(bb.enlarged(max(W, H) * 0.02, max(W, H) * 0.02))
    tmp = png_path + ".tmp.png"
    lv.save_image(tmp, width, height)
    data = open(tmp, "rb").read()
    os.remove(tmp)
    return data, (W, H)


# ------------------------------------------------------------------------------------------------ README editing
def fence(txt, kind="bash"):
    return f"```{kind}\n{txt}\n```"


def block(kind, cell, body):
    return f"<!-- AUTO:{kind}:{cell} -->\n{body}\n<!-- /AUTO -->"


def find_heading(lines, pred):
    for i, l in enumerate(lines):
        m = HEADING.match(l)
        if m and pred(m.group(2)):
            return i, len(m.group(1))
    return None, None


def section_end(lines, i, level):
    for j in range(i + 1, len(lines)):
        m = HEADING.match(lines[j])
        if m and len(m.group(1)) <= level:
            return j
    return len(lines)


def apply_block(text, kind, cell, body, heading_pred=None, fallback="h1", after_marker=None):
    """-> new text. Replace an existing block, or place a new one (see module doc)."""
    new = block(kind, cell, body)
    pat = re.compile(rf"<!-- AUTO:{kind}:{re.escape(cell)} -->.*?<!-- /AUTO -->", re.S)
    if pat.search(text):
        return pat.sub(lambda m: new, text, count=1)
    lines = text.split("\n")
    if after_marker:
        m = re.search(rf"<!-- AUTO:{after_marker}:{re.escape(cell)} -->.*?<!-- /AUTO -->", text, re.S)
        if m:
            return text[: m.end()] + "\n\n" + new + text[m.end():]
    if heading_pred:
        i, lvl = find_heading(lines, heading_pred)
        if i is not None:
            end = section_end(lines, i, lvl)
            for j in range(i + 1, end):
                if IMG_LINE.match(lines[j]):
                    return "\n".join(lines[:j] + [new] + lines[j + 1:])
            if fallback == "heading":
                return "\n".join(lines[: i + 1] + ["", new] + lines[i + 1:])
    if fallback == "none":
        return None
    i, _ = find_heading(lines, lambda t: True)
    if i is not None and HEADING.match(lines[i]).group(1) == "#":
        return "\n".join(lines[: i + 1] + ["", new, ""] + lines[i + 1:]).replace("\n\n\n\n", "\n\n\n")
    return new + "\n\n" + text


def replace_dimension(text, cell, W, H):
    """the `Dimension:` fence (or the `Physical Spec` fence with W = ..) that follows the layout block -> measured W/L in its own block"""
    body = fence(f"W = {W:.2f}um\nL = {H:.2f}um")
    if re.search(rf"<!-- AUTO:dims:{re.escape(cell)} -->", text):
        return apply_block(text, "dims", cell, body)
    m = re.search(rf"<!-- AUTO:layout:{re.escape(cell)} -->.*?<!-- /AUTO -->", text, re.S)
    if not m:
        return text
    tail = text[m.end():]
    seg = tail
    for h in re.finditer(r"\n#{1,6} +(.*)", tail):   # the section ends at the next heading that is not a "Physical Spec"/"Dimension" one
        if not re.search(r"physical spec|dimension", h.group(1), re.I):
            seg = tail[: h.start()]
            break
    # "Dimension:" + fence (or "Insert dimension") directly after the picture, else the first W = / L = fence of the section
    d = re.search(r"\n*(Dimension:\s*\n+(```[^\n]*\n.*?\n```|Insert dimension))", seg, re.S)
    if d:
        a, b = d.start(1), d.end(1)
        return text[: m.end() + a] + "Dimension:\n" + block("dims", cell, body) + text[m.end() + b:]
    f = re.search(r"```[^\n]*\n(?:[^`]*?)W\s*=[^`]*?```", seg, re.S)
    if f:
        return text[: m.end() + f.start()] + block("dims", cell, body) + text[m.end() + f.end():]
    return text


# ------------------------------------------------------------------------------------------------ main
def staged_files():
    out = subprocess.run(["git", "-C", ROOT, "diff", "--cached", "--name-only"], capture_output=True, text=True).stdout.split()
    return set(out)


def cells_of(args, reg):
    if args.cell != "all":
        if args.cell not in reg:
            sys.exit(f"update_images: {args.cell} is not in cells.yaml")
        return [args.cell]
    names = [c for c, v in reg.items() if v.get("sch") or v.get("gds")]
    if args.staged:
        st = staged_files()
        sel = []
        for c in names:
            v = reg[c]
            dirs = {os.path.dirname(v[k]) for k in ("sch",) if v.get(k)}
            files = {v.get("gds")} | {s for s in v.get("schematics", [])}
            if any(f in st for f in files if f) or any(f.startswith(d + "/") and f.endswith((".sch", ".sym")) for f in st for d in dirs):
                sel.append(c)
        return sel
    return names


def do_cell(cell, v, args):
    media = os.path.join(ROOT, "docs", cell, "media")
    res = {}
    with tempfile.TemporaryDirectory() as tmp:
        sch = os.path.join(ROOT, v["sch"]) if v.get("sch") else None
        if sch and os.path.isfile(sch):
            r = render_schematic(sch, tmp)
            if r:
                put(os.path.join(media, f"{cell}_schematic.svg"), r[0])
                put(os.path.join(media, f"{cell}_schematic.png"), r[1])
                res["schematic"] = True
            sym = sch[:-4] + ".sym"
            if os.path.isfile(sym):
                tmp2 = os.path.join(tmp, "sym")
                os.makedirs(tmp2)
                r = render_schematic(sym, tmp2, strip_code=False)
                if r:
                    put(os.path.join(media, f"{cell}_symbol.svg"), r[0])
            for k, extra in enumerate(v.get("schematics", []) or []):
                ep = os.path.join(ROOT, extra)
                tmp3 = os.path.join(tmp, f"x{k}")
                os.makedirs(tmp3)
                r = render_schematic(ep, tmp3) if os.path.isfile(ep) else None
                if r:
                    base = os.path.splitext(os.path.basename(extra))[0]
                    put(os.path.join(media, f"{cell}_{base}_schematic.svg"), r[0])
                    put(os.path.join(media, f"{cell}_{base}_schematic.png"), r[1])
                    res.setdefault("extra", []).append(base)
        gds = os.path.join(ROOT, v["gds"]) if v.get("gds") else None
        if gds and os.path.isfile(gds):
            r = render_layout(gds, v.get("top", cell), os.path.join(tmp, "l.png"), args.labels)
            if r:
                put(os.path.join(media, f"{cell}_layout.png"), r[0])
                res["layout"] = r[1]
    return res


def readmes(cell, v, res, args):
    rel = lambda p: os.path.relpath(p, ROOT)
    # ---- xschem README: schematic (+ layout when the cell has no title in the gds README)
    if v.get("sch") and (res.get("schematic") or res.get("layout")):
        rp = os.path.join(ROOT, os.path.dirname(v["sch"]), "README.md")
        text = open(rp).read() if os.path.isfile(rp) else f"# {cell}\n"
        new = text
        pred = lambda t: re.search(r"topology|schematic|circuit", t, re.I) is not None
        if res.get("schematic"):
            body = f"![{cell} schematic](../../docs/{cell}/media/{cell}_schematic.png)"
            for base in res.get("extra", []):
                body += f"\n\n![{cell} {base}](../../docs/{cell}/media/{cell}_{base}_schematic.png)"
            new = apply_block(new, "schematic", cell, body, pred, fallback="heading")
        if res.get("layout") and not v.get("title"):
            W, H = res["layout"]
            body = f"### Layout\n\n![{cell} layout](../../docs/{cell}/media/{cell}_layout.png)\n\n{fence(f'W = {W:.2f}um' + chr(10) + f'L = {H:.2f}um')}"
            new = apply_block(new, "layout", cell, body, None, after_marker="schematic")
        if new != text:
            put(rp, new, "README block")
    # ---- gds README: layout under the heading `title`
    if v.get("gds") and v.get("title") and res.get("layout"):
        rp = os.path.join(ROOT, os.path.dirname(v["gds"]), "README.md")
        if os.path.isfile(rp):
            text = open(rp).read()
            W, H = res["layout"]
            depth = os.path.relpath(os.path.join(ROOT, "docs"), os.path.dirname(rp))
            body = f"![{cell} layout]({depth}/{cell}/media/{cell}_layout.png)"
            title = v["title"].strip().lower()
            new = apply_block(text, "layout", cell, body, lambda t: t.strip().lower() == title, fallback="none")
            if new is None:
                log(f"  note: no heading '{v['title']}' in {rel(rp)}, layout block of {cell} not placed")
            else:
                new = replace_dimension(new, cell, W, H)
                if new != text:
                    put(rp, new, "README block")


def main():
    global WRITE
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cell", nargs="?", default="all")
    ap.add_argument("--no-readme", action="store_true")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--staged", action="store_true")
    ap.add_argument("--labels", action="store_true", help="show text labels in the layout pictures")
    args = ap.parse_args()
    WRITE = not (args.dry_run or args.check)
    reg = yaml.safe_load(open(os.path.join(ROOT, "cells.yaml")))
    for cell in cells_of(args, reg):
        v = reg[cell]
        log(f"{cell}:")
        try:
            res = do_cell(cell, v, args)
            if not args.no_readme:
                readmes(cell, v, res, args)
        except Exception as e:   # one broken cell must not stop the others
            stats["errors"] += 1
            log(f"  ERROR {type(e).__name__}: {e}")
    print(f"images: {stats['updated']} {'to update' if not WRITE else 'updated'}, {stats['unchanged']} unchanged, {stats['errors']} error(s), {stats['warnings']} warning(s)")
    if args.check and stats["updated"]:
        sys.exit(1)
    sys.exit(2 if stats["errors"] else 0)


if __name__ == "__main__":
    main()
