#!/usr/bin/env python3
"""Convert a kpex (KLayout-PEX, 2.5D / FasterCap) netlist into an ngspice netlist the CACE templates can include.

  pex_netlist.py <kpex.spice> <schematic.spice> <out.spice> [--cell NAME]
  pex_netlist.py <magic.spice> <schematic.spice> <out.spice> --magic [--capnodes magic.spice.capnodes] [--cell NAME]

What kpex writes and what ngspice + the PDK models need:
  M$1 d g s b sg13_lv_nmos L=5U W=5U AS=.. AD=.. PS=.. PD=.. rfmode=0   ->  XM_1 ... (the PDK models are .subckts)
  R$39 a b sub 0.5 rhigh l=1.95 ps=0 b=0 m=1   (w, l, ps in um, no units) ->  XR_39 a b sub rhigh w=0.5u l=1.95u ...
  C$30 a b 14.88 cap_cmomi A=0 P=0 m=1         (w/l lost by the writer)    ->  XC_30 a b cap_cmomi w= l= ... taken
                                                                             from the schematic cap line
  Rext_1 a b 9 R                               (stray trailing "R")        ->  Rext_1 a b 9
  D$98 AVSS s[4] dantenna A=0.6084P P=3.12U m=1 (antenna diode, area/perimeter) ->  XD_98 AVSS s[4] dantenna w=0.78u l=0.78u
                                               (w, l solved from w*l = A, 2(w+l) = P; the PDK model is a .subckt with w, l)
  nodes such as \\$12.$0.17                     (backslash, $, .)           ->  n12_0_17
  VSUBS                                        (substrate)                 ->  VSS
  .SUBCKT cell IBIAS VDD ...                   (alphabetical ports)        ->  ports in the order of the schematic
                                                                             netlist (the CACE templates instantiate by
                                                                             symbol pin order)

--magic: input is the RC netlist of scripts/pex_magic.tcl (wire resistances wired to the device terminals). Devices are already
PDK subckt calls; node names lose "." and "#"; the internal-net port labels (pnN) leave the .subckt line; poly resistors get
ps/b/m; MoM caps are not in Magic's output (the GDS copy has no fingers) and are re-created from the schematic cap line
between the two nets of every line of --capnodes.
"""
import argparse
import os
import re
import sys


def read_logical_lines(path):
    out = []
    for raw in open(path).read().splitlines():
        if raw.startswith("+") and out:
            out[-1] += " " + raw[1:].strip()
        else:
            out.append(raw.rstrip())
    return out


def schematic_info(path):
    """(cell, ports in symbol order, {w,l,... of the first MoM cap line})"""
    cell = ports = None
    cap = {}
    for line in read_logical_lines(path):
        m = re.match(r"^\**\s*\.subckt\s+(\S+)(.*)$", line, re.I)
        if m and cell is None:
            cell = m.group(1)
            ports = [t for t in m.group(2).split() if "=" not in t]
        t = line.split()
        if len(t) >= 4 and t[0][0] in "CcXx" and any(x.lower() in ("cap_cmomi", "cap_cmomf") for x in t[1:5]) and not cap:
            cap = {"model": next(x for x in t[1:5] if x.lower().startswith("cap_cmom")),
                   "params": [x for x in t if "=" in x and not x.lower().startswith(("m=", "mm_ok="))]}
    return cell, ports, cap


def substrate_node(ports):
    """The substrate (VSUBS) is ground. Cells with a VSS port keep VSS; a cell without one (pgia_top: AVSS / VGND) ties it to its analog ground,
    otherwise the node would carry only capacitors and make the DC matrix singular."""
    for cand in ("VSS", "AVSS", "VSSA", "GND", "VGND"):
        if cand in ports:
            return cand
    return "VSS"


def node(n, ports):
    if n in ports:
        return n
    if n.upper() == "VSUBS":
        return substrate_node(ports)
    n = n.replace("\\$", "n").replace("\\", "").replace("$", "_").replace(".", "_")
    return n


def si(v):
    """kpex number with SI suffix (0.6084P, 3.12U) -> float"""
    m = re.match(r"^([-+0-9.eE]+?)([FPNUMKG]|MEG)?$", v.strip().upper())
    if not m:
        sys.exit(f"pex_netlist: cannot read the number {v!r}")
    return float(m.group(1)) * {None: 1.0, "F": 1e-15, "P": 1e-12, "N": 1e-9, "U": 1e-6, "M": 1e-3, "K": 1e3, "MEG": 1e6, "G": 1e9}[m.group(2)]


def diode_wl(params):
    """antenna diode: w, l in um from the area A (m^2) and the perimeter P (m) kpex prints"""
    kv = {x.split("=", 1)[0].upper(): x.split("=", 1)[1] for x in params if "=" in x}
    a, p = si(kv["A"]), si(kv["P"])
    half = p / 2.0
    disc = half * half - 4.0 * a
    if disc < -1e-24:
        sys.exit(f"pex_netlist: inconsistent diode geometry A={kv['A']} P={kv['P']}")
    r = max(disc, 0.0) ** 0.5
    return (half + r) / 2.0 * 1e6, (half - r) / 2.0 * 1e6


