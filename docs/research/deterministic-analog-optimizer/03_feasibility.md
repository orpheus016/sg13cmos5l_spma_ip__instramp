# 03: Feasibility, measured on 2026-10-15

| Question | Verdict | Evidence |
|---|---|---|
| Can a port-based kit reproduce CACE? | **Yes, within a few %** | `ota_cmos5l` hand design: A0 57.69 vs 57.87 dB, UGF 2.54 vs 2.70 MHz, PM 62.0 vs 60.6°, IRN 195/74 vs 197/74 nV/√Hz at 1 k/10 kHz (`dao/tests/test_sim.py::test_kit_reproduces_cace_baseline`). The remaining differences are the loop-break method (L/C vs CACE's Tian probe) |
| Is simulator-in-the-loop affordable? | **Yes, on IHP** | 0.14 s per evaluation (AC + noise + op in one ngspice run). About 5000 evaluations in 2.5 min on 8 workers |
| …on SKY130? | **Yes, but slow today** | About 17 s per evaluation, dominated by loading `sky130.lib.spice`. Fix: a trimmed MOS-only corner include in the profile (next week) |
| Deterministic? | **Yes, verified** | Demo A, 4817 evaluations, rerun **without cache**: byte-identical `history.csv` (SHA-256 `9863b74c…`) and identical best design. `test_two_runs_identical_history` checks it in CI |
| PDK-agnostic? | **Yes, demonstrated on one circuit** | AnalogGym NMCF converted once. The *identical* `circuit.cir` evaluates on SKY130 and IHP; the problem files differ only in `pdk:` and the supply. Both PDKs' op-point probes work (PSP `vdss`, BSIM4 `vdsat`) |
| Topology-agnostic within a class? | **Yes** | Same kit for the 2-stage Miller OTA and the 3-stage NMCF (polarity check plus DC-phase normalisation added for multi-stage amplifiers) |
| FoM-agnostic? | **Yes** | Demo A minimises noise; demo B maximises FoM_S under a noise cap. Same circuit and variables, different YAML. User expressions use a restricted AST (no `eval`) |
| Local optimality evidence? | **Yes** | Demos A and B end with "no improving poll point at the finest mesh" |
| Global optimality? | **No (no method can promise it)** | Multi-start CMA-ES reduces the risk; the certificate is local |
| Half-optimised → optimised? | **Yes, within the problem as stated** | The seed is evaluated first and reported side by side. The constraint set decides the answer (case study [06](06_case_ota_noise.md)) |
| AnalogGym benchmark parity? | **Not yet measured** | Needs the fast SKY130 include and AnalogGym's FOM_AMP definition checked against the paper; planned for next week |
| FALCON-style surrogate? | **Planned** | `opt/surrogate_gradient.py` stub with the design written down |
