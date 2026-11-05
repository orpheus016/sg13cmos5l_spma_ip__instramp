#!/usr/bin/env python3
"""CACE template `input_network` of instramp_cmos5l: the instrumentation amplifier WITH the input bias network it has in pgia_top.

  make_instramp_inbias_template.py [--check]

The instramp cell has no input bias network; in pgia_top the four PMOS pseudo-resistors MM1..MM4 (VINN - VCM and VINP - VCM, two
diode-connected devices back to back each) sit outside the cell. The other instramp CACE testbenches drive VINP / VINN / CM with ideal
voltage sources (core characterisation). This template puts the network back, and a source impedance Rs in front of it, and measures what an
ideal source hides:
  R_IN     DC input resistance of one input (AC at 0.1 Hz, source impedance subtracted)      A_NET    closed-loop gain at 1 kHz with the network
  IRN_100  input-referred noise at 100 Hz and  IRN_1K at 1 kHz, source impedance included     VOS_NET  output DC level minus Vcm
  THD_DB / HD3_DB  distortion of a vin_amp sine on VINP behind Rs, coherent FFT as in thd.sch
The four transistors are NOT copied by hand: they are read from the LVS netlist of pgia_top (netlist/pgia_top/lvs/pgia_top.spice, the netlist
the layout was verified against), so the template follows the chip. Written: cace/templates/instramp_cmos5l/inbias.sch (skeleton: thd.sch).
--check writes nothing and exits 1 when the template is out of date (CI / build_all.sh).
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NETLIST = os.path.join(ROOT, "netlist", "pgia_top", "lvs", "pgia_top.spice")
SKELETON = os.path.join(ROOT, "cace", "templates", "instramp_cmos5l", "thd.sch")
OUT = os.path.join(ROOT, "cace", "templates", "instramp_cmos5l", "inbias.sch")
NODE = {"VCM": "vcm", "VINN": "vinn", "VINP": "vinp", "AVDD": "VDD", "net1": "pr_n1", "net2": "pr_n2"}


def network():
    """The pseudo-resistor devices of pgia_top as SPICE lines for the testbench."""
    if not os.path.isfile(NETLIST):
        sys.exit(f"make_instramp_inbias_template: {os.path.relpath(NETLIST, ROOT)} missing - run scripts/run_lvs.sh pgia_top")
    lines, inside = [], False
    for ln in open(NETLIST):
        if ln.lower().startswith(".subckt pgia_top"):
            inside = True
            continue
        if inside and ln.lower().startswith((".ends", ".subckt")):
            break
        m = re.match(r"^M(M\d+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(sg13_lv_pmos)\s+(.*)$", ln.strip()) if inside else None
        if m:
            name, d, g, s, b, model, rest = m.groups()
            try:
                nodes = " ".join(NODE[x] for x in (d, g, s, b))
            except KeyError as e:
                sys.exit(f"make_instramp_inbias_template: unexpected net {e} in {ln.strip()} - extend NODE")
            lines.append(f"X{name} {nodes} {model} {rest} m=1 mm_ok=1")
    if len(lines) != 4:
        sys.exit(f"make_instramp_inbias_template: expected 4 pseudo-resistor PMOS (MM1..MM4) in pgia_top, found {len(lines)}")
    return lines


CONTROL = r""".control
set num_threads=CACE\{jobs\}
save all
* 1) DC: output level with the network and the source impedance in place
op
let vos_net = v(out)[0] - CACE\{vcm\}
set s_vos = $&vos_net
* 2) small signal: gain at 1 kHz and the resistance one input sees (V3 drives VINP through Rs; VINN is held at DC)
alter @v3[acmag]=1
ac dec 10 0.1 1meg
let gdb = db(v(out))
meas ac gain_1k find gdb at=1k
let a_net = gain_1k
set s_gain = $&a_net
let r_in = 1 / abs(i(v3)[0]) - CACE\{rs\}
set s_rin = $&r_in
* 3) noise referred to V3, source impedance included (Rs and the network are part of the circuit)
noise v(out) v3 dec 20 10 100k
alter @v3[acmag]=0
setplot noise1
let irn_100 = noise1.inoise_spectrum[20]
let irn_1k = noise1.inoise_spectrum[40]
set s_irn100 = $&irn_100
set s_irn1k = $&irn_1k
* 4) distortion: vin_amp sine on VINP behind Rs, coherent sampling (ncyc periods, 128 points each)
let fin_ = CACE\{fin\}
let tstep = 1 / (fin_ * 128)
let tstop = (2 + 8) / fin_ - tstep
let tstart = 2 / fin_
tran $&tstep $&tstop $&tstart $&tstep
set specwindow=none
linearize v(out)
fft v(out)
let nc = floor(2 * (length(v(out)) - 1) / 128 + 0.5)
let mag_f = mag(v(out))
let h1 = mag_f[nc]
let h2 = mag_f[2*nc]
let h3 = mag_f[3*nc]
let hsq = 0
let k = 2
while k <= 9
  let hsq = hsq + mag_f[k*nc]^2
  let k = k + 1
