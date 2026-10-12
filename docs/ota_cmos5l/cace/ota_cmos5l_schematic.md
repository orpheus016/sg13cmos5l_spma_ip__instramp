
# CACE Summary for ota_cmos5l

**netlist source**: schematic

|      Parameter       |         Tool         |     Result      | Min Limit  |  Min Value   | Typ Target |  Typ Value   | Max Limit  |  Max Value   |  Status  |
| :------------------- | :------------------- | :-------------- | ---------: | -----------: | ---------: | -----------: | ---------: | -----------: | :------: |
| DC gain              | ngspice              | A0                   |           50 dB |  55.594 dB |          any |  57.873 dB |          any |  59.484 dB |   Pass ✅    |
| -3 dB frequency      | ngspice              | F3DB                 |             any | 3075.780 Hz |          any | 3697.540 Hz |          any | 4351.160 Hz |   Pass ✅    |
| Unity-gain frequency | ngspice              | UGF                  |    1000000.0 Hz | 2109530.000 Hz |          any | 2699830.000 Hz |          any | 3445080.000 Hz |   Pass ✅    |
| Phase margin         | ngspice              | PM                   |            60 ° |   55.635 ° |          any |   60.647 ° |          any |   66.901 ° |   Fail ❌    |
| Gain margin          | ngspice              | GM                   |             any |  14.131 dB |          any |  17.161 dB |          any |  21.660 dB |   Pass ✅    |
| Gain-bandwidth product (A0 x f3dB) | ngspice              | GBW                  |             any | 2259320.000 Hz |          any | 2861650.000 Hz |          any | 3610750.000 Hz |   Pass ✅    |
| Input noise @100 Hz  | ngspice              | IRN_100              |             any | 505.113 nV/rtHz |          any | 610.251 nV/rtHz |          any | 708.507 nV/rtHz |   Pass ✅    |
| Input noise @1 kHz   | ngspice              | IRN_1K               |             any | 163.111 nV/rtHz |          any | 197.006 nV/rtHz |          any | 228.600 nV/rtHz |   Pass ✅    |
| Input noise @10 kHz  | ngspice              | IRN_10K              |             any | 61.334 nV/rtHz |          any | 74.134 nV/rtHz |          any | 86.597 nV/rtHz |   Pass ✅    |
| Input noise @1 MHz   | ngspice              | IRN_1M               |             any | 45.977 nV/rtHz |          any | 66.977 nV/rtHz |          any | 98.969 nV/rtHz |   Pass ✅    |
| Output noise @1 kHz  | ngspice              | ORN_1K               |             any | 163.121 nV/rtHz |          any | 197.268 nV/rtHz |          any | 228.444 nV/rtHz |   Pass ✅    |
| Integrated input noise | ngspice              | INOISE_TOT           |             any | 2675.580 uV-rms |          any | 2863.530 uV-rms |          any | 3030.460 uV-rms |   Pass ✅    |
| Integrated output noise | ngspice              | ONOISE_TOT           |             any | 224.287 uV-rms |          any | 290.224 uV-rms |          any | 357.332 uV-rms |   Pass ✅    |
| Input offset voltage | ngspice              | VOS                  |           -1 mV |  -0.553 mV |          any |  -0.213 mV |         1 mV |  -0.046 mV |   Pass ✅    |
| Quiescent current    | ngspice              | IQ                   |             any |  16.008 uA |          any |  18.293 uA |          any |  19.919 uA |   Pass ✅    |
| Quiescent power      | ngspice              | PWR                  |             any |  19.209 uW |          any |  24.696 uW |        50 uW |  29.878 uW |   Pass ✅    |
| Output voltage       | ngspice              | VOUT                 |             any |    0.600 V |          any |    0.600 V |          any |    0.601 V |   Pass ✅    |
| Gain error (1 - dVout/dVin) | ngspice              | GAIN_ERR             |             any |   -0.218 % |          any |    0.044 % |          any |    0.084 % |   Pass ✅    |
| Gain tempco (ppm per °C) | ngspice              | GAIN_TC              |             any |  0.249 ppm |          any |  1.301 ppm |          any |  2.043 ppm |   Pass ✅    |
| Mean follower gain   | ngspice              | G_MEAN               |             any |  0.999 V/V |          any |  1.000 V/V |          any |  1.002 V/V |   Pass ✅    |
| CMRR @10 Hz          | ngspice              | CMRR_DC              |             any |  53.977 dB |          any |  64.868 dB |          any |  84.357 dB |   Pass ✅    |
| CMRR @100 kHz        | ngspice              | CMRR_100K            |             any |  27.317 dB |          any |  29.294 dB |          any |  31.224 dB |   Pass ✅    |
| CMRR @1 MHz          | ngspice              | CMRR_1M              |             any |   6.976 dB |          any |   9.152 dB |          any |  11.236 dB |   Pass ✅    |
| PSRR @10 Hz          | ngspice              | PSRR_DC              |             any |  51.479 dB |          any |  73.886 dB |          any | 105.355 dB |   Pass ✅    |
| PSRR @100 kHz        | ngspice              | PSRR_100K            |             any |  51.349 dB |          any |  62.907 dB |          any |  66.926 dB |   Pass ✅    |
| PSRR @1 MHz          | ngspice              | PSRR_1M              |             any |  41.813 dB |          any |  44.032 dB |          any |  48.104 dB |   Pass ✅    |
| Lower ICMR bound     | ngspice              | ICMR_MIN             |             any |    0.060 V |          any |    0.078 V |          any |    0.096 V |   Pass ✅    |
| Upper ICMR bound     | ngspice              | ICMR_MAX             |             any |    0.991 V |          any |    1.180 V |          any |    1.369 V |   Pass ✅    |
| ICMR span            | ngspice              | ICMR_SPAN            |             any |    0.900 V |          any |    1.103 V |          any |    1.297 V |   Pass ✅    |
| Delay (50 %)         | ngspice              | T_DELAY              |             any |  50.698 ns |          any |  67.558 ns |          any |  86.179 ns |   Pass ✅    |
| Rise time (10-90 %)  | ngspice              | T_RISE               |             any |  65.799 ns |          any |  79.484 ns |          any |  94.454 ns |   Pass ✅    |
| Overshoot            | ngspice              | OVERSHOOT            |             any |    4.413 % |          any |    9.871 % |          any |   14.731 % |   Pass ✅    |
| Settling time 1 %    | ngspice              | TS_1PCT              |             any | 100.072 ns |          any | 123.057 ns |          any | 388.205 ns |   Pass ✅    |
| Settling time 0.1 %  | ngspice              | TS_01PCT             |             any | 102.145 ns |          any | 365.746 ns |          any | 455.678 ns |   Pass ✅    |
| Positive slew rate   | ngspice              | SR_POS               |             any | 314969.000 V/s |          any | 1945790.000 V/s |          any | 2239030.000 V/s |   Pass ✅    |
| Negative slew rate   | ngspice              | SR_NEG               |             any | 2151780.000 V/s |          any | 2430660.000 V/s |          any | 2678770.000 V/s |   Pass ✅    |
| Rise time (10-90 %)  | ngspice              | T_RISE               |             any | 214.378 ns |          any | 246.686 ns |          any | 1523.960 ns |   Pass ✅    |
| Fall time (90-10 %)  | ngspice              | T_FALL               |             any | 179.187 ns |          any | 197.477 ns |          any | 223.071 ns |   Pass ✅    |
| Propagation delay tpLH | ngspice              | T_PLH                |             any | 153.229 ns |          any | 182.424 ns |          any | 208.093 ns |   Pass ✅    |
| Propagation delay tpHL | ngspice              | T_PHL                |             any | 121.768 ns |          any | 141.929 ns |          any | 161.907 ns |   Pass ✅    |
| Input offset voltage | ngspice              | VOS                  |             any |  -1.867 mV |          any |  -0.066 mV |          any |   2.551 mV |   Pass ✅    |
| CMRR @10 Hz          | ngspice              | CMRR_DC              |             any |  48.051 dB |          any |  63.006 dB |          any | 108.395 dB |   Pass ✅    |
| PSRR @10 Hz          | ngspice              | PSRR_DC              |             any |  46.691 dB |          any |  57.302 dB |          any |  75.805 dB |   Pass ✅    |


## Plots

## ac_response_A0_vs_temperature

![ac_response_A0_vs_temperature](./ota_cmos5l/schematic/ac_response_A0_vs_temperature.png)

## ac_response_UGF_vs_temperature

![ac_response_UGF_vs_temperature](./ota_cmos5l/schematic/ac_response_UGF_vs_temperature.png)

## ac_response_PM_vs_temperature

![ac_response_PM_vs_temperature](./ota_cmos5l/schematic/ac_response_PM_vs_temperature.png)

## ac_response_PM_vs_vdd

![ac_response_PM_vs_vdd](./ota_cmos5l/schematic/ac_response_PM_vs_vdd.png)

## cmrr_CMRR_DC_vs_temperature

![cmrr_CMRR_DC_vs_temperature](./ota_cmos5l/schematic/cmrr_CMRR_DC_vs_temperature.png)

## psrr_PSRR_DC_vs_temperature

![psrr_PSRR_DC_vs_temperature](./ota_cmos5l/schematic/psrr_PSRR_DC_vs_temperature.png)

## icmr_ICMR_SPAN_vs_vdd

![icmr_ICMR_SPAN_vs_vdd](./ota_cmos5l/schematic/icmr_ICMR_SPAN_vs_vdd.png)
