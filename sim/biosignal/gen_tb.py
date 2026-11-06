#!/usr/bin/env python3
"""Generate an ngspice transient deck that drives slot9_wrapper with a recorded biosignal.

DUT variants (--net):
  schematic  netlist/pgia_top/schematic/pgia_top.spice   (+ std-cell and decoder includes, as in CACE tran.sch)
  pex_c      netlist/pgia_top/pex/pgia_top.c.spice   (kpex wire C only, flat)
  pex_rc     netlist/pgia_top/pex/pgia_top.rc.spice  (Magic extresist R+C, flat)
All three are wrapped in the slot9_wrapper subckt below.  slot9_wrapper has no extracted netlist of its
own and is a pure pin pass-through to pgia_top (xschem/slot9_wrapper; its LVS netlist
netlist/slot9_wrapper/lvs/slot9_wrapper.spice uses M-cards for devices and is for netgen, not ngspice),
so wrapping reproduces it exactly.

Test bench (same topology as cace/templates/pgia_top/tran.sch):
  VCM (vbias) = 0.6 V, VDD = 1.2 V, IBIAS = 1 uA sourced into ibias0, CL = 15 pF, RL = 100 kOhm,
  V_INP = VCM + vin_off + x(t)/2     V_INN = VCM - x(t)/2        (x = electrode differential voltage)
vin_off is the intentional input offset that cancels the chip's systematic input-referred offset
(0 / -334.7 uV schematic null / -903.7 uV extracted-layout null).
"""
import argparse, os
import numpy as np

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PDK = "/foss/pdks/ihp-sg13cmos5l"
MODELS = f"{PDK}/libs.tech/ngspice/models"
NETLISTS = {
    "schematic": f"{REPO}/netlist/pgia_top/schematic/pgia_top.spice",
    "pex_c": f"{REPO}/netlist/pgia_top/pex/pgia_top.c.spice",
    "pex_rc": f"{REPO}/netlist/pgia_top/pex/pgia_top.rc.spice",
}
# null of the systematic input offset, volts (cace/pgia_top.yaml, vin_off)
VIN_OFF_NULL = {"schematic": -334.7e-6, "pex_c": -903.7e-6, "pex_rc": -903.7e-6}
VCM, VDD, IB = 0.6, 1.2, 1.0e-6

WRAPPER = """\
.subckt slot9_wrapper s9_an_0_esd s9_an_1_esd vbias dig_in[0] dig_in[1] dig_in[2] dig_in[3] vdd_1v2 vss_1v2 ibias0 s9_an[2]
x1 s9_an_0_esd s9_an_1_esd vbias dig_in[0] dig_in[1] dig_in[2] dig_in[3] s9_an[2] vdd_1v2 vdd_1v2 ibias0 vss_1v2 vss_1v2 pgia_top
.ends
"""


def load_signal(name):
    if name.startswith("sine"):                       # sine:<f_Hz>:<Vpp>:<T_s>
        _, f, vpp, T = name.split(":")
        t = np.arange(0, float(T), 1 / (float(f) * 50))
        return t, 0.5 * float(vpp) * np.sin(2 * np.pi * float(f) * t)
    p = os.path.join(REPO, "docs/biosignal/data", name)
    d = np.loadtxt(p, delimiter=",", skiprows=1)
    return d[:, 0], d[:, 1]


def pwl(t, v, scale, offset=0.0):
    pts = " ".join(f"{ti:.6g} {offset + scale * vi:.6e}" for ti, vi in zip(t, v))
    return f"PWL({pts})"


def make_deck(signal, code, net, vin_off, out_csv, tmax=200e-6, tstop=None, corner="tt", temp=27):
    t, x = load_signal(signal)
    if tstop is not None:
        keep = t <= tstop
        t, x = t[keep], x[keep]
    tstop = t[-1]
    dut = NETLISTS[net]
    wrapper = WRAPPER
    extra = (f".include {PDK}/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice\n"
             f".include {REPO}/gds/gain_decoder_4b/final/spice/gain_decoder_4b.spice\n"
             if net == "schematic" else "")
    inp = pwl(t, x, +0.5, VCM + vin_off)
    inn = pwl(t, x, -0.5, VCM)
    bits = [(code >> i) & 1 for i in range(4)]
    gsrc = "\n".join(f"V_D{i} dig_in[{i}] 0 {VDD if b else 0}" for i, b in enumerate(bits))
    return f"""* biosignal transient: {signal}  net={net}  gain code={code}  vin_off={vin_off*1e6:.1f} uV
.lib {MODELS}/cornerMOSlv.lib mos_{corner}
.lib {MODELS}/cornerMOShv.lib mos_{corner}
.lib {MODELS}/cornerRES.lib res_typ
.lib {MODELS}/cornerCAP.lib cap_typ
.lib {MODELS}/cornerDIO.lib dio_tt
.lib {MODELS}/cornerMOSCAP.lib moscap_tt
.include {dut}
{extra}{wrapper}
.temp {temp}
.option method=gear reltol=1e-3 abstol=1e-13 vntol=1e-7 gmin=1e-14

X_DUT s9_an_0_esd s9_an_1_esd vbias dig_in[0] dig_in[1] dig_in[2] dig_in[3] vdd_1v2 vss_1v2 ibias0 s9_an[2] slot9_wrapper
V_VDD vdd_1v2 0 {VDD}
V_VSS vss_1v2 0 0
V_VCM vbias 0 {VCM}
I_IA ibias0 0 -{IB}
{gsrc}
V_INP s9_an_0_esd 0 {inp}
V_INN s9_an_1_esd 0 {inn}
CL s9_an[2] 0 15p
RL s9_an[2] 0 100k
E_OUT vout 0 s9_an[2] 0 1
E_IN vdiff 0 s9_an_0_esd s9_an_1_esd 1

.control
set num_threads=1
save vout vdiff v_vdd#branch
tran {tmax:.3g} {tstop:.6g} 0 {tmax:.3g}
wrdata {out_csv} vout vdiff v_vdd#branch
quit
.endc
.end
"""


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("signal", help="eeg_oz.csv | emg_tibialis.csv | ecg_mitdb100.csv | sine:<Hz>:<Vpp>:<s>")
    ap.add_argument("--code", type=int, default=0, help="gain code 0..10 (gain = 8*2^code)")
    ap.add_argument("--net", choices=NETLISTS, default="schematic")
    ap.add_argument("--vin-off", type=float, default=None,
                    help="offset on VINP in uV; default = the null for the chosen netlist; 0 = no null")
    ap.add_argument("--out", default="out.txt", help="wrdata output file written by ngspice")
    ap.add_argument("--tmax", type=float, default=200e-6, help="max internal time step (s)")
    ap.add_argument("--tstop", type=float, default=None, help="truncate the signal to this length (s)")
    a = ap.parse_args()
    off = VIN_OFF_NULL[a.net] if a.vin_off is None else a.vin_off * 1e-6
    print(make_deck(a.signal, a.code, a.net, off, a.out, a.tmax, a.tstop))
