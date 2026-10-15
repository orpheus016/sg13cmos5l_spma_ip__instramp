#!/usr/bin/env python3
"""Build the CACE templates and the `parameters:` part of the datasheet from the interactive xschem testbenches.

  gen_cace.py <cell> [--check] [-q]

Source of truth (edit these, never the generated files):
  xschem/<cell>/tb/<tb>/<tb>.sch   your interactive testbenches (the control block with the plots, banners, ...)
  cace/<cell>.params.yaml          manifest: which testbench gives which parameter, the numbers that become CACE variables
                                   (expression, unit, limits), conditions
Generated:
  cace/templates/<cell>/<template>.sch   = the testbench with the CACE rules applied (see docs/README.md, CACE guide 3a)
  cace/<cell>.yaml  from the line `parameters:` on; everything above it (pins, default_conditions) stays hand-written

A cell without cace/<cell>.params.yaml is not touched. Parameters without `tb:` keep their hand-written template
(only the yaml entry is generated). Files are only written when the content changes, so make-style timestamps stay valid.
--check: write nothing, exit 1 if something is out of date (CI).

What is changed in the testbench (the table of docs/README.md CACE guide 3b, automated):
  * DUT symbol path  -> <cell>.sym                          * graph boxes and launchers are removed
  * sources named in `sources:` (instramp: V1 vdd, I0 ib, C1 cl, V3..V5 vcm; per parameter additions) get value=\\{cond\\}
  * .subckt/.func helper blocks and symbols found in cace/templates/<cell>/ (loop gain probe) are kept / referenced by name
  * every .lib / .param block is replaced by the canonical CACE block (libs by condition, ib vdd vcm cl, .temp, .include DUT)
  * control block: `set num_threads=CACE{jobs}` first; plot / shell / write / show / echo / print / run lines and `.op` removed;
    at the end   let cace_<VAR> = <expr>   for every spec variable and the echo line into CACE{simpath}/CACE{filename}_CACE{N}.data
"""
import os
import re
import sys

import yaml

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

LIBS = r""".lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOSlv.lib mos_CACE\{corner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOShv.lib mos_CACE\{corner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerRES.lib res_CACE\{rcorner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerCAP.lib cap_typ
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerDIO.lib dio_tt
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOSCAP.lib moscap_tt

.include CACE\{DUT_path\}

.temp CACE\{temperature\}

.option SEED=CACE[CACE\{seed=12345\} + CACE\{iterations=0\}]
"""
PARAMS = r""".param ib=CACE\{ib\}
.param vdd=CACE\{vdd\}
.param vcm=CACE\{vcm\}
.param cl=CACE\{cl\}
"""
DEFAULT_SOURCES = {"V1": "vdd", "I0": "ib", "C1": "cl", "V3": "vcm", "V4": "vcm", "V5": "vcm"}
DROP_CMD = re.compile(r"^\s*(plot|shell|write|show|echo|print|run|\.op)\b", re.I)


def esc(s):
    """CACE{x} in the manifest -> CACE\\{x\\} as it must stand in a .sch attribute."""
    return s.replace("\\{", "{").replace("\\}", "}").replace("{", "\\{").replace("}", "\\}")


# ---------------------------------------------------------------- .sch chunks
def depth(line):
    line = re.sub(r"\\.", "", line)
    return line.count("{") - line.count("}")


def chunks(text):
    """Split a .sch into its objects (a chunk ends when the braces balance; attribute values may span lines)."""
    out, cur, d = [], [], 0
    for line in text.split("\n"):
        if not cur and not line.strip():
            continue
        cur.append(line)
        d += depth(line)
        if d <= 0:
            out.append("\n".join(cur))
            cur, d = [], 0
    if cur:
        out.append("\n".join(cur))
    return out


def sym_of(ch):
    m = re.match(r"C \{([^}]*)\}", ch)
    return m.group(1) if m else ""


def name_of(ch):
    m = re.search(r"\bname=(\w+)", ch)
    return m.group(1) if m else ""


def value_of(ch):
    m = re.search(r'\bvalue="(.*)"\s*\n?\s*\}\s*$', ch, re.S)
    return m.group(1) if m else None


def pos_of(ch):
    m = re.match(r"C \{[^}]*\} (\S+) (\S+) ", ch)
    return (m.group(1), m.group(2)) if m else ("0", "0")


def shown(name, x, y, value):
    return f'C {{simulator_commands_shown.sym}} {x} {y} 0 0 {{name={name}\nsimulator=ngspice\nonly_toplevel=false\nvalue="{value}"\n      }}'


