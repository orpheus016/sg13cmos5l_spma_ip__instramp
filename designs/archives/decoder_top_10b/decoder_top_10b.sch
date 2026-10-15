v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -360 -190 -340 -190 {lab=D0}
N -360 -170 -340 -170 {lab=D1}
N -360 -150 -340 -150 {lab=D2}
N -360 -130 -340 -130 {lab=D3}
N -200 -190 -180 -190 {lab=Y0}
N -200 -170 -180 -170 {lab=Y1}
N -200 -150 -180 -150 {lab=Y2}
N -200 -130 -180 -130 {lab=Y3}
N -200 -110 -180 -110 {lab=Y4}
N -200 -90 -180 -90 {lab=Y5}
N -200 -70 -180 -70 {lab=Y6}
N -200 -50 -180 -50 {lab=Y7}
N -200 -30 -180 -30 {lab=Y8}
N -200 -10 -180 -10 {lab=Y9}
N -200 10 -180 10 {lab=Y10}
N -200 30 -180 30 {lab=Y11}
N -200 50 -180 50 {lab=Y12}
N -200 70 -180 70 {lab=Y13}
N -200 90 -180 90 {lab=Y14}
N -200 110 -180 110 {lab=Y15}
N -270 -250 -270 -230 {lab=VDD}
N -270 140 -270 190 {lab=VSS}
N -80 -190 -60 -190 {lab=D4}
N -80 -170 -60 -170 {lab=D5}
N -80 -150 -60 -150 {lab=D6}
N -80 -130 -60 -130 {lab=D7}
N -80 -110 -60 -110 {lab=D8}
N -80 -90 -60 -90 {lab=D9}
N 10 170 10 190 {lab=VSS}
N 10 -250 10 -230 {lab=VDD}
N 80 -190 100 -190 {lab=S4}
N 80 -170 100 -170 {lab=S4B}
N 80 -130 100 -130 {lab=S5}
N 80 -110 100 -110 {lab=S5B}
N 80 -70 100 -70 {lab=S6}
N 80 -50 100 -50 {lab=S6B}
N 80 -10 100 -10 {lab=S7}
N 80 10 100 10 {lab=S7B}
N 80 50 100 50 {lab=S8}
N 80 70 100 70 {lab=S8B}
N 80 110 100 110 {lab=S9}
N 80 130 100 130 {lab=S9B}
N -120 -250 10 -250 {lab=VDD}
N -140 190 10 190 {lab=VSS}
N -140 190 -140 210 {lab=VSS}
N -270 190 -140 190 {lab=VSS}
N -120 -270 -120 -250 {lab=VDD}
N -270 -250 -120 -250 {lab=VDD}
C {/foss/designs/Chipalooza/Programmable-Instrumentation-Amplifier-IP/designs/libs/core_digital/dec4to16/dec4to16.sym} 20 -20 0 0 {name=x_coarse_dec}
C {/foss/designs/Chipalooza/Programmable-Instrumentation-Amplifier-IP/designs/libs/core_digital/fine_driver_6b/fine_driver_6b.sym} 300 -60 0 0 {name=x_fine_driver}
C {ipin.sym} -360 -190 0 0 {name=p1 lab=D0}
C {ipin.sym} -360 -170 0 0 {name=p2 lab=D1}
C {ipin.sym} -360 -150 0 0 {name=p3 lab=D2}
C {ipin.sym} -360 -130 0 0 {name=p4 lab=D3}
C {ipin.sym} -80 -190 0 0 {name=p21 lab=D4}
C {ipin.sym} -80 -170 0 0 {name=p22 lab=D5}
C {ipin.sym} -80 -150 0 0 {name=p23 lab=D6}
C {ipin.sym} -80 -130 0 0 {name=p24 lab=D7}
C {ipin.sym} -80 -110 0 0 {name=p25 lab=D8}
C {ipin.sym} -80 -90 0 0 {name=p26 lab=D9}
C {opin.sym} -180 -190 0 0 {name=p5 lab=Y0}
C {opin.sym} -180 -170 0 0 {name=p6 lab=Y1}
C {opin.sym} -180 -150 0 0 {name=p7 lab=Y2}
C {opin.sym} -180 -130 0 0 {name=p8 lab=Y3}
C {opin.sym} -180 -110 0 0 {name=p9 lab=Y4}
C {opin.sym} -180 -90 0 0 {name=p10 lab=Y5}
C {opin.sym} -180 -70 0 0 {name=p11 lab=Y6}
C {opin.sym} -180 -50 0 0 {name=p12 lab=Y7}
C {opin.sym} -180 -30 0 0 {name=p13 lab=Y8}
C {opin.sym} -180 -10 0 0 {name=p14 lab=Y9}
C {opin.sym} -180 10 0 0 {name=p15 lab=Y10}
C {opin.sym} -180 30 0 0 {name=p16 lab=Y11}
C {opin.sym} -180 50 0 0 {name=p17 lab=Y12}
C {opin.sym} -180 70 0 0 {name=p18 lab=Y13}
C {opin.sym} -180 90 0 0 {name=p19 lab=Y14}
C {opin.sym} -180 110 0 0 {name=p20 lab=Y15}
C {opin.sym} 100 -190 0 0 {name=p27 lab=S4}
C {opin.sym} 100 -170 0 0 {name=p28 lab=S4B}
C {opin.sym} 100 -130 0 0 {name=p29 lab=S5}
C {opin.sym} 100 -110 0 0 {name=p30 lab=S5B}
C {opin.sym} 100 -70 0 0 {name=p31 lab=S6}
C {opin.sym} 100 -50 0 0 {name=p32 lab=S6B}
C {opin.sym} 100 -10 0 0 {name=p33 lab=S7}
C {opin.sym} 100 10 0 0 {name=p34 lab=S7B}
C {opin.sym} 100 50 0 0 {name=p35 lab=S8}
C {opin.sym} 100 70 0 0 {name=p36 lab=S8B}
C {opin.sym} 100 110 0 0 {name=p37 lab=S9}
C {opin.sym} 100 130 0 0 {name=p38 lab=S9B}
C {iopin.sym} -120 -270 3 0 {name=p39 lab=VDD}
C {iopin.sym} -140 210 1 0 {name=p40 lab=VSS}
C {title.sym} -570 290 0 0 {name=l1 author="Rafi Ananta Alden"}
