# Schematic vs post-layout

* schematic run: `/foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-11-05_17-41-44` (netlist source: schematic)
* post-layout run: `/foss/designs/sg13cmos5l_spma_ip__instramp/runs/pex_cace_rc/pgia_top/RUN_2026-11-05_18-40-35` (netlist source: pex)
* flag threshold: 5 % on the typical value; units as in the CACE summary

| Parameter | Var | Unit | Schematic min / typ / max | Post-layout min / typ / max | Δ typ | Δ typ % | Status | Flag |
|---|---|---|---|---|---:|---:|---|---|
| Closed-loop gain @1 kHz | A_CL | dB | -157.27 / 26.91 / 77.375 | -40.065 / 20.922 / 44.99 | -5.988 | -22.25 | Pass → Pass | Δ |
| Gain step error vs target | A_ERR | dB | -235.54 / -3.527 / 21.937 | -118.33 / -2.437 / 0.115 | +1.09 | +30.90 | Pass → Pass | Δ |
| -3 dB bandwidth | F3DB | Hz | 1421.3 / 2.2013e+05 / 4.448e+07 | 6409.4 / 1.9916e+05 / 2.3605e+05 | -2.097e+04 | -9.53 | Pass → Pass | Δ |
| 0 dB frequency | F0DB | Hz | 27614 / 2.8383e+06 / 1e+07 | 3.9484e+05 / 2.4202e+06 / 1e+07 | -4.181e+05 | -14.73 | Pass → Pass | Δ |
| Phase @1 kHz | PH_1K | ° | -179.24 / -0.377 / 179.81 | -10.734 / -0.457 / -0.356 | -0.08 | -21.22 | Pass → Pass | Δ |
| Input pseudo-resistor | R_PSEUDO | GOhm | 3.563 / 13.559 / 43.789 | 16.63 / 16.995 / 18.407 | +3.436 | +25.34 | Pass → Pass | Δ |
| Output peak-to-peak | VPP_OUT | mV | 0 / 1.969 / 73.973 | 0.001 / 0.953 / 14.19 | -1.016 | -51.60 | Pass → Pass | Δ |
| Effective voltage gain | EFF_GAIN | V/V | 0 / 49.237 / 1849.3 | 0.02 / 23.813 / 354.76 | -25.42 | -51.64 | Pass → Pass | Δ |

8 row(s) flagged.

![deltas](postlayout_rc.png)
