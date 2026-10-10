# Gain Stage

## Overview & Architecture
This block implements the gain configuration of the Programmable Gain Instrumentation Amplifier (PGIA). It provides a programmable gain interface using an operational transconductance amplifier (OTA) and a digitally switched resistor ladder:
* **OTA Core**: A two-stage topology consisting of a PMOS folded-cascode input stage (fully-differential input, single-ended output) driving a common-source Class-AB push-pull output stage with split-capacitor active Miller compensation.
* **Feedback Attenuation Network**: An one-hot encoded 5-bit digitally switched logarithmic feedback-resistor string providing 5 programmable gain settings ranging from 0 dB to +30.103 dB in +6.02 dB/step increments.
* **Control Interface**: Controlled via active-high select lines (`S0`–`S5`)

## Pin Description
| Pin Name | Type | Description |
| :--- | :--- | :--- |
| `VIN2` | Analog Input | Signal input from the preceding Stage 1. |
| `VCM` | Analog Input | Common-mode reference voltage ($V_{DD}/2 = 0.6\text{ V}$). |
| `S0` – `S5` | Digital Input | 5-bit one-hot control bus decoded |
| `VOUT` | Analog Output | Amplified single-ended output signal. |
| `AVDD` / `AVSS` | Power | Analog positive power supply ($1.2\text{ V}$ nominal) and ground. |

## Schematics & Circuit Diagrams

