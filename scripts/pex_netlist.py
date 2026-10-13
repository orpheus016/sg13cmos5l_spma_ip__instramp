#!/usr/bin/env python3
"""Convert a kpex (KLayout-PEX, 2.5D / FasterCap) netlist into an ngspice netlist the CACE templates can include.

  pex_netlist.py <kpex.spice> <schematic.spice> <out.spice> [--cell NAME]

What kpex writes and what ngspice + the PDK models need:
  M$1 d g s b sg13_lv_nmos L=5U W=5U AS=.. AD=.. PS=.. PD=.. rfmode=0   ->  XM_1 ... (the PDK models are .subckts)
  R$39 a b sub 0.5 rhigh l=1.95 ps=0 b=0 m=1   (w, l, ps in um, no units) ->  XR_39 a b sub rhigh w=0.5u l=1.95u ...
  C$30 a b 14.88 cap_cmomi A=0 P=0 m=1         (w/l lost by the writer)    ->  XC_30 a b cap_cmomi w= l= ... taken
                                                                             from the schematic cap line
  Rext_1 a b 9 R                               (stray trailing "R")        ->  Rext_1 a b 9
  nodes such as \\$12.$0.17                     (backslash, $, .)           ->  n12_0_17
  VSUBS                                        (substrate)                 ->  VSS
  .SUBCKT cell IBIAS VDD ...                   (alphabetical ports)        ->  ports in the order of the schematic
                                                                             netlist (the CACE templates instantiate by
                                                                             symbol pin order)
"""
import argparse
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


def node(n, ports):
    if n in ports:
        return n
    if n.upper() == "VSUBS":
        return "VSS"
    n = n.replace("\\$", "n").replace("\\", "").replace("$", "_").replace(".", "_")
    return n


def um(v):
    """kpex prints the poly resistor geometry in um without unit"""
    return f"{float(v)}u"


def convert(src, sch, out, cell=None):
    scell, sports, cap = schematic_info(sch)
    if not sports:
        sys.exit(f"pex_netlist: no .subckt line in {sch}")
    cell = cell or scell
    ports = list(sports)
    lines = read_logical_lines(src)
    res, nconv = [], {"M": 0, "Rpoly": 0, "Rext": 0, "Cdev": 0, "Cext": 0}
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
        else:
            sys.exit(f"pex_netlist: unhandled line: {s[:100]}")
    if not top_ports:
        sys.exit(f"pex_netlist: no .SUBCKT {cell} in {src}")
    missing = set(ports) ^ set(top_ports)
    if missing:
        sys.exit(f"pex_netlist: port mismatch between schematic {ports} and kpex {top_ports}")
    with open(out, "w") as f:
        f.write(f"** post-layout netlist of {cell}: kpex -> ngspice by scripts/pex_netlist.py (source: {src})\n")
        f.write(f".subckt {cell} {' '.join(ports)}\n")
        f.write("\n".join(res) + "\n")
        f.write(f".ends {cell}\n")
    print(f"pex_netlist: {out}: ports {' '.join(ports)}; " + ", ".join(f"{k}={v}" for k, v in nconv.items()))


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("src")
    ap.add_argument("schematic")
    ap.add_argument("out")
    ap.add_argument("--cell")
    a = ap.parse_args()
    convert(a.src, a.schematic, a.out, a.cell)
