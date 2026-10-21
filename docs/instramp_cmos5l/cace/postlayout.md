# Schematic vs post-layout

* schematic run: `/foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-10-21_10-03-50` (netlist source: schematic)
* post-layout run: `/foss/designs/sg13cmos5l_spma_ip__instramp/runs/pex_cace/instramp_cmos5l/RUN_2026-10-21_10-05-47` (netlist source: pex)
* flag threshold: 5 % on the typical value; units as in the CACE summary

| Parameter | Var | Unit | Schematic min / typ / max | Post-layout min / typ / max | Δ typ | Δ typ % | Status | Flag |
|---|---|---|---|---|---:|---:|---|---|
| Closed-loop gain at 1 Hz | A_CL | dB | 17.765 / 18.061 / 18.262 | 18.06 / 18.06 / 18.06 | -0.001 | -0.01 | Pass → Pass |  |
| Gain error vs 8 V/V | A_ERR | dB | -0.297 / -0 / 0.2 | -0.002 / -0.002 / -0.002 | -0.002 | n/a | Pass → Pass |  |
| -3 dB bandwidth | F3DB | Hz | 2.0889e+05 / 2.7925e+05 / 3.6166e+05 | 2.8461e+05 / 2.8461e+05 / 2.8461e+05 | +5355 | +1.92 | Pass → Pass |  |
| 0 dB frequency | F0DB | Hz | 1.5061e+06 / 1.9876e+06 / 2.539e+06 | 2.0418e+06 / 2.0418e+06 / 2.0418e+06 | +5.421e+04 | +2.73 | Pass → Pass |  |
| Closed-loop phase at 0 dB | PH0 | ° | -143.19 / -139.83 / -134.18 | -142.71 / -142.71 / -142.71 | -2.885 | -2.06 | Pass → Pass |  |
| THD | THD_DB | dB | -72.538 / -63.52 / -46.17 | -62.618 / -62.618 / -62.618 | +0.902 | +1.42 | Pass → Pass |  |
| THD | THD_PCT | % | 0.024 / 0.067 / 0.491 | 0.074 / 0.074 / 0.074 | +0.007 | +10.45 | Pass → Pass | Δ |
| 2nd harmonic | HD2_DB | dB | -80.791 / -64.979 / -48.314 | -63.677 / -63.677 / -63.677 | +1.302 | +2.00 | Pass → Pass |  |
| 3rd harmonic | HD3_DB | dB | -76.241 / -69.23 / -50.352 | -69.281 / -69.281 / -69.281 | -0.051 | -0.07 | Pass → Pass |  |
| Output fundamental amplitude | VO1 | V | 0.192 / 0.2 / 0.204 | 0.2 / 0.2 / 0.2 | +0 | +0.00 | Pass → Pass |  |
| Differential gain @10 Hz | ADM_DC | dB | 17.735 / 18.039 / 18.241 | 18.044 / 18.044 / 18.044 | +0.005 | +0.03 | Pass → Pass |  |
| CMRR @10 Hz | CMRR_DC | dB | 41.798 / 47.694 / 52.303 | 48.397 / 48.397 / 48.397 | +0.703 | +1.47 | Pass → Pass |  |
| CMRR @100 kHz | CMRR_100K | dB | 38.52 / 44.356 / 49.51 | 44.836 / 44.836 / 44.836 | +0.48 | +1.08 | Pass → Pass |  |
| CMRR @1 MHz | CMRR_1M | dB | 21.311 / 27.278 / 32.934 | 27.357 / 27.357 / 27.357 | +0.079 | +0.29 | Pass → Pass |  |
| Differential gain @10 Hz | ADM_DC#2 | dB | 17.735 / 18.039 / 18.241 | 18.044 / 18.044 / 18.044 | +0.005 | +0.03 | Pass → Pass |  |
| PSRR @10 Hz | PSRR_DC | dB | 50.403 / 72.884 / 102.12 | 75.594 / 75.594 / 75.594 | +2.71 | +3.72 | Pass → Pass |  |
| PSRR @100 kHz | PSRR_100K | dB | 50.344 / 62.056 / 66.067 | 66.067 / 66.067 / 66.067 | +4.011 | +6.46 | Pass → Pass | Δ |
| PSRR @1 MHz | PSRR_1M | dB | 41.461 / 44.243 / 50.529 | 46.236 / 46.236 / 46.236 | +1.993 | +4.50 | Pass → Pass |  |
| Input noise @10 Hz | IRN_10 | nV/rtHz | 2859.5 / 3453.6 / 4016.5 | 3423.4 / 3423.4 / 3423.4 | -30.15 | -0.87 | Pass → Pass |  |
| Input noise @100 Hz | IRN_100 | nV/rtHz | 906.4 / 1095 / 1272.9 | 1085.1 / 1085.1 / 1085.1 | -9.91 | -0.91 | Pass → Pass |  |
| Input noise @1 kHz | IRN_1K | nV/rtHz | 293.35 / 354.55 / 411.25 | 350.86 / 350.86 / 350.86 | -3.69 | -1.04 | Pass → Pass |  |
| Input noise @10 kHz | IRN_10K | nV/rtHz | 111.85 / 134.68 / 155.09 | 133.04 / 133.04 / 133.04 | -1.636 | -1.21 | Pass → Pass |  |
| Output noise @1 kHz | ORN_1K | nV/rtHz | 2392.1 / 2837.7 / 3213.4 | 2806.4 / 2806.4 / 2806.4 | -31.31 | -1.10 | Pass → Pass |  |
| Integrated output noise | ONOISE_TOT | uV-rms | 482.78 / 544.2 / 593.5 | 543.46 / 543.46 / 543.46 | -0.734 | -0.13 | Pass → Pass |  |
| In-band input-referred noise (Vn_out / gain) | INOISE_EQ | uV-rms | 59.204 / 67.899 / 75.955 | 67.945 / 67.945 / 67.945 | +0.046 | +0.07 | Pass → Pass |  |
| Output offset (Vcm - Vout) | VOS | mV | -4.87 / -1.933 / -0.436 | -6.597 / -6.597 / -6.597 | -4.664 | -241.28 | Pass → Pass | Δ |
| Output voltage | VOUT | V | 0.6 / 0.602 / 0.605 | 0.607 / 0.607 / 0.607 | +0.005 | +0.83 | Pass → Pass |  |
| Quiescent current | IQ | uA | 48.004 / 54.873 / 59.75 | 54.93 / 54.93 / 54.93 | +0.057 | +0.10 | Pass → Pass |  |
| Quiescent power | PWR | uW | 57.605 / 74.078 / 89.625 | 74.155 / 74.155 / 74.155 | +0.077 | +0.10 | Pass → Pass |  |
| Small-signal gain (transient) | TR_GAIN |  | 7.7318 / 7.9999 / 8.1872 | 7.9987 / 7.9987 / 7.9987 | -0.00114 | -0.01 | Pass → Pass |  |
| Mean output level | TR_VOUT_AVG | V | 0.6 / 0.602 / 0.605 | 0.607 / 0.607 / 0.607 | +0.005 | +0.83 | Pass → Pass |  |

3 row(s) flagged.

![deltas](postlayout.png)
