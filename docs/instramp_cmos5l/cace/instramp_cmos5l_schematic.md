
# CACE Summary for instramp_cmos5l

**netlist source**: schematic

|      Parameter       |         Tool         |     Result      | Min Limit  |  Min Value   | Typ Target |  Typ Value   | Max Limit  |  Max Value   |  Status  |
| :------------------- | :------------------- | :-------------- | ---------: | -----------: | ---------: | -----------: | ---------: | -----------: | :------: |
| Closed-loop gain at 1 Hz | ngspice              | A_CL                 |             any |  17.765 dB |   18.0618 dB |  18.061 dB |          any |  18.262 dB |   Pass ✅    |
| Gain error vs 8 V/V  | ngspice              | A_ERR                |             any |  -0.297 dB |          any |  -0.000 dB |          any |   0.200 dB |   Pass ✅    |
| -3 dB bandwidth      | ngspice              | F3DB                 |             any | 208894.000 Hz |          any | 279254.000 Hz |          any | 361657.000 Hz |   Pass ✅    |
| 0 dB frequency       | ngspice              | F0DB                 |             any | 1506090.000 Hz |          any | 1987590.000 Hz |          any | 2539050.000 Hz |   Pass ✅    |
| Closed-loop phase at 0 dB | ngspice              | PH0                  |             any | -143.186 ° |          any | -139.829 ° |          any | -134.184 ° |   Pass ✅    |
| THD                  | ngspice              | THD_DB               |             any | -72.538 dB |          any | -63.520 dB |          any | -46.170 dB |   Pass ✅    |
| THD                  | ngspice              | THD_PCT              |             any |    0.024 % |          any |    0.067 % |          any |    0.491 % |   Pass ✅    |
| 2nd harmonic         | ngspice              | HD2_DB               |             any | -80.791 dB |          any | -64.979 dB |          any | -48.314 dB |   Pass ✅    |
| 3rd harmonic         | ngspice              | HD3_DB               |             any | -76.241 dB |          any | -69.230 dB |          any | -50.352 dB |   Pass ✅    |
| Output fundamental amplitude | ngspice              | VO1                  |             any |    0.192 V |          any |    0.200 V |          any |    0.204 V |   Pass ✅    |
| Differential gain @10 Hz | ngspice              | ADM_DC               |             any |  17.735 dB |          any |  18.039 dB |          any |  18.241 dB |   Pass ✅    |
| CMRR @10 Hz          | ngspice              | CMRR_DC              |             any |  41.798 dB |          any |  47.694 dB |          any |  52.303 dB |   Pass ✅    |
| CMRR @100 kHz        | ngspice              | CMRR_100K            |             any |  38.520 dB |          any |  44.356 dB |          any |  49.510 dB |   Pass ✅    |
| CMRR @1 MHz          | ngspice              | CMRR_1M              |             any |  21.311 dB |          any |  27.278 dB |          any |  32.934 dB |   Pass ✅    |
| Differential gain @10 Hz | ngspice              | ADM_DC               |             any |  17.735 dB |          any |  18.039 dB |          any |  18.241 dB |   Pass ✅    |
| PSRR @10 Hz          | ngspice              | PSRR_DC              |             any |  50.403 dB |          any |  72.884 dB |          any | 102.125 dB |   Pass ✅    |
| PSRR @100 kHz        | ngspice              | PSRR_100K            |             any |  50.344 dB |          any |  62.056 dB |          any |  66.067 dB |   Pass ✅    |
| PSRR @1 MHz          | ngspice              | PSRR_1M              |             any |  41.461 dB |          any |  44.243 dB |          any |  50.529 dB |   Pass ✅    |
| Input noise @10 Hz   | ngspice              | IRN_10               |             any | 2859.500 nV/rtHz |          any | 3453.580 nV/rtHz |          any | 4016.520 nV/rtHz |   Pass ✅    |
| Input noise @100 Hz  | ngspice              | IRN_100              |             any | 906.405 nV/rtHz |          any | 1094.970 nV/rtHz |          any | 1272.920 nV/rtHz |   Pass ✅    |
| Input noise @1 kHz   | ngspice              | IRN_1K               |             any | 293.349 nV/rtHz |          any | 354.553 nV/rtHz |          any | 411.250 nV/rtHz |   Pass ✅    |
| Input noise @10 kHz  | ngspice              | IRN_10K              |             any | 111.854 nV/rtHz |          any | 134.681 nV/rtHz |          any | 155.093 nV/rtHz |   Pass ✅    |
| Output noise @1 kHz  | ngspice              | ORN_1K               |             any | 2392.110 nV/rtHz |          any | 2837.670 nV/rtHz |          any | 3213.450 nV/rtHz |   Pass ✅    |
| Integrated output noise | ngspice              | ONOISE_TOT           |             any | 482.778 uV-rms |          any | 544.195 uV-rms |          any | 593.505 uV-rms |   Pass ✅    |
| In-band input-referred noise (Vn_out / gain) | ngspice              | INOISE_EQ            |             any | 59.204 uV-rms |          any | 67.899 uV-rms |          any | 75.955 uV-rms |   Pass ✅    |
| Output offset (Vcm - Vout) | ngspice              | VOS                  |             any |  -4.870 mV |          any |  -1.933 mV |          any |  -0.436 mV |   Pass ✅    |
| Output voltage       | ngspice              | VOUT                 |             any |    0.600 V |          any |    0.602 V |          any |    0.605 V |   Pass ✅    |
| Quiescent current    | ngspice              | IQ                   |             any |  48.004 uA |          any |  54.873 uA |          any |  59.750 uA |   Pass ✅    |
| Quiescent power      | ngspice              | PWR                  |             any |  57.605 uW |          any |  74.078 uW |          any |  89.625 uW |   Pass ✅    |
| Small-signal gain (transient) | ngspice              | TR_GAIN              |             any |    7.73179 |          any |    7.99988 |          any |    8.18719 |   Pass ✅    |
| Mean output level    | ngspice              | TR_VOUT_AVG          |             any |    0.600 V |          any |    0.602 V |          any |    0.605 V |   Pass ✅    |


