# Two-Stage Miller-Compensated OTA (`ota_cmos5l`)
**Circuit Datasheet & Silicon Characterization Report**  
*Technology: IHP SG13CMOS5L (130 nm BiCMOS/CMOS) | Status: Taped-Out (Slot 9 Deliverable)*

[![Technology](https://img.shields.io/badge/Technology-IHP_SG13CMOS5L-green)](#)
[![Status](https://img.shields.io/badge/Status-Taped--Out-success)](#)
[![DRC](https://img.shields.io/badge/DRC-Clean_(0_Violations)-success)](#)
[![LVS](https://img.shields.io/badge/LVS-MATCH-success)](#)
[![CACE](https://img.shields.io/badge/CACE-43%2F43_Passed-success)](#)

---

## 1. Overview & Circuit Function

The `ota_cmos5l` is a high-gain, general-purpose operational transconductance amplifier (OTA) designed for precision low-frequency analog processing. Within the Programmable Gain Instrumentation Amplifier (PGIA) architecture, this OTA serves two fundamental roles:
1. **Input Buffering & Subtraction**: Instantiated three times within the static Instrumentation Amplifier (`instramp_cmos5l`) to form the non-inverting input buffers and differential difference subtractor.
2. **Output Driving**: Instantiated once within `output_buffer` as a unity-gain follower to drive off-chip loads ($15\text{ pF} \parallel 100\text{ k}\Omega$).

### Key Features
* **Topology**: Differential PMOS input pair driving an active NMOS current mirror load (Stage 1), followed by an NMOS common-source amplifier with an active PMOS current source load (Stage 2).
* **Compensation**: Internal active Miller capacitor ($C_c = 2.0\text{ pF}$) providing dominant pole-splitting for unconditional closed-loop stability ($\text{PM} > 60^\circ$).
* **Ultra-Low Power**: Quiescent power consumption of $24.7\,\mu\text{W}$ ($18.3\,\mu\text{A}$ at $1.2\text{ V}$ nominal supply).
* **Wide ICMR**: PMOS differential input enables linear common-mode operation down to $78\text{ mV}$ above ground rail ($V_{\text{SS}}$).

---

## 2. Port Interface & Pin Description

| Pin Name | Type | Direction | Nominal Level | Description |
| :--- | :---: | :---: | :---: | :--- |
| `VDD` | Power | Inout | $1.20\text{ V}$ | Positive analog supply rail ($1.08\text{ V} - 1.50\text{ V}$) |
| `VSS` | Ground | Inout | $0.00\text{ V}$ | Analog substrate ground reference |
| `IBIAS` | Bias | Input | $1.40\,\mu\text{A}$ | Master current bias input (current sink to ground) |
| `VINP` | Analog Signal | Input | $0.60\text{ V}$ | Non-inverting high-impedance differential input |
| `VINN` | Analog Signal | Input | $0.60\text{ V}$ | Inverting high-impedance differential input |
| `VOUT` | Analog Signal | Output | $0.60\text{ V}$ | High-impedance analog output terminal |

---

## 3. Circuit Sizing & Device Parameters

The schematic is parameterized in `xschem/ota_cmos5l/ota_cmos5l.sch`. All transistors utilize the standard low-voltage CMOS devices (`sg13_lv_pmos` and `sg13_lv_nmos`):

| Device Role | Instance(s) | Type | $W$ ($\mu\text{m}$) | $L$ ($\mu\text{m}$) | Multiplier ($m$) | Sizing Rationale |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| **Input Pair** | `M1`, `M2` | `sg13_lv_pmos` | 20.00 | 3.00 | 1 | Long channel to suppress flicker noise and enhance $g_m/I_d$ matching |
| **Active Mirror Load** | `M3`, `M4` | `sg13_lv_nmos` | 10.00 | 5.00 | 1 | High output impedance ($r_{o}$) and low threshold mismatch |
| **Tail Current Source** | `M5` | `sg13_lv_pmos` | 20.00 | 3.00 | 8 (`m8`) | Low saturation voltage, high output impedance ($I_{\text{tail}} \approx 11.2\,\mu\text{A}$) |
| **Bias Diode / Mirror**| `M6` | `sg13_lv_nmos` | 0.15 | 0.15 | 1 (`m6`) | Master bias reference receiver |
| **Stage 2 Driver (CS)** | `M7` | `sg13_lv_nmos` | 20.00 | 3.00 | 4 (`m7`) | High transconductance second stage driver |
| **Stage 2 Active Load** | `M8` | `sg13_lv_pmos` | 20.00 | 3.00 | 8 (`m8`) | Matches tail mirror sizing for symmetrical current scaling |
| **Miller Capacitor** | `Cc` | `cap_cmom` | $2.00\text{ pF}$ | — | 1 | Metal-Oxide-Metal (MoM) capacitor for dominant pole splitting |

---

## 4. Electrical Performance Summary (Pre- vs Post-Layout)

Characterization results across nominal conditions ($V_{\text{DD}} = 1.2\text{ V}$, $V_{\text{CM}} = 0.6\text{ V}$, $I_{\text{BIAS}} = 1.4\,\mu\text{A}$, $C_L = 3\text{ pF}$, $T = 27^\circ\text{C}$):

| Figure of Merit (FOM) | Symbol | Unit | Target | Pre-Layout (Schematic) | Post-Layout (RC-PEX) | Status |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Open-Loop DC Gain** | $A_{v0}$ | dB | $\ge 50.0$ | **57.87** | **57.78** | Met |
| **-3 dB Cutoff Frequency** | $f_{-3\text{dB}}$ | kHz | — | 3.70 | 3.41 | Met |
| **Unity-Gain Frequency** | UGF | MHz | $\ge 1.0$ | **2.70** | **2.48** | Met |
| **Phase Margin** | PM | deg | $\ge 50.0$ | **60.65** | **61.60** | Met ($+11.6^\circ$ margin) |
| **Gain Margin** | GM | dB | — | 17.16 | 17.34 | Met |
| **Gain-Bandwidth Product** | GBW | MHz | — | 2.86 | 2.64 | Met |
| **Input Offset Voltage** | $V_{\text{os}}$ | mV | $\le \pm 1.0$ | -0.21 | -0.80 | Met |
| **DC CMRR (@ 10 Hz)** | $\text{CMRR}_{\text{dc}}$ | dB | — | 64.87 | 64.69 | Met |
| **DC PSRR (@ 10 Hz)** | $\text{PSRR}_{\text{dc}}$ | dB | — | 73.89 | 77.85 | Met |
| **Input Referred Noise (@ 1 kHz)**| IRN | $\text{nV}/\sqrt{\text{Hz}}$ | — | 197.0 | 195.8 | Met |
| **Total Integrated Input Noise** | $v_{n,\text{in}}$ | $\mu\text{V}_{\text{rms}}$ | — | 2863.5 | 3085.7 | Met |
| **Linear ICMR Range** | ICMR | V | — | 0.078 – 1.180 | 0.079 – 1.180 | Met ($1.10\text{ V}$ span) |
| **Quiescent Current** | $I_Q$ | $\mu\text{A}$ | — | 18.30 | 18.32 | Met |
| **Quiescent Power** | $P_{\text{dc}}$ | $\mu\text{W}$ | $\le 50.0$ | **24.71** | **24.74** | Met |
| **Positive Slew Rate** | $\text{SR}^+$ | $\text{V}/\mu\text{s}$ | — | +1.95 | +1.88 | Met |
| **Negative Slew Rate** | $\text{SR}^-$ | $\text{V}/\mu\text{s}$ | — | -2.43 | -2.39 | Met |
| **Small-Signal Settling (0.1%)**| $t_s$ | ns | — | 365.7 | 378.2 | Met |

---

## 5. Frequency Stability & PVT Corner Analysis

Simulated across 45 PVT operating corners (`tt`, `ss`, `ff`, `sf`, `fs`), supply rails ($1.08\text{ V}$ to $1.50\text{ V}$), and temperatures ($-40^\circ\text{C}$ to $+85^\circ\text{C}$):
* **Gain Robustness**: Open-loop DC gain remains between $55.59\text{ dB}$ (worst-case at $+85^\circ\text{C}$, $1.2\text{ V}$, `ff`) and $59.48\text{ dB}$, exceeding the $50\text{ dB}$ specification floor across all conditions.
* **Phase Margin Boundary**: Phase Margin ranges from $55.64^\circ$ to $66.90^\circ$. Even under the worst-case hot corner ($+85^\circ\text{C}$), the phase margin maintains $>55^\circ$, precluding closed-loop ringing or instability.
* **Gain Tracking**: As a unity-gain follower, the closed-loop gain error is $+0.048\%$ ($0.9995\text{ V/V}$) with an ultra-low temperature coefficient of $1.30\text{ ppm}/^\circ\text{C}$.

---

## 6. Monte Carlo Statistical Analysis

Local device mismatch analysis evaluated over 50 Monte Carlo runs ($V_{\text{DD}} = 1.2\text{ V}$, $T = 27^\circ\text{C}$):
* **Input Offset Voltage ($V_{\text{os}}$)**: Mean $\mu = -0.066\text{ mV}$, standard deviation $\sigma = 0.81\text{ mV}$. Over $72\%$ of uncalibrated dies fall within $\pm 1.0\text{ mV}$.
* **CMRR Spread**: Mean CMRR at $10\text{ Hz}$ is $63.0\text{ dB}$ with a $3\sigma$ worst-case bound above $48.0\text{ dB}$.
* **PSRR Spread**: Mean PSRR at $10\text{ Hz}$ is $57.3\text{ dB}$ with a lower $3\sigma$ bound of $46.7\text{ dB}$.

---

## 7. Physical Layout & Parasitic Impact

* **Layout Dimensions**: $W = 112.21\,\mu\text{m}$, $L = 37.41\,\mu\text{m}$, Area = $4,198\,\mu\text{m}^2$.
* **Extracted Parasitics (Magic RC-PEX)**: 30 active subcircuits, 273 parasitic resistors, and 116 parasitic capacitors.
* **Parasitic Degradation**:
  * Unity-Gain Frequency dropped by $8.01\%$ (from $2.70\text{ MHz}$ to $2.48\text{ MHz}$) due to interconnect capacitance loading the high-impedance inter-stage node.
  * Phase Margin increased by $+0.95^\circ$ ($60.65^\circ \rightarrow 61.60^\circ$) due to mild low-pass damping from metal routing resistance.
* **Physical Checks**: KLayout DRC clean (`0` violations), antenna check clean, and tap audit fully compliant.

---

## 8. Known Anomalies & Future Work

1. **High-Temperature Phase Margin Degradation**:
   * *Observation*: PM decreases from $60.65^\circ$ at $27^\circ\text{C}$ to $55.64^\circ$ at $+85^\circ\text{C}$ due to transconductance roll-off in the second-stage driver.
   * *Future Work*: Incorporate a series nulling resistor ($R_z$) in the Miller compensation branch to shift the right-half-plane (RHP) zero into the left-half-plane, improving high-temperature phase margin to $>65^\circ$.
2. **Post-Layout Systematic Offset Drift**:
   * *Observation*: Systematic offset increases from $-0.21\text{ mV}$ (schematic) to $-0.80\text{ mV}$ (RC-PEX) due to slight asymmetric parasitic routing on the PMOS input pair drains.
   * *Future Work*: Adopt a fully cross-quad common-centroid multi-finger layout ($m=4$, interleaved ABBA pattern) for `M1` and `M2`.

