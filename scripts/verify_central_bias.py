#!/usr/bin/env python3
"""Does the chip work with only the harness bias pin?  Simulation proof for xschem/central_bias.

  verify_central_bias.py [--ibias0 1.0u] [--keep]

pgia_top used to be simulated with four separate bias currents (IBIAS_IA 4.2 uA and IBIAS_BUF 1.4 uA sunk, IBIAS_G1 / IBIAS_G2 1.0 uA sourced:
commit 0777ca0). The harness slot has only ibias0 (an iDAC *source*). The schematic of pgia_top still ties all four bias pins to one net; central_bias
makes the four currents from one. This script takes the CURRENT schematics (nothing in the repository is modified; everything happens in a temp
directory), puts central_bias between ibias0 and the four blocks in the chip testbench and checks

  - the four currents delivered by central_bias at ibias0 (targets 4.2 / 1.4 / 1.0 / 1.0 uA at 1.0 uA, +-15 %)
  - VOUT at gain code 0 within 15 mV of Vcm (0.6 V), static power below 500 uW
  - the gain of the 11 codes within 0.6 dB of the verified result of commit 0777ca0 (scripts/audit_gain_steps.py BASELINE_MEASURED_DB)

Exit: 0 all met, 1 something is outside the limits, 2 a tool step failed.
"""
import argparse
import importlib.util
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENV = dict(os.environ, PDK="ihp-sg13cmos5l", PDK_ROOT=os.environ.get("PDK_ROOT", "/foss/pdks"))
TARGET = {"IA": 4.2, "BUF": 1.4, "G1": 1.0, "G2": 1.0}   # uA at ibias0 = 1.0 uA
BLOCKS = [("x_ia AVSS AVDD", "ib_ia", "IA"), ("x_stage1 AVDD AVSS", "ib_g1", "G1"), ("x_stage2 AVDD AVSS", "ib_g2", "G2"), ("x_buf AVDD AVSS", "ib_buf", "BUF")]


def netlist(sch_dir, sch, out_dir, home):
    r = subprocess.run(["xschem", "-q", "-n", "-s", "--rcfile", "xschemrc", "-o", out_dir, sch], cwd=sch_dir, env=dict(ENV, HOME=home), capture_output=True, text=True)
    path = os.path.join(out_dir, os.path.splitext(sch)[0] + ".spice")
    if not os.path.isfile(path):
        sys.exit("verify_central_bias: xschem produced no netlist for %s\n%s" % (sch, r.stdout[-400:] + r.stderr[-400:]))
    txt = open(path).read()
    if "IS MISSING" in txt:
        sys.exit("verify_central_bias: xschem could not find symbols for %s (PDK=%s)" % (sch, ENV["PDK"]))
    return txt


def load_audit():
    spec = importlib.util.spec_from_file_location("audit_gain_steps", os.path.join(ROOT, "scripts", "audit_gain_steps.py"))
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


