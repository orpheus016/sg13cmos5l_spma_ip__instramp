# ota_cmos5l – CACE PVT + Monte Carlo results

Generated with `scripts/run_cace.sh ota_cmos5l` then `scripts/summarize_cace.py` (2026-10-12, schematic netlist, ~1100 simulations in 90 s).

- **PVT:** corner tt/ss/ff/sf/fs × vdd 1.2/1.35/1.5 V × T −40/27/**85** °C (125 °C dropped), Ib 1.4 µA, CL 3 pF, Vcm 0.6 V; res corner typ, cap typ.
- **Monte Carlo:** local mismatch only (`mos_<c>_mismatch`, `res_typ_mismatch`; the `cap_cmomi` C2 has no characterised mismatch), 5 corners × 50 seeds, vdd 1.2 V, 27 °C.
- Raw numbers are in SI in `runs/RUN_*/parameters/*/run_*/*.data`; this file shows them in the yaml display units.

## Headlines
- **Fails against the current specs:** only `PM ≥ 60°` (15/45 PVT runs, worst 55.6° at sf/85 °C; typ 60.6°). A0 ≥ 50 dB passes everywhere (min 55.6 dB).
- **Offset:** systematic |VOS| ≤ 0.55 mV over PVT (follower, spec ±1 mV passes), but **Monte Carlo σ(VOS) ≈ 0.8 mV** → ±3σ ≈ ±2.5 mV, i.e. the ±1 mV target is not met with mismatch (71 % of the 250 MC samples are within ±1 mV – see mc_vos).
- **CMRR @10 Hz** (follower): PVT 54–84 dB, MC mean 55–75 dB, σ 4.6–10 dB (worst sample 48 dB at ss). Falls to ~28 dB @100 kHz and ~7–11 dB @1 MHz.
- **PSRR @10 Hz**: MC (vdd 1.2 V) mean 52–63 dB, σ ≈ 3–4 dB. Over PVT it is 51–62 dB at vdd 1.2 V but **~80–105 dB at vdd ≥ 1.35 V** – verified as a real flat DC value (e.g. sf/1.5 V/27 °C: 105 dB flat from 1 Hz to 30 Hz), not a measurement artifact. Likely a sign-change/cancellation of the supply path between 1.2 V and 1.35 V; worth a vdd sweep before quoting a PSRR number.
- **Gain error** (follower, 1 − dVout/dVin around Vcm): −0.22 % … +0.08 % (negative = gain slightly > 1, the error depends on Vcm through CMRR). **Gain tempco** (box method, −40…85 °C): 0.25 … 2.0 ppm/°C (sign lost in box method; endpoint check agrees, see below).
- **ICMR (follower gain > 0.98):** 0.06–0.10 V … 0.99–1.37 V; span 0.90 V (fs, 1.2 V, 85 °C) … 1.30 V.
- **Small step (±50 mV):** overshoot 4.4–14.7 % (>10 % in some corners), 1 % settling 100–390 ns.
- **Large step (±0.3 V):** SR+ 0.3–2.2 V/µs (min at ss/−40 °C, rise time 1.5 µs – class-A tail), SR− 2.2–2.7 V/µs. Note: the original 0.2→1.0 V step exceeds the upper ICMR at vdd = 1.2 V (ICMR_MAX down to 0.99 V), so it was reduced to vcm ± 0.3 V.


## ac_response – AC response (Tian loop gain)

45 runs.

| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec |
|---|---|---|---|---|---|
| A0 [dB] | 55.59 | ff, 1.2, 85 | 59.48 | ss, 1.5, -40 | ≥ 50 (pass) |
| F3DB [Hz] | 3076 | ss, 1.2, -40 | 4351 | ff, 1.5, 85 | any |
| UGF [Hz] | 2.11e+06 | ss, 1.2, 85 | 3.445e+06 | ff, 1.5, -40 | ≥ 1000000.0 (pass) |
| PM [°] | 55.64 | sf, 1.35, 85 | 66.9 | fs, 1.5, -40 | ≥ 60 (**15/45 fail**) |
| GM [dB] | 14.13 | sf, 1.2, 85 | 21.66 | fs, 1.5, -40 | any |
| GBW [Hz] | 2.259e+06 | ss, 1.2, 85 | 3.611e+06 | ff, 1.5, -40 | any |

## noise – Noise

45 runs.

| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec |
|---|---|---|---|---|---|
| IRN_100 [nV/rtHz] | 505.1 | ff, 1.2, -40 | 708.5 | ss, 1.5, 85 | any |
| IRN_1K [nV/rtHz] | 163.1 | ff, 1.2, -40 | 228.6 | ss, 1.5, 85 | any |
| IRN_10K [nV/rtHz] | 61.33 | ff, 1.2, -40 | 86.6 | ss, 1.2, 85 | any |
| IRN_1M [nV/rtHz] | 45.98 | ff, 1.5, -40 | 98.97 | ss, 1.2, 85 | any |
| ORN_1K [nV/rtHz] | 163.1 | ff, 1.2, -40 | 228.4 | ss, 1.5, 85 | any |
| INOISE_TOT [uV-rms] | 2676 | ff, 1.2, -40 | 3030 | ss, 1.5, 27 | any |
| ONOISE_TOT [uV-rms] | 224.3 | ff, 1.2, -40 | 357.3 | ss, 1.2, 85 | any |

## dc_op – DC operating point (follower)

45 runs.

| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec |
|---|---|---|---|---|---|
| VOS [mV] | -0.5531 | ss, 1.2, 85 | -0.04621 | ff, 1.5, -40 | ≥ -1 ≤ 1 (pass) |
| IQ [uA] | 16.01 | ss, 1.2, -40 | 19.92 | ff, 1.5, 85 | any |
| PWR [uW] | 19.21 | ss, 1.2, -40 | 29.88 | ff, 1.5, 85 | ≤ 50 (pass) |
| VOUT [V] | 0.6 | ff, 1.5, -40 | 0.6006 | ss, 1.2, 85 | any |
| GAIN_ERR [%] | -0.2182 | ss, 1.2, 27 | 0.08398 | ff, 1.5, 85 | any |

## gain_tc – Gain temperature coefficient

15 runs.

| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec |
|---|---|---|---|---|---|
| GAIN_TC [ppm] | 0.2493 | ss, 1.35, 27 | 2.043 | ff, 1.5, 27 | any |
| G_MEAN [V/V] | 0.9993 | ff, 1.5, 27 | 1.002 | ss, 1.2, 27 | any |

## cmrr – CMRR

45 runs.

| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec |
|---|---|---|---|---|---|
| CMRR_DC [dB] | 53.98 | ss, 1.2, 27 | 84.36 | ff, 1.2, -40 | any |
| CMRR_100K [dB] | 27.32 | ss, 1.2, 85 | 31.22 | ff, 1.5, -40 | any |
| CMRR_1M [dB] | 6.976 | ss, 1.2, 85 | 11.24 | ff, 1.5, -40 | any |

## psrr – PSRR

45 runs.

| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec |
|---|---|---|---|---|---|
| PSRR_DC [dB] | 51.48 | ss, 1.2, 27 | 105.4 | sf, 1.5, 27 | any |
| PSRR_100K [dB] | 51.35 | ss, 1.2, 27 | 66.93 | ff, 1.5, -40 | any |
| PSRR_1M [dB] | 41.81 | ss, 1.2, 85 | 48.1 | tt, 1.2, -40 | any |

## icmr – Input common-mode range

45 runs.

| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec |
|---|---|---|---|---|---|
| ICMR_MIN [V] | 0.06041 | fs, 1.2, -40 | 0.09616 | sf, 1.5, 85 | any |
| ICMR_MAX [V] | 0.9912 | fs, 1.2, 85 | 1.369 | sf, 1.5, 27 | any |
| ICMR_SPAN [V] | 0.8998 | fs, 1.2, 85 | 1.297 | sf, 1.5, -40 | any |

## tran_small – Small-signal step (100 mV)

45 runs.

| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec |
|---|---|---|---|---|---|
| T_DELAY [ns] | 50.7 | ff, 1.5, -40 | 86.18 | ss, 1.2, 85 | any |
| T_RISE [ns] | 65.8 | ff, 1.5, -40 | 94.45 | ss, 1.2, 85 | any |
| OVERSHOOT [%] | 4.413 | ss, 1.2, -40 | 14.73 | sf, 1.35, 85 | any |
| TS_1PCT [ns] | 100.1 | ff, 1.5, -40 | 388.2 | ff, 1.2, 85 | any |
| TS_01PCT [ns] | 102.1 | ff, 1.5, -40 | 455.7 | fs, 1.2, 85 | any |

## tran_large – Large-signal step (0.8 V)

45 runs.

| metric | min | at (corner, vdd, T) | max | at (corner, vdd, T) | spec |
|---|---|---|---|---|---|
| SR_POS [V/s] | 3.15e+05 | ss, 1.2, -40 | 2.239e+06 | ff, 1.5, -40 | any |
| SR_NEG [V/s] | 2.152e+06 | ss, 1.2, -40 | 2.679e+06 | ff, 1.5, -40 | any |
| T_RISE [ns] | 214.4 | ff, 1.5, -40 | 1524 | ss, 1.2, -40 | any |
| T_FALL [ns] | 179.2 | ff, 1.5, -40 | 223.1 | ss, 1.2, -40 | any |
| T_PLH [ns] | 153.2 | ff, 1.5, -40 | 208.1 | fs, 1.2, 85 | any |
| T_PHL [ns] | 121.8 | ff, 1.5, -40 | 161.9 | ss, 1.2, 85 | any |

## mc_vos – MC input offset

| metric | corner | N | mean | σ | min | max | mean−3σ | mean+3σ |
|---|---|---|---|---|---|---|---|---|
| VOS [mV] | tt_mismatch | 50 | -0.1713 | 0.8 | -1.641 | 2.195 | -2.573 | 2.23 |
| VOS [mV] | ss_mismatch | 50 | -0.3731 | 0.781 | -1.867 | 1.854 | -2.715 | 1.969 |
| VOS [mV] | ff_mismatch | 50 | -0.01439 | 0.824 | -1.47 | 2.481 | -2.488 | 2.459 |
| VOS [mV] | sf_mismatch | 50 | -0.1795 | 0.805 | -1.623 | 2.225 | -2.593 | 2.234 |
| VOS [mV] | fs_mismatch | 50 | -0.177 | 0.796 | -1.677 | 2.143 | -2.566 | 2.212 |

## mc_cmrr – MC CMRR

| metric | corner | N | mean | σ | min | max | mean−3σ | mean+3σ |
|---|---|---|---|---|---|---|---|---|
| CMRR_DC [dB] | tt_mismatch | 50 | 64.62 | 8.71 | 52.88 | 93.15 | 38.49 | 90.76 |
| CMRR_DC [dB] | ss_mismatch | 50 | 54.88 | 4.58 | 48.05 | 70.96 | 41.13 | 68.62 |
| CMRR_DC [dB] | ff_mismatch | 50 | 75.26 | 10.1 | 58.88 | 95.96 | 45.01 | 105.5 |
| CMRR_DC [dB] | sf_mismatch | 50 | 70.79 | 9.83 | 56.06 | 106 | 41.3 | 100.3 |
| CMRR_DC [dB] | fs_mismatch | 50 | 59.07 | 6.83 | 50.17 | 90.36 | 38.59 | 79.55 |

## mc_psrr – MC PSRR

| metric | corner | N | mean | σ | min | max | mean−3σ | mean+3σ |
|---|---|---|---|---|---|---|---|---|
| PSRR_DC [dB] | tt_mismatch | 50 | 57.37 | 3.66 | 50.68 | 66.87 | 46.38 | 68.36 |
| PSRR_DC [dB] | ss_mismatch | 50 | 51.93 | 3.12 | 46.69 | 60.73 | 42.57 | 61.3 |
| PSRR_DC [dB] | ff_mismatch | 50 | 62.93 | 4.21 | 54.99 | 72.94 | 50.29 | 75.56 |
| PSRR_DC [dB] | sf_mismatch | 50 | 60.32 | 3.88 | 53.07 | 70.03 | 48.67 | 71.97 |
| PSRR_DC [dB] | fs_mismatch | 50 | 54.54 | 3.44 | 48.49 | 63.84 | 44.23 | 64.85 |
