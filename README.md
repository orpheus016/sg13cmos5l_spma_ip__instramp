# Programmable Gain Instrumentation Amplifier (PGIA) IP
**Linear-in-dB from 18 dB to 78 dB on IHP SG13CMOS5L**

[![Chipalooza 2026](https://img.shields.io/badge/Chipalooza_2026-Challenge_%232-blue)](#)
[![Technology](https://img.shields.io/badge/Technology-IHP_SG13CMOS5L-green)](#)
[![Status](https://img.shields.io/badge/Status-Active_Development-orange)](#)

## Overview
This repository contains the open-source IC design for a Programmable Gain Instrumentation Amplifier (PGIA) tailored for precision, low-frequency sensor interfaces in mixed-signal SoCs. Designed specifically for the IHP SG13CMOS5L technology node, this IP is optimized for measuring weak differential biosignals (such as EEG, ECG, EMG, and EOG) with high input impedance, low offset, and low noise. 

The core value proposition of this IP is its flexible, linear-in-dB gain configurability. By utilizing a hybrid dual-stage tuning architecture (Coarse and Fine), SoC designers can accommodate diverse sensor types and varying signal conditions without requiring custom hardware redesigns.

## Architecture 
The system features two separate voltage domains: an analog domain (`AVDD`/`AVSS`) for the amplification stages and a digital domain (`DVDD`/`DVSS`) for the 10-bit decoder. The total system gain is calculated as:  
**G(dB)_total = G(dB)_IA + G(dB)_coarse + G(dB)_fine + G(dB)_buffer**

<img width="806" height="323" alt="image" src="https://github.com/user-attachments/assets/2bf6e69c-8966-496c-a588-8b3f7fcb7b78" />


### 1. Instrumentation Amplifier (Input Stage)
*   **Purpose:** Provides ultra-high input impedance (> 1 GΩ) to buffer sensor signals, establishes strong Common-Mode Rejection Ratio (CMRR), and provides an initial static gain of 18.06 dB (8x).
*   **Topology:** Two unity-gain voltage follower buffers driving a difference-amplifier subtractor (standard two-op-amp IA).

### 2. Coarse-Gain Stage (PGA)
*   **Purpose:** Provides large-step gain adjustments.
*   **Gain Range:** 0 dB to +56.25 dB (+3.75 dB/step).
*   **Control:** 4-bit digital control word ($D_0$ - $D_3$) driving 16 CMOS transmission gates via a 4-to-16 thermometer decoder.
*   **Topology:** Single-ended operational amplifier with a 17-resistor switched-feedback network.

### 3. Fine-Gain Stage (PGA)
*   **Purpose:** Provides precise, high-resolution gain tuning.
*   **Gain Range:** 0 dB to +3.69 dB (+0.0581 dB/step).
*   **Control:** 6-bit digital control word ($D_4$ - $D_9$) driving 6 CMOS transmission gates.
*   **Topology:** Single-ended operational amplifier with a 15-resistor R-2R ladder network.

### 4. Output Buffer & Support Blocks
*   **Output Buffer:** A unity-gain voltage follower designed to provide a low-impedance output (approx. 0 dB gain) suitable for driving off-chip loads like ADC inputs or PCB traces.
*   **Bias Network:** A V-to-I converter (diode-connected MOSFET and current-mirror replica biasing) converting voltage references into a stable $I_{BIAS}$ for all OTAs.
*   **Digital Decoder:** Static CMOS purely combinational logic operating on the digital power domain, generating non-overlapping ON/OFF signal pairs (including inverters) for the transmission gates to ensure zero static power consumption.

## I/O Port List

| Port Name | Category | Description |
| :--- | :--- | :--- |
| `VINP` / `VINN` | Analog Input | Positive and negative differential analog inputs from the sensor. |
| `VOUT` | Analog Output | Single-ended amplified output. |
| `AVDD` / `AVSS` | Power | Analog supply voltage (1.2V - 1.5V) and analog ground. |
| `DVDD` / `DVSS` | Power | Digital supply voltage and digital ground (for the 10-bit decoder). |
| `VCM` | Reference | Common-mode voltage reference input (typically VDD/2). |
| `VBIAS` | Reference | BGR (1.2 V) reference input. |
| `D0` - `D9` | Digital Control | 10-bit digital control word for Coarse (D0-D3) and Fine (D4-D9) gain switching. |

## Target Specifications

| Parameter | Min | Typ | Max | Unit | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Supply Voltage (VDD)** | 1.2 | 1.5 | - | V | Low-voltage transistors on IHP SG13CMOS5L |
| **Gain Range** | 18 | - | 78 | dB | Targeted gain accuracy is approx. 10-bit |
| **Frequency Response** | 0.05 | - | 20k | Hz | Targeted for biomedical signal spectrums |
| **Phase Margin (PM)** | 60 | - | - | deg | Minimum for unconditional stability |
| **CMRR & PSRR** | 60 | - | - | dB | Over the frequency response range |
| **THD** | - | - | 1 | % | Total Harmonic Distortion |
| **Input Impedance** | $10^9$ | - | $10^{12}$ | Ω | High-Z for sensitive biochemical interfaces |
| **Input Referred Noise**| - | - | 20 | $nV/\sqrt{Hz}$ | - |
| **Input Offset Voltage** | -1 | - | 1 | mV | - |
| **Input Diff Range** | 0.001| - | 10 | mV | Accommodates weak biomechanical signals |
| **Power Consumption** | - | - | 10 | mW | - |
| **Silicon Area** | - | - | 0.5 | $mm^2$ | - |

## Verification and Test Plan
This design utilizes a fully open-source verification flow (Xschem, ngspice, Python) for pre-silicon validation. The verification suite covers various gain configurations ($G = 8, 80, 800, 8000 \text{ V/V}$) and includes:
*   **AC Analysis:** Bode plots (PM, GM, GBW, BW), CMRR/PSRR vs frequency, Input Impedance.
*   **Transient Analysis:** Gain switching transient response, repeatability, Maximum Output Voltage vs Frequency.
*   **Noise & Distortion:** Voltage noise density, THD + Noise vs Frequency.
*   **Statistical & Drift:** Monte Carlo simulations for CMRR, PSRR, and Offset Voltage Temperature Drift. DC Sweeps for Gain Linearity.
## Shortcuts
Below are the shortcuts to see each core specs.

Layout:
- [Top level and Cells](https://github.com/orpheus016/sg13cmos5l_spma_ip__instramp/tree/main/gds/pgia_top)

Core:
- [Two-Stage Miller-Compensated OTA](https://github.com/orpheus016/sg13cmos5l_spma_ip__instramp/tree/main/xschem/ota_cmos5l)
- [Instrumentation Amplifier](https://github.com/orpheus016/sg13cmos5l_spma_ip__instramp/tree/main/xschem/instramp_cmos5l)
- [Fine-Gain Stage](https://github.com/orpheus016/sg13cmos5l_spma_ip__instramp/tree/main/xschem/fine_gain)
- [Coarse-Gain Stage](https://github.com/orpheus016/sg13cmos5l_spma_ip__instramp/tree/main/xschem/coarse_gain)
- [Digital Decoder](https://github.com/orpheus016/sg13cmos5l_spma_ip__instramp/tree/main/xschem/decoder_top_10b)
- [Output Buffer](https://github.com/orpheus016/sg13cmos5l_spma_ip__instramp/tree/main/xschem/output_buffer)