def ngspice(cwd, spice):
    shutil.copy(os.path.join(ROOT, "xschem", "pgia_top", "simulations", ".spiceinit"), os.path.join(cwd, ".spiceinit"))
    r = subprocess.run(["ngspice", "-b", spice], cwd=cwd, capture_output=True, text=True)
    return r.stdout + r.stderr


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--ibias0", default="1.0u", help="current sourced into the ibias0 pin (default 1.0u)")
    ap.add_argument("--keep", action="store_true", help="keep the temp directory")
    a = ap.parse_args()
    tmp = tempfile.mkdtemp(prefix="central_bias_")
    home = tempfile.mkdtemp(prefix="xsh_home_")
    try:
        cb = netlist(os.path.join(ROOT, "xschem", "central_bias"), "central_bias.sch", tmp, home)
        devs = [l for l in cb.splitlines() if l.startswith("X")]
        if len(devs) != 7:
            sys.exit(f"verify_central_bias: expected 7 devices in central_bias, found {len(devs)}")
        sub = ".subckt central_bias IB_IN IB_IA IB_BUF IB_G1 IB_G2 AVDD AVSS\n" + "\n".join(devs) + "\n.ends\n"
        tb = netlist(os.path.join(ROOT, "xschem", "pgia_top"), "tb_pgia_top.sch", tmp, home)
        s = tb
        integrated = bool(re.search(r"^x_bias .* central_bias\s*$", s, re.M))   # central_bias already instantiated in pgia_top.sch
        if not integrated:
            for blk, net, _ in BLOCKS:
                old = f"{blk} IBIAS_IA "
                if s.count(old) != 1:
                    sys.exit(f"verify_central_bias: pgia_top.sch changed (expected '{old}...' once): this script patches the placeholder wiring where all blocks share IBIAS_IA")
                s = s.replace(old, f"{blk} {net}_x ")
            s = s.replace("x_buf AVDD AVSS ib_buf_x v_stage2 VOUT output_buffer", "x_buf AVDD AVSS ib_buf_x v_stage2 VOUT output_buffer\n" + "\n".join(
                [f"Vs_{net} {net} {net}_x 0" for _, net, _ in BLOCKS] + ["x_bias IBIAS_IA ib_ia ib_buf ib_g1 ib_g2 AVDD AVSS central_bias"]), 1)
            s = s.replace("\n.subckt instramp_cmos5l", "\n" + sub + ".subckt instramp_cmos5l", 1)
        m = re.search(r"^I_IA IBIAS_IA 0 [^\n]*$", s, re.M)
        if not m:
            sys.exit("verify_central_bias: no bias source I_IA in the chip testbench")
        s = s.replace(m.group(0), f"I_IA 0 IBIAS_IA {a.ibias0}")
        chip = os.path.join(tmp, "tb_chip.spice")
        open(chip, "w").write(s)
        # 1) the four currents (operating point of the same netlist, branch currents of the 0 V sense sources; only for the pre-integration wiring)
        cur = {}
        if not integrated:
            i0, j0 = s.index(".control"), s.rindex(".endc") + len(".endc")
            probe = s[:i0] + ".control\nset num_threads=4\nsave all\nop\n" + "\n".join(
                f'print "v.x1.vs_{net}#branch"' for _, net, _ in BLOCKS) + "\n.endc" + s[j0:]
            open(os.path.join(tmp, "tb_probe.spice"), "w").write(probe)
            out = ngspice(tmp, "tb_probe.spice")
            for _, net, name in BLOCKS:
                mm = re.search(r'v\.x1\.vs_%s#branch"\s*=\s*([-0-9.e+]+)' % net, out)
                if not mm:
                    sys.exit("verify_central_bias: could not read the bias current of %s\n%s" % (name, out[-600:]))
                cur[name] = abs(float(mm.group(1))) * 1e6
        # 2) the full chip testbench: DC levels, power and the gain of every code
        log = ngspice(tmp, "tb_chip.spice")
        au = load_audit()
        measured = au.parse_log(log)
        vout = re.search(r"V\(VOUT\)\s*=\s*([-0-9.e+]+)", log)
        pwr = re.search(r"Total Static DC Power\s*=\s*([-0-9.e+]+)", log)
        if not measured or not vout or not pwr:
            sys.exit("verify_central_bias: the chip simulation gave no result\n" + log[-800:])
        vout, pwr = float(vout.group(1)), float(pwr.group(1))
    finally:
        if not a.keep:
            shutil.rmtree(tmp, ignore_errors=True)
        shutil.rmtree(home, ignore_errors=True)
    ib = float(a.ibias0.replace("u", "e-6").replace("n", "e-9").replace("m", "e-3")) * 1e6
    ok = True
    print(f"central_bias with ibias0 = {a.ibias0} sourced (ratios drawn for 1.0 uA; scale = {ib:.2f}):")
    if integrated:
        print("  (central_bias is instantiated in pgia_top.sch: bias currents are not probed, the chip result below is the proof)")
    for name in ("IA", "BUF", "G1", "G2") if cur else ():
        want = TARGET[name] * ib
        good = abs(cur[name] - want) <= 0.15 * want
        ok &= good
        print(f"  {name:3s} bias current {cur[name]:6.3f} uA   target {want:5.2f} uA   {'ok' if good else 'OUT'}")
    good = abs(vout - 0.6) <= 0.015
    ok &= good
    print(f"  VOUT (code 0) {vout:.4f} V   target 0.600 V +-15 mV   {'ok' if good else 'OUT'}")
    good = pwr < 500
    ok &= good
    print(f"  static power {pwr:.1f} uW   limit 500 uW   {'ok' if good else 'OUT'}")
    print("  code  gain dB   reference dB (0777ca0)   delta")
    for code in range(11):
        g, ref = measured.get(code), au.BASELINE_MEASURED_DB[code]
        d = None if g is None else g - ref
        good = d is not None and abs(d) <= 0.6
        ok &= good
        print(f"  {code:4d}  {('%.2f' % g) if g is not None else '  n/a':>7s}   {ref:7.2f}                {('%+.2f' % d) if d is not None else 'n/a':>6s}  {'ok' if good else 'OUT'}")
    print("verify_central_bias:", "OK" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
