# central_bias

One bias current in (`ibias0` of the Chipalooza harness) -> the four bias currents `pgia_top` needs. **Schematic only so far: not instantiated in `pgia_top.sch`, no layout.**

## Why it exists

`pgia_top.sch` ties `IBIAS_IA` to the bias pin of the instrumentation amplifier, both gain stages and the buffer. That cannot work:

| block | bias pin must | reference | needed (commit 0777ca0, where the chip worked) |
|---|---|---|---|
| `instramp_cmos5l` (3 OTAs) | be **sunk** | PMOS diode to VDD (`MM6 IBIAS IBIAS VDD VDD`) | 4.2 uA |
| `output_buffer` (1 OTA) | be **sunk** | same | 1.4 uA |
| `gain_stage` x2 (`gain_ota`) | be **sourced** | NMOS diode to VSS (`MM_refn I_bias I_bias VSS`) | 1.0 uA each |

The harness gives the slot `ibias0` / `ibias1`, driven by iDACs through `idac1_source` / `idac2_source` in the harness netlist: a **sourced** current of programmable value (5 bit; the range is defined by the harness biasgen, not in this checkout).

## Circuit (7 transistors)

```
ibias0 (sourced) -> IB_IN = NMOS diode MN_R (m=10, W=1u L=2u)           reference
                    MN_IA  m=33  drain IB_IA   (sinks into the IA bias pin)
                    MN_BUF m=11  drain IB_BUF  (sinks into the buffer bias pin)
                    MN_P   m=8   drain n_pref  (pulls the PMOS reference)
n_pref = PMOS diode MP_R (m=10, W=2u L=2u) from AVDD
                    MP_G1 m=9 -> IB_G1  (sources into stage 1)      MP_G2 m=9 -> IB_G2 (stage 2)
```
Pins: `IB_IN` (in), `IB_IA` `IB_BUF` (out, sink), `IB_G1` `IB_G2` (out, source), `AVDD`, `AVSS`. The mirrors deliver about 1.26x their drawn ratio (measured; longer devices barely change it), so the multipliers are calibrated: **1.0 uA in -> IA 4.40, buffer 1.47, stages 1.08 / 1.08 uA** (targets 4.2 / 1.4 / 1.0 / 1.0).

## Proof

`python3 scripts/verify_central_bias.py` (23 s, nothing in the repo is modified; also step `bias` of `scripts/build_all.sh`): takes the current schematics, puts `central_bias` between `ibias0` and the four blocks in the chip testbench and checks the four currents (+-15 %), `VOUT` at code 0, power < 500 uW and the 11 gain codes against the verified result of commit 0777ca0. Result: VOUT 0.5991 V, 277 uW, **all codes within 0.04 dB** (17.64 ... 76.67 dB).
Operating window (same script, `--ibias0`): 0.7 uA -> 208 uW, all codes within 0.25 dB; 1.3 uA -> 342 uW, within 0.35 dB; 1.5 uA -> 384 uW, code 10 +0.98 dB (outside the 0.6 dB check); 2.0 uA -> 481 uW and codes 9-10 collapse (the gain-stage OTAs run out of headroom). So the harness iDAC should be set to **0.7 .. 1.3 uA** (nominal 1.0 uA); the absolute scale is the knob for power vs accuracy. The iDAC range itself is defined by the harness and is not in this checkout: confirm it reaches this window.

## To integrate (needs the layout first, otherwise LVS of `pgia_top` goes red)

1. Layout `central_bias` (below), place it near the geometric centre of the four pins, add it to `gds/pgia_top/pgia_top.gds` and the copy in `gds/slot9_wrapper/slot9_wrapper.gds`.
2. Cut the shared bias net in `pgia_top` (68 top-level shapes on `IBIAS_IA`: M2 23, V2 11, M3 26, V3 3, M4 5, x 1..495 um, y 43..236 um) and route four nets: `ibias0` pin (1.2, 98.2) -> `IB_IN`; `IB_IA` -> the three IA bias pins (478.1, 51.9 / 67.7 / 130.2); `IB_G1` -> stage 1 (316.2, 43.0); `IB_G2` -> stage 2 (220.5, 177.9); `IB_BUF` -> buffer (380.0, 235.3). Block boxes: IA x 360-484 y 18-141, stage 1 x 218-317 y 25-104, stage 2 x 220-319 y 160-239, buffer x 380-494 y 205-242.
3. `xschem/pgia_top/pgia_top.sch`: rename the four labels at the bias pins (`l_ia_ib` -> `ib_ia`, `l_st1_ib` -> `ib_g1`, `l_st2_ib` -> `ib_g2`, `l_buf_ib` -> `ib_buf`, and the matching `N ... {lab=IBIAS_IA}` wires) and place `central_bias.sym` with its pins on those nets and `IBIAS_IA` -> `IB_IN`. Then `scripts/run_lvs.sh pgia_top` / `slot9_wrapper`, DRC, `scripts/export_slot_gds.py`, and `scripts/verify_central_bias.py` (it recognises the integrated wiring).

## Layout requirements

- Matching is what sets the ratios: interdigitate reference and outputs of each mirror (common centroid, same orientation, same finger width; unit device 1u x 2u NMOS / 2u x 2u PMOS, or fingers of an integer fraction), dummy gates at the ends.
- NMOS in the substrate with a p-tie ring, PMOS in its own NWell with an n-tie ring (`scripts/tap_audit.py` must stay clean; the 20 um latch-up distance is easily met).
- Only the four outputs and the input leave the cell (Metal3 pins named `IB_IN`, `IB_IA`, `IB_BUF`, `IB_G1`, `IB_G2`, `/25` text labels as in the other cells); supply from the existing AVDD/AVSS grid.
- Keep it away from the digital decoder (x 25-90, y 60-105): these are nA..uA nodes.
- PDK PCells (`SG13_dev`) are usable from a script: `import sg13cmos5l_pycell_lib` with `libs.tech/klayout/python` and `pycell4klayout-api/source/python` on `sys.path` (see `docs/README.md`).
