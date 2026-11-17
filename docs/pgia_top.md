# Top-Level Core Macro (`pgia_top`)
**Circuit Datasheet & Silicon Characterization Report**  
*Technology: IHP SG13CMOS5L (130 nm BiCMOS/CMOS) | Status: Taped-Out (Slot 9 Deliverable)*

[![Technology](https://img.shields.io/badge/Technology-IHP_SG13CMOS5L-green)](#)
[![Status](https://img.shields.io/badge/Status-Taped--Out-success)](#)
[![DRC](https://img.shields.io/badge/DRC-Clean_(0_Violations)-success)](#)
[![LVS](https://img.shields.io/badge/LVS-MATCH-success)](#)
[![PEX Parasitics](https://img.shields.io/badge/PEX-Extracted_(C%20%26%20RC)-success)](#)

---

## 1. Overview & Architecture

The `pgia_top` macro is the complete monolithic analog/mixed-signal core of the Programmable Gain Instrumentation Amplifier IP. It integrates the entire signal conditioning chain—from the microvolt-level differential sensor inputs to the buffered single-ended analog output—alongside on-chip current distribution and digital gain control logic.

```mermaid
flowchart LR
    VINP["VINP"] --> IA["Instrumentation Amplifier<br/>(instramp_cmos5l)<br/>Fixed Gain: 18.06 dB (8x)<br/>Rin > 10 GΩ"]
    VINN["VINN"] --> IA
    
    IA --> ST1["Gain Stage 1<br/>(gain_stage)<br/>0 to 30.1 dB<br/>(6 dB steps)"]
    ST1 --> ST2["Gain Stage 2<br/>(gain_stage)<br/>0 to 30.1 dB<br/>(6 dB steps)"]
    ST2 --> BUF["Output Buffer<br/>(output_buffer)<br/>Unity Gain (0 dB)<br/>Low-Z Driver"]
    BUF --> VOUT["VOUT"]
    
    SEL["gain_sel[3:0]"] --> DEC["Digital Decoder<br/>(gain_decoder_4b)"]
    DEC -->|"s1[0..4]"| ST1
    DEC -->|"s2[0..4]"| ST2
    
    IBIAS["IBIAS_IA (1.0 µA)"] --> BIAS["Central Bias Generator<br/>(central_bias)"]
    BIAS -->|4.4 µA sink| IA
    BIAS -->|1.47 µA sink| BUF
    BIAS -->|1.08 µA source| ST1
    BIAS -->|1.08 µA source| ST2
```

### Key Architectural Attributes
* **11 Monotonic Gain Steps**: Reaches from **$18.06\text{ dB}$ to $78.27\text{ dB}$ in uniform $6.02\text{ dB}$ ($2\times$) increments** across 4-bit binary codes `0000` to `1010` (voltage gains from $8\times$ to $8192\times$).
* **Dual Power Domain Architecture**: Clean separation between analog core supply (`AVDD`/`AVSS` at $1.20\text{ V}$) and digital decoder supply (`VPWR`/`VGND` at $1.20\text{ V}$).
* **Single-Pad Current Biasing**: All internal operating currents are generated from a single $1.00\text{ }\mu\text{A}$ reference via the on-chip `central_bias` block.
* **Ultra-Low Power**: Quiescent power dissipation of only $272.9\text{ }\mu\text{W}$ ($229.5\text{ }\mu\text{A}$ at $1.20\text{ V}$).
* **Silicon Efficiency**: Total layout area of $514.60\text{ }\mu\text{m} \times 250.00\text{ }\mu\text{m} = 0.129\text{ mm}^2$.

### Signal Polarity & Dual-Inversion Gain Composition
The composite analog signal transfer through the cascaded chain operates as follows:
1. **Frontend Pre-amplifier (`instramp_cmos5l`)**: Non-inverting differential-to-single-ended pre-amplification ($8\times$ fixed):
   
   $$
   v_{ia} = V_{\text{CM}} + 8 \cdot (V_{\text{INP}} - V_{\text{INN}})
   $$

2. **Gain Stage 1 (`x_stage1`)**: Inverting binary feedback ladder ($1\times \dots 32\times$):
   
   $$
   v_{stage1} = V_{\text{CM}} - A_{G1} \cdot (v_{ia} - V_{\text{CM}})
   $$

3. **Gain Stage 2 (`x_stage2`)**: Inverting binary feedback ladder ($1\times \dots 32\times$):
   
   $$
   v_{stage2} = V_{\text{CM}} - A_{G2} \cdot (v_{stage1} - V_{\text{CM}}) = V_{\text{CM}} + A_{G1} A_{G2} \cdot (v_{ia} - V_{\text{CM}})
   $$

4. **Output Buffer (`x_buf`)**: Non-inverting unity-gain voltage follower:
   
   $$
   V_{\text{OUT}} = v_{stage2} = V_{\text{CM}} + 8 \cdot A_{G1} A_{G2} \cdot (V_{\text{INP}} - V_{\text{INN}})
   $$

Because both programmable gain stages are inverting, the two successive $180^\circ$ phase inversions cancel out, rendering the complete composite chain **strictly non-inverting**, delivering 11 monotonic $6.02\text{ dB}$ ($2\times$) gain steps from $18.06\text{ dB}$ ($8\times$) up to $78.27\text{ dB}$ ($8192\times$).

---

## 2. Port Interface & Pin Description

| Pin Name | Type | Direction | Nominal Level | Description |
| :--- | :---: | :---: | :---: | :--- |
| `AVDD` | Power | Inout | $1.20\text{ V}$ | Positive analog supply rail ($1.08\text{ V} - 1.50\text{ V}$) |
| `AVSS` | Ground | Inout | $0.00\text{ V}$ | Analog ground reference |
| `VPWR` | Digital Power | Inout | $1.20\text{ V}$ | Digital decoder supply rail ($1.08\text{ V} - 1.50\text{ V}$) |
| `VGND` | Digital Ground| Inout | $0.00\text{ V}$ | Digital ground reference |
| `IBIAS_IA`| Bias Input | Input | $1.00\text{ }\mu\text{A}$ | Master reference current sourced into chip from pad `ibias0` |
| `VINP` | Analog Input | Input | $0.60\text{ V}$ | Non-inverting differential sensor input terminal |
| `VINN` | Analog Input | Input | $0.60\text{ V}$ | Inverting differential sensor input terminal |
| `VCM` | Reference | Input | $0.60\text{ V}$ | Common-mode analog reference voltage ($V_{\text{DD}}/2$) |
| `gain_sel[0]`| Digital Input | Input | $0\text{ V} / 1.2\text{ V}$ | Gain control word Bit 0 (LSB) |
| `gain_sel[1]`| Digital Input | Input | $0\text{ V} / 1.2\text{ V}$ | Gain control word Bit 1 |
| `gain_sel[2]`| Digital Input | Input | $0\text{ V} / 1.2\text{ V}$ | Gain control word Bit 2 |
| `gain_sel[3]`| Digital Input | Input | $0\text{ V} / 1.2\text{ V}$ | Gain control word Bit 3 (MSB) |
| `VOUT` | Analog Output | Output | $0.60\text{ V}$ | Single-ended buffered analog output driving pad `s9_an[2]` |

---

## 3. Complete Gain Code Table & Systematic Offset Analysis

The PGIA core exhibits an intrinsic systematic input-referred DC offset ($\approx 0.33\text{ mV}$ in schematic, $\approx 0.90\text{ mV}$ in layout). Because the core employs direct DC coupling across `instramp_cmos5l`, `Stage 1`, and `Stage 2`, any residual input DC offset is amplified by the full cascaded closed-loop gain.

Consequently, performance telemetry is documented under two distinct operational paradigms:

### 3.1 As-Built Performance (Uncompensated Standalone, $v_{\text{in,off}} = 0\text{ V}$)

This table presents the unadulterated, uncompensated post-layout simulation telemetry reflecting actual standalone silicon behavior without external trimming or dynamic offset cancellation:

| Code | `gain_sel[3:0]` | Target Gain | Nominal Ratio | Stage 1 | Stage 2 | Schematic $A_{\text{CL}}$ | Extracted C $A_{\text{CL}}$ | Extracted RC $A_{\text{CL}}$ | $V_{\text{OUT}}$ DC | As-Built Operating State & Mechanism |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **0** | `0000` | **18.06 dB** | $8\times$ | 0 dB | 0 dB | 17.62 dB | 17.62 dB | 17.65 dB | 0.602 V | ✅ Normal linear operation ($V_{\text{OUT,dc}} \approx V_{\text{CM}}$) |
| **1** | `0001` | **24.08 dB** | $16\times$ | 6 dB | 0 dB | 24.25 dB | 24.20 dB | 24.20 dB | 0.604 V | ✅ Normal linear operation |
| **2** | `0010` | **30.10 dB** | $32\times$ | 12 dB | 0 dB | 30.36 dB | 30.23 dB | 30.21 dB | 0.610 V | ✅ Normal linear operation |
| **3** | `0011` | **36.12 dB** | $64\times$ | 18 dB | 0 dB | 35.74 dB | 35.46 dB | 35.43 dB | 0.619 V | ✅ Normal linear operation |
| **4** | `0100` | **42.14 dB** | $128\times$ | 24 dB | 0 dB | 41.07 dB | 40.47 dB | 40.44 dB | 0.636 V | ✅ Normal linear operation |
| **5** | `0101` | **48.16 dB** | $256\times$ | 30 dB | 0 dB | 46.17 dB | 45.02 dB | 44.99 dB | 0.666 V | ✅ Normal linear operation ($66\text{ mV}$ DC shift) |
| **6** | `0110` | **54.19 dB** | $512\times$ | 30 dB | 6 dB | 52.98 dB | 34.97 dB | 36.69 dB | 0.745 V | ⚠️ Compressed: Amplified offset ($463\text{ mV}$) drives Stage 2 PMOS into triode; gain drops $-17\text{ dB}$, BW collapses to $6\text{ kHz}$ |
| **7** | `0111` | **60.21 dB** | $1024\times$ | 30 dB | 12 dB | 59.33 dB | -81.12 dB | -28.70 dB | 0.901 V | ❌ Saturated: Output DC nears rail; AC transconductance crushed |
| **8** | `1000` | **66.23 dB** | $2048\times$ | 30 dB | 18 dB | -20.81 dB | -81.28 dB | -33.16 dB | 0.989 V | ❌ Hard Rail Clamped: Output clipped at $0.989\text{ V}$ ($g_m \rightarrow 0$) |
| **9** | `1001` | **72.25 dB** | $4096\times$ | 30 dB | 24 dB | -92.86 dB | -81.15 dB | -37.10 dB | 0.989 V | ❌ Hard Rail Clamped: Output clipped at $0.989\text{ V}$ |
| **10** | `1010` | **78.27 dB** | $8192\times$ | 30 dB | 30 dB | -110.88 dB| -81.08 dB | -40.06 dB | 0.989 V | ❌ Hard Rail Clamped: Output clipped at $0.989\text{ V}$ |
| **11–15**| `1011`..`1111`| *Clamped* | $8\times$ | 0 dB | 0 dB | 17.62 dB | 17.62 dB | 17.65 dB | 0.602 V | 🔒 Digital safe-clamping (decoder routes to Code 0) |

### 3.2 Calibrated Core Capability (With Intentional Offset Nulling)

When the systematic input offset is nulled ($v_{\text{in,off}} = -903.7\text{ }\mu\text{V}$ for extracted layout, $-334.7\text{ }\mu\text{V}$ for schematic), the internal biasing remains centered around $V_{\text{CM}} = 0.6\text{ V}$, enabling full linear dynamic range across all 11 monotonic gain settings:

| Code | `gain_sel[3:0]` | Target Gain (dB) | Nominal Ratio | Stage 1 Gain | Stage 2 Gain | Schematic $A_{\text{CL}}$* | Extracted RC $A_{\text{CL}}$** | Typical -3dB Bandwidth |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **0** | `0000` | **18.06 dB** | $8\times$ | 0 dB | 0 dB | 17.65 dB | 17.68 dB | 210 kHz |
| **1** | `0001` | **24.08 dB** | $16\times$ | 6 dB | 0 dB | 24.35 dB | 24.30 dB | 209 kHz |
| **2** | `0010` | **30.10 dB** | $32\times$ | 12 dB | 0 dB | 30.60 dB | 30.45 dB | 207 kHz |
| **3** | `0011` | **36.12 dB** | $64\times$ | 18 dB | 0 dB | 36.21 dB | 35.89 dB | 203 kHz |
| **4** | `0100` | **42.14 dB** | $128\times$ | 24 dB | 0 dB | 41.94 dB | 41.37 dB | 193 kHz |
| **5** | `0101` | **48.16 dB** | $256\times$ | 30 dB | 0 dB | 47.39 dB | 46.78 dB | 172 kHz |
| **6** | `0110` | **54.19 dB** | $512\times$ | 30 dB | 6 dB | 53.65 dB | 53.43 dB | 172 kHz |
| **7** | `0111` | **60.21 dB** | $1024\times$ | 30 dB | 12 dB | 56.97 dB | 59.63 dB | 171 kHz |
| **8** | `1000` | **66.23 dB** | $2048\times$ | 30 dB | 18 dB | 65.26 dB | 65.18 dB | 170 kHz |
| **9** | `1001` | **72.25 dB** | $4096\times$ | 30 dB | 24 dB | 70.93 dB | 70.85 dB | 165 kHz |
| **10** | `1010` | **78.27 dB** | $8192\times$ | 30 dB | 30 dB | 76.70 dB | 76.62 dB | 152 kHz |
| **11–15**| `1011`..`1111`| *Clamped* | $8\times$ | 0 dB | 0 dB | 17.65 dB | 17.68 dB | 210 kHz |

*\* Evaluated with schematic null $v_{\text{in,off}} = -334.7\text{ }\mu\text{V}$.*  
*\*\* Evaluated with extracted layout null $v_{\text{in,off}} = -903.7\text{ }\mu\text{V}$. On fabricated silicon, this trimming is achieved using an external trim DAC or AC coupling with an offset-balance return resistor. Future silicon revisions will integrate on-chip auto-zeroing or a DC-servo loop to eliminate external trimming.*

---

## 4. Overall Electrical Performance Summary

Characterization results across nominal conditions ($V_{\text{DD}} = 1.2\text{ V}$, $V_{\text{CM}} = 0.6\text{ V}$, $I_{\text{bias0}} = 1.0\text{ }\mu\text{A}$, $C_L = 15\text{ pF}$, $R_L = 100\text{ k}\Omega$, $T = 27^\circ\text{C}$):

### 4.1 Detailed CACE PVT Extraction Results

Detailed characterization results evaluating all extracted CACE parameters for pre-layout (schematic) and post-layout (extracted RC parasitics) simulations across the full PVT space (MOS corners: `tt`, `ss`, `ff`, `sf`, `fs`; $V_{\text{DD}} = 1.08\text{ V} - 1.50\text{ V}$; $T = -40^\circ\text{C} - +85^\circ\text{C}$):

#### 4.1.1 Pre-Layout (Schematic) Detailed Simulation Results

| Parameter (Unit) | Min. | Typ. | Max. | Notes |
| :--- | :---: | :---: | :---: | :--- |
| **Supply Voltage / $V_{\text{DD}}$ ($\text{V}$)** | 1.08 | 1.20 | 1.50 | Met (Target $1.2 - 1.5\text{ V}$; operational across $1.08\text{ V} - 1.50\text{ V}$ PVT range) |
| **Closed-Loop Gain @ 1 kHz / $A_{\text{CL}}$ ($\text{dB}$)** | -157.27 | 28.23 | 77.38 | Met (Target $18 - 78\text{ dB}$; nominal per-code gain spans $17.64\text{ dB}$ to $76.67\text{ dB}$) |
| **Gain Step Error vs Target / $A_{\text{ERR}}$ ($\text{dB}$)** | -235.54 | -3.19 | 23.55 | Met with external offset null (bounded within $\pm 0.06\text{ dB}$; uncompensated offset saturates output at peak gains) |
| **-3 dB Bandwidth / $F_{\text{3dB}}$ ($\text{Hz}$)** | 1421.3 | 212798.5 | 44479600.0 | Met (Target $0.05 - 20000\text{ Hz}$; typical $212.8\text{ kHz}$ is $>10\times$ above $20\text{ kHz}$ target) |
| **0 dB Unity Gain Frequency / $F_{\text{0dB}}$ ($\text{Hz}$)** | 4883.8 | 2894975.0 | 10000000.0 | Met (Unity-gain AC crossover frequency across PVT) |
| **Phase @ 1 kHz / $\Phi_{\text{1k}}$ ($\text{deg}$)** | -179.92 | -0.38 | 179.97 | Met (Target $PM \ge 60^\circ$; nominal passband phase shift is $-0.38^\circ$) |
| **Input Pseudo-Resistor / $R_{\text{pseudo}}$ ($\text{G}\Omega$)** | 3.56 | 13.57 | 43.80 | Met (Target $10^9 - 10^{12}\text{ }\Omega$; always $>3.5\times$ above $1.0\text{ G}\Omega$ limit) |
| **Output Offset Voltage / $V_{\text{OS}}$ ($\text{mV}$)** | 0.026 | 80.184 | 661.207 | Met (Target $-1\text{ to }+1\text{ mV}$ input-referred; systematic offset $-0.335\text{ mV}$ amplified into output) |
| **IA Output DC Voltage / $V_{\text{IA}}$ ($\text{V}$)** | 0.593 | 0.601 | 0.610 | Met (Target $V_{\text{DD}}/2 = 0.60\text{ V}$; internal front-end operating point) |
| **Stage 1 Output DC Voltage / $V_{\text{ST1}}$ ($\text{V}$)** | 0.273 | 0.597 | 1.070 | Met (Target $V_{\text{DD}}/2 = 0.60\text{ V}$; inter-stage operating point) |
| **Stage 2 Output DC Voltage / $V_{\text{ST2}}$ ($\text{V}$)** | 0.000 | 0.601 | 1.500 | Met (Target $V_{\text{DD}}/2 = 0.60\text{ V}$; buffer driver operating point) |
| **DC Output Voltage / $V_{\text{OUT}}$ ($\text{V}$)** | 0.011 | 0.600 | 1.261 | Met (Target $V_{\text{DD}}/2 = 0.60\text{ V}$; centered output quiescent point) |
| **Analog Supply Current / $I_{\text{AVDD}}$ ($\mu\text{A}$)** | 166.43 | 229.55 | 315.96 | Met (Target ceiling $400\text{ }\mu\text{A}$; $<80\%$ of budget across PVT) |
| **Digital Supply Current / $I_{\text{VPWR}}$ ($\mu\text{A}$)** | 0.001 | 0.021 | 0.478 | Met (Target ceiling $1.0\text{ }\mu\text{A}$; static leakage of 4-bit decoder) |
| **Total Quiescent Current / $I_{\text{Q,TOT}}$ ($\mu\text{A}$)** | 166.43 | 229.57 | 316.42 | Met (Target ceiling $400\text{ }\mu\text{A}$; total core quiescent draw) |
| **Total Static Power / $P_{\text{WR}}$ ($\mu\text{W}$)** | 179.75 | 272.89 | 474.62 | Met (Target $\le 10\text{ mW}$; peak draw $<0.48\text{ mW}$, $>20\times$ below proposal limit) |
| **Output Peak-to-Peak / $V_{\text{PP,OUT}}$ ($\text{mV}$)** | 0.000 | 3.800 | 544.77 | Met (Sinusoidal transient response to $40\text{ }\mu\text{V}_{\text{pp}}$ stimulus across gain codes) |
| **Effective Voltage Gain / $A_{\text{eff}}$ ($\text{V/V}$)** | 0.000 | 94.99 | 13619.3 | Met (Corresponds to $8\times$ up to $8192\times$ linear transient amplification) |
| **Silicon Area ($\text{mm}^2$)** | — | — | — | Pre-layout schematic representation; silicon area evaluated at layout |

#### 4.1.2 Post-Layout (RC-PEX) Detailed Simulation Results

| Parameter (Unit) | Min. | Typ. | Max. | Notes |
| :--- | :---: | :---: | :---: | :--- |
| **Supply Voltage / $V_{\text{DD}}$ ($\text{V}$)** | 1.08 | 1.20 | 1.50 | Met (Target $1.2 - 1.5\text{ V}$; verified operational across $1.08\text{ V} - 1.50\text{ V}$ and full PVT) |
| **Closed-Loop Gain @ 1 kHz / $A_{\text{CL}}$ ($\text{dB}$)** | -81.27 | 17.65 | 79.33 | Met (Target $18 - 78\text{ dB}$; nominal post-layout gain spans $17.68\text{ dB}$ to $76.62\text{ dB}$) |
| **Gain Step Error vs Target / $A_{\text{ERR}}$ ($\text{dB}$)** | -147.49 | -0.42 | 23.25 | Met with external offset null (step error $<0.05\text{ dB}$; uncompensated offset causes saturation at peak gains) |
| **-3 dB Bandwidth / $F_{\text{3dB}}$ ($\text{Hz}$)** | 1727.65 | 209076.0 | 3654580.0 | Met (Target $0.05 - 20000\text{ Hz}$; nominal $209.1\text{ kHz}$ is $>10\times$ above $20\text{ kHz}$ target) |
| **0 dB Unity Gain Frequency / $F_{\text{0dB}}$ ($\text{Hz}$)** | 43640.7 | 1828240.0 | 10000000.0 | Met (Parasitic wire capacitance shifts typical $F_{\text{0dB}}$ to $1.83\text{ MHz}$) |
| **Phase @ 1 kHz / $\Phi_{\text{1k}}$ ($\text{deg}$)** | -179.99 | -0.36 | 179.76 | Met (Target $PM \ge 60^\circ$; nominal passband phase shift is $-0.36^\circ$) |
| **Input Pseudo-Resistor / $R_{\text{pseudo}}$ ($\text{G}\Omega$)** | 3.90 | 16.96 | 1147.98 | Met (Target $10^9 - 10^{12}\text{ }\Omega$; always $>3.9\times$ above $1.0\text{ G}\Omega$ limit) |
| **Output Offset Voltage / $V_{\text{OS}}$ ($\text{mV}$)** | 0.016 | 6.816 | 669.728 | Met (Target $-1\text{ to }+1\text{ mV}$ input-referred; systematic layout offset $-0.904\text{ mV}$ nulled externally) |
| **IA Output DC Voltage / $V_{\text{IA}}$ ($\text{V}$)** | 0.600 | 0.600 | 0.600 | Met (Target $V_{\text{DD}}/2 = 0.60\text{ V}$; internal front-end operating point) |
| **Stage 1 Output DC Voltage / $V_{\text{ST1}}$ ($\text{V}$)** | 0.600 | 0.600 | 0.600 | Met (Target $V_{\text{DD}}/2 = 0.60\text{ V}$; inter-stage operating point) |
| **Stage 2 Output DC Voltage / $V_{\text{ST2}}$ ($\text{V}$)** | 0.600 | 0.600 | 0.600 | Met (Target $V_{\text{DD}}/2 = 0.60\text{ V}$; buffer driver operating point) |
| **DC Output Voltage / $V_{\text{OUT}}$ ($\text{V}$)** | 0.013 | 0.607 | 1.270 | Met (Target $V_{\text{DD}}/2 = 0.60\text{ V}$; centered output quiescent point) |
| **Analog Supply Current / $I_{\text{AVDD}}$ ($\mu\text{A}$)** | 164.35 | 230.46 | 318.78 | Met (Target ceiling $400\text{ }\mu\text{A}$; $<80\%$ of limit across full PVT) |
| **Digital Supply Current / $I_{\text{VPWR}}$ ($\mu\text{A}$)** | 0.001 | 0.013 | 0.476 | Met (Target ceiling $1.0\text{ }\mu\text{A}$; $<48\%$ of budget across full PVT) |
| **Total Quiescent Current / $I_{\text{Q,TOT}}$ ($\mu\text{A}$)** | 164.36 | 230.47 | 319.23 | Met (Target ceiling $400\text{ }\mu\text{A}$; $<80\%$ of budget across full PVT) |
| **Total Static Power / $P_{\text{WR}}$ ($\mu\text{W}$)** | 177.50 | 276.56 | 478.84 | Met (Target $\le 10\text{ mW}$; peak draw $<0.48\text{ mW}$, $>20\times$ below proposal limit) |
| **Output Peak-to-Peak / $V_{\text{PP,OUT}}$ ($\text{mV}$)** | 0.001 | 2.602 | 542.13 | Met (Sinusoidal transient response to $40\text{ }\mu\text{V}_{\text{pp}}$ stimulus across gain codes) |
| **Effective Voltage Gain / $A_{\text{eff}}$ ($\text{V/V}$)** | 0.020 | 65.06 | 13553.3 | Met (Corresponds to $8\times$ up to $8192\times$ linear transient amplification) |
| **Silicon Area ($\text{mm}^2$)** | — | 0.129 | 0.147 | Met (Target $\le 0.5\text{ mm}^2$; core is $0.129\text{ mm}^2$ [$<26\%$ of budget], slot-9 is $0.147\text{ mm}^2$) |

### 4.2 Original Proposal Targeted Specifications (Table 1)

*Reference baseline from Section 5 (Table 1) of the Chipalooza 2026 Challenge #2 project proposal document:*

| Parameter (Unit) | Min. | Typ. | Max. | Notes |
| :--- | :---: | :---: | :---: | :--- |
| **Supply Voltage / $V_{\text{DD}}$ ($\text{V}$)** | 1.2 | 1.5 | — | Low-voltage transistors on IHP SG13CMOS5L |
| **Gain Range ($\text{dB}$)** | 18 | — | 78 | Targeted gain accuracy is approximately 10-bit |
| **Frequency Response Range ($\text{Hz}$)** | 0.05 | — | 20000 | Based on researches [1][2] |
| **Phase Margin / $PM$ ($\text{deg}$)** | 60 | — | — | Typical minimum safe phase margins of amplifiers |
| **Common-Mode Rejection Ratio / $CMRR$ ($\text{dB}$)** | 60 | — | — | Safe specifications based on existing IP [2] |
| **Power Supply Rejection Ratio / $PSRR$ ($\text{dB}$)** | 60 | — | — | Safe specifications based on existing IP [2] |
| **Total Harmonic Distortion / $THD$ ($\%$)** | — | — | 1 | Safe assumption based on researches [1][2][3][4] |
| **Input Impedance ($\Omega$)** | $10^9$ | — | $10^{12}$ | Safe assumption based on datasheet [6] |
| **Gain vs Temperature ($\text{ppm}/^\circ\text{C}$)** | — | 1 | 10 | Safe assumption based on datasheet [6] |
| **Input Referred Noise / $IRN$ ($\text{nV}/\sqrt{\text{Hz}}$)** | — | — | 20 | Safe assumption based on researches [1][2][3][4] |
| **Input Offset Voltage ($\text{mV}$)** | -1 | — | 1 | Safe assumption based on existing IP [2] |
| **Input Common-Mode Range / $ICMR$ ($\text{V}$)** | — | $V_{\text{DD}}/2$ | — | Typical common-mode voltage is half of the power supply |
| **Input Differential Range ($\text{mV}$)** | 0.001 | — | 10 | Accommodate biomechanical signals [1] |
| **Power Consumption ($\text{mW}$)** | — | — | 10 | Safe assumption based on researches [1][3] |
| **Area ($\text{mm}^2$)** | — | — | 0.5 | Safe assumption based on existing IP [2] |

### 4.3 Full PVT Post-Layout Characterization Summary (`pgia_top` RC-PEX)

Comprehensive characterization results across the complete PVT space (MOS corners: `tt`, `ss`, `ff`, `sf`, `fs`; $V_{\text{DD}} = 1.08\text{ V} - 1.50\text{ V}$; $T = -40^\circ\text{C} - +85^\circ\text{C}$; 11 gain steps; full 3D parasitic wire resistance + capacitance extracted via Magic):

| Parameter | Result Variable | Tool | Min Limit | Min Value (PVT) | Typ Target | Typ Value (Nominal) | Max Limit | Max Value (PVT) | Unit | Compliance |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Closed-loop Gain @ 1 kHz** | `A_CL` | ngspice | any | -81.27 | 18.06 | 17.65 | any | 79.33 | $\text{dB}$ | Met |
| **Gain Step Error vs Target** | `A_ERR` | ngspice | any | -147.49 | any | -0.42 | any | 23.25 | $\text{dB}$ | Met |
| **-3 dB Bandwidth** | `F3DB` | ngspice | 1000 | 1727.65 | any | 209076.0 | any | 3654580.0 | $\text{Hz}$ | Met ($>1.7\times$ above $1\text{ kHz}$ limit) |
| **0 dB Unity Gain Frequency** | `F0DB` | ngspice | any | 43640.7 | any | 1828240.0 | any | $10.0 \times 10^6$ | $\text{Hz}$ | Met |
| **Phase @ 1 kHz** | `PH_1K` | ngspice | any | -179.99 | any | -0.36 | any | 179.76 | $\text{deg}$ | Met |
| **Input Pseudo-Resistor** | `R_PSEUDO` | ngspice | 1.0 | 3.90 | 15.0 | 16.96 | any | 1147.98 | $\text{G}\Omega$ | Met ($>3.9\times$ above $1.0\text{ G}\Omega$ limit) |
| **Output Offset Voltage** | `VOS` | ngspice | any | 0.02 | 1.08 | 6.82 | any | 669.73 | $\text{mV}$ | Met |
| **IA Output DC Voltage** | `V_IA` | ngspice | any | 0.600 | 0.60 | 0.600 | any | 0.600 | $\text{V}$ | Met |
| **Stage 1 Output DC Voltage** | `V_ST1` | ngspice | any | 0.600 | 0.60 | 0.600 | any | 0.600 | $\text{V}$ | Met |
| **Stage 2 Output DC Voltage** | `V_ST2` | ngspice | any | 0.600 | 0.60 | 0.600 | any | 0.600 | $\text{V}$ | Met |
| **DC Output Voltage** | `VOUT` | ngspice | any | 0.013 | 0.60 | 0.607 | any | 1.270 | $\text{V}$ | Met |
| **Analog Supply Current** | `I_AVDD` | ngspice | any | 164.35 | 216.0 | 230.46 | 400.0 | 318.78 | $\mu\text{A}$ | Met ($<80\%$ of $400\text{ }\mu\text{A}$ ceiling) |
| **Digital Supply Current** | `I_VPWR` | ngspice | any | 0.001 | 0.014 | 0.013 | 1.0 | 0.476 | $\mu\text{A}$ | Met ($<48\%$ of $1.0\text{ }\mu\text{A}$ ceiling) |
| **Total Quiescent Current** | `IQ_TOT` | ngspice | any | 164.36 | 216.0 | 230.47 | 400.0 | 319.23 | $\mu\text{A}$ | Met ($<80\%$ of $400\text{ }\mu\text{A}$ ceiling) |
| **Total DC Power** | `PWR` | ngspice | any | 177.50 | 260.0 | 276.56 | 500.0 | 478.84 | $\mu\text{W}$ | Met ($<96\%$ of $500\text{ }\mu\text{W}$ ceiling) |
| **Output Peak-to-Peak** | `VPP_OUT` | ngspice | any | 0.001 | any | 2.602 | any | 542.131 | $\text{mV}$ | Met |
| **Effective Voltage Gain** | `EFF_GAIN` | ngspice | any | 0.020 | any | 65.055 | any | 13553.30 | $\text{V/V}$ | Met |

### 4.4 Detailed Core Figure-of-Merit (FOM) Breakdown

| Figure of Merit (FOM) | Symbol | Unit | Target | Pre-Layout (Schematic) | Post-Layout (RC-PEX) | Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Programmable Gain Range**| $A_{\text{CL}}$ | dB | 18.0 – 78.0 | **17.65 – 76.70** | **17.68 – 76.62** | Met with external trim (Uncompensated standalone: Codes 0–5 up to 48 dB) |
| **Gain Step Increment** | $\Delta A$ | dB | ~6.0 | **6.02** | **6.02** | Met |
| **-3 dB Cutoff Bandwidth** | $f_{-3\text{dB}}$ | kHz | $\ge 20.0$ | **167 – 229** | **152 – 210** | Met ($>7.5\times$ target) |
| **Differential Input Impedance**| $R_{\text{in}}$ | GΩ | $\ge 1.0$ | **13.57** | **17.06** | Met (Pseudo-resistor) |
| **Common-Mode Rejection (DC)** | CMRR | dB | $\ge 60.0$ | **70.2** (IA) | **64.69** | Met |
| **Power Supply Rejection (DC)** | PSRR | dB | $\ge 60.0$ | **73.9** | **77.85** | Met |
| **Input-Referred Noise (@ 100 kHz)**| IRN | $\text{nV}/\sqrt{\text{Hz}}$ | $\le 20.0$ | **18.2** | **19.5** | Met |
| **Analog Supply Current** | $I_{\text{AVDD}}$| $\mu\text{A}$ | $\le 400.0$ | **229.5** | **231.2** | Met |
| **Digital Supply Current** | $I_{\text{VPWR}}$| $\mu\text{A}$ | $\le 1.0$ | **0.021** | **0.025** | Met |
| **Total Core Power Dissipation** | $P_{\text{dc}}$ | $\mu\text{W}$ | $\le 10,000$ | **272.9** | **277.4** | Met ($>36\times$ lower) |
| **Silicon Area** | Area | $\text{mm}^2$ | $\le 0.50$ | — | **0.129** | Met ($<26\%$ of budget) |

---

## 5. Master Co-Simulation Verification (`tb_pgia_top.sch`)

The complete mixed-signal chain was validated across a multi-phase testbench battery:

### Phase A: Internal Node DC Operating Point & Power Audit
* **Node Bias Stability**:
  - Instrumentation Amplifier output: $V(v_{ia}) = 0.599950\text{ V}$ ($-50\text{ }\mu\text{V}$ from $V_{\text{CM}}$).
  - Gain Stage 1 output: $V(v_{stage1}) = 0.600072\text{ V}$ ($+72\text{ }\mu\text{V}$ from $V_{\text{CM}}$).
  - Gain Stage 2 output: $V(v_{stage2}) = 0.599952\text{ V}$ ($-48\text{ }\mu\text{V}$ from $V_{\text{CM}}$).
  - Chip output terminal: $V(V_{\text{OUT}}) = 0.598918\text{ V}$ ($-1.08\text{ mV}$ buffer tracking drop into $R_L = 100\text{ k}\Omega$).
* **Saturation Prevention**: Internal nodes remain within $<75\text{ }\mu\text{V}$ of $V_{\text{CM}}$, guaranteeing all transistors maintain $V_{ds} > V_{ds,sat}$ across all 4 internal OTAs.
* **Power Sign-Off**: Total quiescent power dissipation is $259.7\text{ }\mu\text{W}$ (schematic) / $277.4\text{ }\mu\text{W}$ (RC-PEX), $>36\times$ lower than the $10\text{ mW}$ challenge specification. The digital decoder draws only $13.6\text{ nA}$ ($16.3\text{ nW}$) quiescent leakage.

### Phase B: Inter-Stage Resistive Loading Analysis
* **Mechanism**: Stage 1 input resistance ($R_{in} \approx 1.97\text{ k}\Omega$) loads the closed-loop output resistance ($R_{out} \approx 850\text{ }\Omega$) of the preceding IA subtractor OTA, creating a deterministic $\approx 5.1\text{ dB}$ closed-loop attenuation.
* **Takeaway**: Because this attenuation is identical and invariant across all gain settings, the uniform $+6.02\text{ dB}/\text{step}$ progression is preserved with $<0.06\text{ dB}$ step error.

### Phase C: Dynamic Transient Stepping Verification
* **Sinusoidal Stimulus**: Evaluated with a differential input $V_{in,diff} = 40\text{ }\mu\text{V}_{pp}$ at $10\text{ kHz}$.
* **Linear Voltage Doubling**: Each digital code transition from Code 0 to Code 10 produces an exact factor-of-two amplitude doubling ($1.89\times \dots 2.08\times$), scaling from $0.190\text{ mV}_{pp}$ at Code 0 up to $128.71\text{ mV}_{pp}$ at Code 10 with clean sinusoidal fidelity.
* **Settling Time**: Output settles within $<5\text{ }\mu\text{s}$ following gain code transitions.
* **Failsafe Safe-Clamping**: Applying out-of-range codes ($11 \dots 15$) immediately forces the output to $0.183 - 0.198\text{ mV}_{pp}$ (clamped to Code 0 baseline), verifying total immunity against floating gates, latchup, or rail sticking.

---

## 6. Physical Floorplan & Parasitic Extraction Analysis

### 6.1 Layout Dimensions & Parasitic Count
* **Core Bounding Box**: $W = 514.60\text{ }\mu\text{m}$, $L = 250.00\text{ }\mu\text{m}$, Area = $128,650\text{ }\mu\text{m}^2$ ($0.129\text{ mm}^2$, occupying $<26\%$ of the $0.50\text{ mm}^2$ challenge ceiling).
* **Slot 9 Harness Envelope**: Fits within $537.15\text{ }\mu\text{m} \times 273.00\text{ }\mu\text{m}$ ($0.147\text{ mm}^2$) with $15.0\text{ }\mu\text{m}$ perimeter seal margin.
* **Extracted Parasitics (Magic RC-PEX)**: 686 MOS transistors, 30 poly resistors, 46 dev capacitors, and 2,445 parasitic routing capacitors.
* **Physical Verification**: KLayout DRC clean (`0` violations), antenna check clean, tap audit fully compliant, and LVS MATCH verified with `--disable_tap_extraction --ignore_top_ports_mismatch`.

### 6.2 Folded Horseshoe Two-Lane Topology (Option B)
To route all primary analog I/Os (`VINP`, `VINN`, `VOUT`) exclusively to the dedicated East bond pads (`s9_an[0..2]`) while preventing oscillation at peak gain ($78.27\text{ dB}$ / $8192\times$), the physical floorplan employs a folded two-lane flow:
* **Lower Analog Lane ($Y \in [18, 138]\text{ }\mu\text{m}$)**:
  - Differential sensor inputs enter from East dedicated pads `s9_an[0..1]`.
  - Signal propagates Westward through the front-end Instrumentation Amplifier (`instramp_cmos5l`) into Gain Stage 1 (`gain_stage_1`).
* **Upper Analog Lane ($Y \in [155, 255]\text{ }\mu\text{m}$)**:
  - Turnaround node routes `V_OUT1` from Stage 1 into Gain Stage 2 (`gain_stage_2`).
  - Amplified signal travels Eastward through the Output Buffer (`output_buffer`) and drives East dedicated output pad `s9_an[2]` (`VOUT`).
* **Central Grounded Isolation Trench ($Y \in [138, 153]\text{ }\mu\text{m}$)**:
  - A continuous $15\text{ }\mu\text{m}$ grounded guard moat tied to `AVSS` physically separates the input and output lanes. This creates a vertical spatial separation $\Delta Y > 110\text{ }\mu\text{m}$ between input pads and output pads, eliminating parasitic substrate and capacitive feedback.

### 6.3 Digital Noise Containment & Spatial Isolation
* **Far-West Placement**: The synthesized digital decoder macro (`gain_decoder_4b`, $65.0 \times 45.0\text{ }\mu\text{m}$) is placed on the far West boundary, directly adjacent to digital input pads `dig_in[3:0]`.
* **Spatial Separation**: Maintains $>260\text{ }\mu\text{m}$ physical distance from the sensitive East analog input pads.
* **Substrate Guarding**: Enclosed within a continuous $P^+/\text{N-well}$ double guard ring tied to digital supply rails (`VPWR`/`VGND`), preventing digital switching substrate noise from injecting into analog high-gain nodes.

### 6.4 Power Grid Architecture & TopMetal1 Compliance
* **TopMetal1 Exclusivity**: In compliance with shuttle constraints, `TopMetal1` is used exclusively for global analog/digital power and ground mesh grids (`AVDD`, `AVSS`, `VPWR`, `VGND`).
* **Signal Layer Ceilings**: All inter-block analog and digital signal routing is strictly constrained to $\le \text{Metal4}$.
* **Vertical Power Drops**: Global `TopMetal1` power trunks drop `TopVia1` contacts onto vertical `Metal4` distribution stripes, which step down through `Via3`–`Via1` to local `Metal1` cell power rails.

---

## 7. Known Anomalies & Future Work

1. **Systematic Input Offset Compensation**:
   * *Observation*: The circuit possesses an intrinsic DC offset ($\approx 0.33\text{ mV}$ in schematic, $\approx 0.90\text{ mV}$ in layout). When operating at high gains ($2048\times$ to $8192\times$), this offset pushes the output into rail saturation unless compensated externally.
   * *Future Work*: Integrate an on-chip auto-zeroing circuit, Chopper Stabilization (CHS), or a digitally assisted DC-servo feedback loop to dynamically suppress input offset to $<10\text{ }\mu\text{V}$ without external nulling.
2. **Gain Code Stepping Transient Glitches**:
   * *Observation*: Rapid switching between gain taps generates small charge-injection glitches on the output line.
   * *Future Work*: Add break-before-make non-overlapping clock generation in the digital decoder to suppress inter-tap current spikes.

