# Output Buffer (`output_buffer`)

The `output_buffer` is a unity-gain analog voltage follower designed to isolate the PGIA second gain stage from external pin/pad parasitics and cable/probe loads on East dedicated pad `s9_an[2]` (`VOUT`).

It is implemented using the standardized, characterized, and layout-verified **`ota_cmos5l`** 2-stage Miller OTA operating on the **$1.2\,\text{V}$ analog supply** (`AVDD` / `AVSS`).

---

## 1. Architecture & Circuit Topology

```
                        output_buffer
              ┌─────────────────────────────────────┐
              │             ota_cmos5l              │
              │         ┌─────────────────┐         │
AVDD ─────────┼────────►│ VDD             │         │
AVSS ─────────┼────────►│ VSS             │         │
IBIAS ────────┼────────►│ IBIAS           │         │
              │         │                 │         │
VIN_BUF+ ─────┼────────►│ VINP       VOUT ├──┬──────┼──► VOUT
              │         │                 │  │      │
VIN_BUF- ─────┼────────►│ VINN            │  │      │
              │         └─────────────────┘  │      │
              │ (In follower mode, VIN_BUF- ◄┘      │
              │  connects externally to VOUT)       │
              └─────────────────────────────────────┘
```

### Subcircuit Pin Interface
```spice
.subckt output_buffer AVDD IBIAS VOUT VIN_BUF+ VIN_BUF- AVSS
```

| Pin | Type | Connection in System |
|:---|:---:|:---|
| **`AVDD`** | power | $1.2\,\text{V}$ Analog Core Power |
| **`AVSS`** | ground | $0\,\text{V}$ Analog Core Ground |
| **`IBIAS`** | in | $1.4\,\mu\text{A}$ nominal reference current from Central Bias |
| **`VIN_BUF+`** | in | Non-inverting input from Stage 2 (`V_OUT2`) |
| **`VIN_BUF-`** | in | Inverting feedback terminal (tied to `VOUT` for unity gain follower) |
| **`VOUT`** | out | Low-impedance buffered analog output terminal to pad `s9_an[2]` |

---

## 2. Characterization & Verification Results

Simulation conditions: $V_{AVDD} = 1.2\,\text{V}$, $V_{AVSS} = 0\,\text{V}$, $V_{CM} = 0.60\,\text{V}$, $I_{BIAS} = 1.4\,\mu\text{A}$, $C_L = 100\,\text{fF}$, $R_L = 100\,\text{M}\Omega$.

### Comparison with Deprecated 5T Buffer:

| Metric | Deprecated 5T HV Buffer | Updated `ota_cmos5l` Buffer | Improvement |
|:---|:---:|:---:|:---:|
| **Supply Voltage ($V_{AVDD}$)** | $3.30\,\text{V}$ | **$1.20\,\text{V}$** | Unified with PGIA core |
| **Common-Mode Bias ($V_{CM}$)** | $1.65\,\text{V}$ | **$0.60\,\text{V}$** | Native match with Stage 2 |
| **Total Quiescent Current** | $28.14\,\mu\text{A}$ | **$17.27\,\mu\text{A}$** | **$38.6\%$ lower current** |
| **Static Power Dissipation** | $92.86\,\mu\text{W}$ | **$20.72\,\mu\text{W}$** | **$4.48\times$ lower power** |
| **Systematic Offset Voltage ($V_{OS}$)** | $+14.83\,\text{mV}$ | **$+0.286\,\text{mV}$** | **$51.8\times$ lower offset** |
| **$-3\,\text{dB}$ Closed-Loop BW** | $>10.0\,\text{MHz}$ | **$3.55\,\text{MHz}$** | Optimal for instrumentation |
| **Gain Peaking** | $+0.053\,\text{dB}$ | **$+0.000\,\text{dB}$** | Perfectly flat response |
| **Linear Tracking Dynamic Range** | $0.20\text{--}3.10\,\text{V}$ ($3.3\,\text{V}$ rail) | **$0.20\text{--}0.85\,\text{V}$ ($1.2\,\text{V}$ rail)** | Error $< 1.5\,\text{mV}$ over $0.65\,\text{V}_{pp}$ |

### Detailed Performance Breakdown:

#### 1. AC Small-Signal Tracking
- **DC Gain:** $+0.0068\,\text{dB}$ ($1.0008\times$)
- **Gain @ $100\,\text{kHz}$:** $+0.0037\,\text{dB}$, phase shift $-2.07^\circ$
- **Gain @ $1\,\text{MHz}$:** $-0.2951\,\text{dB}$, phase shift $-20.45^\circ$
- **$-3\,\text{dB}$ Bandwidth:** $3.55\,\text{MHz}$

#### 2. DC Transfer Linearity ($0.2\,\text{V} \dots 1.0\,\text{V}$)
- $V_{in} = 0.20\,\text{V} \rightarrow V_{out} = 0.2005\,\text{V}$ (Error: $+0.537\,\text{mV}$)
- $V_{in} = 0.40\,\text{V} \rightarrow V_{out} = 0.4003\,\text{V}$ (Error: $+0.336\,\text{mV}$)
- $V_{in} = 0.60\,\text{V} \rightarrow V_{out} = 0.6003\,\text{V}$ (Error: $+0.286\,\text{mV}$)
- $V_{in} = 0.80\,\text{V} \rightarrow V_{out} = 0.8014\,\text{V}$ (Error: $+1.374\,\text{mV}$)
- $V_{in} = 0.90\,\text{V} \rightarrow V_{out} = 0.9029\,\text{V}$ (Error: $+2.931\,\text{mV}$)

#### 3. Small-Signal Transient Pulse Tracking
- Input step: $0.59\,\text{V} \to 0.61\,\text{V}$ ($20\,\text{mV}$ step, $1\,\mu\text{s}$ rise/fall).
- Output cleanly settles with monotonic tracking and zero ringing.
