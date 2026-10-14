#!/usr/bin/env python3
"""Scaffold the CACE part of a cell that is schematic-only so far.

  new_cell.py <cell> [--outputs a,b] [--current-pins a,b] [--logic a,b] [--sch xschem/<cell>/<cell>.sym] [--force]

Reads the pins of xschem/<cell>/<cell>.sym and writes
  cace/<cell>.yaml                  datasheet: pins, default conditions, ONE parameter `dc_op` (supply current and the DC level of
                                    every output), PVT sweep (5 corners x 3 vdd x 3 T); every limit is `any` (report-only)
  cace/templates/<cell>/dc_op.sch   testbench that CACE netlists: supplies, inputs at vcm, bias current sources, loads
and registers the cell in cells.yaml (cace: ...; stage `cace` added). It does not invent specifications and it does not know what
the cell is supposed to do: add the real parameters (ac, noise, ...) by copying cace/templates/instramp_cmos5l/ac.sch and the matching
block of cace/instramp_cmos5l.yaml. Pin roles are guessed from the names (override with the options):
  power VDD|AVDD|DVDD|VCC     ground VSS|AVSS|DVSS|GND     current input IBIAS|IREF|BIAS (isource {ib})
  output VOUT|OUT*|Y|Q|Z      logic D<n>|EN*|SEL*|CLK (0 V, DC)     everything else: input at {vcm}
"""
import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
POWER = re.compile(r"^(A|D)?(VDD|VCC|VPWR)\d*$", re.I)
GROUND = re.compile(r"^(A|D)?(VSS|GND|VGND)\d*$|^0$", re.I)
CURRENT = re.compile(r"(IBIAS|IREF|BIAS)", re.I)
OUTPUT = re.compile(r"^(V?OUT\w*|Y\d*|Q\d*|Z\d*)$", re.I)
LOGIC = re.compile(r"^(D\d+|EN\w*|SEL\w*|CLK\w*|B\d+)$", re.I)

LIBS = """.lib CACE\\{PDK_ROOT\\}/CACE\\{PDK\\}/libs.tech/ngspice/models/cornerMOSlv.lib mos_CACE\\{corner\\}
.lib CACE\\{PDK_ROOT\\}/CACE\\{PDK\\}/libs.tech/ngspice/models/cornerMOShv.lib mos_CACE\\{corner\\}
.lib CACE\\{PDK_ROOT\\}/CACE\\{PDK\\}/libs.tech/ngspice/models/cornerRES.lib res_CACE\\{rcorner\\}
.lib CACE\\{PDK_ROOT\\}/CACE\\{PDK\\}/libs.tech/ngspice/models/cornerCAP.lib cap_typ
.lib CACE\\{PDK_ROOT\\}/CACE\\{PDK\\}/libs.tech/ngspice/models/cornerDIO.lib dio_tt
.lib CACE\\{PDK_ROOT\\}/CACE\\{PDK\\}/libs.tech/ngspice/models/cornerMOSCAP.lib moscap_tt

.include CACE\\{DUT_path\\}

.temp CACE\\{temperature\\}"""


def read_pins(sym):
    pins = []
    for line in open(sym):
        m = re.match(r"^B 5 (\S+) (\S+) (\S+) (\S+) \{(.*?)\}", line)
        if m:
            x1, y1, x2, y2 = map(float, m.groups()[:4])
            name = re.search(r"name=(\S+)", m.group(5)).group(1)
            d = re.search(r"dir=(\S+)", m.group(5))
            pins.append(dict(name=name, x=(x1 + x2) / 2, y=(y1 + y2) / 2, dir=d.group(1) if d else "inout"))
    return pins


