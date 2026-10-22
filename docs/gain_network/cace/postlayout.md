# Schematic vs post-layout

* schematic run: `/foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-10-22_12-19-21` (netlist source: schematic)
* post-layout run: `/foss/designs/sg13cmos5l_spma_ip__instramp/runs/pex_cace/gain_network/RUN_2026-10-22_12-23-36` (netlist source: pex)
* flag threshold: 5 % on the typical value; units as in the CACE summary

| Parameter | Var | Unit | Schematic min / typ / max | Post-layout min / typ / max | Δ typ | Δ typ % | Status | Flag |
|---|---|---|---|---|---:|---:|---|---|
| Closed-loop gain @1 kHz | A_CL | dB | -4.828 / 15.219 / 31.985 | 0.077 / 0.077 / 0.077 | -15.14 | -99.49 | Pass → Pass | Δ |
| Gain error vs target | A_ERR | dB | -34.729 / -0.261 / 8.377 | 0.077 / 0.077 / 0.077 | +0.338 | +129.50 | Pass → Pass | Δ |
| -3 dB bandwidth | F3DB | Hz | 2.5333e+05 / 1.7007e+06 / 6.854e+07 | 1.1732e+06 / 1.1732e+06 / 1.1732e+06 | -5.275e+05 | -31.02 | Pass → Pass | Δ |
| 0 dB frequency | F0DB | Hz | 3.0889e+05 / 1.0396e+07 / 1e+08 | 1.5175e+05 / 1.5175e+05 / 1.5175e+05 | -1.024e+07 | -98.54 | Pass → Pass | Δ |
| Phase @0 dB | PH0 | ° | -180 / 71.769 / 173.84 | 170.14 / 170.14 / 170.14 | +98.37 | +137.07 | Pass → Pass | Δ |
| Output offset voltage | VOS | mV | -284.89 / -2.227 / 474.15 | 0.032 / 0.032 / 0.032 | +2.259 | +101.44 | Pass → Pass | Δ |
| Virtual ground error | V_VG_ERR | mV | -10.115 / -0.653 / 18.195 | 0 / 0 / 0 | +0.653 | +100.00 | Pass → Pass | Δ |
| Quiescent current | IQ | uA | 64.207 / 73.956 / 85.999 | 73.776 / 73.776 / 73.776 | -0.18 | -0.24 | Pass → Pass |  |
| DC power dissipation | PWR | uW | 69.343 / 88.747 / 129 | 88.532 / 88.532 / 88.532 | -0.215 | -0.24 | Pass → Pass |  |
| DC output voltage | VOUT | V | 0.315 / 0.598 / 1.074 | 0.6 / 0.6 / 0.6 | +0.002 | +0.33 | Pass → Pass |  |
| Input noise @10 Hz | IRN_10 | nV/rtHz | 5574.5 / 7162.1 / 12611 | 10761 / 10761 / 10761 | +3599 | +50.25 | Pass → Pass | Δ |
| Input noise @100 Hz | IRN_100 | nV/rtHz | 1763.6 / 2265.8 / 3989.7 | 3404.5 / 3404.5 / 3404.5 | +1139 | +50.25 | Pass → Pass | Δ |
| Input noise @1 kHz | IRN_1K | nV/rtHz | 560.07 / 719.53 / 1267.2 | 1081.2 / 1081.2 / 1081.2 | +361.6 | +50.26 | Pass → Pass | Δ |
| Input noise @10 kHz | IRN_10K | nV/rtHz | 184.46 / 236.88 / 417.82 | 356.02 / 356.02 / 356.02 | +119.1 | +50.29 | Pass → Pass | Δ |
| Output noise @1 kHz | ORN_1K | nV/rtHz | 966.46 / 9429.4 / 19260 | 1090.8 / 1090.8 / 1090.8 | -8339 | -88.43 | Pass → Pass | Δ |
| Integrated output noise | ONOISE_TOT | uV-rms | 449.4 / 1384.8 / 2436 | 279.52 / 279.52 / 279.52 | -1105 | -79.81 | Pass → Pass | Δ |
| In-band input noise | INOISE_EQ | uV-rms | 71.302 / 184.62 / 589.25 | 277.04 / 277.04 / 277.04 | +92.42 | +50.06 | Pass → Pass | Δ |
| Transient step gain | TR_GAIN |  | 0.76511 / 8.0136 / 33.223 | 1.0106 / 1.0106 / 1.0106 | -7.003 | -87.39 | Pass → Pass | Δ |
| Percentage overshoot | OVERSHOOT | % | 0 / 0 / 0 | 0 / 0 / 0 | +0 | n/a | Pass → Pass |  |
| Settling time (0.1%) | SETTLING_TIME | us | 0.206 / 0.792 / 2.87 | 1.038 / 1.038 / 1.038 | +0.246 | +31.06 | Pass → Pass | Δ |
| Slew rate positive | SR_POS | V/s | 3.0692e+06 / 4.2712e+06 / 9.5443e+06 | 1.1122e+06 / 1.1122e+06 / 1.1122e+06 | -3.159e+06 | -73.96 | Pass → Pass | Δ |
| Slew rate negative | SR_NEG | V/s | 1.4213e+06 / 4.0447e+06 / 7.2991e+06 | 1.258e+06 / 1.258e+06 / 1.258e+06 | -2.787e+06 | -68.90 | Pass → Pass | Δ |
| THD in dB | THD_DB | dB | -51.884 / -49.037 / -24.696 | -38.753 / -38.753 / -38.753 | +10.28 | +20.97 | Pass → Pass | Δ |
| THD in % | THD_PCT | % | 0.255 / 0.354 / 5.824 | 1.154 / 1.154 / 1.154 | +0.8 | +225.99 | Pass → Pass | Δ |
| 2nd harmonic | HD2_DB | dB | -57.701 / -50.1 / -35.073 | -41.225 / -41.225 / -41.225 | +8.875 | +17.71 | Pass → Pass | Δ |
| 3rd harmonic | HD3_DB | dB | -82.708 / -58.256 / -25.459 | -42.857 / -42.857 / -42.857 | +15.4 | +26.43 | Pass → Pass | Δ |
| Fundamental output amplitude | VO1 | V | 0.157 / 0.2 / 0.263 | 0.2 / 0.2 / 0.2 | +0 | +0.00 | Pass → Pass |  |
| PSRR @10 Hz | PSRR_DC | dB | 30.485 / 32.91 / 37.733 | 31.337 / 31.337 / 31.337 | -1.573 | -4.78 | Pass → Pass |  |
| PSRR @100 kHz | PSRR_100K | dB | 30.264 / 32.943 / 37.784 | 26.346 / 26.346 / 26.346 | -6.597 | -20.03 | Pass → Pass | Δ |
| PSRR @1 MHz | PSRR_1M | dB | 22.548 / 31.695 / 38.484 | 10.55 / 10.55 / 10.55 | -21.14 | -66.71 | Pass → Pass | Δ |
| CMRR @10 Hz | CMRR_DC | dB | 57.512 / 62.055 / 67.517 | 60.359 / 60.359 / 60.359 | -1.696 | -2.73 | Pass → Pass |  |
| CMRR @100 kHz | CMRR_100K | dB | 34.791 / 40.133 / 42.384 | 25.381 / 25.381 / 25.381 | -14.75 | -36.76 | Pass → Pass | Δ |
| CMRR @1 MHz | CMRR_1M | dB | 14.886 / 24.497 / 31.372 | 7.964 / 7.964 / 7.964 | -16.53 | -67.49 | Pass → Pass | Δ |
| Max glitch voltage deviation | V_GLITCH_MAX | mV | 0.248 / 11.622 / 50.638 | 10.04 / 10.04 / 10.04 | -1.582 | -13.61 | Pass → Pass | Δ |
| Gain switching settling time | T_SWITCH_SETTLE | us | 0.003 / 0.5 / 2.153 | 2.017 / 2.017 / 2.017 | +1.517 | +303.40 | Pass → Pass | Δ |

28 row(s) flagged.

![deltas](postlayout.png)
