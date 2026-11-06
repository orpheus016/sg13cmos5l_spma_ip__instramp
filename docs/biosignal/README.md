# PGIA on real EEG / EMG / ECG recordings

The CACE testbenches drive the chip with a 40 uVpp sine. This page shows what it does with **recorded**
brain, muscle and heart signals, through `slot9_wrapper` (the chip as the Chipalooza harness sees it), on the
**schematic** and on the **extracted layout** (kpex C-only and Magic R+C).

Interactive version (pick signal, netlist and gain code, zoom, hover): open [`report.html`](report.html)
(self-contained, no network needed; e.g. `report.html#sig=eeg&net=pex_rc&code=8&view=overlay`).

> **Scope of this first run.** Only the **ideal input-offset null** is simulated (see
> [the offset quirk](#the-input-offset-quirk)), at the **typical corner, 27 C**, and only for **short
> windows** (EEG and ECG 4 s, EMG 1 s), because one extracted-layout (RC) run takes 20 to 30 minutes.
> The unnulled case, other corners/temperatures and longer recordings are scheduled for a later,
> more complete run ([below](#scheduled-for-the-complete-run)).

## Result in one paragraph

With the offset null applied, the chip reproduces all three signals with correlation of 0.999 or better at a
suitable gain code: **EEG at code 8 (x2048)**, **EMG and ECG at code 5 (x256)**. The extracted layout
(C and RC) tracks the schematic within 0.15 dB in fitted gain and 0.7 points of NRMSE at every case simulated.
VOUT saturates at about 0.99 V, so one gain code too much (ECG/EMG at code 6, ECG at 8 and above) compresses the
R-wave or the bursts. Supply current is about 231 uA (about 277 uW at 1.2 V).

## Signals (real recordings, PhysioNet, ODC-By 1.0)

| Signal | Source | Excerpt used | Amplitude at the electrode |
|---|---|---|---|
| EEG | [EEG Motor Movement/Imagery](https://physionet.org/content/eegmmidb/1.0.0/), S001 run 2 (eyes closed), channel Oz | 4 s, 160 Hz; 54 % of the power is in the 8 to 13 Hz alpha band | 377 uVpp (62 uV rms) |
| EMG | [Examples of Electromyograms](https://physionet.org/content/emgdb/1.0.0/), healthy, needle in tibialis anterior | 1 s of strongest activity, 4 kHz | 1.6 mVpp |
| ECG | [MIT-BIH Arrhythmia](https://physionet.org/content/mitdb/1.0.0/), record 100, MLII | 4 s (5 beats), 360 Hz | 1.5 mVpp |

The excerpts are small CSVs in [`data/`](data/) (`t_s, v_V`), with the DC removed and the time starting at 0.
[`data/fetch_data.py`](data/fetch_data.py) re-downloads the full records and regenerates them;
[`data/ATTRIBUTION.md`](data/ATTRIBUTION.md) has the citations and the processing.

## Test setup

`sim/biosignal/gen_tb.py` writes one ngspice deck per case. All three DUTs sit inside the `slot9_wrapper`
subcircuit, which is a pure pin pass-through to `pgia_top`:

| `slot9_wrapper` pin | Connected to | In the testbench |
|---|---|---|
| `s9_an_0_esd` | VINP | `VCM + vin_off + x(t)/2` |
| `s9_an_1_esd` | VINN | `VCM - x(t)/2` |
| `vbias` | VCM | **0.6 V** |
| `dig_in[3:0]` | `gain_sel[3:0]` | 0 or 1.2 V (binary gain code) |
| `vdd_1v2`, `vss_1v2` | AVDD + VPWR, AVSS + VGND | 1.2 V, 0 V |
| `ibias0` | IBIAS_IA | 1.0 uA sourced into the pin (`I_IA ibias0 0 -1.0u`) |
| `s9_an[2]` | VOUT | 15 pF and 100 kOhm to ground |

`x(t)` is the recorded electrode voltage, applied differentially as a piecewise-linear source. Models: IHP
SG13CMOS5L `cornerMOSlv/hv` tt, `res_typ`, `cap_typ`, 27 C. The three netlists:

| Variant | Netlist | Notes |
|---|---|---|
| Schematic | `netlist/pgia_top/schematic/pgia_top.spice` | plus the std-cell and gain-decoder includes, as in `cace/templates/pgia_top/tran.sch` |
| Layout C | `netlist/pgia_top/pex/pgia_top.c.spice` | kpex, wire capacitance only |
| Layout RC | `netlist/pgia_top/pex/pgia_top.rc.spice` | Magic `extresist`, wire R and C |

There is no extracted netlist of `slot9_wrapper` itself, only of `pgia_top`. As the wrapper only forwards pins,
wrapping the `pgia_top` netlists reproduces it exactly. The wrapper's LVS netlist
(`netlist/slot9_wrapper/lvs/slot9_wrapper.spice`) uses `M` cards for the devices (right for netgen) and does not
simulate in ngspice, so it is not used as a simulation netlist.

### The input offset quirk

The chip has a systematic input-referred offset (about 0.33 mV in the schematic and about 0.9 mV in the extracted
layout). It is amplified by the gain, so without compensation high gain codes rail (see
[`../pgia_top/cace/gain_codes.md`](../pgia_top/cace/gain_codes.md)). The testbench therefore adds an
**intentional DC offset `vin_off` on VINP**, relative to VCM, that cancels it. The values are the CACE `vin_off`
nulls of `cace/pgia_top.yaml`:

| Netlist | `vin_off` |
|---|---|
| Schematic | **-334.7 uV** |
| Layout C and RC | **-903.7 uV** |

The null is fixed per netlist, it is **not** re-tuned per signal or per gain code. It stands for an equivalent
DC offset applied to `s9_an_0_esd` from outside; a real system needs some such offset handling for the high gain
codes.

## Results (ideal offset null, tt, 27 C)

"Fitted" is the least-squares gain between the recorded input and VOUT (DC removed, first 50 ms excluded).
Correlation and NRMSE (residual after the fit, relative to the amplified signal) measure how faithfully the
waveform is reproduced.

| Signal | Code | Netlist | Ideal | Fitted | Error | Corr. | NRMSE | VOUT range (V) | Clipped | State |
|---|---|---|---|---|---|---|---|---|---|---|
| EEG | 8 | Schematic | x2048 | x1832 | -1.0 dB | 1.000 | 0.2 % | 0.21-0.90 | 0.0 % | usable |
| EEG | 8 | Layout C | x2048 | x1834 | -1.0 dB | 1.000 | 0.2 % | 0.24-0.93 | 0.0 % | usable |
| EEG | 8 | Layout RC | x2048 | x1817 | -1.0 dB | 1.000 | 0.2 % | 0.24-0.93 | 0.0 % | usable |
| EMG | 5 | Schematic | x256 | x215 | -1.5 dB | 0.999 | 4.7 % | 0.48-0.81 | 0.0 % | usable |
| EMG | 5 | Layout C | x256 | x214 | -1.5 dB | 0.999 | 4.8 % | 0.48-0.81 | 0.0 % | usable |
| EMG | 5 | Layout RC | x256 | x214 | -1.6 dB | 0.999 | 4.8 % | 0.48-0.81 | 0.0 % | usable |
| EMG | 6 | Schematic | x512 | x462 | -0.9 dB | 0.998 | 5.5 % | 0.34-0.99 | 0.2 % | usable |
| EMG | 6 | Layout C | x512 | x461 | -0.9 dB | 0.998 | 5.9 % | 0.35-0.99 | 0.2 % | usable |
| EMG | 6 | Layout RC | x512 | x458 | -1.0 dB | 0.998 | 5.9 % | 0.35-0.99 | 0.2 % | usable |
| ECG | 5 | Schematic | x256 | x200 | -2.1 dB | 0.999 | 5.0 % | 0.54-0.84 | 0.0 % | usable |
| ECG | 5 | Layout C | x256 | x200 | -2.1 dB | 0.999 | 5.0 % | 0.54-0.84 | 0.0 % | usable |
| ECG | 5 | Layout RC | x256 | x199 | -2.2 dB | 0.999 | 5.0 % | 0.54-0.84 | 0.0 % | usable |
| ECG | 6 | Schematic | x512 | x393 | -2.3 dB | 0.990 | 14.4 % | 0.47-0.99 | 1.3 % | distorted |
| ECG | 6 | Layout C | x512 | x389 | -2.4 dB | 0.989 | 15.1 % | 0.47-0.99 | 1.3 % | distorted |
| ECG | 6 | Layout RC | x512 | x387 | -2.4 dB | 0.989 | 15.0 % | 0.48-0.99 | 1.3 % | distorted |

"Clipped" is the fraction of samples outside 0.05 to 0.98 V. "usable" means clipped below 1 % and correlation
above 0.95; "railed" means clipped above 20 %.

Gain-code sweep on the schematic (correlation / gain error / state):

| Signal | code 0 | code 2 | code 4 | code 6 | code 8 | code 10 |
|---|---|---|---|---|---|---|
| EEG | 1.000 / -0.4 dB / usable | 1.000 / +0.3 dB / usable | 1.000 / -0.7 dB / usable | 1.000 / -0.7 dB / usable | 1.000 / -1.0 dB / usable | 0.964 / -4.0 dB / railed |
| EMG | 1.000 / -0.4 dB / usable | 1.000 / +0.3 dB / usable | 1.000 / -0.8 dB / usable | 0.998 / -0.9 dB / usable | aborted | aborted |
| ECG | 1.000 / -0.4 dB / usable | 1.000 / +0.2 dB / usable | 1.000 / -1.2 dB / usable | 0.990 / -2.3 dB / distorted | 0.799 / -9.3 dB / distorted | 0.616 / -16.0 dB / railed |

### What the numbers say

- **Gain code is set by the signal amplitude.** VOUT saturates near 0.99 V (0.4 V above VCM). The 1.5 mV R-wave of
  the ECG therefore fits at code 5 (x256) but not at code 8; the 377 uV EEG fits at code 8 but not at code 10.
- **Layout vs schematic:** with each netlist's own null, the layout tracks the schematic to within 0.15 dB in
  fitted gain and 0.7 points of NRMSE at all cases simulated (0.1 dB and 0.1 point at the primary codes);
  adding wire resistance (C vs RC) changes the fitted gain by less than 1 %.
- **The fitted gain is 1 to 2 dB below ideal**, as in the small-signal sweep of `gain_codes.md` (-1.0 dB at code 8,
  -1.3 dB at code 5 at 1 kHz). The EEG case matches it; the ECG case at code 5 is 0.8 dB lower than the
  small-signal number, probably from compression near the peak of the R-wave (0.84 V). This was not investigated.
- **EMG at codes 8 and 10 aborts** in ngspice ("timestep too small" in a gain-stage diode) because a 1.6 mV burst at
  x2048 or more is a hard overdrive. Those cases are not reported.
- **Power:** about 231 uA from the 1.2 V supply in every case (about 277 uW).

## Limitations

- **No noise.** The transient has no noise sources, so the EEG shows the chip's linearity and gain, not its SNR.
  At 10 Hz the instrumentation amplifier alone is about 3.45 uV/rtHz (`docs/instramp_cmos5l/cace`), which is a
  noticeable fraction of a 62 uV rms EEG; a noise run is needed for an SNR claim.
- **Ideal source.** The electrode is a voltage source: no electrode-skin impedance, DC drift or mains pickup, and
  no AC-coupling capacitor in front of the inputs (the CACE default has a 10 nF coupling capacitor).
- **One corner, one offset.** tt, 27 C, 1.2 V, and only the ideal offset null.
- **Short windows**, see the scope note. Slow EEG components (delta band and below) are barely represented in 4 s.
- The `pgia_top` post-layout CACE status is currently "fail" on some parameters (`docs/pgia_top/status.md`);
  the transient results above do not contradict it, they cover a different measurement.

## Reproduce

```bash
# 1. recordings -> CSV excerpts (optional, the excerpts are committed)
python3 docs/biosignal/data/fetch_data.py

# 2. one deck by hand (prints the ngspice deck)
python3 sim/biosignal/gen_tb.py ecg_mitdb100.csv --code 5 --net pex_rc --out /tmp/ecg.txt > /tmp/ecg.cir
OMP_NUM_THREADS=1 ngspice -b /tmp/ecg.cir

# 3. the whole matrix + analysis (~35 min wall clock, dominated by the two RC runs)
cd sim/biosignal && python3 run_biosignal.py          # writes results/ and results/summary.json

# 4. the interactive page
python3 docs/biosignal/build_report.py
```

Run each ngspice process on one thread (`OMP_NUM_THREADS=1`, already set by `run_biosignal.py`): several
processes with several threads each oversubscribe the machine badly.

Runtimes measured here (single thread): schematic 2 to 5 min, layout C 3 to 8 min, layout RC 19 to 30 min per case.

## Scheduled for the complete run

- `python3 sim/biosignal/run_biosignal.py --with-none`: the unnulled case (`vin_off = 0`) next to the null, to
  show on real signals what the offset does at the high codes.
- Corners (ss, ff, sf, fs) and -40 / 85 C, and the 1.08 V and 1.5 V supplies.
- Longer recordings (10 s of ECG, several seconds of EMG bursts, longer EEG) and the layout RC netlist at all
  codes, not only the primary one.
- Electrode noise and source impedance, the input coupling capacitor, and an SNR measurement.
- A kpex / Magic extraction of the whole `slot9_wrapper` layout, to replace the wrapped `pgia_top` netlists.
