# Transmission Gate (`tgate`) Design & Characterization Note

## 1. Overview & Context

- **Block:** CMOS Transmission Gate (`tgate`)
- **Location:** `designs/libs/core_digital/tgate/`
- **Role in IP:** Serves as the analog switch for the programmable gain network:
  - **Coarse-Gain Stage (Stage 2):** 16 switches in switched-resistor feedback array controlled by 4-to-16 thermometer decoder (`D0-D3`).
  - **Fine-Gain Stage (Stage 3):** Switches in R-2R ladder network controlled by 6-bit fine driver (`D4-D9`).
- **Operating Domain:** 1.2 V Core/Digital domain (`DVDD` / `AVDD_1V2`, `DVSS` / `AVSS`).

---

## 2. Circuit Topology & Sizing

<!-- AUTO:schematic:tgate -->
![tgate schematic](../../docs/tgate/media/tgate_schematic.png)
<!-- /AUTO -->

The switch consists of a complementary NMOS and PMOS pair connected in parallel to ensure rail-to-rail signal transmission (0 V to 1.2 V).

### Transistor Sizing

| Instance     | Device Type      | Width ($W$) | Length ($L$) | Multiplier ($m$) | Substrate / Bulk |   |                  |
| :----------- | :--------------- | :-------------------------------------------------- | :--------------- | :- | :--------------- |
| **M1** | `sg13_lv_nmos` | 1.0 µm                                             | 0.13 µm         | 1 | `AVSS` (0 V)   |
| **M2** | `sg13_lv_pmos` | 2.5 µm                                             | 0.13 µm         | 1 | `AVDD` (1.2 V) |

### Subcircuit Interface

```spice
.subckt tgate IN AVSS AVDD EN ENB OUT
```

- **`IN` / `OUT`:** Bidirectional analog switch terminals.
- **`EN`:** Active-high gate drive for NMOS (1.2 V = ON, 0 V = OFF).
- **`ENB`:** Active-low gate drive for PMOS (0 V = ON, 1.2 V = OFF).
- **`AVDD` / `AVSS`:** Bulk bias rails (1.2 V and 0 V).

---

## 3. Testbench & Simulation Setup

- **Testbench Schematic:** `tb_tgate.sch` (`tb_tgate.spice`)
- **Stimulus:**
  - Common-mode DC voltage source `VCM` swept from 0 V to 1.2 V in 10 mV steps.
  - Test current source: $I_{\text{test}} = 10\,\mu\text{A}$ injected across `IN` and `OUT`.
  - Control signals set to full ON state: $\text{EN} = 1.2\text{ V}$, $\text{ENB} = 0\text{ V}$.
- **On-Resistance Calculation:**
  ```spice
  * Calculated in ngspice control block:
  let ron = (v(OUT) - v(IN)) / 10u
  plot ron title 'T-Gate On-Resistance vs Input Voltage' xlabel 'V_in (V)' ylabel 'R_on (Ohms)'
  ```

---

## 4. Simulation Results & Waveform

![T-Gate On-Resistance vs Input Voltage](.media/r_on.png)

### Key Metrics Summary

| Parameter                                        | Value                          | Condition / Mechanism                                                                             |
| :----------------------------------------------- | :----------------------------- | :------------------------------------------------------------------------------------------------ |
| **$R_{\text{on, min}}$ (Low Rail)**      | $\approx 700\,\Omega$        | $V_{\text{in}} = 0\text{ V}$ (NMOS strongly in triode, $V_{GS} = 1.2\text{ V}$)               |
| **$R_{\text{on, min}}$ (High Rail)**     | $\approx 800\,\Omega$        | $V_{\text{in}} = 1.2\text{ V}$ (PMOS strongly in triode, $|V_{GS}| = 1.2\text{ V}$)           |
| **$R_{\text{on, max}}$ (Mid-Rail Peak)** | $\approx 4.6\text{ k}\Omega$ | $V_{\text{in}} \approx 0.56\text{ V}$ (Both devices experience reduced overdrive & body effect) |
| **Usable Dynamic Range**                   | Full 0 V – 1.2 V              | Fully conductive across the entire supply range                                                   |

---

## 5. Critical Engineering Notes & Integration Rules

1. **Bulk Bias Warning:**
   - Transistors are 1.2 V thin-oxide devices (`sg13_lv_*`).
   - PMOS bulk (`AVDD`) **must be connected to 1.2 V** (not 3.3 V analog supply). Connecting to 3.3 V will cause severe threshold shift via body effect ($V_{BS} > 2.5\text{ V}$) and risk oxide/junction degradation.
2. **Impact on Resistor Ladder Linearity:**
   - Peak on-resistance is $\approx 4.6\text{ k}\Omega$.
   - Unit resistor values in the coarse ladder and R-2R ladder must be chosen sufficiently high ($\ge 100\text{ k}\Omega$) or compensated so switch resistance variations do not degrade 10-bit gain accuracy.
3. **Control Signals & Decoder Requirements:**
   - Decoder outputs (`EN` and `ENB`) must transition synchronously to minimize dynamic charge injection and clock feedthrough.
   - Buffers/inverters driving `tgate` must provide sufficient drive strength for fast gain-switching settling.

---

## 6. Current File Locations

- **Schematic:** `designs/libs/core_digital/tgate/tgate.sch`
- **Symbol:** `designs/libs/core_digital/tgate/tgate.sym`
- **Testbench:** `designs/libs/core_digital/tgate/tb_tgate.sch`
- **Simulations:** `designs/libs/core_digital/tgate/simulations/tb_tgate_dc.raw`
