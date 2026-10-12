v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 380 -700 420 -700 {lab=vdd}
N 180 -640 180 -610 {lab=vdd}
N 420 -640 420 -610 {lab=vdd}
N 720 -640 720 -610 {lab=vdd}
N 680 -580 680 -570 {lab=#net1}
N 380 -580 380 -570 {lab=#net1}
N 420 -580 430 -580 {lab=vdd}
N 430 -610 430 -580 {lab=vdd}
N 420 -610 430 -610 {lab=vdd}
N 170 -580 180 -580 {lab=vdd}
N 170 -610 170 -580 {lab=vdd}
N 170 -610 180 -610 {lab=vdd}
N 720 -580 730 -580 {lab=vdd}
N 730 -610 730 -580 {lab=vdd}
N 720 -610 730 -610 {lab=vdd}
N 310 -570 310 -530 {lab=#net1}
N 180 -530 310 -530 {lab=#net1}
N 180 -550 180 -530 {lab=#net1}
N 180 -640 420 -640 {lab=vdd}
N 310 -570 380 -570 {lab=#net1}
N 420 -440 510 -440 {lab=#net2}
N 420 -410 510 -410 {lab=vdd}
N 420 -410 420 -390 {lab=vdd}
N 340 -410 420 -410 {lab=vdd}
N 400 -210 470 -210 {lab=#net3}
N 510 -260 510 -240 {lab=#net4}
N 340 -260 400 -260 {lab=#net3}
N 340 -260 340 -240 {lab=#net3}
N 380 -210 400 -210 {lab=#net3}
N 400 -260 400 -210 {lab=#net3}
N 280 -410 300 -410 {lab=VINN}
N 550 -410 570 -410 {lab=VINP}
N 330 -210 340 -210 {lab=VSS}
N 330 -210 330 -180 {lab=VSS}
N 330 -180 340 -180 {lab=VSS}
N 510 -210 520 -210 {lab=VSS}
N 520 -210 520 -180 {lab=VSS}
N 510 -180 520 -180 {lab=VSS}
N 340 -160 340 -120 {lab=VSS}
N 510 -180 510 -160 {lab=VSS}
N 220 -570 310 -570 {lab=#net1}
N 220 -580 220 -570 {lab=#net1}
N 510 -260 570 -260 {lab=#net4}
N 570 -260 570 -210 {lab=#net4}
N 720 -180 730 -180 {lab=VSS}
N 730 -210 730 -180 {lab=VSS}
N 720 -210 730 -210 {lab=VSS}
N 720 -180 720 -160 {lab=VSS}
N 420 -640 720 -640 {lab=vdd}
N 380 -570 680 -570 {lab=#net1}
N 570 -210 680 -210 {lab=#net4}
N 570 -260 600 -260 {lab=#net4}
N 180 -530 180 -520 {lab=#net1}
N 180 -460 180 -280 {lab=IBIAS}
N 420 -550 420 -520 {lab=#net5}
N 420 -460 420 -440 {lab=#net2}
N 340 -440 420 -440 {lab=#net2}
N 720 -550 720 -520 {lab=#net6}
N 720 -410 780 -410 {lab=VOUT}
N 720 -460 720 -410 {lab=VOUT}
N 340 -280 340 -260 {lab=#net3}
N 340 -380 340 -340 {lab=#net7}
N 510 -280 510 -260 {lab=#net4}
N 510 -380 510 -340 {lab=#net8}
N 720 -280 720 -240 {lab=#net9}
N 720 -410 720 -340 {lab=VOUT}
N 420 -700 420 -640 {lab=vdd}
N 510 -160 720 -160 {lab=VSS}
N 340 -160 510 -160 {lab=VSS}
N 340 -180 340 -160 {lab=VSS}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 200 -580 0 1 {name=M6
l=\{lbias\}
w=\{wbias\}
ng=1
m=\{m6\}
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 400 -580 0 0 {name=M7
l=\{lbias\}
w=\{wbias\}
ng=1
m=\{m7\}
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 700 -580 0 0 {name=M8
l=\{lbias\}
w=\{wbias\}
ng=1
m=\{m8\}
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 320 -410 0 0 {name=M1
l=\{linpair\}
w=\{winpair\}
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 530 -410 0 1 {name=M2
l=\{linpair\}
w=\{winpair\}
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 360 -210 0 1 {name=M3
l=\{lload\}
w=\{wload\}
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 490 -210 0 0 {name=M4
l=\{lload\}
w=\{wload\}
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_wire.sym} 420 -660 0 0 {name=p1 sig_type=std_logic lab=vdd}
C {lab_wire.sym} 420 -390 0 0 {name=p6 sig_type=std_logic lab=vdd}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 700 -210 0 0 {name=M5
l=\{lcs\}
w=\{wcs\}
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {sg13cmos5l_pr/rhigh.sym} 630 -260 3 0 {name=R1
w=0.5e-6
l=1.95e-6
model=rhigh
body=vss
spiceprefix=X
b=0
 m=1
  mm_ok=1
value="expr_eng(  ( 1.6e-4 / @w + 1360.0 * ( (@b + 1)* @l + ( 1.081*( @w - 0.04e-6 ) + 0.18e-6 )*@b ) / ( @w - 0.04e-6 ) ) / @m  )"
}
C {title.sym} 160 -30 0 0 {name=l4 author="James Patrick"}
C {ammeter.sym} 180 -490 0 0 {name=VIBIAS savecurrent=true spice_ignore=0}
C {ammeter.sym} 420 -490 0 0 {name=VID7 savecurrent=true spice_ignore=0}
C {ammeter.sym} 720 -490 0 0 {name=VID8 savecurrent=true spice_ignore=0}
C {iopin.sym} 180 -280 1 0 {name=p2 lab=IBIAS}
C {iopin.sym} 380 -700 2 0 {name=p4 lab=VDD}
C {iopin.sym} 340 -120 1 0 {name=p13 lab=VSS}
C {iopin.sym} 780 -410 0 0 {name=p14 lab=VOUT}
C {iopin.sym} 570 -410 3 0 {name=p10 lab=VINP}
C {iopin.sym} 280 -410 3 0 {name=p11 lab=VINN}
C {spice_probe.sym} 560 -410 2 1 {name=p15 attrs=""}
C {spice_probe.sym} 290 -410 2 0 {name=p16 attrs=""}
C {spice_probe.sym} 760 -410 2 1 {name=p17 attrs=""}
C {ammeter.sym} 340 -310 0 0 {name=VID1 savecurrent=true spice_ignore=0}
C {ammeter.sym} 510 -310 0 0 {name=VID2 savecurrent=true spice_ignore=0}
C {ammeter.sym} 720 -310 0 0 {name=VID5 savecurrent=true spice_ignore=0}
C {sg13cmos5l_pr/cap_cmomi.sym} 690 -260 1 1 {name=C2
model=cap_cmomi
w=15e-6
l=15e-6
mmin=1
mmax=4
feed=double
subblock=0
m=9
mm_ok=1
spiceprefix=X
}
