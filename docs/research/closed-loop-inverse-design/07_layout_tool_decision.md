# 07: Layout tool decision. ALIGN on IHP, move to SKY130, or neither?

Decided 2026-10-15: **neither, for now.**
- Stay on IHP SG13CMOS5L.
- Defer closing the layout loop.
- Build the deterministic sizing optimiser first ([`../deterministic-analog-optimizer/`](../deterministic-analog-optimizer/README.md)).

## Facts (checked 2026-10-15)
- **ALIGN has no IHP SG13G2/SG13CMOS5L support.** No ALIGN repository, issue or document mentions it.
- **What adding a PDK to ALIGN takes**, per the [ALIGN-public README](https://github.com/ALIGN-analoglayout/ALIGN-public):
  - a JSON design-rule abstraction;
  - device models (`models.sp`);
  - SPICE-to-size translation (`gen_param.py`);
  - primitive generators `mos.py`, `fabric_Res.py`, `fabric_Cap.py` and `guard_ring.py`.
- **IHP specifics a port would also have to satisfy** (from this repo):
  - MoM `recog_mom` markers;
  - `/25` LVS label conventions;
  - rhigh heads;
  - antenna and forbidden-layer rules.
- **ALIGN's own SKY130 port is unfinished.** [ALIGN-pdk-sky130](https://github.com/ALIGN-analoglayout/ALIGN-pdk-sky130) says *"We are working to support SKY130 with ALIGN."*
- **This IP is for the Chipalooza 2026 challenge #2 on IHP SG13CMOS5L** (README badge). Moving to SKY130 means leaving the target, and redoing every schematic, layout and CACE datasheet.

## Judgement
- **ALIGN on IHP:** about 1–2 months for one person to reach DRC- and LVS-clean primitives and a routed 5T OTA. That does not fit the 2026-10-31 deadline.
- **SKY130:** loses the challenge target. The SKY130 ALIGN path is not finished either.
- **ALIGN was never on the critical path of the loop.** Roadmap §5 M1/M3 use parametrised KLayout/PDK-PCell generators, which are cheaper and IHP-correct by construction. ALIGN stays an optional comparison (M5), through an IR export of the constraints.
- **"Convert any schematic to any PDK, for any topology"** is a sound but separate research thread: *PDK-agnostic topology retargeting*. Its building blocks:
  - the device-class abstraction in the optimiser (`dao/pdk/profiles/*.yaml`);
  - gm/ID-based re-seeding of sizes across PDKs;
  - the IR of [05](05_intermediate_representation.md).

  The optimiser's PDK profiles are the first step of that thread.
