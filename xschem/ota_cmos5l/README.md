# OTA Specs and Performance

## Topology
<img width="862" height="728" alt="image" src="https://github.com/user-attachments/assets/93cbe3e7-4963-4372-8eb0-26019f4ba6d9" />

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
- P = 29.57uW
- Gain ($A_{ol}$) = 57.21 dB
- Phase Margin (PM) = 64.88 deg
- Gain Margin = 17.82 dB
- $f_3{dB}$ or fc = 4.02kHz
- UGB ft = 2.78 MHz
- PSD noise at 1mHz = $189.56 nV/\sqrt{Hz}$
- Vos = 124.4 uV - 2.3 mV (worst case at 1.5 V outside ICMR)

## Plots

<img width="750" height="631" alt="image" src="https://github.com/user-attachments/assets/5dc9a45c-70d2-4940-b5ca-1712d7e57a25" />

<img width="753" height="635" alt="image" src="https://github.com/user-attachments/assets/2d31245c-d720-4ee0-8aae-e30776df0af3" />

## Future Plan
- Defo add more gm on the input pair
- Automated characterization and reporting to this file for better viewing
- CACE?
- Move .param to core
- Automate physical metric log and the improtant ops
