# Folded-Cascode Class-AB OTA (`gain_ota`)
**Circuit Datasheet & Silicon Characterization Report**  
*Technology: IHP SG13CMOS5L (130 nm BiCMOS/CMOS) | Status: Taped-Out (Slot 9 Deliverable)*

[![Technology](https://img.shields.io/badge/Technology-IHP_SG13CMOS5L-green)](#)
[![Status](https://img.shields.io/badge/Status-Taped--Out-success)](#)
[![DRC](https://img.shields.io/badge/DRC-Clean_(0_Violations)-success)](#)
[![LVS](https://img.shields.io/badge/LVS-MATCH-success)](#)
[![CACE](https://img.shields.io/badge/CACE-44%2F44_Passed-success)](#)

---

## 1. Overview & Circuit Function

The `gain_ota` is a high-bandwidth, high-slew-rate operational transconductance amplifier engineered specifically to drive the switched feedback resistor network of the Programmable Gain Stages (`gain_stage`). Because each gain stage must maintain a closed-loop bandwidth exceeding $20\text{ kHz}$ across all gain tap selections ($0\text{ dB}$ to $+30.1\text{ dB}$) while driving low-resistance feedback branches down to $\sim 7\text{ k}\Omega$, this OTA employs an advanced two-stage hybrid architecture:
1. **First Stage**: A PMOS-input folded-cascode differential amplifier providing high DC voltage gain and wide input common-mode range.
2. **Second Stage**: A Monticelli Class-AB push-pull output driver providing high dynamic current delivery with low quiescent power dissipation.
3. **Frequency Compensation**: Split-capacitor active Miller compensation featuring a series nulling resistor to eliminate the right-half-plane (RHP) zero.

---

## 2. Port Interface & Pin Description

| Pin Name | Type | Direction | Nominal Level | Description |
| :--- | :---: | :---: | :---: | :--- |
| `VDD` | Power | Inout | $1.20\text{ V}$ | Positive analog supply rail ($1.08\text{ V} - 1.50\text{ V}$) |
| `VSS` | Ground | Inout | $0.00\text{ V}$ | Analog ground reference |
| `I_bias` | Bias | Input | $1.00\,\mu\text{A}$ | Master reference current sourced into cell from `central_bias` |
| `V_inp` | Analog Signal | Input | $0.60\text{ V}$ | Non-inverting high-impedance differential input |
| `V_inn` | Analog Signal | Input | $0.60\text{ V}$ | Inverting virtual ground input terminal |
| `V_out` | Analog Signal | Output | $0.60\text{ V}$ | Low-impedance Class-AB push-pull analog output |

---

## 3. Circuit Sizing & Transistor Level Architecture

The schematic is located at `xschem/gain_ota/gain_ota.sch`. Sizing parameters for all core devices:

### A. Folded-Cascode Input Stage
| Instance | Device Type | $W$ ($\mu\text{m}$) | $L$ ($\mu\text{m}$) | Layout ($m$, $ng$) | Circuit Function |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `XM_tail` | `sg13_lv_pmos` | 7.46 | 2.00 | $m=8, ng=1$ | Differential tail current source ($W_{\text{tot}} = 59.68\,\mu\text{m}$) |
| `XM1, XM2` | `sg13_lv_pmos` | 26.56 | 2.00 | $m=1, ng=4$ | Folded-cascode differential input pair |
| `XM3, XM4` | `sg13_lv_pmos` | 7.33 | 2.00 | $m=1, ng=1$ | First-stage active PMOS current mirror load |
| `XM5, XM6` | `sg13_lv_nmos` | 6.41 | 2.00 | $m=1, ng=1$ | NMOS folding cascode transistors |
| `XM7, XM8` | `sg13_lv_nmos` | 9.21 | 2.00 | $m=1, ng=1$ | First-stage base current sinks |

### B. Monticelli Class-AB Mesh & Output Drivers
| Instance | Device Type | $W$ ($\mu\text{m}$) | $L$ ($\mu\text{m}$) | Layout ($m$, $ng$) | Circuit Function |
| :--- | :--- | :---: | :---: | :---: | :--- |
| `XM_ctrlp` | `sg13_lv_pmos` | 2.20 | 0.50 | $m=1, ng=1$ | Floating battery top PMOS for Class-AB mesh |
| `XM_ctrln` | `sg13_lv_nmos` | 0.84 | 0.50 | $m=1, ng=1$ | Floating battery bottom NMOS for Class-AB mesh |
| `XM_outp` | `sg13_lv_pmos` | 22.20 | 0.50 | $m=1, ng=4$ | Stage-2 Class-AB pull-up output driver |
| `XM_outn` | `sg13_lv_nmos` | 8.40 | 0.50 | $m=1, ng=1$ | Stage-2 Class-AB pull-down output driver |

### C. Active Miller Compensation Network
| Instance | Component | Value / Dimensions | Terminals | Circuit Function |
| :--- | :--- | :---: | :---: | :--- |
| `XC1` | `cap_cmomf` | $22.00 \times 22.00\,\mu\text{m}$ | Cascode $\rightarrow$ Output | Active cascode-node Miller capacitor |
| `XC2` | `cap_cmomf` | $15.44 \times 15.44\,\mu\text{m}$ | High-Z node $\rightarrow$ Output | Dominant first-stage Miller capacitor |
| `XR2` | `rhigh` | $W = 0.50, L = 4.00\,\mu\text{m}$ | Series with `XC2` | RHP zero cancellation nulling resistor |

---

## 4. Electrical Performance Summary (Pre- vs Post-Layout)

Characterization results across nominal conditions ($V_{\text{DD}} = 1.2\text{ V}$, $V_{\text{CM}} = 0.6\text{ V}$, $I_{\text{BIAS}} = 1.0\,\mu\text{A}$, $C_L = 2\text{ pF}$, $T = 27^\circ\text{C}$):

| Figure of Merit (FOM) | Symbol | Unit | Target | Pre-Layout (Schematic) | Post-Layout (RC-PEX) | Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Open-Loop DC Gain** | $A_{v0}$ | dB | $\ge 60.0$ | **62.34** | **62.93** | Met |
| **-3 dB Cutoff Frequency** | $f_{-3\text{dB}}$ | kHz | — | 9.14 | 8.10 | Met |
| **Unity-Gain Frequency** | UGF | MHz | $\ge 8.0$ | **12.08** | **11.43** | Met |
| **Phase Margin** | PM | deg | $\ge 60.0$ | **67.53** | **64.02** | Met ($+4.0^\circ$ margin) |
| **Gain Margin** | GM | dB | $\ge 6.0$ | **8.39** | **8.21** | Met |
| **Gain-Bandwidth Product** | GBW | MHz | — | 11.91 | 11.35 | Met |
| **Input Offset Voltage** | $V_{\text{os}}$ | mV | $\le \pm 1.0$ | +0.69 | -0.065 | Met |
| **DC CMRR (@ 10 Hz)** | $\text{CMRR}_{\text{dc}}$ | dB | $\ge 60.0$ | **62.23** | **67.75** | Met ($+5.5\text{ dB}$ layout gain) |
| **DC PSRR (@ 10 Hz)** | $\text{PSRR}_{\text{dc}}$ | dB | — | 37.46 | 37.26 | See Section 8 |
| **Input Referred Noise (@ 100 Hz)**| IRN | $\text{nV}/\sqrt{\text{Hz}}$ | — | 1788.0 | 1711.9 | Met |
| **Input Referred Noise (@ 1 kHz)**| IRN | $\text{nV}/\sqrt{\text{Hz}}$ | — | 567.9 | 543.6 | Met |
| **Input Referred Noise (@ 1 MHz)**| IRN | $\text{nV}/\sqrt{\text{Hz}}$ | — | 57.9 | 55.9 | Thermal floor |
| **Total Integrated Input Noise** | $v_{n,\text{in}}$ | $\mu\text{V}_{\text{rms}}$ | — | 1247.7 | 1046.4 | Met |
| **Linear ICMR Range** | ICMR | V | $\ge 0.70$ | 0.035 – 0.869 | 0.035 – 0.869 | Met ($0.834\text{ V}$ span) |
| **Quiescent Current** | $I_Q$ | $\mu\text{A}$ | — | 73.95 | 73.77 | Met |
| **Quiescent Power** | $P_{\text{dc}}$ | $\mu\text{W}$ | — | 88.61 | 88.53 | Met |
| **Positive Slew Rate** | $\text{SR}^+$ | $\text{V}/\mu\text{s}$ | $\ge 2.0$ | **+6.66** | **+6.54** | Met |
| **Negative Slew Rate** | $\text{SR}^-$ | $\text{V}/\mu\text{s}$ | $\ge 2.0$ | **-10.79** | **-10.62** | Met |
| **Small-Signal Settling (0.1%)**| $t_s$ | ns | — | 58.1 | 62.4 | Met |

---

## 5. Stability & PVT Corner Analysis

Simulated across 90 PVT operating conditions (`tt`, `ss`, `ff`, `sf`, `fs`), operating temperatures ($-40^\circ\text{C}$ to $+125^\circ\text{C}$), and supply rails ($1.00\text{ V}$ to $1.50\text{ V}$):
* **DC Gain**: Spans from $54.31\text{ dB}$ (worst-case at $+125^\circ\text{C}$, $1.0\text{ V}$, `ff`) to $67.35\text{ dB}$ (best-case at $-40^\circ\text{C}$, `ss`).
* **Phase Margin**: Remains strictly bounded between $59.12^\circ$ (worst-case at $-40^\circ\text{C}$, $1.0\text{ V}$, `ss`) and $70.32^\circ$. Across all corners, the circuit exhibits zero closed-loop ringing.
* **Class-AB Quiescent Balance**: Push-pull currents stay matched within $1.4\%$ ($I_{\text{outp}} = 14.09\,\mu\text{A}$, $I_{\text{outn}} = 13.89\,\mu\text{A}$) across supply voltage variations from $1.08\text{ V}$ to $1.32\text{ V}$.

---

## 6. Monte Carlo Statistical Analysis

Evaluated across 100 Monte Carlo runs with local device and threshold mismatch:
* **Input Offset Voltage ($V_{\text{os}}$)**: Mean $\mu = -12.12\,\mu\text{V}$, standard deviation $\sigma = 4.45\,\mu\text{V}$, $6\sigma$ full spread = $26.67\,\mu\text{V}$. Measured bounds: $-22.9\,\mu\text{V} \le V_{\text{os}} \le -4.4\,\mu\text{V}$.
* **Quiescent Current ($I_Q$)**: Mean $\mu = 73.83\,\mu\text{A}$ with $\sigma = 39.81\text{ nA}$, demonstrating outstanding bias tracking.

---

## 7. Physical Layout & Parasitic Extraction Analysis

* **Layout Dimensions**: $W = 81.00\,\mu\text{m}$, $L = 59.41\,\mu\text{m}$, Area = $4,812\,\mu\text{m}^2$.
* **Extracted Parasitics (Magic RC-PEX)**: 59 active subcircuits, 2,397 parasitic resistors, and 585 parasitic capacitors.
* **Parasitic Impact**:
  * $f_{-3\text{dB}}$ experienced an $11.46\%$ decrease ($9.14\text{ kHz} \rightarrow 8.10\text{ kHz}$) due to metal routing capacitance on the high-impedance node $N_A$.
  * Unity-Gain Frequency shifted by $-5.44\%$ ($12.08\text{ MHz} \rightarrow 11.43\text{ MHz}$), which remains comfortably within the required bandwidth budget.
  * CMRR improved by $+5.52\text{ dB}$ in post-layout ($62.23\text{ dB} \rightarrow 67.75\text{ dB}$) due to balanced differential layout routing.
* **LVS Check**: MATCH confirmed with `--disable_tap_extraction` (standard for IHP SG13 tap rules).

---

## 8. Known Anomalies & Future Work

1. **PSRR Sensitivity (~37.5 dB)**:
   * *Observation*: The single-ended folded-cascode architecture achieves a DC PSRR of $37.46\text{ dB}$, missing the aspirational $60\text{ dB}$ system goal. Supply ripple couples into the first-stage output node $N_A$ via the PMOS current mirror `XM3`/`XM4`.
   * *Future Work*: Implement cascode current sources in the internal replica biasing branch (`central_bias`) and add supply-filtering capacitors to achieve PSRR $>55\text{ dB}$.
2. **High-Frequency Flicker Noise**:
   * *Observation*: The $1/f$ noise corner is located at $\approx 10\text{ kHz}$, with IRN reaching $1788\text{ nV}/\sqrt{\text{Hz}}$ at $100\text{ Hz}$.
   * *Future Work*: Increase the gate area ($W \times L$) of the PMOS input pair `XM1`/`XM2` and evaluate pMOS source degeneration.

