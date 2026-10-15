# 02: AnalogGym. Fork it, or use it?

Sources:
- repository [CODA-Team/AnalogGym](https://github.com/CODA-Team/AnalogGym) at commit `0a9d139` (2025-10-29), BSD-3-Clause, 87 MB, inspected from a shallow clone;
- paper [arXiv 2409.08534](../closed-loop-inverse-design/2409.08534v1.pdf), read through the arXiv HTML.

## What is in the repository
| Part | Content | Useful for DAO? |
|---|---|---|
| `AnalogGym/Amplifier/spice_netlist/` | 17 ngspice amplifier subckts (NMCF, NMCNR, DFCFC1/2, SMC, AFFC, ...). Each device's W/L/M is a named `.param` (e.g. `MOSFET_8_2_W_gm1_PMOS`), with matched groups sharing names | **Yes:** exactly the "served circuit" format |
| `AnalogGym/Amplifier/design_variables/` | 21 files of `.PARAM` values | Partly: **values only, no bounds or grid** |
| `amp_spice_testbench/TB_Amplifier_{ACDC,Tran}.cir` | Open loop through a 1 T L / 1 T C; DC gain, GBW, PM; CMRR; PSRR±; offset, power and TC from a −40…125 °C sweep; transient SR and settling | **Yes:** measurement definitions (re-implemented port-based in `dao.kits.amplifier`) |
| `perf_extraction_amp.py` (345 lines) | `.meas` and transient parsing; FoM written inline in code (line 328) | Definitions only |
| `RGNN_RL/` (~16k lines) | DDPG + relational GNN agent; **one ~800-line environment per topology** (13 copies) hard-coding bounds, graph and reward; torch 1.13 wheels bundled | No |
| `PDK/sky130_pdk.zip`, `mosfet_model/` | Bundled SKY130 models | No (use the installed PDK) |
| LDO, sensing front end, PLL, charge pump, VREF | LDO in ngspice; the rest mostly Spectre/Cadence | LDO later |

**What blocks reuse as-is:**
- **SKY130 is hard-wired.** Device names are inside the netlists, model paths are relative, VDD is 1.8 V, VCM is 0.25·VDD, op-point parsing is BSIM4-specific, and lengths are in µm.
- **FoM and constraints live in Python code.**
- **There is no noise analysis** in the amplifier testbench.
- **ngspice is called through `os.system('cd ./benchmarks/... && ngspice ...')`** with fixed paths.

## The paper
- **Algorithms:** GCNRL, WEIBO, cVTS (single-objective); SMEA, MTEA (multi-objective).
- **Circuits:** four SKY130 amplifiers (NMCNR, NMCF, DFCFC1, DFCFC2).
- **Budget:** about 1000 simulations, 10 runs each.
- **Results on NMCF:** FOM_AMP of 28.5 for cVTS (8.8 min), 9.5 for WEIBO and 7.8 for GCNRL.
- **Stated limitations:**
  - strict constraints trap optimisers in local optima;
  - the multiplicative FOM_AMP is sensitive and slows convergence;
  - transient analysis is 10–100× slower;
  - layout generation and topology search are future work.
- **Only SKY130 is used.** The other categories have no open-PDK support.

## Verdict: use AnalogGym's content, write the engine
- About 5 % of the repository (netlists, measurement definitions, FoM definitions, published baselines) is exactly what DAO needs.
- About 95 % (the RL stack and the SKY130 coupling) would be deleted in a fork. So DAO is a **new repository** that imports AnalogGym circuits through an adapter (`dao/adapters/analoggym.py`, planned), pinned to `0a9d139`, with BSD-3 attribution (`dao/third_party/analoggym/`).
- An upstream PR ("PDK-agnostic netlists") can follow.

**What AnalogGym gives the research:** a ready **benchmark protocol**. Same circuits, about 1000 simulations, and published baselines. DAO's claim, *"deterministic, certified methods match or beat RL/BO at equal budget, reproducibly, on any PDK"*, becomes measurable: run NMCF on SKY130 against the published numbers, then the same `problem.yaml` on IHP.
