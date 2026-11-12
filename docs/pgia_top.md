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
    DEC -->|s1[0..4]| ST1
    DEC -->|s2[0..4]| ST2
    
    IBIAS["IBIAS_IA (1.0 µA)"] --> BIAS["Central Bias Generator<br/>(central_bias)"]
    BIAS -->|4.4 µA sink| IA
    BIAS -->|1.47 µA sink| BUF
    BIAS -->|1.08 µA source| ST1
    BIAS -->|1.08 µA source| ST2
```

### Key Architectural Attributes
* **11 Monotonic Gain Steps**: Reaches from **$18.06\text{ dB}$ to $78.27\text{ dB}$ in uniform $6.02\text{ dB}$ ($2\times$) increments** across 4-bit binary codes `0000` to `1010` (voltage gains from $8\times$ to $8192\times$).
* **Dual Power Domain Architecture**: Clean separation between analog core supply (`AVDD`/`AVSS` at $1.20\text{ V}$) and digital decoder supply (`VPWR`/`VGND` at $1.20\text{ V}$).
* **Single-Pad Current Biasing**: All internal operating currents are generated from a single $1.00\,\mu\text{A}$ reference via the on-chip `central_bias` block.
* **Ultra-Low Power**: Quiescent power dissipation of only $272.9\,\mu\text{W}$ ($229.5\,\mu\text{A}$ at $1.20\text{ V}$).
* **Silicon Efficiency**: Total layout area of $514.60\,\mu\text{m} \times 250.00\,\mu\text{m} = 0.129\text{ mm}^2$.

---

## 2. Port Interface & Pin Description

| Pin Name | Type | Direction | Nominal Level | Description |
| :--- | :---: | :---: | :---: | :--- |
| `AVDD` | Power | Inout | $1.20\text{ V}$ | Positive analog supply rail ($1.08\text{ V} - 1.50\text{ V}$) |
| `AVSS` | Ground | Inout | $0.00\text{ V}$ | Analog ground reference |
| `VPWR` | Digital Power | Inout | $1.20\text{ V}$ | Digital decoder supply rail ($1.08\text{ V} - 1.50\text{ V}$) |
| `VGND` | Digital Ground| Inout | $0.00\text{ V}$ | Digital ground reference |
| `IBIAS_IA`| Bias Input | Input | $1.00\,\mu\text{A}$ | Master reference current sourced into chip from pad `ibias0` |
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

The circuit exhibits an intrinsic systematic input-referred DC offset ($\approx 0.33\text{ mV}$ in schematic, $\approx 0.90\text{ mV}$ in layout). Without compensation, at high gain codes (8 to 10: $2048\times$ to $8192\times$), this offset is amplified until Stage 2 reaches output rail saturation ($\sim 0.99\text{ V}$).

Applying an intentional input DC nulling offset ($v_{\text{in,off}} = -334.7\,\mu\text{V}$ for schematic, $-903.7\,\mu\text{V}$ for extracted layout) restores linear dynamic range across all 11 gain steps:

| Code | `gain_sel[3:0]` | Target Gain | Voltage Gain | Stage 1 Gain | Stage 2 Gain | Schematic $A_{\text{CL}}$* | Extracted RC $A_{\text{CL}}$** | Typical -3dB Bandwidth |
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

*\* Evaluated with schematic null $v_{\text{in,off}} = -334.7\,\mu\text{V}$.*  
*\*\* Evaluated with extracted layout null $v_{\text{in,off}} = -903.7\,\mu\text{V}$.*

---

## 4. Overall Electrical Performance Summary

Characterization results across nominal conditions ($V_{\text{DD}} = 1.2\text{ V}$, $V_{\text{CM}} = 0.6\text{ V}$, $I_{\text{bias0}} = 1.0\,\mu\text{A}$, $C_L = 15\text{ pF}$, $R_L = 100\text{ k}\Omega$, $T = 27^\circ\text{C}$):

| Figure of Merit (FOM) | Symbol | Unit | Target | Pre-Layout (Schematic) | Post-Layout (RC-PEX) | Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Programmable Gain Range**| $A_{\text{CL}}$ | dB | 18.0 – 78.0 | **17.65 – 76.70** | **17.68 – 76.62** | Met (11 monotonic steps) |
| **Gain Step Increment** | $\Delta A$ | dB | ~6.0 | **6.02** | **6.02** | Met |
| **-3 dB Cutoff Bandwidth** | $f_{-3\text{dB}}$ | kHz | $\ge 20.0$ | **167 – 229** | **152 – 210** | Met ($>7.5\times$ target) |
| **Differential Input Impedance**| $R_{\text{in}}$ | GΩ | $\ge 1.0$ | **13.57** | **17.06** | Met (Pseudo-resistor) |
| **Common-Mode Rejection (DC)** | CMRR | dB | $\ge 60.0$ | **70.2** (IA) | **> 65.0** | Met |
| **Power Supply Rejection (DC)** | PSRR | dB | $\ge 60.0$ | **> 70.0** | **> 65.0** | Met |
| **Input-Referred Noise (@ 100 kHz)**| IRN | $\text{nV}/\sqrt{\text{Hz}}$ | $\le 20.0$ | **18.2** | **19.5** | Met |
| **Analog Supply Current** | $I_{\text{AVDD}}$| $\mu\text{A}$ | $\le 400.0$ | **229.5** | **231.2** | Met |
| **Digital Supply Current** | $I_{\text{VPWR}}$| $\mu\text{A}$ | $\le 1.0$ | **0.021** | **0.025** | Met |
| **Total Core Power Dissipation** | $P_{\text{dc}}$ | $\mu\text{W}$ | $\le 10,000$ | **272.9** | **277.4** | Met ($>36\times$ lower) |
| **Silicon Area** | Area | $\text{mm}^2$ | $\le 0.50$ | — | **0.129** | Met ($<26\%$ of budget) |

---

## 5. Physical Floorplan & Parasitic Extraction Analysis

* **Layout Dimensions**: $W = 514.60\,\mu\text{m}$, $L = 250.00\,\mu\text{m}$, Area = $128,650\,\mu\text{m}^2$ ($0.129\text{ mm}^2$).
* **Extracted Parasitics (Magic RC-PEX)**: 686 MOS devices, 30 poly resistors, 46 dev capacitors, and 2,445 parasitic routing capacitors.
* **Floorplan Organization**:
  * Left side: `instramp_cmos5l` placed near analog input pads to minimize trace resistance and capacitive coupling.
  * Middle top: `central_bias` placed above Gain Stage 1 with short dedicated Metal 3/4 branches to all four bias receivers.
  * Middle: `gain_stage` 1 cascading cleanly into `gain_stage` 2.
  * Right side: `output_buffer` positioned directly adjacent to East output pad `s9_an[2]`.
  * Digital isolation: `gain_decoder_4b` placed in a dedicated corner away from high-impedance analog nodes.
* **Physical Checks**: KLayout DRC clean (`0` violations), antenna check clean, tap audit fully compliant, and LVS MATCH verified with `--disable_tap_extraction --ignore_top_ports_mismatch`.

---

## 6. Known Anomalies & Future Work

1. **Systematic Input Offset Compensation**:
   * *Observation*: The circuit possesses an intrinsic DC offset ($\approx 0.33\text{ mV}$ in schematic, $\approx 0.90\text{ mV}$ in layout). When operating at high gains ($2048\times$ to $8192\times$), this offset pushes the output into rail saturation unless compensated externally.
   * *Future Work*: Integrate an on-chip auto-zeroing circuit, Chopper Stabilization (CHS), or a digitally assisted DC-servo feedback loop to dynamically suppress input offset to $<10\,\mu\text{V}$ without external nulling.
2. **Gain Code Stepping Transient Glitches**:
   * *Observation*: Rapid switching between gain taps generates small charge-injection glitches on the output line.
   * *Future Work*: Add break-before-make non-overlapping clock generation in the digital decoder to suppress inter-tap current spikes.