def um(v):
    """kpex prints the poly resistor geometry in um without unit"""
    return f"{float(v)}u"


def tie_floating(res, ports, sub):
    """Metal islands that carry only coupling capacitors (unconnected fill, dummies) have no DC path: ngspice reports a singular matrix at
    them and the operating point fails. Give each one a 1 TOhm leak to the substrate/ground node; nothing else changes."""
    touched, capnodes = set(), []
    for ln in res:
        t = ln.split()
        if not t:
            continue
        if t[0][0].upper() == "C" and not t[0].lower().startswith("xc"):
            capnodes += t[1:3]
        else:
            touched.update(x for x in t[1:] if "=" not in x)
    floating = sorted({n for n in capnodes if n not in touched and n not in ports and n != "0"})
    res.extend(f"Rfl_{n} {n} {sub} 1T" for n in floating)
    return len(floating)


def convert(src, sch, out, cell=None):
    scell, sports, cap = schematic_info(sch)
    if not sports:
        sys.exit(f"pex_netlist: no .subckt line in {sch}")
    cell = cell or scell
    ports = list(sports)
    lines = read_logical_lines(src)
    res, nconv = [], {"M": 0, "Rpoly": 0, "Rext": 0, "Cdev": 0, "Cext": 0, "D": 0}
    in_top = False
    top_ports = []
    for line in lines:
        s = line.strip()
        if not s or s.startswith("*"):
            continue
        low = s.lower()
        if low.startswith(".subckt"):
            toks = s.split()
            if toks[1].lower() == cell.lower():
                in_top = True
                top_ports = toks[2:]
            continue
        if low.startswith(".ends"):
            in_top = False
            continue
        if not in_top or s.startswith("."):
            continue
        t = s.split()
        name, kind = t[0], t[0][0].upper()
        nm = node(name, [])
        if kind == "M":
            # d g s b model params...
            res.append(" ".join([f"X{nm}"] + [node(x, ports) for x in t[1:5]] + [t[5]] + t[6:]))
            nconv["M"] += 1
        elif kind == "R" and name.lower().startswith("rext"):
            res.append(" ".join([nm] + [node(x, ports) for x in t[1:3]] + [t[3]]))
            nconv["Rext"] += 1
        elif kind == "R":
            # R n1 n2 sub w model k=v ...   (poly resistor)
            sub, w, model = node(t[3], ports), t[4], t[5]
            kv = dict(x.split("=", 1) for x in t[6:] if "=" in x)
            ps = um(kv.get("ps", "0")) if float(kv.get("ps", "0")) else "0"
            res.append(f"X{nm} {node(t[1], ports)} {node(t[2], ports)} {sub} {model} w={um(w)} l={um(kv['l'])} "
                       f"ps={ps} b={kv.get('b', '0')} m={kv.get('m', '1')}")
            nconv["Rpoly"] += 1
        elif kind == "C" and name.lower().startswith("cext"):
            res.append(" ".join([nm] + [node(x, ports) for x in t[1:3]] + [t[3]]))
            nconv["Cext"] += 1
        elif kind == "C":
            if not cap:
                sys.exit("pex_netlist: layout has a MoM cap but the schematic netlist has no cap_cmomi/cap_cmomf line "
                         "(needed for w/l: the kpex writer drops them)")
            res.append(f"X{nm} {node(t[1], ports)} {node(t[2], ports)} {cap['model']} " + " ".join(cap["params"]) + " m=1")
            nconv["Cdev"] += 1
        elif kind == "D" and len(t) > 3 and t[3].lower() == "dantenna":
            w, l = diode_wl(t[4:])
            res.append(f"X{nm} {node(t[1], ports)} {node(t[2], ports)} dantenna w={w:.4g}u l={l:.4g}u")
            nconv["D"] += 1
        else:
            sys.exit(f"pex_netlist: unhandled line: {s[:100]}")
    if not top_ports:
        sys.exit(f"pex_netlist: no .SUBCKT {cell} in {src}")
    missing = set(ports) ^ set(top_ports)
    if missing:
        sys.exit(f"pex_netlist: port mismatch between schematic {ports} and kpex {top_ports}")
    nconv["floating"] = tie_floating(res, ports, substrate_node(ports))
    with open(out, "w") as f:
        f.write(f"** post-layout netlist of {cell}: kpex -> ngspice by scripts/pex_netlist.py (source: {src})\n")
        f.write(f".subckt {cell} {' '.join(ports)}\n")
        f.write("\n".join(res) + "\n")
        f.write(f".ends {cell}\n")
    print(f"pex_netlist: {out}: ports {' '.join(ports)}; " + ", ".join(f"{k}={v}" for k, v in nconv.items()))


def mnode(n, ports):
    """Magic node name -> ngspice-safe name (ports unchanged)"""
    return n if n in ports else n.replace(".", "_").replace("#", "_")


