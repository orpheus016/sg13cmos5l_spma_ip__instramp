v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {gain_decoder_4b.sym} 0 0 0 0 {name=x1}
N 10 -100 10 -80 {lab=VPWR}
C {lab_wire.sym} 10 -100 0 0 {name=p_vpwr sig_type=std_logic lab=VPWR}
N 10 380 10 400 {lab=0}
C {gnd.sym} 10 400 0 0 {name=g_vgnd lab=0}
N -90 -40 -70 -40 {lab=gain_sel[0]}
C {lab_wire.sym} -90 -40 0 0 {name=p_gain_sel_0_ sig_type=std_logic lab=gain_sel[0]}
N -90 -20 -70 -20 {lab=gain_sel[1]}
C {lab_wire.sym} -90 -20 0 0 {name=p_gain_sel_1_ sig_type=std_logic lab=gain_sel[1]}
N -90 0 -70 0 {lab=gain_sel[2]}
C {lab_wire.sym} -90 0 0 0 {name=p_gain_sel_2_ sig_type=std_logic lab=gain_sel[2]}
N -90 20 -70 20 {lab=gain_sel[3]}
C {lab_wire.sym} -90 20 0 0 {name=p_gain_sel_3_ sig_type=std_logic lab=gain_sel[3]}
N 90 -40 110 -40 {lab=s1[0]}
C {lab_wire.sym} 110 -40 2 0 {name=p_s1_0_ sig_type=std_logic lab=s1[0]}
N 90 -20 110 -20 {lab=s1[1]}
C {lab_wire.sym} 110 -20 2 0 {name=p_s1_1_ sig_type=std_logic lab=s1[1]}
N 90 0 110 0 {lab=s1[2]}
C {lab_wire.sym} 110 0 2 0 {name=p_s1_2_ sig_type=std_logic lab=s1[2]}
N 90 20 110 20 {lab=s1[3]}
C {lab_wire.sym} 110 20 2 0 {name=p_s1_3_ sig_type=std_logic lab=s1[3]}
N 90 40 110 40 {lab=s1[4]}
C {lab_wire.sym} 110 40 2 0 {name=p_s1_4_ sig_type=std_logic lab=s1[4]}
N 90 60 110 60 {lab=s1_b[0]}
C {lab_wire.sym} 110 60 2 0 {name=p_s1_b_0_ sig_type=std_logic lab=s1_b[0]}
N 90 80 110 80 {lab=s1_b[1]}
C {lab_wire.sym} 110 80 2 0 {name=p_s1_b_1_ sig_type=std_logic lab=s1_b[1]}
N 90 100 110 100 {lab=s1_b[2]}
C {lab_wire.sym} 110 100 2 0 {name=p_s1_b_2_ sig_type=std_logic lab=s1_b[2]}
N 90 120 110 120 {lab=s1_b[3]}
C {lab_wire.sym} 110 120 2 0 {name=p_s1_b_3_ sig_type=std_logic lab=s1_b[3]}
N 90 140 110 140 {lab=s1_b[4]}
C {lab_wire.sym} 110 140 2 0 {name=p_s1_b_4_ sig_type=std_logic lab=s1_b[4]}
N 90 160 110 160 {lab=s2[0]}
C {lab_wire.sym} 110 160 2 0 {name=p_s2_0_ sig_type=std_logic lab=s2[0]}
N 90 180 110 180 {lab=s2[1]}
C {lab_wire.sym} 110 180 2 0 {name=p_s2_1_ sig_type=std_logic lab=s2[1]}
N 90 200 110 200 {lab=s2[2]}
C {lab_wire.sym} 110 200 2 0 {name=p_s2_2_ sig_type=std_logic lab=s2[2]}
N 90 220 110 220 {lab=s2[3]}
C {lab_wire.sym} 110 220 2 0 {name=p_s2_3_ sig_type=std_logic lab=s2[3]}
N 90 240 110 240 {lab=s2[4]}
C {lab_wire.sym} 110 240 2 0 {name=p_s2_4_ sig_type=std_logic lab=s2[4]}
N 90 260 110 260 {lab=s2_b[0]}
C {lab_wire.sym} 110 260 2 0 {name=p_s2_b_0_ sig_type=std_logic lab=s2_b[0]}
N 90 280 110 280 {lab=s2_b[1]}
C {lab_wire.sym} 110 280 2 0 {name=p_s2_b_1_ sig_type=std_logic lab=s2_b[1]}
N 90 300 110 300 {lab=s2_b[2]}
C {lab_wire.sym} 110 300 2 0 {name=p_s2_b_2_ sig_type=std_logic lab=s2_b[2]}
N 90 320 110 320 {lab=s2_b[3]}
C {lab_wire.sym} 110 320 2 0 {name=p_s2_b_3_ sig_type=std_logic lab=s2_b[3]}
N 90 340 110 340 {lab=s2_b[4]}
C {lab_wire.sym} 110 340 2 0 {name=p_s2_b_4_ sig_type=std_logic lab=s2_b[4]}
C {code_shown.sym} -200 450 0 0 {
name=SPICE_COMMANDS
only_toplevel=false
value="
* Power supply
VVDD VPWR 0 1.2

* Binary input pulse sources (16 states sweep 0 to 15 over 320ns, 20ns per state)
* Period = 2 * step_width
* State 0: 0000 (0 to 20ns)
* State 1: 0001 (20 to 40ns), etc.
V0 gain_sel[0] 0 PULSE(0 1.2 20n 100p 100p 20n 40n)
V1 gain_sel[1] 0 PULSE(0 1.2 40n 100p 100p 40n 80n)
V2 gain_sel[2] 0 PULSE(0 1.2 80n 100p 100p 80n 160n)
V3 gain_sel[3] 0 PULSE(0 1.2 160n 100p 100p 160n 320n)

* Output 10fF load capacitors
C_s1_0 s1[0] 0 10f
C_s1_1 s1[1] 0 10f
C_s1_2 s1[2] 0 10f
C_s1_3 s1[3] 0 10f
C_s1_4 s1[4] 0 10f

C_s1_b0 s1_b[0] 0 10f
C_s1_b1 s1_b[1] 0 10f
C_s1_b2 s1_b[2] 0 10f
C_s1_b3 s1_b[3] 0 10f
C_s1_b4 s1_b[4] 0 10f

C_s2_0 s2[0] 0 10f
C_s2_1 s2[1] 0 10f
C_s2_2 s2[2] 0 10f
C_s2_3 s2[3] 0 10f
C_s2_4 s2[4] 0 10f

C_s2_b0 s2_b[0] 0 10f
C_s2_b1 s2_b[1] 0 10f
C_s2_b2 s2_b[2] 0 10f
C_s2_b3 s2_b[3] 0 10f
C_s2_b4 s2_b[4] 0 10f

* Standard cell models & extracted layout macro
.include /foss/pdks/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice
.include /foss/designs/Chipalooza/Programmable-Instrumentation-Amplifier-IP/gds/gain_decoder_4b/final/spice/gain_decoder_4b.spice
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerMOSlv.lib mos_tt

.control
  tran 100p 320n
  remzerovec
  write tb_gain_decoder_4b.raw
  echo SIMULATION_COMPLETE
.endc
"
}
