
# CACE Summary for pgia_top

**netlist source**: schematic

|      Parameter       |         Tool         |     Result      | Min Limit  |  Min Value   | Typ Target |  Typ Value   | Max Limit  |  Max Value   |  Status  |
| :------------------- | :------------------- | :-------------- | ---------: | -----------: | ---------: | -----------: | ---------: | -----------: | :------: |
| Closed-loop gain @1 kHz | ngspice              | A_CL                 |             any | -180.218 dB |     18.06 dB |  26.226 dB |          any |  77.481 dB |   Pass ✅    |
| Gain step error vs target | ngspice              | A_ERR                |             any | -258.486 dB |          any |  -3.804 dB |          any |  20.668 dB |   Pass ✅    |
| -3 dB bandwidth      | ngspice              | F3DB                 |         1000 Hz | 1422.560 Hz |          any | 207272.000 Hz |          any | 93620400.000 Hz |   Pass ✅    |
| 0 dB frequency       | ngspice              | F0DB                 |             any | 2368.360 Hz |          any | 2605740.000 Hz |          any | 10000000.000 Hz |   Pass ✅    |
| Phase @1 kHz         | ngspice              | PH_1K                |             any | -179.899 ° |          any |   -0.398 ° |          any |  179.815 ° |   Pass ✅    |
| Input pseudo-resistor | ngspice              | R_PSEUDO             |          1 GOhm | 3.803 GOhm |      15 GOhm | 13.656 GOhm |          any | 46.053 GOhm |   Pass ✅    |
| Output offset voltage | ngspice              | VOS                  |             any |   0.011 mV |      1.08 mV |  78.923 mV |          any | 587.698 mV |   Pass ✅    |
| IA output DC voltage | ngspice              | V_IA                 |             any |    0.600 V |        0.6 V |    0.602 V |          any |    0.611 V |   Pass ✅    |
| Stage 1 output DC voltage | ngspice              | V_ST1                |             any |    0.270 V |        0.6 V |    0.562 V |          any |    0.915 V |   Pass ✅    |
| Stage 2 output DC voltage | ngspice              | V_ST2                |             any |    0.000 V |        0.6 V |    0.637 V |          any |    1.500 V |   Pass ✅    |
| DC output voltage    | ngspice              | VOUT                 |             any |    0.012 V |        0.6 V |    0.636 V |          any |    1.090 V |   Pass ✅    |
| Analog supply current | ngspice              | I_AVDD               |             any | 169.901 uA |       216 uA | 213.755 uA |       400 uA | 254.745 uA |   Pass ✅    |
| Digital supply current | ngspice              | I_VPWR               |             any |   0.001 uA |     0.014 uA |   0.020 uA |       1.0 uA |   0.478 uA |   Pass ✅    |
| Total quiescent current | ngspice              | IQ_TOT               |             any | 169.907 uA |       216 uA | 213.774 uA |       400 uA | 254.896 uA |   Pass ✅    |
| Total DC power       | ngspice              | PWR                  |             any | 183.500 uW |       260 uW | 257.108 uW |       500 uW | 382.344 uW |   Pass ✅    |
| Output peak-to-peak  | ngspice              | VPP_OUT              |             any |   0.000 mV |          any |   1.962 mV |          any |  72.896 mV |   Pass ✅    |
| Effective voltage gain | ngspice              | EFF_GAIN             |             any |  0.000 V/V |          any | 49.052 V/V |          any | 1822.400 V/V |   Pass ✅    |


## Plots

## ac_gain_A_CL_vs_temperature

![ac_gain_A_CL_vs_temperature](./pgia_top/schematic/ac_gain_A_CL_vs_temperature.png)

## ac_gain_F3DB_vs_temperature

![ac_gain_F3DB_vs_temperature](./pgia_top/schematic/ac_gain_F3DB_vs_temperature.png)

## ac_gain_A_CL_vs_gain_code

![ac_gain_A_CL_vs_gain_code](./pgia_top/schematic/ac_gain_A_CL_vs_gain_code.png)

## ac_gain_R_PSEUDO_vs_temperature

![ac_gain_R_PSEUDO_vs_temperature](./pgia_top/schematic/ac_gain_R_PSEUDO_vs_temperature.png)

## dc_op_VOS_vs_temperature

![dc_op_VOS_vs_temperature](./pgia_top/schematic/dc_op_VOS_vs_temperature.png)

## dc_op_PWR_vs_temperature

![dc_op_PWR_vs_temperature](./pgia_top/schematic/dc_op_PWR_vs_temperature.png)

## dc_op_IQ_TOT_vs_vdd

![dc_op_IQ_TOT_vs_vdd](./pgia_top/schematic/dc_op_IQ_TOT_vs_vdd.png)

## tran_VPP_OUT_vs_gain_code

![tran_VPP_OUT_vs_gain_code](./pgia_top/schematic/tran_VPP_OUT_vs_gain_code.png)

## tran_EFF_GAIN_vs_gain_code

![tran_EFF_GAIN_vs_gain_code](./pgia_top/schematic/tran_EFF_GAIN_vs_gain_code.png)