def control(name, x, y, lines):
    return f'C {{simulator_commands.sym}} {x} {y} 0 0 {{name={name}\nsimulator=ngspice\nonly_toplevel="false"\nvalue="{lines}"\n}}'


def rewrite_control(ch, spec, subst):
    """Control block of the testbench -> control block of the template."""
    val = value_of(ch)
    if val is None:
        return ch
    keep = [l for l in val.split("\n") if not DROP_CMD.match(l)]
    body = "\n".join(keep)
    for old, new in (subst or {}).items():
        if old not in body:
            sys.exit(f"gen_cace: subst text not found in the testbench control block: {old!r}")
        body = body.replace(old, esc(new))
    lines = body.split("\n")
    i = next(k for k, l in enumerate(lines) if l.strip().startswith(".control"))
    j = max(k for k, l in enumerate(lines) if l.strip().startswith(".endc"))
    head, mid, tail = lines[: i + 1], lines[i + 1 : j], lines[j:]
    while mid and not mid[-1].strip():
        mid.pop()
    add = ["set num_threads=CACE\\{jobs\\}"] + mid
    for var, s in spec.items():
        add.append(f"let cace_{var} = {esc(str(s['expr']))}")
    add.append("echo " + " ".join(f"$&cace_{v}" for v in spec) + " > CACE\\{simpath\\}/CACE\\{filename\\}_CACE\\{N\\}.data")
    x, y = pos_of(ch)
    return control(name_of(ch), x, y, "\n".join(head + add + tail))


def convert(text, cell, spec, sources, subst, tb_name, params_block, tdir):
    out, ctrl_pos = [], ("1070", "-600")
    for ch in chunks(text):
        sym = sym_of(ch)
        if ch.startswith("B ") and "flags=graph" in ch:
            continue
        if "launcher.sym" in sym:
            continue
        if sym == "simulator_commands_shown.sym":
            # libs / params are replaced by the canonical blocks below; a .control...endc kept in such a block (ac tb) is the control block
            val = value_of(ch) or ""
            if ".subckt" in val or ".func" in val:
                out.append(ch)   # helper definitions (loop gain probe, tian_loop) belong to the testbench: keep
            elif ".control" in val and ".endc" in val:
                x, y = pos_of(ch)
                sub = val[val.index(".control"): val.rindex(".endc") + 5]
                out.append(rewrite_control(control(name_of(ch) or "Control", x, y, sub), spec, subst))
            continue
        m = re.match(r"C \{(.*/)?([^/}]+\.sym)\}", ch)
        if m and m.group(1) and (m.group(2) == f"{cell}.sym" or os.path.isfile(os.path.join(tdir, m.group(2)))):
            # DUT symbol and symbols that live in the templates folder (loopgainprobe.sym): relative name, CACE finds them there
            ch = ch.replace("{" + m.group(1) + m.group(2) + "}", "{" + m.group(2) + "}", 1)
        elif sym == "simulator_commands.sym":
            if (value_of(ch) or "").lstrip().startswith(".control"):
                ch = rewrite_control(ch, spec, subst)
        elif sym in ("vsource.sym", "isource.sym", "capa.sym") and name_of(ch) in sources:
            ch = re.sub(r"\bvalue=(?!\\\{)[^\s}]+", lambda m: f"value=\\{{{sources[name_of(ch)]}\\}}", ch, count=1)
        out.append(ch)
    out.append(shown("Libs_Ngspice", "1070", "-990", "\n" + LIBS))
    out.append(shown("General_Params", "1070", "-760", params_block))
    out.append(f"T {{GENERATED by scripts/gen_cace.py from xschem tb {tb_name} - edit the testbench / the manifest, not this file}} 160 -80 0 0 0.3 0.3 {{}}")
    return "\n".join(out) + "\n"


# ---------------------------------------------------------------- yaml
def q(s):
    import json
    return json.dumps(str(s), ensure_ascii=False)


def scalar(v):
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, (int, float)):
        return repr(v)
    if isinstance(v, list):
        return "[" + ", ".join(scalar(x) for x in v) + "]"
    return str(v)


