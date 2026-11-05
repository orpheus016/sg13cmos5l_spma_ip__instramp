
# CACE Summary for central_bias

**netlist source**: schematic

|      Parameter       |         Tool         |     Result      | Min Limit  |  Min Value   | Typ Target |  Typ Value   | Max Limit  |  Max Value   |  Status  |
| :------------------- | :------------------- | :-------------- | ---------: | -----------: | ---------: | -----------: | ---------: | -----------: | :------: |
| Current into the instrumentation amplifier (sink) | ngspice              | I_IA                 |             any |   2.611 uA |       4.4 uA |   4.444 uA |          any |   6.782 uA |   Pass ✅    |
| Current into the output buffer (sink) | ngspice              | I_BUF                |             any |   0.870 uA |      1.47 uA |   1.481 uA |          any |   2.261 uA |   Pass ✅    |
| Current into gain stage 1 (source) | ngspice              | I_G1                 |             any |   0.664 uA |      1.08 uA |   1.080 uA |          any |   1.618 uA |   Pass ✅    |
| Current into gain stage 2 (source) | ngspice              | I_G2                 |             any |   0.664 uA |      1.08 uA |   1.080 uA |          any |   1.618 uA |   Pass ✅    |
| Ratio I_IA / ibias0  | ngspice              | R_IA                 |         3.1 A/A |  3.547 A/A |      4.4 A/A |  4.461 A/A |      5.7 A/A |  5.678 A/A |   Pass ✅    |
| Ratio I_BUF / ibias0 | ngspice              | R_BUF                |         1.0 A/A |  1.182 A/A |     1.47 A/A |  1.487 A/A |      1.9 A/A |  1.893 A/A |   Pass ✅    |
| Ratio I_G / ibias0 (mean of the two stages) | ngspice              | R_G                  |        0.75 A/A |  0.908 A/A |     1.08 A/A |  1.096 A/A |      1.4 A/A |  1.344 A/A |   Pass ✅    |
| Stage 1 / stage 2 current difference | ngspice              | ERR_G                |            -3 % |   -0.000 % |          0 % |    0.000 % |          3 % |    0.000 % |   Pass ✅    |
| Supply power of the block (with the loads) | ngspice              | PWR                  |             any |   5.979 uW |          any |  11.391 uW |          any |  21.038 uW |   Pass ✅    |
| Current into the instrumentation amplifier (sink) | ngspice              | I_IA                 |             any |          ​ |          any |          ​ |          any |          ​ |   Skip 🟧    |
| Current into the output buffer (sink) | ngspice              | I_BUF                |             any |          ​ |          any |          ​ |          any |          ​ |   Skip 🟧    |
| Current into gain stage 1 (source) | ngspice              | I_G1                 |             any |          ​ |          any |          ​ |          any |          ​ |   Skip 🟧    |
| Current into gain stage 2 (source) | ngspice              | I_G2                 |             any |          ​ |          any |          ​ |          any |          ​ |   Skip 🟧    |
| Ratio I_IA / ibias0  | ngspice              | R_IA                 |             any |          ​ |          any |          ​ |          any |          ​ |   Skip 🟧    |
| Ratio I_BUF / ibias0 | ngspice              | R_BUF                |             any |          ​ |          any |          ​ |          any |          ​ |   Skip 🟧    |
| Ratio I_G / ibias0 (mean of the two stages) | ngspice              | R_G                  |             any |          ​ |          any |          ​ |          any |          ​ |   Skip 🟧    |
| Stage 1 / stage 2 current difference | ngspice              | ERR_G                |             any |          ​ |          any |          ​ |          any |          ​ |   Skip 🟧    |


## Plots

## currents_I_IA_vs_temperature

![currents_I_IA_vs_temperature](./central_bias/schematic/currents_I_IA_vs_temperature.png)

## currents_I_BUF_vs_temperature

![currents_I_BUF_vs_temperature](./central_bias/schematic/currents_I_BUF_vs_temperature.png)

## currents_I_G1_vs_ib0

![currents_I_G1_vs_ib0](./central_bias/schematic/currents_I_G1_vs_ib0.png)

## currents_R_IA_vs_corner

![currents_R_IA_vs_corner](./central_bias/schematic/currents_R_IA_vs_corner.png)