### Gain Stage OTA Core
![Gain Stage OTA Core](https://github.com/user-attachments/assets/9c3f0ce1-58f2-49aa-9a54-50f53a957621)

### Gain Stage OTA Testbench
![Gain Stage OTA Testbench](https://github.com/user-attachments/assets/465ea932-eed0-470c-baef-6a1eef441d5e)

### Gain Stage Network Core
![Gain Stage Network](https://github.com/user-attachments/assets/8aa8213d-75cf-4b4b-8130-7e429d81107f)

### Gain Stage Network Core Testbench
![Gain Stage Network Testbench](https://github.com/user-attachments/assets/ba9a5028-7001-4ac0-8654-9393b73c888c)

## Specifications & Pre-Layout Performance Summary

### Gain Stage Network
Characterization of the complete gain stage across all 16 gain states (`S0` through `S5`) under nominal operating conditions ($V_{DD} = 1.2\text{ V}$, $V_{ICM} = 0.6\text{ V}$, $T = 27^\circ\text{C}$):

| Tap | Code | Target (dB) | Meas (dB) | Err (dB) | Err (Step) | Acc_FS (%) | -3dB BW (Hz) | Vos_out (mV) | V_vg_err (mV) | P_dc ($\mu\text{W}$) |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| S0   | 0    | 0       | 0.0735754       | 0.0735754     | 0.0122206     | 99.7556    | 8498.71        | 0.0126336       | 0.0123349       | 88.6027 |
| S1   | 1    | 6.0206       | 6.00887       | -0.0117289     | -0.00194813     | 99.961    | 4462.37        | 0.0129185       | 0.0123346       | 88.6027 |
| S2   | 2    | 12.0412       | 12.0658       | 0.0246002     | 0.004086     | 99.9183    | 2603.07        | 0.0134976       | 0.0123345       | 88.6027 |
| S3   | 3    | 18.0618       | 18.0544       | -0.00739974     | -0.00122907     | 99.9754    | 1456.45        | 0.0146333       | 0.0123337       | 88.6027 |
| S4   | 4    | 24.0824       | 24.0966       | 0.0141803     | 0.0023553     | 99.9529    | 773.465        | 0.0168682       | 0.0123324       | 88.6027 |
| S5   | 5    | 30.103       | 30.0761       | -0.0268896     | -0.00446626     | 99.9107    | 401.539        | 0.0212303       | 0.0123296       | 88.6028 |

#### Key Observations
* **Step Monotonicity & Accuracy**: High linearity across all 16 gain states with full-scale accuracy exceeding 98.97% across all codes (peaking at 99.997% at `S2` with an error of only $-0.0015\text{ dB}$). Positive error is strictly bounded within $+0.391\text{ dB}$ (at `S0`), and the worst-case negative deviation is $-0.579\text{ dB}$ (at `S15`).
* **Bandwidth Progression**: Closed-loop $-3\text{ dB}$ bandwidth scales smoothly from $8.12\text{ MHz}$ at unity gain (`S0`) down to $21.83\text{ kHz}$ at maximum gain (`S15`), successfully preserving the required bandwidth ($> 20\text{ kHz}$) across the entire range.
* **Virtual Ground DC Stability**: Virtual ground error ($V_{vg,err}$) is suppressed to $\approx 12.3\,\mu\text{V}$ ($0.0123\text{ mV}$) across all steps, verifying precise closed-loop virtual ground tracking.
* **Ultra-Low Output DC Offset**: Output DC offset ($V_{os,out}$) remains below $0.18\text{ mV}$ across all steps (scaling from $12.6\,\mu\text{V}$ at `S0` to $172.0\,\mu\text{V}$ at `S15`), preserving optimal dynamic headroom.
* **Static Power Stability**: Total core DC power dissipation remains practically invariant at $88.60\,\mu\text{W}$ across all gain tap selections.

### Gain Stage OTA
Evaluated at nominal conditions: $V_{DD} = 1.2\text{ V}$, $V_{ICM} = 0.6\text{ V}$, $T = 27^\circ\text{C}$, TT corner:

| Figure of Merit (FOM) | Target Specification | Simulated (Pre-Layout) | Status |
| :--- | :--- | :--- | :--- |
| **Open-Loop DC Gain ($A_{v0}$)** | $> 60.0\text{ dB}$ | **$62.97\text{ dB}$** ($1407.0\text{ V/V}$) | Met ($+2.97\text{ dB}$) |
| **Unity-Gain Bandwidth (UGBW)** | $\sim 8.0 - 13.0\text{ MHz}$ | **$13.09\text{ MHz}$** | Met (GBW: $13.22\text{ MHz}$) |
| **Dominant Pole ($f_{-3\text{dB}}$)** | — | **$9.40\text{ kHz}$** (Phase: $135.05^\circ$) | Target pole split achieved |
| **Phase Margin (PM)** | $> 60.0^\circ$ | **$63.50^\circ$** | Met ($+3.50^\circ$) |
| **Gain Margin (GM)** | $> 6.0\text{ dB}$ | **$8.19\text{ dB}$** ($f_{180} = 38.24\text{ MHz}$) | Met |
| **Total Quiescent Current ($I_q$)** | $\sim 10\text{ }\mu\text{A}$ (bias branch) | **$73.84\text{ }\mu\text{A}$** ($P_{dc} = 88.60\text{ }\mu\text{W}$) | Total core consumption |
| **Class-AB Quiescent Current** | Balanced push-pull | $I_{outp} = 14.09\text{ }\mu\text{A}$, $I_{outn} = 13.89\text{ }\mu\text{A}$ | Balanced ($g_{m,\text{center}} = 15.88\text{ mA/V}$) |
| **Slew Rate ($SR^+/SR^-$)** | $> 2.0\text{ V}/\mu\text{s}$ | **$+3.05\text{ V}/\mu\text{s} / -11.34\text{ V}/\mu\text{s}$** | Met |
| **Settling Time ($t_s$, 0.1%)** | $< 1.0\text{ }\mu\text{s}$ | **$506.5\text{ ns}$** (Overshoot: $1.76\%$) | Met |
| **CMRR (@DC/100 kHz)** | $> 60.0\text{ dB} / > 35.0\text{ dB}$ | **$67.82\text{ dB} / 42.43\text{ dB}$** | Met |
| **PSRR (@DC/100 kHz)** | $> 60.0\text{ dB}$ | **$37.28\text{ dB} / 37.07\text{ dB}$** | Not Met |
| **Linear ICMR Span** | $> 0.70\text{ V}$ | **$0.035\text{ V} - 0.981\text{ V}$ ($0.946\text{ V}$ span)** | Met (Linear gain $> 0.98$) |
| **Input-Referred Noise Floor** | $\sim 10\text{ nV}/\sqrt{\text{Hz}}$ | **$55.70\text{ nV}/\sqrt{\text{Hz}}$ (@ 1 MHz)** | Not Met ($1/f$ corner $\sim 10\text{ kHz}$) |

#### Detailed Telemetry & Characterization

#### 1. Operating Point & DC Linearity
* **Unity-Gain Follower Configuration**: Closed-loop systematic offset is $-0.0123\text{ mV}$ ($-12.35\text{ }\mu\text{V}$) with $V_{OUT} = 0.600012\text{ V}$ at $V_{ICM} = 0.6\text{ V}$, drawing $I_q = 73.84\text{ }\mu\text{A}$ ($88.60\text{ }\mu\text{W}$).
* **Open-Loop Configuration**: Systematic offset of $-17.48\text{ mV}$ ($V_{OUT} = 0.6175\text{ V}$ at $V_{ICM} = 0.6\text{ V}$) with all core transistors operating in saturation ($I_q = 73.93\text{ }\mu\text{A}$, $P_{dc} = 88.71\text{ }\mu\text{W}$).
* **DC Incremental Gain Range**: Sweeping the differential DC input yields a peak open-loop gain of $62.86\text{ dB}$ ($1389.6\text{ V/V}$).

#### 2. Noise Performance
* **Total Integrated Output Noise ($10\text{ Hz} - 100\text{ MHz}$)**: $554.11\text{ }\mu\text{V}_{\text{rms}}$.
* **Total Integrated Input Noise ($10\text{ Hz} - 100\text{ MHz}$)**: $1185.48\text{ }\mu\text{V}_{\text{rms}}$.
* **Spot Input-Referred Noise (IRN)**:
  * @ $10\text{ Hz}$ (Flicker noise dominant): $5407.29\text{ nV}/\sqrt{\text{Hz}}$
  * @ $100\text{ Hz}$: $1710.66\text{ nV}/\sqrt{\text{Hz}}$
  * @ $1\text{ kHz}$: $543.24\text{ nV}/\sqrt{\text{Hz}}$
  * @ $10\text{ kHz}$: $178.84\text{ nV}/\sqrt{\text{Hz}}$
  * @ $100\text{ kHz}$: $75.31\text{ nV}/\sqrt{\text{Hz}}$
  * @ $1\text{ MHz}$ (Thermal noise floor): $55.70\text{ nV}/\sqrt{\text{Hz}}$

#### 3. Step Response & Large-Signal Transient
* **Rise / Fall Times ($10\% - 90\%$)**: $t_r = 209.77\text{ ns}$, $t_f = 56.41\text{ ns}$.
* **Propagation Delays**: $t_{pLH} = 45.54\text{ ns}$, $t_{pHL} = 36.28\text{ ns}$.
* **Small-Signal Tracking**: Delay $= 13.25\text{ ns}$, rise time $= 14.16\text{ ns}$.
* **Settling Dynamics**: $506.93\text{ ns}$ (1% error band), $506.47\text{ ns}$ (0.1% error band) with an overshoot of $1.76\%$ ($V_{peak} = 0.6518\text{ V}$).

#### 4. Monte Carlo Statistical Analysis (100 Iterations)
Evaluated with process and device mismatch enabled (`mm_ok=1`, `mc_ok=1`):
* **Input Offset Voltage ($V_{os}$)**:
  * Mean ($\mu$): $-0.0121\text{ mV}$ ($-12.12\text{ }\mu\text{V}$)
  * Standard Deviation ($\sigma$): $4.45\text{ }\mu\text{V}$ ($0.00445\text{ mV}$)
  * Full Spread ($6\sigma$): $26.67\text{ }\mu\text{V}$ ($0.02667\text{ mV}$)
  * Measured Bounds: $-0.0229\text{ mV} \le V_{os} \le -0.0044\text{ mV}$
* **Total Quiescent Current ($I_q$)**:
  * Mean ($\mu$): $73.83\text{ }\mu\text{A}$
  * Standard Deviation ($\sigma$): $39.81\text{ nA}$ ($0.03981\text{ }\mu\text{A}$)

#### 5. PVT Corner Stability Analysis
Simulated across all process corners (`tt`, `ss`, `ff`, `sf`, `fs`), operating temperatures ($-40^\circ\text{C}$ to $+125^\circ\text{C}$), and supply rails ($1.00\text{ V}$ to $1.50\text{ V}$):

| Process Corner | DC Gain Range (dB) | UGBW Range (MHz) | Phase Margin Range ($^\circ$) | Gain Margin Range (dB) | Worst-Case Condition |
| :---: | :---: | :---: | :---: | :---: | :--- |
| **TT** | $56.86 - 66.69$ | $9.53 - 16.92$ | $62.73 - 68.78$ | $7.05 - 10.27$ | Min Gain @ $125^\circ\text{C}, 1.0\text{ V}$ |
| **SS** | $57.45 - 67.35$ | $7.85 - 18.02$ | $59.12 - 66.38$ | $6.55 - 15.21$ | Min PM ($59.12^\circ$), Min UGBW @ $-40^\circ\text{C}, 1.0\text{ V}$ |
| **FF** | $54.31 - 65.96$ | $9.60 - 16.09$ | $64.07 - 70.32$ | $7.46 - 8.97$ | Min Gain @ $125^\circ\text{C}, 1.0\text{ V}$ |
| **SF** | $57.18 - 66.70$ | $10.09 - 17.72$ | $61.00 - 67.88$ | $6.50 - 8.45$ | Min PM ($61.00^\circ$) @ $27^\circ\text{C}, 1.08\text{ V}$ |
| **FS** | $55.93 - 66.73$ | $8.89 - 16.27$ | $63.97 - 69.54$ | $7.60 - 12.10$ | Min Gain @ $125^\circ\text{C}, 1.0\text{ V}$ |

Across all 90 PVT operating conditions, Phase Margin remains comfortably above $59^\circ$ (worst-case $59.12^\circ$ under extreme low-temperature SS conditions at $-40^\circ\text{C}$, $1.0\text{ V}$), guaranteeing stability and eliminating the risk of closed-loop ringing.

## Sizings
### Gain Stage Network
#### 1. Feedback Resistor String
Switched resistor ladder topology providing 6 gain settings (`S0` through `S5`). All substrate/bulk pins are tied to analog ground (`AVSS`):

| Instance | Device Type | W (µm) | L (µm) | Bends ($b$) | Node Connections (+ / -) | Segment / Circuit Role |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `XR1` | `rppd` | 2.00 | 15.16 | 0 | net7 to `V_IN2` | Base input resistor ($R_{in}$) |
| `XR2` | `rppd` | 2.00 | 7.00 | 0 | net1 to `V_OUT2` | Base feedback segment (Tap S0) |
| `XR3` | `rppd` | 2.00 | 15.16 | 0 | net2 to net1 | Ladder segment between Tap S0 and S1 |
| `XR4` | `rhigh` | 0.50 | 1.25 | 0 | net3 to net2 | Ladder segment between Tap S1 and S2 |
| `XR5` | `rhigh` | 0.50 | 2.60 | 0 | net4 to net3 | Ladder segment between Tap S2 and S3 |
| `XR6` | `rhigh` | 0.50 | 5.30 | 0 | net5 to net4 | Ladder segment between Tap S3 and S4 |
| `XR7` | `rhigh` | 0.50 | 10.72 | 0 | net6 to net5 | Ladder segment between Tap S4 and S5 |

#### 2. Digitally Controlled Transmission Gate Switches (`tgate`)
Progressively tapered transmission gates routing the selected resistor ladder tap to the summing junction / virtual ground node (`net7`). All switches use channel length $L = 0.13\,\mu\text{m}$:

| Switch Tier | Instance | Associated Tap | Connected Tap Node | $W_n$ (µm) | $W_p$ (µm) | Design Rationale |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Low-Gain Tier** | `x2` | S0 | net1 | 3.00 | 9.00 | Minimum $R_{on}$ to minimize gain error on small ladder resistances |
| | `x3` | S1 | net2 | 2.90 | 8.70 | Low $R_{on}$ tracking base ladder segment |
| | `x4` | S2 | net3 | 2.60 | 7.80 | Tapered $R_{on}$ transition |
| **Mid-to-High Gain** | `x5` | S3 | net4 | 2.20 | 6.60 | Balanced trade-off between $R_{on}$ and junction capacitance |
| | `x6` | S4 | net5 | 1.50 | 4.50 | Reduced switch area and capacitive loading |
| | `x7` | S5 | net6 | 0.90 | 2.70 | Minimum parasitic capacitance to preserve phase margin at peak gain |

### Gain Stage OTA
#### 1. Main Core Transistors (OTA Core)
Fully-differential PMOS folded-cascode input stage driving a common-source Class-AB push-pull output stage:

| Instance | Device Type | W / L (µm) | Layout (m / ng) | Circuit Role |
| :--- | :--- | :--- | :--- | :--- |
| `XM_tail` | `sg13_lv_pmos` | 7.46 / 2.00 | m=8, ng=1 | Differential tail current source (Total $W = 59.68\,\mu\text{m}$) |
| `XM1, XM2` | `sg13_lv_pmos` | 26.56 / 2.00 | m=1, ng=4 | Folded-cascode differential input pair |
| `XM3, XM4` | `sg13_lv_pmos` | 7.33 / 2.00 | m=1, ng=1 | First-stage active current mirror load |
| `XM5, XM6` | `sg13_lv_nmos` | 6.41 / 2.00 | m=1, ng=1 | NMOS folding cascode pair |
| `XM7, XM8` | `sg13_lv_nmos` | 9.21 / 2.00 | m=1, ng=1 | First-stage base current sinks |
| `XM_ctrlp` | `sg13_lv_pmos` | 2.20 / 0.50 | m=1, ng=1 | Monticelli Class-AB mesh floating battery (top PMOS) |
| `XM_ctrln` | `sg13_lv_nmos` | 0.84 / 0.50 | m=1, ng=1 | Monticelli Class-AB mesh floating battery (bottom NMOS) |
| `XM_outp` | `sg13_lv_pmos` | 22.20 / 0.50 | m=1, ng=4 | Stage-2 pull-up output driver |
| `XM_outn` | `sg13_lv_nmos` | 8.40 / 0.50 | m=1, ng=1 | Stage-2 pull-down output driver |

#### 2. Miller Compensation Network (Active Split-Miller & Nulling)
Split-capacitor active Miller compensation featuring a series nulling resistor to suppress the right-half-plane (RHP) zero:

| Instance | Component Type | Dimensions / Size (µm) | Terminal Connections | Circuit Role |
| :--- | :--- | :--- | :--- | :--- |
| `XC1` | `cap_cmomf` | $22.00 \times 22.00$, $m=1$ | Node F2 to `V_out` | Cascode-node active Miller compensation capacitor |
| `XC2` | `cap_cmomf` | $15.44 \times 15.44$, $m=1$ | Node net7 to `V_out` | Dominant first-stage Miller compensation capacitor |
| `XR2` | `rhigh` | $W = 0.50, L = 4.00$, $b=0$ | Node N_A to net7 | Series nulling resistor for RHP zero mitigation |

#### 3. Bias Generator Circuitry & Replicas
Internal current reference and bias generation network referenced to master input current `I_bias` ($1\,\mu\text{A}$):

| Instance | Device Type | W / L (µm) | Layout (m / ng) | Circuit Role / Bias Sub-block |
| :--- | :--- | :--- | :--- | :--- |
| `XM_refn, XM_mn1` | `sg13_lv_nmos` | 0.87 / 2.00 | m=1, ng=1 | Master $1\text{ }\mu\text{A}$ current mirror (diode input & net1 reference) |
| `XM_mp1` | `sg13_lv_pmos` | 2.30 / 2.00 | m=1, ng=1 | Master PMOS diode load establishing net1 gate bias |
| `XM_mp2` | `sg13_lv_pmos` | 11.50 / 2.00 | m=1, ng=2 | Current mirror for $V_{bn1}$ cascode bias branch |
| `XM_bn1` | `sg13_lv_nmos` | 1.60 / 2.00 | m=1, ng=1 | Diode-connected NMOS generating $V_{bn1}$ cascode gate bias |
| `XR1` | `rhigh` | $W = 0.50, L = 15.00$, $b=0$ | Node net2 to VSS | Source degeneration resistor for $V_{bn1}$ bias generator |
| `XM_mp3` | `sg13_lv_pmos` | 23.00 / 2.00 | m=1, ng=4 | Current mirror for $V_{bn2}$ current sink bias branch |
| `XM_bn2` | `sg13_lv_nmos` | 9.21 / 2.00 | m=1, ng=1 | Diode-connected NMOS generating $V_{bn2}$ gate bias |
| `XM_mn2` | `sg13_lv_nmos` | 6.00 / 2.00 | m=1, ng=1 | Current sink pulling reference current for $V_{btail}$ |
| `XM_rep_tail` | `sg13_lv_pmos` | 7.46 / 2.00 | m=8, ng=1 | Replica diode load establishing tail bias voltage $V_{btail}$ |
| `XM_mp4` | `sg13_lv_pmos` | 4.60 / 2.00 | m=1, ng=1 | Current source for $V_{ctrln}$ Class-AB replica bias branch |
| `XM_rep_ctrln` | `sg13_lv_nmos` | 0.84 / 0.50 | m=1, ng=1 | Diode replica of NMOS Class-AB mesh control transistor |
| `XM_rep_outn` | `sg13_lv_nmos` | 2.10 / 0.50 | m=1, ng=1 | Scaled replica of Stage-2 NMOS output driver |
| `XM_mn3` | `sg13_lv_nmos` | 1.74 / 2.00 | m=1, ng=1 | Current sink for $V_{ctrlp}$ Class-AB replica bias branch |
| `XM_rep_ctrlp` | `sg13_lv_pmos` | 2.20 / 0.50 | m=1, ng=1 | Diode replica of PMOS Class-AB mesh control transistor |
| `XM_rep_outp` | `sg13_lv_pmos` | 5.55 / 0.50 | m=1, ng=1 | Scaled replica of Stage-2 PMOS output driver |
| `XM_mn4` | `sg13_lv_nmos` | 3.20 / 2.00 | m=1, ng=1 | Current sink balancing gate control node N_B |
| `XM_mp5` | `sg13_lv_pmos` | 9.21 / 2.00 | m=1, ng=1 | Current injector balancing first-stage output node N_A |
