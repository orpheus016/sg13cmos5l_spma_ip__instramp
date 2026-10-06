v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 600 -800 640 -800 {lab=#net1}
N 600 -800 600 -680 {lab=#net1}
N 920 -840 920 -760 {lab=#net2}
N 880 -840 920 -840 {lab=#net2}
N 600 -330 640 -330 {lab=#net3}
N 600 -330 600 -210 {lab=#net3}
N 600 -210 920 -210 {lab=#net3}
N 920 -370 1000 -370 {lab=#net4}
N 920 -840 1000 -840 {lab=#net2}
N 1060 -840 1120 -840 {lab=#net5}
N 1120 -840 1120 -570 {lab=#net5}
N 1120 -570 1320 -570 {lab=#net5}
N 1060 -370 1180 -370 {lab=#net6}
N 1180 -650 1180 -370 {lab=#net6}
N 1180 -650 1320 -650 {lab=#net6}
N 1180 -370 1180 -320 {lab=#net6}
N 1180 -260 1180 -210 {lab=CM}
N 1180 -210 1280 -210 {lab=CM}
N 1120 -940 1220 -940 {lab=#net5}
N 1280 -940 1640 -940 {lab=#net7}
N 1640 -720 1640 -610 {lab=#net8}
N 1560 -610 1640 -610 {lab=#net8}
N 1640 -610 1700 -610 {lab=#net8}
N 1760 -610 1820 -610 {lab=VOUT}
N 500 -410 640 -410 {lab=VINP}
N 720 -620 720 -500 {lab=vdd}
N 720 -1090 720 -970 {lab=vdd}
N 1400 -860 1400 -740 {lab=vdd}
N 1120 -940 1120 -840 {lab=#net5}
N 1640 -940 1640 -780 {lab=#net7}
N 760 -1090 760 -970 {lab=vss}
N 760 -620 760 -500 {lab=vss}
N 1440 -860 1440 -740 {lab=vss}
N 500 -880 640 -880 {lab=VINN}
N 500 -880 500 -800 {lab=VINN}
N 460 -880 500 -880 {lab=VINN}
N 500 -490 500 -410 {lab=VINP}
N 500 -740 500 -550 {lab=vcm}
N 460 -410 500 -410 {lab=VINP}
N 600 -680 920 -680 {lab=#net1}
N 920 -700 920 -680 {lab=#net1}
N 920 -230 920 -210 {lab=#net3}
N 920 -370 920 -290 {lab=#net4}
N 880 -370 920 -370 {lab=#net4}
N 800 -620 800 -500 {lab=ibias}
N 1480 -860 1480 -740 {lab=ibias}
N 800 -1090 800 -970 {lab=ibias}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/ota_cmos5l/ota_cmos5l.sym} 760 -370 0 0 {name=x1}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/ota_cmos5l/ota_cmos5l.sym} 760 -840 0 0 {name=x2}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/ota_cmos5l/ota_cmos5l.sym} 1440 -610 0 0 {name=x3}
C {sg13cmos5l_pr/rhigh.sym} 1030 -370 3 0 {name=R1
w=0.5e-6
l=2e-6
model=rhigh
body=sub!
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {sg13cmos5l_pr/rhigh.sym} 1030 -840 3 0 {name=R2
w=0.5e-6
l=2e-6
model=rhigh
body=sub!
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {sg13cmos5l_pr/rhigh.sym} 1180 -290 0 0 {name=R3
w=0.5e-6
l=8*2.23e-6
model=rhigh
body=sub!
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {sg13cmos5l_pr/rhigh.sym} 1250 -940 3 0 {name=R4
w=0.5e-6
l=8*2.23e-6
model=rhigh
body=sub!
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {ammeter.sym} 1640 -750 0 0 {name=Vmeas savecurrent=true spice_ignore=0}
C {ammeter.sym} 1730 -610 3 0 {name=Vmeas1 savecurrent=true spice_ignore=0}
C {lab_wire.sym} 760 -620 3 0 {name=p1 sig_type=std_logic lab=vss}
C {lab_wire.sym} 720 -620 3 0 {name=p2 sig_type=std_logic lab=vdd}
C {lab_wire.sym} 760 -1010 3 0 {name=p3 sig_type=std_logic lab=vss}
C {lab_wire.sym} 720 -1010 3 0 {name=p4 sig_type=std_logic lab=vdd}
C {lab_wire.sym} 1440 -860 3 0 {name=p5 sig_type=std_logic lab=vss}
C {lab_wire.sym} 1400 -860 3 0 {name=p6 sig_type=std_logic lab=vdd}
C {iopin.sym} 720 -1090 3 0 {name=p7 lab=VDD}
C {lab_wire.sym} 1480 -860 3 0 {name=p8 sig_type=std_logic lab=ibias}
C {lab_wire.sym} 800 -620 3 0 {name=p9 sig_type=std_logic lab=ibias}
C {lab_wire.sym} 800 -1010 3 0 {name=p10 sig_type=std_logic lab=ibias}
C {iopin.sym} 800 -1090 3 0 {name=p11 lab=IBIAS}
C {iopin.sym} 760 -1090 3 0 {name=p12 lab=VSS}
C {iopin.sym} 1280 -210 0 0 {name=p13 lab=CM}
C {iopin.sym} 1820 -610 0 0 {name=p14 lab=VOUT}
C {iopin.sym} 460 -880 2 0 {name=p15 lab=VINN}
C {iopin.sym} 460 -410 2 0 {name=p16 lab=VINP}
C {res.sym} 500 -770 0 0 {name=R5
value=10MEG
footprint=1206
device=resistor
m=1}
C {res.sym} 500 -520 0 0 {name=R6
value=10MEG
footprint=1206
device=resistor
m=1}
C {lab_wire.sym} 500 -630 2 0 {name=p17 sig_type=std_logic lab=vcm}
C {lab_wire.sym} 1220 -210 2 0 {name=p18 sig_type=std_logic lab=vcm}
C {sg13cmos5l_pr/rhigh.sym} 920 -730 0 0 {name=R7
w=0.5e-6
l=2e-6
model=rhigh
body=sub!
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {sg13cmos5l_pr/rhigh.sym} 920 -260 0 0 {name=R8
w=0.5e-6
l=2e-6
model=rhigh
body=sub!
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