def emit_param(name, p):
    L = [f"  {name}:", f"    display: {q(p['display'])}", f"    description: {q(p.get('description', p['display']))}", "    spec:"]
    for var, s in p["spec"].items():
        L += [f"      {var}:", f"        display: {q(s.get('display', var))}"]
        if s.get("description"):
            L.append(f"        description: {q(s['description'])}")
        L.append(f"        unit: {q(s.get('unit', ''))}")   # always present: make_readme.py needs it ("" = dimensionless)
        for key, k in (("minimum", "min"), ("typical", "typ"), ("maximum", "max")):
            L += [f"        {key}:", f"          value: {scalar(s.get(k, 'any'))}"]
    variables = p.get("variables") or list(p["spec"])
    L += ["    tool:", "      ngspice:", f"        template: {p['template']}"]
    if p.get("collate"):
        L.append(f"        collate: {p['collate']}")
    L += ["        format: ascii", "        suffix: .data", f"        variables: [{', '.join('null' if v is None else v for v in variables)}]"]
    plots = p["plots"] if "plots" in p else [f"{next(iter(p['spec']))}:temperature"]
    if plots:
        L.append("    plot:")
        for pl in plots:
            var, x = pl.split(":")
            L += [f"      {name}_{var}_vs_{x}:", "        type: xyplot", f"        xaxis: {x}", f"        yaxis: {var}", "        limits: auto"]
    L.append("    conditions:")
    for cname, c in p["conditions"].items():
        L.append(f"      {cname}:")
        for k, v in c.items():
            L.append(f"        {k}: {scalar(v)}")
    return "\n".join(L)


MARK = "# parameters: from here on GENERATED by scripts/gen_cace.py from cace/{cell}.params.yaml - edit the manifest / the testbenches, not this part"


def main():
    a = [x for x in sys.argv[1:] if not x.startswith("-")]
    check = "--check" in sys.argv
    quiet = "-q" in sys.argv
    if not a:
        sys.exit(__doc__)
    cell = a[0]
    man_path = os.path.join(ROOT, "cace", f"{cell}.params.yaml")
    if not os.path.isfile(man_path):
        return 0
    man = yaml.safe_load(open(man_path))
    sources = man.get("sources") or DEFAULT_SOURCES
    params_block = esc(man["params"]).rstrip("\n") + "\n" if man.get("params") else PARAMS
    tbdir = os.path.join(ROOT, man.get("tb_dir", f"xschem/{cell}/tb"))
    tdir = os.path.join(ROOT, "cace", "templates", cell)
    changed = []

    def write(path, text):
        old = open(path).read() if os.path.isfile(path) else None
        if old == text:
            return
        changed.append(os.path.relpath(path, ROOT))
        if not check:
            os.makedirs(os.path.dirname(path), exist_ok=True)
            open(path, "w").write(text)

    params = {}
    for pname, p in man["parameters"].items():
        p = dict(p)
        p["conditions"] = p.get("conditions") or man["conditions"]
        tb = p.get("tb")
        if tb:
            folder = os.path.join(tbdir, tb)
            sch = os.path.join(folder, tb + ".sch")
            if not os.path.isfile(sch):  # testbench file not renamed yet: take the only .sch in the folder
                cand = [f for f in os.listdir(folder) if f.endswith(".sch")] if os.path.isdir(folder) else []
                if len(cand) != 1:
                    sys.exit(f"gen_cace: testbench {tb} for parameter {pname} not found in {os.path.relpath(tbdir, ROOT)}")
                sch = os.path.join(folder, cand[0])
            for var, s in p["spec"].items():
                if "expr" not in s:
                    sys.exit(f"gen_cace: {pname}.{var} has no expr")
            tmpl = convert(open(sch).read(), cell, p["spec"], {**sources, **(p.get("sources") or {})}, p.get("subst"), os.path.relpath(sch, ROOT), params_block, tdir)
            write(os.path.join(tdir, p["template"]), tmpl)
        elif not os.path.isfile(os.path.join(tdir, p["template"])):
            sys.exit(f"gen_cace: parameter {pname}: no tb: and no template {p['template']}")
        params[pname] = p

    ypath = os.path.join(ROOT, "cace", f"{cell}.yaml")
    ytxt = open(ypath).read()
    m = re.search(r"^parameters:\s*$", ytxt, re.M)
    if not m:
        sys.exit(f"gen_cace: no 'parameters:' line in {ypath}")
    head = ytxt[: m.start()]
    head = re.sub(r"^# parameters: from here on GENERATED.*\n", "", head, flags=re.M).rstrip("\n") + "\n\n"
    new = head + MARK.format(cell=cell) + "\nparameters:\n" + "\n\n".join(emit_param(n, p) for n, p in params.items()) + "\n"
    write(ypath, new)

    if not quiet or changed:
        print("gen_cace: " + (f"{'out of date' if check else 'wrote'}: " + ", ".join(changed) if changed else f"{cell} up to date"))
    return 1 if (check and changed) else 0


if __name__ == "__main__":
    sys.exit(main())
