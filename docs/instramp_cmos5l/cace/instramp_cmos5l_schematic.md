
# CACE Summary for instramp_cmos5l

**netlist source**: schematic

|      Parameter       |         Tool         |     Result      | Min Limit  |  Min Value   | Typ Target |  Typ Value   | Max Limit  |  Max Value   |  Status  |
| :------------------- | :------------------- | :-------------- | ---------: | -----------: | ---------: | -----------: | ---------: | -----------: | :------: |
| Closed-loop gain at 1 Hz | ngspice              | A_CL                 |             any |  17.765 dB |   18.0618 dB |  18.061 dB |          any |  18.262 dB |   Pass ✅    |
| Gain error vs 8 V/V  | ngspice              | A_ERR                |             any |  -0.297 dB |          any |  -0.000 dB |          any |   0.200 dB |   Pass ✅    |
| -3 dB bandwidth      | ngspice              | F3DB                 |             any | 208893.000 Hz |          any | 279254.000 Hz |          any | 361654.000 Hz |   Pass ✅    |
| 0 dB frequency       | ngspice              | F0DB                 |             any | 1506090.000 Hz |          any | 1987590.000 Hz |          any | 2539050.000 Hz |   Pass ✅    |
| Closed-loop phase at 0 dB | ngspice              | PH0                  |             any | -143.186 ° |          any | -139.829 ° |          any | -134.184 ° |   Pass ✅    |
| THD                  | ngspice              | THD_DB               |             any | -72.538 dB |          any | -63.520 dB |          any | -46.170 dB |   Pass ✅    |
| THD                  | ngspice              | THD_PCT              |             any |    0.024 % |          any |    0.067 % |          any |    0.491 % |   Pass ✅    |
| 2nd harmonic         | ngspice              | HD2_DB               |             any | -80.791 dB |          any | -64.979 dB |          any | -48.314 dB |   Pass ✅    |
| 3rd harmonic         | ngspice              | HD3_DB               |             any | -76.241 dB |          any | -69.230 dB |          any | -50.352 dB |   Pass ✅    |
| Output fundamental amplitude | ngspice              | VO1                  |             any |    0.192 V |          any |    0.200 V |          any |    0.204 V |   Pass ✅    |


## Plots

## ac_gain_A_CL_vs_temperature

![ac_gain_A_CL_vs_temperature](./instramp_cmos5l/schematic/ac_gain_A_CL_vs_temperature.png)

## ac_gain_F3DB_vs_temperature

![ac_gain_F3DB_vs_temperature](./instramp_cmos5l/schematic/ac_gain_F3DB_vs_temperature.png)

## ac_gain_A_CL_vs_vdd

![ac_gain_A_CL_vs_vdd](./instramp_cmos5l/schematic/ac_gain_A_CL_vs_vdd.png)

## thd_THD_DB_vs_temperature

![thd_THD_DB_vs_temperature](./instramp_cmos5l/schematic/thd_THD_DB_vs_temperature.png)