end
let thd_db = 20 * log10(sqrt(hsq) / h1)
let hd3_db = 20 * log10(h3 / h1)
set s_thd = $&thd_db
set s_hd3 = $&hd3_db
echo $s_rin $s_gain $s_irn100 $s_irn1k $s_vos $s_thd $s_hd3 > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"""


def build():
    sk = open(SKELETON).read()
    net = network()
    # the two source-side nets get their own names; Rs joins them to the instrumentation amplifier inputs
    for old, new, name in (("vinp", "vsp", "p9"), ("vinn", "vsn", "p12")):
        pat = re.compile(r"(\{name=%s sig_type=std_logic lab=)%s\}" % (name, old))
        sk, n = pat.subn(r"\g<1>%s}" % new, sk)
        if n != 1:
            sys.exit(f"make_instramp_inbias_template: {SKELETON} changed: source label {name} not found")
    sk = sk.replace(r".param ncyc=8 nskip=2", r".param rs=CACE\{rs\}" + "\n" + r".param ncyc=8 nskip=2", 1)
    a = sk.index("C {simulator_commands.sym} 1070 -600 0 0 {name=THD")
    sk = sk[:a]
    block = (
        "C {simulator_commands_shown.sym} 1070 -1200 0 0 {name=InputNetwork\nsimulator=ngspice\nonly_toplevel=false\nvalue=\"\n"
        "* source impedance in front of both inputs\nRsp vsp vinp \\{rs\\}\nRsn vsn vinn \\{rs\\}\n"
        "* pseudo-resistor network of pgia_top.sch (generated from netlist/pgia_top/lvs/pgia_top.spice, scripts/make_instramp_inbias_template.py)\n"
        + "\n".join(net) + "\n\"\n}\n"
        "C {simulator_commands.sym} 1070 -600 0 0 {name=InputNetworkSim\nsimulator=ngspice\nonly_toplevel=\"false\"\nvalue=\"" + CONTROL + "\"\n}\n"
    )
    return sk + block


def main():
    text = build()
    if "--check" in sys.argv:
        cur = open(OUT).read() if os.path.isfile(OUT) else ""
        if cur != text:
            print(f"make_instramp_inbias_template: {os.path.relpath(OUT, ROOT)} is out of date (pgia_top pseudo-resistors or thd.sch changed): run it without --check")
            return 1
        print("make_instramp_inbias_template: up to date")
        return 0
    if os.path.isfile(OUT) and open(OUT).read() == text:
        print("make_instramp_inbias_template: up to date")
        return 0
    open(OUT, "w").write(text)
    print(f"make_instramp_inbias_template: wrote {os.path.relpath(OUT, ROOT)} ({len(network())} pseudo-resistor devices from pgia_top)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
