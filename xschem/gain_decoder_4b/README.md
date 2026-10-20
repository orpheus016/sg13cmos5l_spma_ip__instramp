# Phase 4: Xschem & SPICE Co-Simulation for `gain_decoder_4b`

This directory contains the schematic and simulation infrastructure for the 4-bit binary to two-stage gain decoder (`gain_decoder_4b`) implemented in **IHP SG13CMOS5L** ($1.2\,\text{V}$ LV standard cells).

---

## 1. Directory Structure

```
xschem/gain_decoder_4b/
├── gain_decoder_4b.sym       # Hierarchical Xschem symbol (26 pins, positional SPICE matching)
├── tb_gain_decoder_4b.sch    # Transient co-simulation testbench sweeping states 0 to 15
├── README.md                 # Documentation and verification report
└── simulations/
    ├── tb_gain_decoder_4b.spice  # Netlisted SPICE testbench with standard cell & extracted macro includes
    └── tb_gain_decoder_4b.raw    # Binary transient simulation output (3372 time points over 320 ns)
```

---

## 2. Symbol Pin Mapping (`gain_decoder_4b.sym`)

In SPICE netlisting, subcircuit port matching is positional. The pins of `gain_decoder_4b.sym` strictly mirror the extracted layout netlist in `gds/gain_decoder_4b/final/spice/gain_decoder_4b.spice`:

| Pin Index | Name | Direction | Function |
|:---|:---|:---|:---|
| 1 | `VGND` | inout | Core digital ground ($0\,\text{V}$) |
| 2 | `VPWR` | inout | Core digital supply ($1.2\,\text{V}$) |
| 3–6 | `gain_sel[0:3]` | in | 4-bit binary gain selection input bus |
| 7–11 | `s1[0:4]` | out | Stage 1 active-high transmission gate controls |
| 12–16 | `s1_b[0:4]` | out | Stage 1 complementary active-low controls |
| 17–21 | `s2[0:4]` | out | Stage 2 active-high transmission gate controls |
| 22–26 | `s2_b[0:4]` | out | Stage 2 complementary active-low controls |

*Note: The symbol uses `type=primitive` so that Xschem directly instantiates the subcircuit without requiring an intermediate gate-level `.sch`, cleanly linking to the layout-extracted SPICE macro.*

---

## 3. Testbench Setup (`tb_gain_decoder_4b.sch`)

- **Supply:** $V_{\text{PWR}} = 1.2\,\text{V}$, $V_{\text{GND}} = 0\,\text{V}$.
- **Stimulus:** Synchronized binary pulse sources ($V_0 \dots V_3$) sweeping states $0 \dots 15$ ($20\,\text{ns}$ per state, total transient window $320\,\text{ns}$).
- **Load Capacitance:** $C_L = 10\,\text{fF}$ on all 20 output lines (`s1`, `s1_b`, `s2`, `s2_b`) modeling transmission gate routing capacitance and MOS gates.
- **Transistor Models:** `cornerMOSlv.lib mos_tt` with full layout parasitic RC and standard cell SPICE models (`sg13cmos5l_stdcell.spice`).

---

## 4. Transient Verification Results

All 16 states were verified using automated python extraction from `tb_gain_decoder_4b.raw`:

| State | Time (ns) | `gain_sel[3:0]` | `s1[4:0]` | `s1_b[4:0]` | `s2[4:0]` | `s2_b[4:0]` | Gain Description | Status |
|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|:---:|
| **0** | 10.0 | `0000` | `00000` | `11111` | `00000` | `11111` | 0 dB ($1\times$) | **PASS** |
| **1** | 30.0 | `0001` | `00001` | `11110` | `00000` | `11111` | 6 dB ($2\times$) | **PASS** |
| **2** | 50.0 | `0010` | `00010` | `11101` | `00000` | `11111` | 12 dB ($4\times$) | **PASS** |
| **3** | 70.0 | `0011` | `00100` | `11011` | `00000` | `11111` | 18 dB ($8\times$) | **PASS** |
| **4** | 90.0 | `0100` | `01000` | `10111` | `00000` | `11111` | 24 dB ($16\times$) | **PASS** |
| **5** | 110.0 | `0101` | `10000` | `01111` | `00000` | `11111` | 26 dB ($20\times$) | **PASS** |
| **6** | 130.0 | `0110` | `10000` | `01111` | `00001` | `11110` | 32 dB ($40\times$) | **PASS** |
| **7** | 150.0 | `0111` | `10000` | `01111` | `00010` | `11101` | 38 dB ($80\times$) | **PASS** |
| **8** | 170.0 | `1000` | `10000` | `01111` | `00100` | `11011` | 44 dB ($160\times$) | **PASS** |
| **9** | 190.0 | `1001` | `10000` | `01111` | `01000` | `10111` | 50 dB ($320\times$) | **PASS** |
| **10** | 210.0 | `1010` | `10000` | `01111` | `10000` | `01111` | 52 dB ($400\times$) | **PASS** |
| **11** | 230.0 | `1011` | `00000` | `11111` | `00000` | `11111` | Safe Clamp ($0\,\text{dB}$) | **PASS** |
| **12** | 250.0 | `1100` | `00000` | `11111` | `00000` | `11111` | Safe Clamp ($0\,\text{dB}$) | **PASS** |
| **13** | 270.0 | `1101` | `00000` | `11111` | `00000` | `11111` | Safe Clamp ($0\,\text{dB}$) | **PASS** |
| **14** | 290.0 | `1110` | `00000` | `11111` | `00000` | `11111` | Safe Clamp ($0\,\text{dB}$) | **PASS** |
| **15** | 310.0 | `1111` | `00000` | `11111` | `00000` | `11111` | Safe Clamp ($0\,\text{dB}$) | **PASS** |

### Dynamic & Electrical Metrics:
- **DC Voltage Levels:** $V_{OH} = 1.2000\,\text{V}$ (rail-to-rail), $V_{OL} = 0.0163\,\text{mV}$ ($\approx 0.00\,\text{V}$).
- **Propagation Delays:**
  - $t_{pd}(\text{gain\_sel}[0] \rightarrow s_1[0] \text{ rise}) = 576.9\,\text{ps}$.
  - $t_{pd}(\text{gain\_sel}[0] \rightarrow s_{1\_b}[0] \text{ fall}) = 509.4\,\text{ps}$.
  - $t_{pd}(\text{gain\_sel}[1] \rightarrow s_2[0] \text{ rise}) = 510.0\,\text{ps}$.
  - $t_{pd}(\text{gain\_sel}[1] \rightarrow s_{2\_b}[0] \text{ fall}) = 489.6\,\text{ps}$.
- **Output Transition Times ($10\,\text{fF}$ load):**
  - $t_r (10\% \text{ to } 90\%) = 140.5 - 176.3\,\text{ps}$.
  - $t_f (90\% \text{ to } 10\%) = 159.7 - 162.0\,\text{ps}$.
- **Complementarity:** $s_1[i] \neq s_{1\_b}[i]$ and $s_2[i] \neq s_{2\_b}[i]$ across 100% of the simulation window.
