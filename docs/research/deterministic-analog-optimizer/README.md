# Deterministic Analog Optimizer (DAO)

The short-term, shippable research piece:
- **drop in a circuit** (fixed topology, possibly half-optimised);
- **set a FoM and constraints**;
- **get back an optimised parameter set** with a reproducibility manifest and an optional CACE sign-off.

It is deterministic (seeded algorithms, no LLM in the loop), PDK-agnostic (device classes and PDK profiles) and simulator-in-the-loop (ngspice). Amplifiers come first.

**Code:** a separate repository, `/foss/designs/dao` (package `dao-sizer`, MIT). Install it with `pip install -e /foss/designs/dao`.

| Doc | Content |
|---|---|
| [01_notebook_review.md](01_notebook_review.md) | LLMForge and CircuitsDNA (ISSCC'26 Code-a-Chip): what transfers, plus corrections to the original framing |
| [02_analoggym_assessment.md](02_analoggym_assessment.md) | AnalogGym repo and paper: why it is used as a circuit/benchmark source and not forked |
| [02b_falcon_assessment.md](02b_falcon_assessment.md) | FALCON (NeurIPS'25) repo and paper: what it is, what it is not, what DAO takes from it |
| [03_feasibility.md](03_feasibility.md) | Feasibility verdicts, with measured numbers |
| [04_architecture.md](04_architecture.md) | Package layout, problem schema, determinism contract, plug-in interfaces |
| [05_serving_a_circuit.md](05_serving_a_circuit.md) | Guide: how to prepare a circuit so the tool can ingest it |
| [06_case_ota_noise.md](06_case_ota_noise.md) | Case study on this repo's `ota_cmos5l`: the noise investigation and DAO results |

The long-term direction that this tool feeds is closing the layout loop: [`../closed-loop-inverse-design/`](../closed-loop-inverse-design/README.md).

## Quick start
```bash
pip install -e /foss/designs/dao
cd /foss/designs/dao
dao eval examples/ota_cmos5l_ihp/baseline.yaml     # evaluate the hand design (compare with CACE)
dao run  examples/ota_cmos5l_ihp/noise.yaml        # demo A: minimise noise under PM/A0/UGF/P/saturation/area
dao run  examples/ota_cmos5l_ihp/foms.yaml         # demo B: maximise FoM_S under a noise cap
pytest -q tests                                    # includes the CACE-baseline and determinism tests
```