def convert_magic(src, sch, out, cell=None, capnodes=None):
    scell, sports, cap = schematic_info(sch)
    if not sports:
        sys.exit(f"pex_netlist: no .subckt line in {sch}")
    cell = cell or scell
    ports = list(sports)
    res, n = [], {"X": 0, "R": 0, "C": 0, "Cdev": 0}
    top_ports = None
    for s in (x.strip() for x in read_logical_lines(src)):
        if not s or s.startswith("*"):
            continue
        low = s.lower()
        if low.startswith(".subckt"):
            toks = s.split()
            if toks[1].lower() == cell.lower():
                top_ports = toks[2:]
            continue
        if s.startswith("."):
            continue
        t = s.split()
        kind = t[0][0].upper()
        if kind == "X":
            i = next(k for k, x in enumerate(t) if "=" in x) - 1      # model = token before the first param
            model, params = t[i], t[i + 1:]
            line = [t[0]] + [mnode(x, ports) for x in t[1:i]] + [model] + params
            if model.lower().startswith(("rhigh", "rppd", "rsil")):
                have = {x.split("=")[0].lower() for x in params}
                line += [f"{k}={v}" for k, v in (("ps", "0"), ("b", "0"), ("m", "1")) if k not in have]
            res.append(" ".join(line))
            n["X"] += 1
        elif kind in "RC":
            res.append(" ".join([t[0]] + [mnode(x, ports) for x in t[1:3]] + t[3:]))
            n[kind] += 1
        else:
            sys.exit(f"pex_netlist: unhandled Magic line: {s[:100]}")
    if top_ports is None:
        sys.exit(f"pex_netlist: no .subckt {cell} in {src}")
    if set(ports) - set(top_ports):
        sys.exit(f"pex_netlist: port mismatch: schematic {ports}, Magic {top_ports}")
    if capnodes and os.path.isfile(capnodes):
        raw_lines = [l.strip() for l in open(capnodes) if l.strip()]
        if raw_lines and not cap:
            sys.exit("pex_netlist: layout has MoM caps but the schematic netlist has no cap_cmomi/cap_cmomf line")
        for k, line in enumerate(raw_lines, 1):
            toks = []
            for m in re.finditer(r'\{([^}]+)\}|(\S+)', line):
                val = m.group(1) or m.group(2)
                if " " in val:
                    sub = val.split()
                    val = next((x for x in sub if "#" not in x), sub[0])
                toks.append(val)
            if len(toks) < 2 or not toks[0] or not toks[1]:
                sys.exit(f"pex_netlist: no net found under MoM cap #{k} (capnodes line '{line}')")
            a, b = toks[0], toks[1]
            params = list(cap["params"])
            if len(toks) >= 4:
                w_val, l_val = toks[2], toks[3]
                new_params = []
                for p in params:
                    if p.lower().startswith("w="):
                        new_params.append(f"w={w_val}")
                    elif p.lower().startswith("l="):
                        new_params.append(f"l={l_val}")
                    else:
                        new_params.append(p)
                params = new_params
            res.append(f"XCM_{k} {mnode(a, ports)} {mnode(b, ports)} {cap['model']} " + " ".join(params) + " m=1")
            n["Cdev"] += 1

    # Filter out dangling resistor stubs (resistors where at least one terminal is an internal node appearing nowhere else)
    node_counts = {}
    for line in res:
        toks = line.split()
        if not toks:
            continue
        kind = toks[0][0].upper()
        if kind == "X":
            i = next((k for k, x in enumerate(toks) if "=" in x), len(toks)) - 1
            for nd in toks[1:i]:
                node_counts[nd] = node_counts.get(nd, 0) + 1
        elif kind in "RC":
            for nd in toks[1:3]:
                node_counts[nd] = node_counts.get(nd, 0) + 1

    clean_res = []
    for line in res:
        toks = line.split()
        if toks and toks[0][0].upper() == "R":
            n1, n2 = toks[1], toks[2]
            if (n1 not in ports and node_counts.get(n1, 0) <= 1) or (n2 not in ports and node_counts.get(n2, 0) <= 1):
                continue
        clean_res.append(line)
    res = clean_res
    n["floating"] = tie_floating(res, ports, substrate_node(ports))
    with open(out, "w") as f:
        f.write(f"** post-layout RC netlist of {cell}: Magic extresist -> ngspice by scripts/pex_netlist.py --magic (source: {src})\n")
        f.write(f".subckt {cell} {' '.join(ports)}\n")
        f.write("\n".join(res) + "\n")
        f.write(f".ends {cell}\n")
    print(f"pex_netlist: {out}: ports {' '.join(ports)}; " + ", ".join(f"{k}={v}" for k, v in n.items()))


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src")
    ap.add_argument("schematic")
    ap.add_argument("out")
    ap.add_argument("--cell")
    ap.add_argument("--magic", action="store_true", help="input is a Magic extresist netlist (scripts/pex_magic.tcl)")
    ap.add_argument("--capnodes", help="Magic: net pairs of the MoM caps (written by pex_magic.tcl as <raw>.capnodes)")
    a = ap.parse_args()
    if a.magic:
        convert_magic(a.src, a.schematic, a.out, a.cell, a.capnodes)
    else:
        convert(a.src, a.schematic, a.out, a.cell)
