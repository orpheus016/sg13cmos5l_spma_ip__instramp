# PGIA Top-Level Floorplanning Technical Implementation Note

**Project:** Programmable Gain Instrumentation Amplifier (PGIA) IP
**Challenge:** Chipalooza Challenge #2 (IHP SG13CMOS5L)
**Process Node:** IHP SG13CMOS5L ($0.13\,\mu\text{m}$ CMOS-only, strictly non-BiCMOS)
**Standard Cell Library:** `sg13cmos5l_stdcell` ($1.2\,\text{V}$ Logic)
**Assigned Slot Wrapper:** `slot9_wrapper` ([`sg13cmos5l_ocd_chipalooza`](file:///home/ranantalden/Projects/Designs/Chipalooza/sg13cmos5l_ocd_chipalooza))
**Slot Footprint:** $537.15\,\mu\text{m} \times 273.00\,\mu\text{m}$ ($0.1466\,\text{mm}^2$)
**Floorplan Architecture:** **Option B — Folded Horseshoe Flow (All Dedicated Analog Pads on East Edge)**
**Top-Level Cell:** `pgia_top`
**Layout Location:** [`gds/pgia_top/pgia_top.gds`](file:///home/ranantalden/Projects/Designs/Chipalooza/Programmable-Instrumentation-Amplifier-IP/gds/pgia_top/pgia_top.gds)

---

## 1. Executive Summary & Design Scope

The **`pgia_top`** layout integrates the complete mixed-signal Programmable Gain Instrumentation Amplifier IP for the Chipalooza Challenge #2 shuttle. The core subsystem amplifies low-level sensor signals across a programmable dynamic range from **$+18.06\,\text{dB}$ ($8\times$) up to $+78.06\,\text{dB}$ ($8192\times$)** in clean $6.02\,\text{dB}$ binary steps ($1\times, 2\times, 4\times, 8\times, 16\times, 32\times$), controlled via a 4-bit binary gain selection word (`gain_sel[3:0]`).

### Primary Physical Design Objectives:

1. **Dedicated Analog Pad Exclusivity (Option B):**All three primary analog I/Os (`VINP`, `VINN`, `VOUT`) are assigned exclusively to the **dedicated analog bond pads on the East edge** (`s9_an[0]`, `s9_an[1]`, `s9_an[2]`). This bypasses the shared chip-level analog bus (`analog_bus[3:0]`), eliminating transmission-gate series switch resistance ($R_{on} \approx 50\text{--}200\,\Omega$), non-linear distortion, and contention with other user slots.
2. **High-Gain Stability via Folded Horseshoe Topology:**Because both the microvolt-level differential inputs (`VINP`/`VINN` on `s9_an[0..1]`) and the high-swing single-ended output (`VOUT` on `s9_an[2]`) reside on the East boundary, the circuit utilizes a **Folded Two-Lane Flow**:
   - **Lower Lane ($Y \in [18, 138]\,\mu\text{m}$):** Signals travel Westward from the East inputs through the Instrumentation Amplifier (`instramp_cmos5l`) into Gain Stage 1 (`gain_stage_1`).
   - **Upper Lane ($Y \in [155, 255]\,\mu\text{m}$):** Signals travel Eastward from Gain Stage 2 (`gain_stage_2`) into the Output Buffer (`output_buffer`) and exit directly to `s9_an[2]`.
   - **Central Isolation Trench ($Y \in [138, 153]\,\mu\text{m}$):** A continuous grounded guard moat separates the two lanes, eliminating parasitic feedback and oscillation risk at maximum gain ($78\,\text{dB}$).
3. **Substrate & Digital Noise Containment:**The digital decoder macro ([`gain_decoder_4b`](file:///home/ranantalden/Projects/Designs/Chipalooza/Programmable-Instrumentation-Amplifier-IP/gds/gain_decoder_4b/README.md), $65.0 \times 45.0\,\mu\text{m}$) is placed on the **far West edge**, directly adjacent to `dig_in[3:0]`. This maintains **$>260\,\mu\text{m}$ physical distance** from the sensitive analog bond pads on the East. It is enclosed in its own dedicated $P^+/\text{N-well}$ double guard ring tied to `vss_1v2`/`vdd_1v2`.
4. **Strict Metal Stack Compliance:**
   In compliance with shuttle rules, all signal routing is strictly constrained to **$\le \text{Metal4}$**. The `TopMetal1` layer is reserved exclusively for global power and ground distribution rails.

---

## 2. Global Die Coordinates & Slot 9 Envelope

From the official Chipalooza harness definition ([`slot9_wrapper.mag`](file:///home/ranantalden/Projects/Designs/Chipalooza/sg13cmos5l_ocd_chipalooza/magic/slot9_wrapper.mag)):

* **Total Slot 9 Boundary:** $X \in [0.00, 537.15]\,\mu\text{m}, \quad Y \in [0.00, 273.00]\,\mu\text{m}$ ($146,642\,\mu\text{m}^2$).
* **Perimeter Margin:** $15.0\,\mu\text{m}$ clearance along all four boundaries for power rings, guard rings, and seal boundary.
* **Usable Core Placement Envelope:**
  $$
  X \in [15.00, 520.00]\,\mu\text{m}, \quad Y \in [15.00, 255.00]\,\mu\text{m}$$  
  ($\Delta X = 505.00\,\mu\text{m}, \; \Delta Y = 240.00\,\mu\text{m}$).
  $$

### Top-Level Floorplan Architecture (Option B):

```
(0, 273) ┌────────────────────────────────────────────────────────────────────────┐ (537.15, 273)
         │                                       [UPPER ANALOG LANE]              │
         │                                   ┌─────────────┐       ┌────────────┐ │
         │                                   │gain_stage_2 │──────►│output_buf  ├─┼─► s9_an[2]
         │                                   │(OTA+5-taps) │       │(Unity-Gain)│ │   (VOUT)
         │                                   └──────▲──────┘       └────────────┘ │   (Y ≈ 255)
         │                                          │                             │
         │ ┌────────────────────────────────────────┴───────────────────────────┐ │
         │ │ === HEAVY GROUNDED ISOLATION TRENCH / SHIELDING MOAT (AVSS) ====== │ │   (Y ≈ 138..153)
         │ └──────────────────────┬─────────────────────────────────────────────┘ │
         │                        │ (10 lines: s2)                                │
         │ ┌────────────────┐     │                  [LOWER ANALOG LANE]          │
dig_in──►├─┤gain_decoder_4b ├─────┴────────┐ ┌─────────────┐      ┌────────────┐  │
[3:0]    │ │(65 um x 45 um) │ (10 lines: s1) ├►│gain_stage_1│◄─────┤instramp    │◄─┼── s9_an[1]
(Y≈78)   │ │[Digital Guard] │────────────────┘ │(OTA+5-taps)│      │_cmos5l(IA) │◄─┼── (VINN)
         │ └────────────────┘                  └─────────────┘      └────────────┘ │   (Y ≈ 145)
vdd_1v2  │      [WEST]                              [CENTER]             [EAST]   │── s9_an[0]
vss_1v2  │                                                                        │   (VINP)
  (0, 0) └────────────────────────────────────────────────────────────────────────┘ (Y ≈ 35)
```

---

## 3. Sub-Block Area Schedule & Quantitative Placement

All dimensions reflect finalized GDS layouts signed off on the IHP SG13CMOS5L process:

| Sub-Block                      | Subsystem Role                                          |           Domain           | Physical Dimensions $(W \times H)$ | Placed Bounding Box $[X_1, Y_1] \rightarrow [X_2, Y_2]$ | Center $(X_c, Y_c)$ | Port Orientation & Interface                                                             |
| :----------------------------- | :------------------------------------------------------ | :-------------------------: | :----------------------------------: | :-------------------------------------------------------: | :-------------------: | :--------------------------------------------------------------------------------------- |
| **`instramp_cmos5l`**  | Fixed Front-End IA ($8\times$ / $18.06\,\text{dB}$) |        Analog (Sens)        | $150.0 \times 120.0\,\mu\text{m}$ |     $[350.00, 18.00] \rightarrow [500.00, 138.00]$     |   $(425.0, 78.0)$   | **In:** East (`s9_an[0..1]`), **Out:** West (to `gain_stage_1`)          |
| **`gain_stage_1`**     | Programmable Stage 1 ($1\times \dots 32\times$)       |         Analog Core         | $105.0 \times 100.0\,\mu\text{m}$ |     $[210.00, 20.00] \rightarrow [315.00, 120.00]$     |   $(262.5, 70.0)$   | **In:** East (from IA), **Control:** West (`s1`), **Out:** West      |
| **`gain_stage_2`**     | Programmable Stage 2 ($1\times \dots 32\times$)       |         Analog Core         | $105.0 \times 100.0\,\mu\text{m}$ |     $[210.00, 155.00] \rightarrow [315.00, 255.00]$     |  $(262.5, 205.0)$  | **In:** West (from Stage 1), **Control:** West (`s2`), **Out:** East |
| **`output_buffer`**    | Unity-Gain Follower Driver                              |        Analog Driver        |  $55.0 \times 55.0\,\mu\text{m}$  |     $[440.00, 200.00] \rightarrow [495.00, 255.00]$     |  $(467.5, 227.5)$  | **In:** West (from Stage 2), **Out:** East (to `s9_an[2]`)                 |
| **`central_bias`**     | Master $V$-to-$I$ & Current Mirrors                 |         Analog Ref         |  $50.0 \times 40.0\,\mu\text{m}$  |     $[120.00, 115.00] \rightarrow [170.00, 155.00]$     |  $(145.0, 135.0)$  | **In:** South (`VBIAS`), **Out:** North/East/South (to OTAs)               |
| **`gain_decoder_4b`**  | 4-bit Binary Gain Decoder Macro                         | Digital ($1.2\,\text{V}$) |  $65.0 \times 45.0\,\mu\text{m}$  |      $[25.00, 60.00] \rightarrow [90.00, 105.00]$      |   $(57.5, 82.5)$   | **In:** West (`dig_in[3:0]`), **Out:** East (`s1`, `s2` buses)         |
| **`digital_guard`**    | Digital Isolation Double Guard Ring                     |          Isolation          |  $75.0 \times 55.0\,\mu\text{m}$  |      $[20.00, 55.00] \rightarrow [95.00, 110.00]$      |   $(57.5, 82.5)$   | Encloses `gain_decoder_4b` ($P^+$ to `vss_1v2`, N-well to `vdd_1v2`)             |
| **`isolation_trench`** | Inter-Lane Ground Shielding Moat                        |          Shielding          |  $320.0 \times 15.0\,\mu\text{m}$  |     $[180.00, 138.00] \rightarrow [500.00, 153.00]$     |  $(340.0, 145.5)$  | Separates Lower & Upper Lanes ($P^+$ to `AVSS`, N-well to `AVDD`)                  |

---

## 4. Substrate Isolation, Shielding & High-Gain Stability Strategy

At maximum gain ($A_v = 8192\,\text{V/V}$ / $78.06\,\text{dB}$), a fraction of a femtofarad ($<0.2\,\text{fF}$) of parasitic coupling from the output driver back into the differential input pair can exceed the Barkhausen criterion ($|A\beta| \ge 1$), triggering instability or rail saturation. Option B resolves this through four physical barriers:

### 4.1 Vertical Spatial Staggering

- On the East boundary, `s9_an[2]` (`VOUT`) sits at $Y \approx 254.5\,\mu\text{m}$.
- The differential inputs `s9_an[1]` (`VINN`) and `s9_an[0]` (`VINP`) sit at $Y \approx 144.5\,\mu\text{m}$ and $Y \approx 34.5\,\mu\text{m}$, providing:
  $$
  \Delta Y_{\text{VOUT-VINN}} = 110.0\,\mu\text{m}, \quad \Delta Y_{\text{VOUT-VINP}} = 220.0\,\mu\text{m}
  $$
- The active input transistors inside `instramp_cmos5l` are situated in the lower quadrant ($Y \le 138.0\,\mu\text{m}$), maintaining $>62\,\mu\text{m}$ direct vertical distance from the `output_buffer` ($Y \ge 200.0\,\mu\text{m}$).

### 4.2 Continuous Grounded Isolation Trench (Horizontal Demilitarized Zone)

- A continuous **$15.0\,\mu\text{m}$ wide grounded substrate trench** spans horizontally from $X = 180.0\,\mu\text{m}$ to $X = 500.0\,\mu\text{m}$ at $Y \in [138.0, 153.0]\,\mu\text{m}$.
- Structure:
  - **Inner $P^+$ Guard Ring:** Heavily tapped to clean analog ground (`AVSS`) to sink majority-carrier substrate hole currents.
  - **Outer N-Well Moat:** Tied to analog supply (`AVDD`) to act as a reverse-biased collector that sweeps minority-carrier electrons out of the p-substrate.
- This breaks both resistive and capacitive bulk substrate transmission between the Upper Lane (high swing) and Lower Lane (microvolt input).

### 4.3 Digital Macro Containment

- `gain_decoder_4b` sits at $X \in [25.0, 90.0]\,\mu\text{m}$, creating a spatial buffer of **$\Delta X > 260\,\mu\text{m}$** from the analog bond pads.
- Enclosed in an independent double guard ring tied exclusively to the digital supply rails (`vdd_1v2` / `vss_1v2`). Digital ground is **never shared** with quiet analog ground (`AVSS`).

### 4.4 Metal Routing Layer Segregation

- **Input traces (`s9_an[0..1]` $\rightarrow$ IA):** Routed strictly on `Metal3` with grounded side-shields. Trace lengths are $<20\,\mu\text{m}$, minimizing input parasitic capacitance and thermal noise.
- **Inter-stage signal routing:** Routed horizontally on `Metal2` and `Metal3`.
- **High-swing output trace (`output_buffer` $\rightarrow$ `s9_an[2]`):** Routed on upper `Metal4` with $<20\,\mu\text{m}$ length, keeping high $dV/dt$ traces completely separate from lower-metal input signals.

---

## 5. Inter-Block Routing Channels & Metal Stack Strategy

```
Layer Stack Allocation:
  • TopMetal1 (2.0 µm thick) : Global power/ground distribution rings (AVDD/AVSS, DVDD/DVSS).
  • Metal4    (0.49 µm thick) : Vertical decoder power straps, output driver line to s9_an[2], digital control trunks.
  • Metal3    (0.42 µm thick) : Horizontal analog signal trunks, dedicated analog pad connections (s9_an[*]).
  • Metal2    (0.42 µm thick) : Vertical inter-block routing, local intra-block wiring.
  • Metal1    (0.42 µm thick) : Standard cell follower rails, internal device routing.
```

### Dedicated Corridors:

1. **Input Feed Corridor (East Edge, $X \in [500.0, 537.15]\,\mu\text{m}$):**
   - Direct, low-impedance `Metal3` connection from `s9_an[0]` and `s9_an[1]` into `instramp_cmos5l`.
   - Secondary ESD lines (`s9_an_0_esd` at $Y \approx 53.6\,\mu\text{m}$, `s9_an_1_esd` at $Y \approx 163.6\,\mu\text{m}$) tap into internal clamp structures.
2. **Lower Lane Signal Corridor ($Y \in [60.0, 90.0]\,\mu\text{m}$):**
   - Direct differential signal handoff from `instramp_cmos5l` output ($X = 350.0$) Westward into `gain_stage_1` input ($X = 315.0$). Corridor width: **$35.0\,\mu\text{m}$**.
3. **Inter-Stage Turnaround Spine ($X \in [175.0, 210.0]\,\mu\text{m}$):**
   - Vertical routing lane carrying the output of `gain_stage_1` ($Y \approx 70.0$) northward across the isolation gap to the input of `gain_stage_2` ($Y \approx 205.0$).
   - Flanked by grounded shielding lines on `Metal2`/`Metal3`.
4. **Upper Lane Signal Corridor ($Y \in [200.0, 230.0]\,\mu\text{m}$):**
   - Direct single-ended signal handoff from `gain_stage_2` output ($X = 315.0$) Eastward into `output_buffer` input ($X = 440.0$).
5. **Digital Switch Control Bus Corridor ($X \in [90.0, 210.0]\,\mu\text{m}$):**
   - Emerges cleanly from the East edge of `gain_decoder_4b` ($X = 90.0$).
   - Carries 10 lines (`s1[4:0]`, `s1_b[4:0]`) horizontally to `gain_stage_1` and 10 lines (`s2[4:0]`, `s2_b[4:0]`) northward to `gain_stage_2` on `Metal2`/`Metal4`.
   - Runs orthogonally to sensitive analog nodes to eliminate capacitive digital-to-analog crosstalk.
6. **Central Bias Distribution Spine ($X \in [120.0, 170.0]\,\mu\text{m}$):**
   - Central location radiates matched current references northward to `gain_stage_2` and `output_buffer`, and southward to `gain_stage_1` and `instramp_cmos5l`.

---

## 6. Power Distribution Network (PDN) & Harness Pinout Schedule

### 6.1 Power Domain Partitioning

* **Analog Core Domain (`AVDD` / `AVSS`):**
  - Powers `instramp_cmos5l`, `gain_stage_1`, `gain_stage_2`, `output_buffer`, and `central_bias`.
  - Driven by the $3.3\,\text{V}$ harness rails (`vdd_3v3` / `vss_3v3` on West edge, with internal regulation to $1.2\text{--}1.5\,\text{V}$) or clean external supplies.
* **Digital Core Domain (`DVDD` / `DVSS`):**
  - Exclusively powers `gain_decoder_4b`.
  - Driven by harness $1.2\,\text{V}$ digital rails: `vdd_1v2` ($Y \in [1.5, 56.8]\,\mu\text{m}$) and `vss_1v2` ($Y \in [66.4, 96.4]\,\mu\text{m}$) on `Metal5`.
  - `TopMetal1` power distribution rails pass over the decoder and drop `TopVia1` contacts directly onto the macro's vertical `Metal4` `VPWR` and `VGND` straps.

### 6.2 Top-Level I/O Pin Schedule (`slot9_wrapper`)

| Signal Name                       | Direction |      Edge      | Coordinates $[X, Y]\,[\mu\text{m}]$ | Physical Layer | Functional Role                                                   |
| :-------------------------------- | :-------: | :------------: | :-----------------------------------: | :------------: | :---------------------------------------------------------------- |
| **`s9_an[0]`**            |   Input   | **East** |          $(537.15, 34.5)$          |   `Metal3`   | Primary Dedicated Analog Input: Non-Inverting (`VINP`)          |
| **`s9_an[1]`**            |   Input   | **East** |          $(537.15, 144.5)$          |   `Metal3`   | Primary Dedicated Analog Input: Inverting (`VINN`)              |
| **`s9_an[2]`**            |  Output  | **East** |          $(537.15, 254.5)$          |   `Metal3`   | Primary Dedicated Analog Output: Single-Ended Buffered (`VOUT`) |
| **`s9_an_0_esd`**         |   Inout   | **East** |          $(537.15, 53.6)$          |   `Metal3`   | Secondary ESD protection tap for `s9_an[0]`                     |
| **`s9_an_1_esd`**         |   Inout   | **East** |          $(537.15, 163.6)$          |   `Metal3`   | Secondary ESD protection tap for `s9_an[1]`                     |
| **`dig_in[0]`**           |   Input   | **West** |           $(0.00, 78.4)$           |   `Metal3`   | 4-bit Gain Selection LSB (`gain_sel[0]`)                        |
| **`dig_in[1]`**           |   Input   | **West** |           $(0.00, 78.8)$           |   `Metal3`   | 4-bit Gain Selection Bit 1 (`gain_sel[1]`)                      |
| **`dig_in[2]`**           |   Input   | **West** |           $(0.00, 79.2)$           |   `Metal3`   | 4-bit Gain Selection Bit 2 (`gain_sel[2]`)                      |
| **`dig_in[3]`**           |   Input   | **West** |           $(0.00, 79.7)$           |   `Metal3`   | 4-bit Gain Selection MSB (`gain_sel[3]`)                        |
| **`vdd_1v2`**             |  Supply  | **West** |    $X=0.0, \; Y \in [1.5, 56.8]$    |   `Metal5`   | $1.2\,\text{V}$ Digital Logic Core Power                        |
| **`vss_1v2`**             |  Ground  | **West** |   $X=0.0, \; Y \in [66.4, 96.4]$   |   `Metal5`   | $0.0\,\text{V}$ Digital Logic Core Ground                       |
| **`vdd_3v3`**             |  Supply  | **West** |  $X=0.0, \; Y \in [150.3, 256.1]$  |   `Metal5`   | $3.3\,\text{V}$ Analog Subsystem Power                          |
| **`vss_3v3`**             |  Ground  | **West** |  $X=0.0, \; Y \in [113.5, 143.5]$  |   `Metal5`   | $0.0\,\text{V}$ Analog Subsystem Ground (`AVSS`)              |
| **`ibias0` / `ibias1`** |   Input   | **West** |           $(0.00, 94.2)$           |   `Metal3`   | Shared harness current bias reference lines                       |
| **`vbias`**               |   Input   | **West** |           $(0.00, 95.2)$           |   `Metal3`   | Shared harness voltage bias reference line                        |
| **`dig_out[11:0]`**       |  Output  | **West** |   $X=0.0, \; Y \in [77.0, 78.0]$   |   `Metal3`   | Digital status outputs (tied to `12'b0` inside wrapper)         |
| **`analog_bus[3:0]`**     |   Inout   | **West** |  $X=0.0, \; Y \in [111.9, 114.0]$  |   `Metal3`   | Shared chip-level analog bus (disabled: `user_analog_ena = 0`)  |

---

## 7. Physical Signoff Verification Strategy

Prior to top-level tape-out freeze, `pgia_top` must satisfy the following physical signoff checklist:

1. **DRC Cleanliness (KLayout & Magic):**
   - Zero design rule violations against `ihp-sg13cmos5l.drc`.
   - Strict adherence to $\le \text{Metal4}$ for all signal routes.
   - Enforce minimum antenna ratios on all analog gate inputs through antenna diodes or metal hopping.
2. **LVS Matching (Netgen):**
   - Transistor-level matching of `pgia_top.gds` against the composite schematic netlist `pgia_top.spice`.
   - 100% matched devices and nets across both digital standard cells and custom analog blocks.
   - Verification of supply isolation (no illegal shorts between `vss_1v2` and `vss_3v3`).
3. **Post-Layout Parasitic Extraction (PEX) & Co-Simulation:**
   - Run C-only and R+C parasitic extraction using Magic / PEX scripts.
   - Verify that parasitic feedback capacitance from `VOUT` to `VINP`/`VINN` is $<0.1\,\text{fF}$.
   - Simulate transient switching across all 11 gain steps ($18\,\text{dB} \dots 78\,\text{dB}$) in ngspice with extracted parasitics.
4. **Slot 9 Wrapper Integration:**
   - Instantiate `pgia_top` inside `slot9_wrapper.mag` and `slot9_wrapper.v`.
   - Verify physical boundary alignment and pin overlap with zero DRC flags at the interface boundary.
