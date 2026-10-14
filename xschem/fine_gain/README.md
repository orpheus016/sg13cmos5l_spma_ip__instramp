# Fine Gain Stage

## Overview
This block implements the Fine-Gain Stage (Stage 3) of the Programmable Gain Instrumentation Amplifier. It utilizes a single-ended operational amplifier with an R-2R resistor ladder network and CMOS transmission gate switches.

## Designed Topology
<!-- Block diagram from the proposal -->
<!-- AUTO:schematic:fine_gain -->
![fine_gain schematic](../../docs/fine_gain/media/fine_gain_schematic.png)
<!-- /AUTO -->

## Schematic (Xschem)
<!-- Xschem schematic capture -->
<img width="893" height="238" alt="Xschem Schematic" src="https://github.com/user-attachments/assets/19ce02c5-c9dd-44ae-b88f-49b870419320" />

## Pin Descriptions (I/O)
| Pin Name | Type | Description |
| :--- | :--- | :--- |
| `VIN3` | Analog Input | Signal input from the preceding Coarse-Gain stage. |
| `VCM` | Analog Input | Common-mode voltage reference (VDD/2). |
| `D4` - `D9` | Digital Input | 6-bit digital control word for fine gain adjustment. |
| `VOUT` | Analog Output | Amplified single-ended output passed to the Buffer stage. |
| `AVDD` / `AVSS` | Power | Analog supply voltage (1.2V - 1.5V) and ground. |

## Expected Performance
- **Gain Range:** 0 dB to +3.69 dB
- **Gain Step:** +0.0581 dB/step
- **Resolution:** 6-bit digital control
- **Frequency Response Range:** 0.05 Hz to 20000 Hz
- **Phase Margin (PM):** 60 deg minimum
- **Supply Voltage (VDD):** 1.2 V to 1.5 V

## Physical Specs
```ngspice
* --- Resistor Ladder ---
.param W_RES=1u L_R=35.18u L_2R=70.475u

* --- Transmission Gates ---
.param W_TG_N=10u L_TG_N=0.13u NG_TG_N=2
.param W_TG_P=30u L_TG_P=0.13u NG_TG_P=6

* --- Scaled Output OTA (5x Drive) ---
.param m8=5 m5=5 Cc=5p
```

## Metrics
- TBA

## Plots
- TBA

## Future Plan
- Complete Simulation
- Verify stability and PM of the OTA under load
