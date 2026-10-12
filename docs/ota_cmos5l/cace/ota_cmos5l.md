# ota_cmos5l

- Description: PMOS-input two-stage Miller OTA
- PDK: ihp-sg13cmos5l

## Authorship

- Designer: SPMA
- Created: October 9, 2026
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
  + Description: Bias current input
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
  + Description: Input common mode voltage
  + Display: Vcm
  + Unit: V
  + Typical: 0.6
- ib
  + Description: Bias current
  + Display: Ib
  + Unit: uA
  + Typical: 1.4
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

![Symbol of ota_cmos5l](ota_cmos5l_symbol.svg)

## Schematic

![Schematic of ota_cmos5l](ota_cmos5l_schematic.svg)
