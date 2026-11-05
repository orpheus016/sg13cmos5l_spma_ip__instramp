#!/usr/bin/env python3
"""CACE template of central_bias: cace/templates/central_bias/currents.sch (+ the DUT symbol and xschemrc).

  make_central_bias_templates.py

central_bias turns one sourced current (ibias0 of the harness) into the four bias currents of pgia_top. The testbench loads every output with the
bias reference of the block it feeds in the chip, so the outputs sit at the voltage they have there:
  IB_IA   sink, PMOS diode to AVDD  w=0.15u l=0.15u m=3 (three OTAs of instramp_cmos5l)      IB_BUF sink, same diode m=1 (output_buffer)
  IB_G1/2 source, NMOS diode to AVSS w=0.87u l=2u (gain_ota MM_refn of each gain stage)
Zero-volt sense sources measure the four currents. One operating point per condition; the corners "<c>_mismatch" make it a Monte Carlo run
(cace/central_bias.params.yaml, parameter mc_currents).
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TDIR = os.path.join(ROOT, "cace", "templates", "central_bias")
os.makedirs(TDIR, exist_ok=True)

# DUT symbol as a primitive: the DUT netlist (schematic or extracted) comes from .include CACE{DUT_path}
sym = open(os.path.join(ROOT, "xschem", "central_bias", "central_bias.sym")).read().replace("type=subcircuit", "type=primitive")
open(os.path.join(TDIR, "central_bias.sym"), "w").write(sym)
sch_copy = os.path.join(TDIR, "central_bias.sch")
if os.path.isfile(sch_copy):
    os.remove(sch_copy)
open(os.path.join(TDIR, "xschemrc"), "w").write("""# xschemrc for central_bias CACE templates
set _here [file dirname [file normalize [info script]]]
source [file normalize "$_here/../xschemrc"]
append XSCHEM_LIBRARY_PATH :$_here
append XSCHEM_LIBRARY_PATH :$_here/../../xschem/central_bias
""")

LIBS_BLOCK = r"""C {simulator_commands_shown.sym} 600 -700 0 0 {name=Libs_Ngspice
simulator=ngspice
only_toplevel=false
value="
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOSlv.lib mos_CACE\{corner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOShv.lib mos_CACE\{corner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerRES.lib res_CACE\{rcorner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerCAP.lib cap_typ
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerDIO.lib dio_tt
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOSCAP.lib moscap_tt

.include CACE\{DUT_path\}

.temp CACE\{temperature\}

.option SEED=CACE[CACE\{seed=12345\} + CACE\{iterations=0\}]
"
      }"""

PARAMS_BLOCK = r"""C {simulator_commands_shown.sym} 600 -480 0 0 {name=General_Params
simulator=ngspice
only_toplevel=false
value=".param temp=CACE\{temperature\}
.param vdd=CACE\{vdd\}
.param ib0=CACE\{ib0\}
"
      }"""


def lab(name, net, x, y, rot=0, flip=0):
    return f"C {{lab_wire.sym}} {x} {y} {rot} {flip} {{name={name} lab={net}}}"


def dev(kind, name, x, y, w, l, m, d, g, s, b):
    """MOS of the PDK symbol library; pins D (20,-30) G (-20,0) S (20,30) B (20,0) for nmos, D/S swapped for pmos."""
    top, bot = (d, s) if kind == "nmos" else (s, d)
    return [
        f"C {{sg13cmos5l_pr/sg13_lv_{kind}.sym}} {x} {y} 0 0 {{name={name}\nl={l}\nw={w}\nng=1\nm={m}\nmm_ok=1\nmodel=sg13_lv_{kind}\nspiceprefix=X\n}}",
        lab(f"l_{name}_t", top, x + 20, y - 30, 1), lab(f"l_{name}_b", bot, x + 20, y + 30, 3),
        lab(f"l_{name}_g", g, x - 20, y, 2), lab(f"l_{name}_bk", b, x + 20, y, 0),
    ]


def vsrc(name, value, p, m, x, y, save="true"):
    return [f"C {{vsource.sym}} {x} {y} 0 0 {{name={name} value={value} savecurrent={save}}}",
            lab(f"l_{name}_p", p, x, y - 30, 1), lab(f"l_{name}_m", m, x, y + 30, 3)]


L = ["v {xschem version=3.4.8RC file_version=1.3}", "G {}", "K {}", "V {}", "S {}", "F {}", "E {}",
     'C {title.sym} 160 -30 0 0 {name=l4 author="SPMA"}',
     "C {central_bias.sym} 0 0 0 0 {name=x1}"]
for name, net, x, y, rot in (("l_in", "IB_IN", -100, 0, 2), ("l_ia", "IB_IA", 100, -60, 0), ("l_buf", "IB_BUF", 100, -20, 0), ("l_g1", "IB_G1", 100, 20, 0),
                             ("l_g2", "IB_G2", 100, 60, 0), ("l_vdd", "AVDD", 0, -90, 1), ("l_vss", "AVSS", 0, 90, 3)):
    L.append(lab(name, net, x, y, rot))
# supplies and the input current (sourced into IB_IN: negative value of a sink-oriented isource, as in pgia_top)
L += vsrc("V_AVDD", r"\{vdd\}", "AVDD", "0", -500, -250, "true")
L += vsrc("V_AVSS", "0", "AVSS", "0", -420, -250, "false")
L += [r"C {isource.sym} -340 -250 0 0 {name=I_IN value=\{-ib0\}}", lab("l_iin_p", "IB_IN", -340, -280, 1), lab("l_iin_m", "0", -340, -220, 3)]
# loads: reference diode of the block, behind a zero-volt sense source
L += vsrc("V_SIA", "0", "n_ia", "IB_IA", 300, -180)
L += dev("pmos", "M_LIA", 380, -180, "0.15u", "0.15u", 3, "n_ia", "n_ia", "AVDD", "AVDD")
L += vsrc("V_SBUF", "0", "n_buf", "IB_BUF", 300, -80)
L += dev("pmos", "M_LBUF", 380, -80, "0.15u", "0.15u", 1, "n_buf", "n_buf", "AVDD", "AVDD")
L += vsrc("V_SG1", "0", "IB_G1", "n_g1", 300, 20)
L += dev("nmos", "M_LG1", 380, 20, "0.87u", "2u", 1, "n_g1", "n_g1", "AVSS", "AVSS")
L += vsrc("V_SG2", "0", "IB_G2", "n_g2", 300, 120)
L += dev("nmos", "M_LG2", 380, 120, "0.87u", "2u", 1, "n_g2", "n_g2", "AVSS", "AVSS")

CONTROL = r""".control
set num_threads=CACE\{jobs\}
save all
op

let i_ia = abs(i(v_sia))
let i_buf = abs(i(v_sbuf))
let i_g1 = abs(i(v_sg1))
let i_g2 = abs(i(v_sg2))
let ib0 = CACE\{ib0\}

let cace_I_IA = i_ia
let cace_I_BUF = i_buf
let cace_I_G1 = i_g1
let cace_I_G2 = i_g2
let cace_R_IA = i_ia / ib0
let cace_R_BUF = i_buf / ib0
let cace_R_G = (i_g1 + i_g2) / 2 / ib0
let cace_ERR_G = 100 * (i_g1 - i_g2) / ((i_g1 + i_g2) / 2)
let cace_PWR = -i(v_avdd) * CACE\{vdd\}

echo $&cace_I_IA $&cace_I_BUF $&cace_I_G1 $&cace_I_G2 $&cace_R_IA $&cace_R_BUF $&cace_R_G $&cace_ERR_G $&cace_PWR > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"""

L.append(LIBS_BLOCK)
L.append(PARAMS_BLOCK)
L.append('C {simulator_commands.sym} 600 -280 0 0 {name=Control\nsimulator=ngspice\nonly_toplevel="false"\nvalue="' + CONTROL + '"\n}')
open(os.path.join(TDIR, "currents.sch"), "w").write("\n".join(L) + "\n")
print("[*] Wrote template: cace/templates/central_bias/currents.sch")