## Plots

## ac_gain_A_CL_vs_temperature

![ac_gain_A_CL_vs_temperature](./instramp_cmos5l/schematic/ac_gain_A_CL_vs_temperature.png)

## ac_gain_F3DB_vs_temperature

![ac_gain_F3DB_vs_temperature](./instramp_cmos5l/schematic/ac_gain_F3DB_vs_temperature.png)

## ac_gain_A_CL_vs_vdd

![ac_gain_A_CL_vs_vdd](./instramp_cmos5l/schematic/ac_gain_A_CL_vs_vdd.png)

## thd_THD_DB_vs_temperature

![thd_THD_DB_vs_temperature](./instramp_cmos5l/schematic/thd_THD_DB_vs_temperature.png)

## cmrr_ADM_DC_vs_temperature

![cmrr_ADM_DC_vs_temperature](./instramp_cmos5l/schematic/cmrr_ADM_DC_vs_temperature.png)

## psrr_ADM_DC_vs_temperature

![psrr_ADM_DC_vs_temperature](./instramp_cmos5l/schematic/psrr_ADM_DC_vs_temperature.png)

## noise_IRN_10_vs_temperature

![noise_IRN_10_vs_temperature](./instramp_cmos5l/schematic/noise_IRN_10_vs_temperature.png)

## dc_op_VOS_vs_temperature

![dc_op_VOS_vs_temperature](./instramp_cmos5l/schematic/dc_op_VOS_vs_temperature.png)

## tran_small_TR_GAIN_vs_temperature

![tran_small_TR_GAIN_vs_temperature](./instramp_cmos5l/schematic/tran_small_TR_GAIN_vs_temperature.png)
