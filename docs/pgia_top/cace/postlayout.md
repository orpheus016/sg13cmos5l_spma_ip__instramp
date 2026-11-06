# Schematic vs post-layout

* schematic run: `/foss/designs/sg13cmos5l_spma_ip__instramp/runs/RUN_2026-11-05_20-16-47` (netlist source: schematic)
* post-layout run: `/foss/designs/sg13cmos5l_spma_ip__instramp/runs/pex_cace/pgia_top/RUN_2026-11-05_20-39-01` (netlist source: pex)
* flag threshold: 5 % on the typical value; units as in the CACE summary

| Parameter | Var | Unit | Schematic min / typ / max | Post-layout min / typ / max | Δ typ | Δ typ % | Status | Flag |
|---|---|---|---|---|---:|---:|---|---|
| Closed-loop gain @1 kHz | A_CL | dB | -157.27 / 28.225 / 77.375 | -81.275 / 30.273 / 76.702 | +2.048 | +7.26 | Pass → Pass | Δ |
| Gain step error vs target | A_ERR | dB | -235.54 / -3.185 / 23.554 | -159.35 / -0.857 / 0.361 | +2.328 | +73.09 | Pass → Pass | Δ |
| -3 dB bandwidth | F3DB | Hz | 1421.3 / 2.128e+05 / 4.448e+07 | 7657.3 / 2.2842e+05 / 4.1579e+06 | +1.562e+04 | +7.34 | Pass → Pass | Δ |
| 0 dB frequency | F0DB | Hz | 4883.8 / 2.895e+06 / 1e+07 | 3.9307e+05 / 2.6042e+06 / 1e+07 | -2.908e+05 | -10.04 | Pass → Pass | Δ |
| Phase @1 kHz | PH_1K | ° | -179.92 / -0.378 / 179.97 | -93.593 / -0.435 / -0.325 | -0.057 | -15.08 | Pass → Pass | Δ |
| Input pseudo-resistor | R_PSEUDO | GOhm | 3.563 / 13.573 / 43.802 | 16.935 / 16.949 / 16.976 | +3.376 | +24.87 | Pass → Pass | Δ |
| Output peak-to-peak | VPP_OUT | mV | 0 / 3.8 / 544.77 | 0 / 2.608 / 547.3 | -1.192 | -31.37 | Pass → Pass | Δ |
| Effective voltage gain | EFF_GAIN | V/V | 0 / 94.99 / 13619 | 0.002 / 65.204 / 13683 | -29.79 | -31.36 | Pass → Pass | Δ |

8 row(s) flagged.

![deltas](postlayout.png)