def classify(p, outs, curs, logic):
    n = p["name"]
    if n in outs or (not outs and OUTPUT.match(n)) or p["dir"] == "out":
        return "out"
    if n in curs or CURRENT.search(n):
        return "ibias"
    if POWER.match(n):
        return "power"
    if GROUND.match(n):
        return "ground"
    if n in logic or LOGIC.match(n):
        return "logic"
    return "in"


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("cell")
    ap.add_argument("--outputs", default="")
    ap.add_argument("--current-pins", default="")
    ap.add_argument("--logic", default="")
    ap.add_argument("--sym", help="symbol file (default xschem/<cell>/<cell>.sym)")
    ap.add_argument("--force", action="store_true", help="overwrite cace/<cell>.yaml and the template")
    a = ap.parse_args()
    cell = a.cell
    sym = a.sym or os.path.join(ROOT, "xschem", cell, f"{cell}.sym")
    if not os.path.isfile(sym):
        sys.exit(f"new_cell: {sym} not found")
    yaml_path = os.path.join(ROOT, "cace", f"{cell}.yaml")
    tdir = os.path.join(ROOT, "cace", "templates", cell)
    if os.path.exists(yaml_path) and not a.force:
        sys.exit(f"new_cell: {yaml_path} exists (--force to overwrite)")
    pins = read_pins(sym)
    if not pins:
        sys.exit(f"new_cell: no pins in {sym}")
    outs, curs, logic = (set(filter(None, s.split(","))) for s in (a.outputs, a.current_pins, a.logic))
    for p in pins:
        p["role"] = classify(p, outs, curs, logic)
    roles = {r: [p["name"] for p in pins if p["role"] == r] for r in ("power", "ground", "ibias", "out", "logic", "in")}
    if not roles["power"] or not roles["ground"]:
        sys.exit(f"new_cell: no power/ground pin recognised in {[p['name'] for p in pins]}; rename or extend POWER/GROUND")
    vdd_pin, vss_pin = roles["power"][0], roles["ground"][0]

    # ---- testbench (nets are connected by lab_wire labels at the DUT pin positions)
    X0, Y0 = 600, -300
    lines = ["v {xschem version=3.4.8RC file_version=1.3}", "G {}", "K {}", "V {}", "S {}", "F {}", "E {}"]
    comps = [f"C {{{cell}.sym}} {X0} {Y0} 0 0 {{name=x1}}"]
    for p in pins:
        net = {"power": "vdd", "ground": "vss"}.get(p["role"], p["name"].lower())
        comps.append(f"C {{lab_wire.sym}} {X0 + p['x']:g} {Y0 + p['y']:g} 0 0 {{name=pp_{p['name']} sig_type=std_logic lab={net}}}")
    srcs = [("vsource", "vdd", "{vdd}", "vss"), ("vsource", "vss", "0", "0")]   # ground pins sit on net vss, which is tied to 0 V
    for p in pins:
        if p["role"] in ("in",):
            srcs.append(("vsource", p["name"].lower(), "{vcm}", "vss"))
        elif p["role"] == "logic":
            srcs.append(("vsource", p["name"].lower(), "0", "vss"))
        elif p["role"] == "ibias":
            srcs.append(("isource", p["name"].lower(), "{ib}", "vss"))
        elif p["role"] == "out":
            srcs.append(("capa", p["name"].lower(), "{cl}", "0"))
    esc = lambda s: s.replace("{", "\\{").replace("}", "\\}")
    x = 100
    vname = {}
    for k, (kind, net, val, ref) in enumerate(srcs):
        nm = {"vsource": f"V{k}", "isource": f"I{k}", "capa": f"C{k}"}[kind]
        vname[net] = nm
        comps.append(f"C {{lab_wire.sym}} {x} -660 0 0 {{name=ps{k} sig_type=std_logic lab={net}}}")
        if kind == "capa":
            comps.append(f"C {{capa.sym}} {x} -630 0 0 {{name={nm} m=1 value={esc(val)} footprint=1206 device=\"ceramic capacitor\"}}")
        else:
            comps.append(f"C {{{kind}.sym}} {x} -630 0 0 {{name={nm} value={esc(val)}" + (" savecurrent=false" if kind == "vsource" else "") + "}")
        if ref == "0":
            comps.append(f"C {{gnd.sym}} {x} -600 0 0 {{name=pr{k} lab=0}}")
        else:
            comps.append(f"C {{lab_wire.sym}} {x} -600 0 0 {{name=pr{k} sig_type=std_logic lab={ref}}}")
        x += 100
    outs_l = [o.lower() for o in roles["out"]]
    echo = "$&IQ " + " ".join(f"$&V_{o.upper()}" for o in outs_l)
    vars_ = ["IQ"] + [f"V_{o.upper()}" for o in outs_l]
    cmds = [".control", "set num_threads=CACE\\{jobs\\}", "save all", "op",
            f"let IQ = -i({vname['vdd']}) * 1e6", *[f"let V_{o.upper()} = v({o})" for o in outs_l],
            f"echo {echo} > CACE\\{{simpath\\}}/CACE\\{{filename\\}}_CACE\\{{N\\}}.data", ".endc"]
    comps.append("C {simulator_commands_shown.sym} 100 -1000 0 0 {name=Libs_Ngspice\nsimulator=ngspice\nonly_toplevel=false\nvalue=\"\n"
                 + LIBS + "\n\"\n      }")
    comps.append("C {simulator_commands_shown.sym} 100 -800 0 0 {name=General_Params\nsimulator=ngspice\nonly_toplevel=false\n"
                 "value=\".param vdd=CACE\\{vdd\\}\n.param vcm=CACE\\{vcm\\}\n.param ib=CACE\\{ib\\}\n.param cl=CACE\\{cl\\}\n\"\n      }")
    comps.append("C {simulator_commands.sym} 700 -800 0 0 {name=OP\nsimulator=ngspice\nonly_toplevel=\"false\"\nvalue=\"" + "\n".join(cmds) + "\"\n}")
    xrc = os.path.join(ROOT, "xschem", cell, "xschemrc")
    if not os.path.exists(xrc):
        open(xrc, "w").write(f"""# Project xschemrc for {cell} (used by CACE to netlist the DUT; written by scripts/new_cell.py)
if {{![info exists PDK]}} {{
    source $env(PDK_ROOT)/$env(PDK)/libs.tech/xschem/xschemrc
}}
# this cell and its siblings (sub-blocks are referenced as <cell>.sym)
set _here [file dirname [file normalize [info script]]]
append XSCHEM_LIBRARY_PATH :$_here
foreach d [glob -nocomplain -type d $_here/../*] {{ append XSCHEM_LIBRARY_PATH :$d }}
""")
    os.makedirs(tdir, exist_ok=True)
    tpath = os.path.join(tdir, "dc_op.sch")
    if os.path.exists(tpath) and not a.force:
        sys.exit(f"new_cell: {tpath} exists (--force)")
    open(tpath, "w").write("\n".join(lines + comps) + "\n")

    # ---- datasheet
    ypins = []
    for p in pins:
        r = p["role"]
        t = {"power": "power", "ground": "ground"}.get(r, "signal")
        d = {"out": "output", "ibias": "input", "in": "input", "logic": "input"}.get(r, "inout")
        extra = "    Vmin: 1.2\n    Vmax: 1.5\n" if r == "power" else ""
        ypins.append(f"  {p['name']}:\n    description: {r} pin (guessed from the name, check)\n    type: {t}\n    direction: {d}\n{extra}")
    spec = "".join(f"""      {v}:
        display: {'Supply current' if v == 'IQ' else 'DC level of ' + v[2:]}
        unit: "{'uA' if v == 'IQ' else 'V'}"
        minimum:
          value: any
        typical:
          value: any
        maximum:
          value: any
""" for v in vars_)
    y = f"""#--------------------------------------------------------------
# CACE datasheet: {cell}   (scaffold written by scripts/new_cell.py, edit it!)
#--------------------------------------------------------------

name:           {cell}
description:    {cell} - scaffold, only the DC operating point is characterised so far
PDK:            ihp-sg13cmos5l

cace_format:    5.2

authorship:
  designer:         SPMA
  creation_date:    {__import__('datetime').date.today():%B %d, %Y}
  license:          MIT

paths:
  root:             ..
  schematic:        xschem/{cell}
  netlist:          netlist/{cell}
  documentation:    docs/{cell}/cace
  templates:        cace/templates/{cell}

pins:
{''.join(ypins)}
default_conditions:
  vdd:
    description: Power supply voltage
    display: Vdd
    unit: V
    typical: 1.2
  vcm:
    description: Common-mode level of the signal inputs
    display: Vcm
    unit: V
    typical: 0.6
  ib:
    description: Bias current into the current pins
    display: Ib
    unit: uA
    typical: 1.4
  cl:
    description: Output load capacitance
    display: CLoad
    unit: pF
    typical: 3
  corner:
    description: Process corner
    display: Corner
    typical: tt
  rcorner:
    description: Resistor corner (res_<rcorner> of cornerRES.lib)
    display: Rcorner
    typical: typ
  temperature:
    description: Ambient temperature
    display: Temp
    unit: °C
    typical: 27

parameters:
  dc_op:
    display: DC operating point
    description: Supply current and DC level of the outputs (inputs at Vcm, logic pins at 0 V)
    spec:
{spec}    tool:
      ngspice:
        template: dc_op.sch
        format: ascii
        suffix: .data
        variables: [{', '.join(vars_)}]
    plot:
      dc_op_IQ_vs_temperature:
        type: xyplot
        xaxis: temperature
        yaxis: IQ
        limits: auto
    conditions:
      corner:
        enumerate: [tt, ss, ff, sf, fs]
      vdd:
        minimum: 1.2
        typical: 1.35
        maximum: 1.5
      temperature:
        minimum: -40
        typical: 27
        maximum: 85
"""
    open(yaml_path, "w").write(y)

    # ---- registry
    cp = os.path.join(ROOT, "cells.yaml")
    t = open(cp).read()
    m = re.search(rf"^{re.escape(cell)}:\n((?:  .*\n)+)", t, re.M)
    if m:
        block = m.group(1)
        nb = block
        if "  cace:" not in nb:
            nb = re.sub(r"(  sch: .*\n)", r"\1" + f"  cace: cace/{cell}.yaml\n", nb) if "  sch:" in nb else nb + f"  cace: cace/{cell}.yaml\n"
        nb = re.sub(r"  stages: \[(.*)\]", lambda s: "  stages: [" + ("cace, " + s.group(1) if "cace" not in s.group(1) else s.group(1)).strip(", ") + "]", nb)
        t = t.replace(block, nb)
    else:
        t += f"{cell}:\n  sch: xschem/{cell}/{cell}.sch\n  cace: cace/{cell}.yaml\n  stages: [cace]\n"
    open(cp, "w").write(t)
    print(f"new_cell: roles {roles}")
    print(f"new_cell: wrote {os.path.relpath(yaml_path, ROOT)}, {os.path.relpath(tpath, ROOT)}; cells.yaml updated")
    print(f"next: scripts/run_cace.sh {cell}   (then add real parameters; scripts/flow.sh {cell})")


if __name__ == "__main__":
    main()
