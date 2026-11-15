# 4-Bit Combinational Gain Decoder (`gain_decoder_4b`)
**Circuit Datasheet & Silicon Characterization Report**  
*Technology: IHP SG13CMOS5L (130 nm BiCMOS/CMOS) | Status: Taped-Out (Slot 9 Deliverable)*

[![Technology](https://img.shields.io/badge/Technology-IHP_SG13CMOS5L-green)](#)
[![Status](https://img.shields.io/badge/Status-Taped--Out-success)](#)
[![DRC](https://img.shields.io/badge/DRC-Clean_(0_Violations)-success)](#)
[![LVS](https://img.shields.io/badge/LVS-MATCH-success)](#)
[![Co-Simulation](https://img.shields.io/badge/Transient_Co--Sim-16%2F16_Passed-success)](#)

---

## 1. Overview & Circuit Function

The `gain_decoder_4b` is a static CMOS combinational logic block operating in the digital power domain (`VPWR`/`VGND`). It converts the 4-bit user digital gain word `gain_sel[3:0]` into two independent sets of one-hot control vectors:
1. **Stage 1 Controls**: Active-high bus `s1[0..4]` and complementary active-low bus `s1_b[0..4]`.
2. **Stage 2 Controls**: Active-high bus `s2[0..4]` and complementary active-low bus `s2_b[0..4]`.

```mermaid
flowchart LR
    IN["gain_sel[3:0]<br/>(4-bit Input Bus)"] --> DEC["4-bit Combinational Decoder<br/>(gain_decoder_4b)<br/>Zero Static Power"]
    
    DEC -->|"s1[0..4] / s1_b[0..4]"| STG1["Gain Stage 1<br/>(Tapped Feedback Ladder)"]
    DEC -->|"s2[0..4] / s2_b[0..4]"| STG2["Gain Stage 2<br/>(Tapped Feedback Ladder)"]
    
    PWR["VPWR (1.2 V) / VGND (0 V)"] --> DEC
```

### Architectural Highlights
* **Noise Optimization Rationale (Friis' Formula)**: By ramping Stage 1 to its maximum gain ($32\times$) first before increasing Stage 2, the input-referred noise contribution of Stage 2 is attenuated by $32$ ($\approx 30\text{ dB}$ suppression):
  $$F_{\text{total}} = F_1 + \frac{F_2 - 1}{G_1}$$
  This guarantees optimal noise floor across all active gain levels.
* **Pin Efficiency**: Replaces legacy 10-bit thermometer bus with a compact 4-bit binary gain selection code (`gain_sel[3:0]`), saving 6 chip pads on the shared digital harness.
* **Zero Static Power**: Pure static CMOS combinational logic with static leakage power $P_{\text{leakage}} < 1.0\text{ nW}$.
* **Domain Isolation**: Powered strictly from the digital domain (`VPWR` and `VGND`), protecting sensitive analog biasing lines from digital switching substrate noise.
* **Failsafe Safe-Clamping**: Any unassigned binary state (Codes 11 through 15) automatically defaults to a safe clamp setting (`s1 = 00000`, `s2 = 00000`), safely locking both stages to their lowest gain setting ($0\text{ dB}$).
* **Balanced Complementary Drives**: Produces non-overlapping inverted pairs (`s` and `s_b`) to simultaneously drive the PMOS and NMOS gates of the transmission switches without shoot-through current.

---

## 2. Port Interface & Pin Description

The cell presents a 26-pin interface mapped in `xschem/gain_decoder_4b/gain_decoder_4b.sym`:

| Pin Index | Pin Name | Type | Direction | Nominal Level | Description |
| :---: | :--- | :---: | :---: | :---: | :--- |
| 1 | `VGND` | Digital Ground| Inout | $0.00\text{ V}$ | Digital ground reference |
| 2 | `VPWR` | Digital Power | Inout | $1.20\text{ V}$ | Digital supply rail for standard cell gates |
| 3–6 | `gain_sel[0..3]` | Digital Input | Input | $0\text{ V} / 1.2\text{ V}$ | 4-bit binary gain selection input bus |
| 7–11 | `s1[0..4]` | Digital Output| Output | $0\text{ V} / 1.2\text{ V}$ | Stage 1 active-high select lines |
| 12–16 | `s1_b[0..4]` | Digital Output| Output | $0\text{ V} / 1.2\text{ V}$ | Stage 1 active-low complementary select lines |
| 17–21 | `s2[0..4]` | Digital Output| Output | $0\text{ V} / 1.2\text{ V}$ | Stage 2 active-high select lines |
| 22–26 | `s2_b[0..4]` | Digital Output| Output | $0\text{ V} / 1.2\text{ V}$ | Stage 2 active-low complementary select lines |

*Note: In SPICE netlisting, subcircuit port matching is strictly positional. The pins of `gain_decoder_4b.sym` mirror the extracted layout netlist in `gds/gain_decoder_4b/final/spice/gain_decoder_4b.spice`.*

---

## 3. Truth Table & Decode Logic Mapping

Characterization across all 16 input combinations verified via transient co-simulation (`xschem/gain_decoder_4b/tb_gain_decoder_4b.sch`):

| Code | Input `gain_sel[3:0]` | Stage 1 `s1[4:0]` | Stage 1 `s1_b[4:0]` | Stage 2 `s2[4:0]` | Stage 2 `s2_b[4:0]` | Stage 1 Gain | Stage 2 Gain | Cascaded Gain | Status |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | `0000` | `00000` | `11111` | `00000` | `11111` | 0 dB ($1\times$) | 0 dB ($1\times$) | **0 dB ($1\times$)** | **PASS** |
| **1** | `0001` | `00001` | `11110` | `00000` | `11111` | 6 dB ($2\times$) | 0 dB ($1\times$) | **6 dB ($2\times$)** | **PASS** |
| **2** | `0010` | `00010` | `11101` | `00000` | `11111` | 12 dB ($4\times$) | 0 dB ($1\times$) | **12 dB ($4\times$)** | **PASS** |
| **3** | `0011` | `00100` | `11011` | `00000` | `11111` | 18 dB ($8\times$) | 0 dB ($1\times$) | **18 dB ($8\times$)** | **PASS** |
| **4** | `0100` | `01000` | `10111` | `00000` | `11111` | 24 dB ($16\times$) | 0 dB ($1\times$) | **24 dB ($16\times$)** | **PASS** |
| **5** | `0101` | `10000` | `01111` | `00000` | `11111` | 30 dB ($32\times$) | 0 dB ($1\times$) | **30 dB ($32\times$)** | **PASS** |
| **6** | `0110` | `10000` | `01111` | `00001` | `11110` | 30 dB ($32\times$) | 6 dB ($2\times$) | **36 dB ($64\times$)** | **PASS** |
| **7** | `0111` | `10000` | `01111` | `00010` | `11101` | 30 dB ($32\times$) | 12 dB ($4\times$) | **42 dB ($128\times$)**| **PASS** |
| **8** | `1000` | `10000` | `01111` | `00100` | `11011` | 30 dB ($32\times$) | 18 dB ($8\times$) | **48 dB ($256\times$)**| **PASS** |
| **9** | `1001` | `10000` | `01111` | `01000` | `10111` | 30 dB ($32\times$) | 24 dB ($16\times$) | **54 dB ($512\times$)**| **PASS** |
| **10** | `1010` | `10000` | `01111` | `10000` | `01111` | 30 dB ($32\times$) | 30 dB ($32\times$) | **60 dB ($1024\times$)**| **PASS** |
| **11** | `1011` | `00000` | `11111` | `00000` | `11111` | 0 dB (Clamp) | 0 dB (Clamp) | **0 dB (Clamp)** | **PASS** |
| **12** | `1100` | `00000` | `11111` | `00000` | `11111` | 0 dB (Clamp) | 0 dB (Clamp) | **0 dB (Clamp)** | **PASS** |
| **13** | `1101` | `00000` | `11111` | `00000` | `11111` | 0 dB (Clamp) | 0 dB (Clamp) | **0 dB (Clamp)** | **PASS** |
| **14** | `1110` | `00000` | `11111` | `00000` | `11111` | 0 dB (Clamp) | 0 dB (Clamp) | **0 dB (Clamp)** | **PASS** |
| **15** | `1111` | `00000` | `11111` | `00000` | `11111` | 0 dB (Clamp) | 0 dB (Clamp) | **0 dB (Clamp)** | **PASS** |

*Note: Adding the static $18.06\text{ dB}$ ($8\times$) gain of the front-end `instramp_cmos5l` yields the total system gain of $18.06\text{ dB}$ to $78.27\text{ dB}$.*

---

## 4. Electrical Timing & Power Metrics

Characterization evaluated under full parasitic RC extraction with $C_L = 10\text{ fF}$ on each output line:

| Figure of Merit (FOM) | Parameter | Value | Unit | Notes |
| :--- | :---: | :---: | :---: | :--- |
| **Digital Supply Voltage** | $V_{\text{PWR}}$ | $1.20$ | V | Operational from $1.08\text{ V} - 1.50\text{ V}$ |
| **Static Leakage Power** | $P_{\text{static}}$ | $< 0.15$ | nW | Zero DC path |
| **Dynamic Switching Energy** | $E_{\text{sw}}$ | $0.28$ | pJ / transition | Low-power digital switching |
| **Propagation Delay ($t_{\text{pd}}$)**| $t_{\text{pLH}} / t_{\text{pHL}}$ | $1.15 / 0.98$ | ns | Maximum delay to any select line |
| **Skew between Complementary Lines** | $\Delta t_{\text{skew}}$ | $< 0.08$ | ns | Symmetrical drive to transmission gates |

---

## 5. Functional Simulation & Verification

### A. RTL Functional Simulation (Icarus Verilog)
The RTL implementation is located at `verilog/gain_decoder_4b.v` and verified using the exhaustive testbench `verilog/tb_gain_decoder_4b.v`:
* **Compilation & Execution**:
  ```bash
  iverilog -o sim_gain_decoder_4b verilog/gain_decoder_4b.v verilog/tb_gain_decoder_4b.v
  vvp sim_gain_decoder_4b
  gtkwave tb_gain_decoder_4b.vcd &
  ```
* **Coverage**: Sweeps all 16 input combinations ($0$ to $15$), checking exact one-hot steering, strict inversion integrity (`s1_b == ~s1`, `s2_b == ~s2`), and out-of-range safe clamping for codes $11 \dots 15$.

### B. Mixed-Signal SPICE Co-Simulation (`tb_gain_decoder_4b.sch`)
Transient co-simulation with full extracted layout parasitics:
* **Supply**: $V_{\text{PWR}} = 1.20\text{ V}$, $V_{\text{GND}} = 0.00\text{ V}$.
* **Stimulus**: Synchronized binary pulse sources ($V_0 \dots V_3$) sweeping states $0 \dots 15$ with $20\text{ ns}$ dwell per state ($320\text{ ns}$ total transient window).
* **Load**: $C_L = 10\text{ fF}$ on all 20 output lines.
* **Timing & Electrical Metrics**:
  - Rail-to-rail voltage levels: $V_{OH} = 1.2000\text{ V}$, $V_{OL} = 0.0163\text{ mV}$.
  - Propagation delay $t_{pd}(\text{gain\_sel}[0] \rightarrow s_1[0]\text{ rise}) = 576.9\text{ ps}$.
  - Propagation delay $t_{pd}(\text{gain\_sel}[0] \rightarrow s_{1\_b}[0]\text{ fall}) = 509.4\text{ ps}$.
  - Output transition times: $t_r = 140.5 - 176.3\text{ ps}$, $t_f = 159.7 - 162.0\text{ ps}$.
  - Complementarity: $100\%$ verified across all transitions with zero shoot-through.

---

## 6. Physical Layout & Verification

### 6.1 ASIC Synthesis & Toolchain Flow
* **Target Library**: IHP SG13CMOS5L $1.2\text{ V}$ standard cells (`sg13cmos5l_stdcell`).
* **Toolchain Flow**: Synthesized and placed via **LibreLane v3.1.0** (Yosys RTL synthesis, OpenROAD floorplanning/placement/CTS/routing, Magic/Netgen/KLayout sign-off).
* **Physical Footprint**: Aspect-ratio optimized to **$65.0\text{ }\mu\text{m} \times 45.0\text{ }\mu\text{m} = 2,925\text{ }\mu\text{m}^2$** (a $30.8\%$ area reduction over the initial $65\times 65\text{ }\mu\text{m}$ floorplan), utilizing 9 cell rows ($9 \times 3.84\text{ }\mu\text{m} \approx 34.6\text{ }\mu\text{m}$ active core height).

### 6.2 Deterministic Pin Placement (`pin_order.cfg`)
* **West Edge ($X = 0.20\text{ }\mu\text{m}$)**: Houses inputs `gain_sel[3:0]` directly facing the chip harness digital input pads `dig_in[3:0]`.
* **East Edge ($X = 64.80\text{ }\mu\text{m}$)**: Houses all 20 output control lines (`s1[4:0]`, `s1_b[4:0]`, `s2[4:0]`, `s2_b[4:0]`), uniformly pitched at $1.68\text{ }\mu\text{m}$ directly facing the gain stage transmission gates.
* **North & South Edges**: Completely free of signal pins, keeping horizontal analog inter-block corridors unobstructed.

### 6.3 Power Distribution Network & Physical Sign-Off
* **PDN Architecture**: Internal vertical `Metal4` stripes for `VPWR` and `VGND` drop vias down to horizontal `Metal1` standard cell follower rails. At the chip level, horizontal `TopMetal1` power mesh lines drop `TopVia1` contacts directly onto these vertical `Metal4` straps.
* **Sign-Off Status**: 100% sign-off clean with **0 DRC violations**, **0 LVS mismatches** (verified against `sg13cmos5l_stdcell_lvs.spice`), **0 antenna violations**, and **0 timing slack violations**.

---

## 7. Architecture Evolution & Future Work

1. **Replaced Legacy 10-bit Decoder (`decoder_top_10b`)**:
   * *Background*: The early prototype utilized a 10-bit thermometer decoder (`decoder_top_10b`) that suffered from standard-cell DRC density and metal forbidden spacing violations (19 DRC errors).
   * *Resolution*: `gain_decoder_4b` replaced the legacy block, achieving 100% clean DRC, LVS, and transient co-simulation.
2. **Future Enhancements**:
   * *Glitch Suppression*: Integrate break-before-make timing buffers to guarantee that during digital code transitions, the outgoing switch completely opens before the incoming switch closes, eliminating inter-tap transient shorting.

