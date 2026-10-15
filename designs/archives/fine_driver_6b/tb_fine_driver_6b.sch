v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -90 -100 -70 -100 {lab=VD4}
N -90 -80 -70 -80 {lab=VD5}
N -90 -60 -70 -60 {lab=VD6}
N -90 -40 -70 -40 {lab=VD7}
N -90 -20 -70 -20 {lab=VD8}
N -90 0 -70 0 {lab=VD9}
N 70 -100 90 -100 {lab=VS4}
N 70 -80 90 -80 {lab=VS4B}
N 70 -40 90 -40 {lab=VS5}
N 70 -20 90 -20 {lab=VS5B}
N 70 20 90 20 {lab=VS6}
N 70 40 90 40 {lab=VS6B}
N 70 80 90 80 {lab=VS7}
N 70 100 90 100 {lab=VS7B}
N 70 140 90 140 {lab=VS8}
N 70 160 90 160 {lab=VS8B}
N 70 200 90 200 {lab=VS9}
N 70 220 90 220 {lab=VS9B}
N 0 260 -0 280 {lab=0}
N 0 -160 0 -140 {lab=DVDD}
N -180 -270 -180 -250 {lab=DVDD}
N -180 -190 -180 -170 {lab=0}
N -350 -110 -350 -90 {lab=VD6}
N -350 -30 -350 -10 {lab=0}
N -590 -110 -590 -90 {lab=VD5}
N -590 -30 -590 -10 {lab=0}
N -830 -110 -830 -90 {lab=VD4}
N -830 -30 -830 -10 {lab=0}
N -830 30 -830 50 {lab=VD7}
N -830 110 -830 130 {lab=0}
N -590 30 -590 50 {lab=VD8}
N -590 110 -590 130 {lab=0}
N -350 30 -350 50 {lab=VD9}
N -350 110 -350 130 {lab=0}
N 220 -130 220 -110 {lab=VS4}
N 220 -50 220 -30 {lab=0}
N 280 -130 280 -110 {lab=VS4B}
N 280 -50 280 -30 {lab=0}
N 220 20 220 40 {lab=VS5}
N 220 100 220 120 {lab=0}
N 280 20 280 40 {lab=VS5B}
N 280 100 280 120 {lab=0}
N 220 170 220 190 {lab=VS6}
N 220 250 220 270 {lab=0}
N 280 170 280 190 {lab=VS6B}
N 280 250 280 270 {lab=0}
N 220 320 220 340 {lab=VS7}
N 220 400 220 420 {lab=0}
N 280 320 280 340 {lab=VS7B}
N 280 400 280 420 {lab=0}
N 220 470 220 490 {lab=VS8}
N 220 550 220 570 {lab=0}
N 280 470 280 490 {lab=VS8B}
N 280 550 280 570 {lab=0}
N 220 620 220 640 {lab=VS9}
N 220 700 220 720 {lab=0}
N 280 620 280 640 {lab=VS9B}
N 280 700 280 720 {lab=0}
C {fine_driver_6b.sym} 290 30 0 0 {name=x1}
C {gnd.sym} 0 280 0 0 {name=l1 lab=0}
C {lab_wire.sym} -90 -100 0 0 {name=p1 sig_type=std_logic lab=VD4}
C {lab_wire.sym} -90 -80 0 0 {name=p2 sig_type=std_logic lab=VD5}
C {lab_wire.sym} -90 -60 0 0 {name=p3 sig_type=std_logic lab=VD6}
C {lab_wire.sym} -90 -40 0 0 {name=p4 sig_type=std_logic lab=VD7}
C {lab_wire.sym} -90 -20 0 0 {name=p5 sig_type=std_logic lab=VD8}
C {lab_wire.sym} -90 0 0 0 {name=p6 sig_type=std_logic lab=VD9}
C {lab_wire.sym} 90 -100 0 1 {name=p7 sig_type=std_logic lab=VS4}
C {lab_wire.sym} 90 -80 0 1 {name=p8 sig_type=std_logic lab=VS4B}
C {lab_wire.sym} 90 -40 0 1 {name=p9 sig_type=std_logic lab=VS5}
C {lab_wire.sym} 90 -20 0 1 {name=p10 sig_type=std_logic lab=VS5B}
C {lab_wire.sym} 90 20 0 1 {name=p11 sig_type=std_logic lab=VS6}
C {lab_wire.sym} 90 40 0 1 {name=p12 sig_type=std_logic lab=VS6B}
C {lab_wire.sym} 90 80 0 1 {name=p13 sig_type=std_logic lab=VS7}
C {lab_wire.sym} 90 100 0 1 {name=p14 sig_type=std_logic lab=VS7B}
C {lab_wire.sym} 90 140 0 1 {name=p15 sig_type=std_logic lab=VS8}
C {lab_wire.sym} 90 160 0 1 {name=p16 sig_type=std_logic lab=VS8B}
C {lab_wire.sym} 90 200 0 1 {name=p17 sig_type=std_logic lab=VS9}
C {lab_wire.sym} 90 220 0 1 {name=p18 sig_type=std_logic lab=VS9B}
C {lab_wire.sym} 0 -160 0 0 {name=p19 sig_type=std_logic lab=DVDD}
C {vsource.sym} -180 -220 0 0 {name=VDD value=1.2 savecurrent=false}
C {lab_wire.sym} -180 -270 0 0 {name=p20 sig_type=std_logic lab=DVDD}
C {gnd.sym} -180 -170 0 0 {name=l2 lab=0}
C {vsource.sym} -350 -60 0 0 {name=V6 value="PULSE(0 1.2 20n 100p 100p 20n 40n)" savecurrent=false}
C {lab_wire.sym} -350 -110 0 0 {name=p21 sig_type=std_logic lab=VD6}
C {gnd.sym} -350 -10 0 0 {name=l3 lab=0}
C {vsource.sym} -590 -60 0 0 {name=V5 value="PULSE(0 1.2 10n 100p 100p 10n 20n)" savecurrent=false}
C {lab_wire.sym} -590 -110 0 0 {name=p22 sig_type=std_logic lab=VD5}
C {gnd.sym} -590 -10 0 0 {name=l4 lab=0}
C {vsource.sym} -830 -60 0 0 {name=V4 value="PULSE(0 1.2 5n 100p 100p 5n 10n)" savecurrent=false}
C {lab_wire.sym} -830 -110 0 0 {name=p23 sig_type=std_logic lab=VD4}
C {gnd.sym} -830 -10 0 0 {name=l5 lab=0}
C {vsource.sym} -830 80 0 0 {name=V7 value="PULSE(0 1.2 40n 100p 100p 40n 80n)" savecurrent=false}
C {lab_wire.sym} -830 30 0 0 {name=p24 sig_type=std_logic lab=VD7}
C {gnd.sym} -830 130 0 0 {name=l6 lab=0}
C {vsource.sym} -590 80 0 0 {name=V8 value="PULSE(0 1.2 80n 100p 100p 80n 160n)" savecurrent=false}
C {lab_wire.sym} -590 30 0 0 {name=p25 sig_type=std_logic lab=VD8}
C {gnd.sym} -590 130 0 0 {name=l7 lab=0}
C {vsource.sym} -350 80 0 0 {name=V9 value="PULSE(0 1.2 160n 100p 100p 160n 320n)" savecurrent=false}
C {lab_wire.sym} -350 30 0 0 {name=p26 sig_type=std_logic lab=VD9}
C {gnd.sym} -350 130 0 0 {name=l8 lab=0}
C {capa.sym} 220 -80 0 0 {name=CL4
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 220 -30 0 0 {name=l9 lab=0}
C {lab_wire.sym} 220 -130 0 1 {name=p27 sig_type=std_logic lab=VS4}
C {capa.sym} 280 -80 0 0 {name=CL4B
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 280 -30 0 0 {name=l10 lab=0}
C {lab_wire.sym} 280 -130 0 1 {name=p28 sig_type=std_logic lab=VS4B}
C {capa.sym} 220 70 0 0 {name=CL5
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 220 120 0 0 {name=l11 lab=0}
C {lab_wire.sym} 220 20 0 1 {name=p29 sig_type=std_logic lab=VS5}
C {capa.sym} 280 70 0 0 {name=CL5B
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 280 120 0 0 {name=l12 lab=0}
C {lab_wire.sym} 280 20 0 1 {name=p30 sig_type=std_logic lab=VS5B}
C {capa.sym} 220 220 0 0 {name=CL6
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 220 270 0 0 {name=l13 lab=0}
C {lab_wire.sym} 220 170 0 1 {name=p31 sig_type=std_logic lab=VS6}
C {capa.sym} 280 220 0 0 {name=CL6B
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 280 270 0 0 {name=l14 lab=0}
C {lab_wire.sym} 280 170 0 1 {name=p32 sig_type=std_logic lab=VS6B}
C {capa.sym} 220 370 0 0 {name=CL7
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 220 420 0 0 {name=l15 lab=0}
C {lab_wire.sym} 220 320 0 1 {name=p33 sig_type=std_logic lab=VS7}
C {capa.sym} 280 370 0 0 {name=CL7B
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 280 420 0 0 {name=l16 lab=0}
C {lab_wire.sym} 280 320 0 1 {name=p34 sig_type=std_logic lab=VS7B}
C {capa.sym} 220 520 0 0 {name=CL8
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 220 570 0 0 {name=l17 lab=0}
C {lab_wire.sym} 220 470 0 1 {name=p35 sig_type=std_logic lab=VS8}
C {capa.sym} 280 520 0 0 {name=CL8B
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 280 570 0 0 {name=l18 lab=0}
C {lab_wire.sym} 280 470 0 1 {name=p36 sig_type=std_logic lab=VS8B}
C {capa.sym} 220 670 0 0 {name=CL9
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 220 720 0 0 {name=l19 lab=0}
C {lab_wire.sym} 220 620 0 1 {name=p37 sig_type=std_logic lab=VS9}
C {capa.sym} 280 670 0 0 {name=CL9B
m=1
value=10f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 280 720 0 0 {name=l20 lab=0}
C {lab_wire.sym} 280 620 0 1 {name=p38 sig_type=std_logic lab=VS9B}
C {code_shown.sym} 390 -210 0 0 {name=MODELS only_toplevel=false value=".lib cornerMOSlv.lib mos_tt
.include /foss/pdks/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice"}
C {code_shown.sym} 390 -140 0 0 {name=NGSPICE only_toplevel=false value=".control
  tran 100p 320n
  write tb_fine_driver_6b.raw

  * Multi-trace offset plots for Lower 3 bits (D4, D5, D6)
  plot v(VD4) v(VS4)+1.5 v(VS4B)+3.0 title 'Bit 4: Input (VD4), True (VS4), Complement (VS4B)' xlabel 'Time (s)' ylabel 'Voltage (V)'
  plot v(VD5) v(VS5)+1.5 v(VS5B)+3.0 title 'Bit 5: Input (VD5), True (VS5), Complement (VS5B)' xlabel 'Time (s)' ylabel 'Voltage (V)'
  plot v(VD6) v(VS6)+1.5 v(VS6B)+3.0 title 'Bit 6: Input (VD6), True (VS6), Complement (VS6B)' xlabel 'Time (s)' ylabel 'Voltage (V)'

  * Multi-trace offset plots for Upper 3 bits (D7, D8, D9)
  plot v(VD7) v(VS7)+1.5 v(VS7B)+3.0 title 'Bit 7: Input (VD7), True (VS7), Complement (VS7B)' xlabel 'Time (s)' ylabel 'Voltage (V)'
  plot v(VD8) v(VS8)+1.5 v(VS8B)+3.0 title 'Bit 8: Input (VD8), True (VS8), Complement (VS8B)' xlabel 'Time (s)' ylabel 'Voltage (V)'
  plot v(VD9) v(VS9)+1.5 v(VS9B)+3.0 title 'Bit 9: Input (VD9), True (VS9), Complement (VS9B)' xlabel 'Time (s)' ylabel 'Voltage (V)'
.endc
"

}
C {title.sym} 560 190 0 0 {name=l21 author="Rafi Ananta Alden"}
