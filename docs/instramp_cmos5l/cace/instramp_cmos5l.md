# instramp_cmos5l

- Description: Three-OTA instrumentation amplifier, closed-loop gain 8 V/V (18.0618 dB)
- PDK: ihp-sg13cmos5l

## Authorship

- Designer: SPMA
- Created: October 13, 2026
- License: MIT
- Company: None
- Last modified: None

## Pins

- VDD
  + Description: Positive analog power supply
  + Type: power
  + Direction: inout
  + Vmin: 1.2
  + Vmax: 1.5
- VSS
  + Description: Analog ground
  + Type: ground
  + Direction: inout
- IBIAS
  + Description: Bias current input (shared by the three OTAs, 1.4 uA each)
  + Type: signal
  + Direction: input
- VINP
  + Description: Non-inverting input
  + Type: signal
  + Direction: input
- VINN
  + Description: Inverting input
  + Type: signal
  + Direction: input
- CM
  + Description: Common-mode reference (input resistor divider centre)
  + Type: signal
  + Direction: input
- VOUT
  + Description: Output
  + Type: signal
  + Direction: output

## Default Conditions

- vdd
  + Description: Analog power supply voltage
  + Display: Vdd
  + Unit: V
  + Typical: 1.2
- vcm
  + Description: Input and CM pin common-mode voltage
  + Display: Vcm
  + Unit: V
  + Typical: 0.6
- ib
  + Description: Total bias current (three OTAs)
  + Display: Ib
  + Unit: uA
  + Typical: 4.2
- fin
  + Description: Input sine frequency for THD
  + Display: Fin
  + Unit: kHz
  + Typical: 1
- vin_amp
  + Description: Differential input sine amplitude (peak) for THD
  + Display: Vin amp
  + Unit: mV
  + Typical: 25
- cl
  + Description: Output load capacitance
  + Display: CLoad
  + Unit: pF
  + Typical: 3
- corner
  + Description: Process corner
  + Display: Corner
  + Typical: tt
- rcorner
  + Description: Resistor corner (res_<rcorner> section of cornerRES.lib)
  + Display: Rcorner
  + Typical: typ
- temperature
  + Description: Ambient temperature
  + Display: Temp
  + Unit: °C
  + Typical: 27

## Symbol

![Symbol of instramp_cmos5l](instramp_cmos5l_symbol.svg)

## Schematic

![Schematic of instramp_cmos5l](instramp_cmos5l_schematic.svg)
