# Top-Level Programmable Gain Instrumentation Amplifier (`pgia_top`)

`pgia_top` is the master top-level schematic and hierarchical cell for the complete mixed-signal Programmable Instrumentation Amplifier (PGIA) implemented on **IHP SG13CMOS5L** ($1.2\,\text{V}$ core).

It integrates the front-end fixed instrumentation amplifier, two cascaded binary gain stages, an analog output buffer, and the 4-bit digital gain decoder into a single unified IP block conforming to Chipalooza Challenge #2 and the Slot 9 wrapper specification.

---

## 1. Top-Level Signal Chain Architecture

```
                                                 pgia_top
┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                        │
│  VPWR ──┐                                                                                              │
│  VGND ──┼──┐                                                                                           │
│         │  │   ┌──────────────────┐ s1[4:0]                                                           │
│ gain_sel┼──┼──►│ gain_decoder_4b  ├────────────────────────────┐                                       │
│  [3:0]  │  │   │  (1.2V Digital)  ├────────────┐               │                                       │
│         │  │   └──────────────────┘ s2[4:0]    │               │                                       │
│         │  │                                   │               ▼                                       │
│         │  │                             ┌─────┼───────────────┴────────┐                              │
│         │  │                             │     │       gain_stage_1     │                              │
│         │  │                             │     │   (Inverting Switched) │                              │
│         │  │                             │     │   1x .. 32x (0..30 dB) │                              │
│         │  │                             │     ▼                        │                              │
│         │  │                             │   ┌────────────────────────┐ │                              │
│ VINP ───┼──┼───►┌────────────────┐       │   │        v_stage1        │ │                              │
│ VINN ───┼──┼───►│ instramp_cmos5l├──v_ia─┼──►│ (Inverts about 0.6V)   ├─┼────────┐                     │
│         │  │    │   (Fixed 8x /  │       │   └────────────────────────┘ │        │                     │
│ VCM ────┼──┼───►│    18.06 dB)   │       │               ▲          │ │        │                     │
│         │  │    └────────┬───────┘       └───────────────┼──────────┼─┘        │                     │
│         │  │             │                               │          │          ▼                     │
│         │  │             │                   AVDD, AVSS ─┤          │   ┌──────────────────────────┐ │
│         │  │             │                   VCM (0.6V) ─┤          │   │       gain_stage_2       │ │
│         │  │             │                   IBIAS_G1 ───┘          │   │   (Inverting Switched)   │ │
│         │  │             │                                          │   │   1x .. 32x (0..30 dB)   │ │
│         │  │             │                                          │   │                          │ │
│         │  │             │                                          │   │   v_stage2               │ │
│         │  │             │                                          │   │ (Inverts BACK to normal) ├─┼──┐
│         │  │             │                                          │   └──────────┬───────────────┘ │  │
│         │  │             │                                          │              │                 │  │
│         │  │             │                                          │  AVDD, AVSS ─┤                 │  │
│         │  │             │                                          │  VCM (0.6V) ─┤                 │  │
│         │  │             │                                          │  IBIAS_G2 ───┘                 │  │
│         │  │             │                                          │                                │  │
│         │  │             ▼                                          ▼                                ▼  ▼
│         │  │       IBIAS_IA (4.2uA)                           IBIAS_BUF (1.4uA)                ┌───────────┐
│         │  │                                                                                   │output_buf │
│         │  │                                                                                   │ (Follower)├──► VOUT
│         │  │                                                                                   └───────────┘
│         │  │                                                                                         ▲
│         ▼  ▼                                                                                         │
│     AVDD, AVSS ──────────────────────────────────────────────────────────────────────────────────────┘
└────────────────────────────────────────────────────────────────────────────────────────────────────────┘
```

![Schematic](./media/sch.png)
*PGIA Top Level Schematic*

### Signal Polarity & Gain Composition:
1. **Frontend IA (`instramp_cmos5l`):** Non-inverting differential to single-ended preamplifier:
   $$v_{ia} = V_{CM} + 8 \cdot (V_{INP} - V_{INN})$$
2. **Gain Stage 1 (`x_stage1`):** Inverting binary feedback ladder ($1\times \dots 32\times$):
   $$v_{stage1} = V_{CM} - A_{G1} \cdot (v_{ia} - V_{CM})$$
3. **Gain Stage 2 (`x_stage2`):** Inverting binary feedback ladder ($1\times \dots 32\times$):
   $$v_{stage2} = V_{CM} - A_{G2} \cdot (v_{stage1} - V_{CM}) = V_{CM} + A_{G1} A_{G2} \cdot (v_{ia} - V_{CM})$$
4. **Output Buffer (`x_buf`):** Non-inverting unity-gain voltage follower:
   $$V_{OUT} = v_{stage2} = V_{CM} + 8 \cdot A_{G1} A_{G2} \cdot (V_{INP} - V_{INN})$$

Because both programmable gain stages are inverting, the complete composite chain is **strictly non-inverting**, providing **11 monotonic $6\,\text{dB}$ gain steps** from **$18.06\,\text{dB}$ ($8\times$)** up to **$78.26\,\text{dB}$ ($8192\times$)**.

---

