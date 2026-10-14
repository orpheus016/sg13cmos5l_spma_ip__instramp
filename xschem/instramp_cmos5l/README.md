# OTA Specs and Performance

## Topology
<!-- AUTO:schematic:instramp_cmos5l -->
![instramp_cmos5l schematic](../../docs/instramp_cmos5l/media/instramp_cmos5l_schematic.png)
<!-- /AUTO -->

## Physical Spec
```ngspice
.param lbias=0.15u wbias=0.15u
.param m6=1 m7=4 m8=8
.param linpair=3u winpair=20u
.param lload=5u wload=10u
.param lcs=3u wcs=20u
.param Cc=2p
```

## Metrics
- Offset: 118.4uV
- Closed Loop Gain: 18.0613dB
- Gain Offset (dB): 0,0004997 dB
- Gain Offset (%): 0.005753%

## Plots

TBA

## Future Plan

TBA