## 2. Top-Level Sub-Block Instantiation Matrix

| Instance | Cell Name | Symbol | Schematics | Role & Connections |
|:---|:---|:---|:---|:---|
| **`x_dec`** | `gain_decoder_4b` | `gain_decoder_4b.sym` | Layout Macro (`.spice`) | Inputs: `gain_sel[3:0]`. Outputs: `s1[4:0]`, `s2[4:0]`. Supplies: `VPWR` ($1.2\,\text{V}$), `VGND` ($0\,\text{V}$). |
| **`x_ia`** | `instramp_cmos5l` | `instramp_cmos5l.sym` | `instramp_cmos5l.sch` | Fixed $8\times$ IA. Inputs: `VINP`, `VINN`, `VCM`, `IBIAS_IA` ($4.2\,\mu\text{A}$). Output: `v_ia`. |
| **`x_stage1`** | `gain_stage` | `gain_stage.sym` | `gain_stage.sch` | Stage 1 PGA ($1\times \dots 32\times$). Input: `v_ia`, Control: `s1[0..4]`, Bias: `IBIAS_G1` ($1.0\,\mu\text{A}$). Output: `v_stage1`. |
| **`x_stage2`** | `gain_stage` | `gain_stage.sym` | `gain_stage.sch` | Stage 2 PGA ($1\times \dots 32\times$). Input: `v_stage1`, Control: `s2[0..4]`, Bias: `IBIAS_G2` ($1.0\,\mu\text{A}$). Output: `v_stage2`. |
| **`x_buf`** | `output_buffer` | `output_buffer.sym` | `output_buffer.sch` | Follower Buffer. Input: `v_stage2`, Feedback: `VOUT`, Bias: `IBIAS_BUF` ($1.4\,\mu\text{A}$). Output: `VOUT`. |

---

## 3. Top-Level Symbol Pin Interface (`pgia_top.sym`)

```spice
.subckt pgia_top VINP VINN VCM gain_sel[0] gain_sel[1] gain_sel[2] gain_sel[3] VOUT AVDD VPWR IBIAS_IA IBIAS_G1 IBIAS_G2 IBIAS_BUF AVSS VGND
```

| Pin | Direction | Domain | Description | Connection in Slot 9 Harness |
|:---|:---:|:---:|:---|:---|
| **`VINP`** | in | Analog | Non-inverting analog input | Dedicated Pad `s9_an[0]` (East) |
| **`VINN`** | in | Analog | Inverting analog input | Dedicated Pad `s9_an[1]` (East) |
| **`VCM`** | in | Analog | Common-mode reference ($0.60\,\text{V}$) | Shared Harness Reference `vbias` |
| **`gain_sel[0]`** | in | Digital | Gain select bit 0 (LSB) | Digital input `dig_in[0]` (West) |
| **`gain_sel[1]`** | in | Digital | Gain select bit 1 | Digital input `dig_in[1]` (West) |
| **`gain_sel[2]`** | in | Digital | Gain select bit 2 | Digital input `dig_in[2]` (West) |
| **`gain_sel[3]`** | in | Digital | Gain select bit 3 (MSB) | Digital input `dig_in[3]` (West) |
| **`VOUT`** | out | Analog | Single-ended buffered output | Dedicated Pad `s9_an[2]` (East) |
| **`AVDD`** | inout | Supply | Analog core power ($1.20\,\text{V}$) | Global analog supply |
| **`AVSS`** | inout | Ground | Analog quiet ground ($0\,\text{V}$) | Global analog ground |
| **`VPWR`** | inout | Supply | Digital logic power ($1.20\,\text{V}$) | Harness digital supply `vdd_1v2` |
| **`VGND`** | inout | Ground | Digital logic ground ($0\,\text{V}$) | Harness digital ground `vss_1v2` |
| **`IBIAS_IA`** | in | Bias | IA bias sink ($4.2\,\mu\text{A}$ to ground) | Bias distribution / test pad |
| **`IBIAS_G1`** | in | Bias | Stage 1 bias source ($1.0\,\mu\text{A}$ from AVDD) | Bias distribution / test pad |
| **`IBIAS_G2`** | in | Bias | Stage 2 bias source ($1.0\,\mu\text{A}$ from AVDD) | Bias distribution / test pad |
| **`IBIAS_BUF`** | in | Bias | Buffer bias sink ($1.4\,\mu\text{A}$ to ground) | Bias distribution / test pad |

![Symbol](./media/sym.png)
*PGIA Top Level Symbol*

---

## 4. Netlist Verification Status

Netlisted successfully with Xschem in batch mode:
```bash
docker exec -i -w /foss/designs/Chipalooza/Programmable-Instrumentation-Amplifier-IP/xschem/pgia_top iic-osic-tools_x11 bash -c 'export PDK=ihp-sg13cmos5l; xschem -q -x -o /foss/designs/Chipalooza/Programmable-Instrumentation-Amplifier-IP/xschem/pgia_top/simulations --netlist pgia_top.sch'
```
**Status: PASSED (0 warnings, 0 missing symbols).**
All subcells expand hierarchically to transistor and passive components cleanly.


![Netlist](./media/netlist_view.png)
*PGIA Top Level Netlist View*
