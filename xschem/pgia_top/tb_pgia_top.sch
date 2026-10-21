v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -180 -100 -150 -100 {lab=VINP}
N -180 -60 -150 -60 {lab=VINN}
N -180 -20 -150 -20 {lab=VCM}
N -180 40 -150 40 {lab=gain_sel[0]}
N -180 70 -150 70 {lab=gain_sel[1]}
N -180 100 -150 100 {lab=gain_sel[2]}
N -180 130 -150 130 {lab=gain_sel[3]}
N 150 -60 190 -60 {lab=VOUT}
N -80 -220 -80 -190 {lab=AVDD}
N -40 -220 -40 -190 {lab=VPWR}
N 0 -220 0 -190 {lab=IBIAS_IA}
N 30 -220 30 -190 {lab=IBIAS_G1}
N 60 -220 60 -190 {lab=IBIAS_G2}
N 90 -220 90 -190 {lab=IBIAS_BUF}
N -60 190 -60 220 {lab=AVSS}
N -20 190 -20 220 {lab=VGND}
N -540 -410 -540 -390 {lab=AVDD}
N -540 -330 -540 -310 {lab=0}
N -460 -410 -460 -390 {lab=AVSS}
N -460 -330 -460 -310 {lab=0}
N -380 -410 -380 -390 {lab=VPWR}
N -380 -330 -380 -310 {lab=0}
N -300 -410 -300 -390 {lab=VGND}
N -300 -330 -300 -310 {lab=0}
N -540 -240 -540 -220 {lab=IBIAS_IA}
N -540 -160 -540 -140 {lab=0}
N -460 -240 -460 -220 {lab=IBIAS_BUF}
N -460 -160 -460 -140 {lab=0}
N -380 -240 -380 -220 {lab=AVDD}
N -380 -160 -380 -140 {lab=IBIAS_G1}
N -300 -240 -300 -220 {lab=AVDD}
N -300 -160 -300 -140 {lab=IBIAS_G2}
N -500 -60 -500 -40 {lab=VCM}
N -500 20 -500 40 {lab=0}
N -420 -60 -420 -40 {lab=VINP}
N -420 20 -420 40 {lab=VCM}
N -340 -60 -340 -40 {lab=VINN}
N -340 20 -340 40 {lab=VCM}
N -540 120 -540 140 {lab=gain_sel[0]}
N -540 200 -540 220 {lab=0}
N -460 120 -460 140 {lab=gain_sel[1]}
N -460 200 -460 220 {lab=0}
N -380 120 -380 140 {lab=gain_sel[2]}
N -380 200 -380 220 {lab=0}
N -300 120 -300 140 {lab=gain_sel[3]}
N -300 200 -300 220 {lab=0}
N 250 -60 250 -40 {lab=VOUT}
N 250 20 250 40 {lab=0}
N 330 -60 330 -40 {lab=VOUT}
N 330 20 330 40 {lab=0}
C {pgia_top.sym} 0 0 0 0 {name=x1}
C {lab_wire.sym} -180 -100 0 0 {name=l_dut_vinp lab=VINP}
C {lab_wire.sym} -180 -60 0 0 {name=l_dut_vinn lab=VINN}
C {lab_wire.sym} -180 -20 0 0 {name=l_dut_vcm lab=VCM}
C {lab_wire.sym} -180 40 0 0 {name=l_dut_g0 lab=gain_sel[0]}
C {lab_wire.sym} -180 70 0 0 {name=l_dut_g1 lab=gain_sel[1]}
C {lab_wire.sym} -180 100 0 0 {name=l_dut_g2 lab=gain_sel[2]}
C {lab_wire.sym} -180 130 0 0 {name=l_dut_g3 lab=gain_sel[3]}
C {lab_wire.sym} 190 -60 2 0 {name=l_dut_vout lab=VOUT}
C {lab_wire.sym} -80 -220 1 0 {name=l_dut_avdd lab=AVDD}
C {lab_wire.sym} -40 -220 1 0 {name=l_dut_vpwr lab=VPWR}
C {lab_wire.sym} 0 -220 1 0 {name=l_dut_ibia lab=IBIAS_IA}
C {lab_wire.sym} 30 -220 1 0 {name=l_dut_ibg1 lab=IBIAS_G1}
C {lab_wire.sym} 60 -220 1 0 {name=l_dut_ibg2 lab=IBIAS_G2}
C {lab_wire.sym} 90 -220 1 0 {name=l_dut_ibbuf lab=IBIAS_BUF}
C {lab_wire.sym} -60 220 3 0 {name=l_dut_avss lab=AVSS}
C {lab_wire.sym} -20 220 3 0 {name=l_dut_vgnd lab=VGND}
C {vsource.sym} -540 -360 0 0 {name=V_AVDD value="1.2" savecurrent=false}
C {lab_wire.sym} -540 -410 1 0 {name=l_p_avdd lab=AVDD}
C {gnd.sym} -540 -310 0 0 {name=g_avdd lab=0}
C {vsource.sym} -460 -360 0 0 {name=V_AVSS value="0" savecurrent=false}
C {lab_wire.sym} -460 -410 1 0 {name=l_p_avss lab=AVSS}
C {gnd.sym} -460 -310 0 0 {name=g_avss lab=0}
C {vsource.sym} -380 -360 0 0 {name=V_VPWR value="1.2" savecurrent=false}
C {lab_wire.sym} -380 -410 1 0 {name=l_p_vpwr lab=VPWR}
C {gnd.sym} -380 -310 0 0 {name=g_vpwr lab=0}
C {vsource.sym} -300 -360 0 0 {name=V_VGND value="0" savecurrent=false}
C {lab_wire.sym} -300 -410 1 0 {name=l_p_vgnd lab=VGND}
C {gnd.sym} -300 -310 0 0 {name=g_vgnd lab=0}
C {isource.sym} -540 -190 0 0 {name=I_IA value=4.2u}
C {lab_wire.sym} -540 -240 1 0 {name=l_src_ibia lab=IBIAS_IA}
C {gnd.sym} -540 -140 0 0 {name=g_src_ibia lab=0}
C {isource.sym} -460 -190 0 0 {name=I_BUF value=1.4u}
C {lab_wire.sym} -460 -240 1 0 {name=l_src_ibbuf lab=IBIAS_BUF}
C {gnd.sym} -460 -140 0 0 {name=g_src_ibbuf lab=0}
C {isource.sym} -380 -190 0 0 {name=I_G1 value=1.0u}
C {lab_wire.sym} -380 -240 1 0 {name=l_src_ibg1_vdd lab=AVDD}
C {lab_wire.sym} -380 -140 3 0 {name=l_src_ibg1 lab=IBIAS_G1}
C {isource.sym} -300 -190 0 0 {name=I_G2 value=1.0u}
C {lab_wire.sym} -300 -240 1 0 {name=l_src_ibg2_vdd lab=AVDD}
C {lab_wire.sym} -300 -140 3 0 {name=l_src_ibg2 lab=IBIAS_G2}
C {vsource.sym} -500 -10 0 0 {name=V_CM value="0.6" savecurrent=false}
C {lab_wire.sym} -500 -60 1 0 {name=l_src_vcm lab=VCM}
C {gnd.sym} -500 40 0 0 {name=g_src_vcm lab=0}
C {vsource.sym} -420 -10 0 0 {name=V_INP value="-334.7u AC 0.5 SIN(-334.7u 20u 10k 0 0 0)" savecurrent=false}
C {lab_wire.sym} -420 -60 1 0 {name=l_src_vinp lab=VINP}
C {lab_wire.sym} -420 40 3 0 {name=l_src_vinp_cm lab=VCM}
C {vsource.sym} -340 -10 0 0 {name=V_INN value="0 AC -0.5 SIN(0 20u 10k 0 0 180)" savecurrent=false}
C {lab_wire.sym} -340 -60 1 0 {name=l_src_vinn lab=VINN}
C {lab_wire.sym} -340 40 3 0 {name=l_src_vinn_cm lab=VCM}
C {vsource.sym} -540 170 0 0 {name=V_G0 value="DC v_g0 PULSE(0 1.2 100u 1n 1n 100u 200u)" savecurrent=false}
C {lab_wire.sym} -540 120 1 0 {name=l_src_g0 lab=gain_sel[0]}
C {gnd.sym} -540 220 0 0 {name=g_src_g0 lab=0}
C {vsource.sym} -460 170 0 0 {name=V_G1 value="DC v_g1 PULSE(0 1.2 200u 1n 1n 200u 400u)" savecurrent=false}
C {lab_wire.sym} -460 120 1 0 {name=l_src_g1 lab=gain_sel[1]}
C {gnd.sym} -460 220 0 0 {name=g_src_g1 lab=0}
C {vsource.sym} -380 170 0 0 {name=V_G2 value="DC v_g2 PULSE(0 1.2 400u 1n 1n 400u 800u)" savecurrent=false}
C {lab_wire.sym} -380 120 1 0 {name=l_src_g2 lab=gain_sel[2]}
C {gnd.sym} -380 220 0 0 {name=g_src_g2 lab=0}
C {vsource.sym} -300 170 0 0 {name=V_G3 value="DC v_g3 PULSE(0 1.2 800u 1n 1n 800u 1600u)" savecurrent=false}
C {lab_wire.sym} -300 120 1 0 {name=l_src_g3 lab=gain_sel[3]}
C {gnd.sym} -300 220 0 0 {name=g_src_g3 lab=0}
C {capa.sym} 250 -10 0 0 {name=CL value=15p m=1}
C {lab_wire.sym} 250 -60 1 0 {name=l_load_cl lab=VOUT}
C {gnd.sym} 250 40 0 0 {name=g_load_cl lab=0}
C {res.sym} 330 -10 0 0 {name=RL value=100k m=1}
C {lab_wire.sym} 330 -60 1 0 {name=l_load_rl lab=VOUT}
C {gnd.sym} 330 40 0 0 {name=g_load_rl lab=0}
C {code_shown.sym} 450 -180 0 0 {
name=MODELS
only_toplevel=false
value="
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerMOSlv.lib mos_tt
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerRES.lib res_typ
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerCAP.lib cap_typ
.include /foss/pdks/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice
.include /foss/designs/Chipalooza/Programmable-Instrumentation-Amplifier-IP/gds/gain_decoder_4b/final/spice/gain_decoder_4b.spice

.param temp=27
.param lbias=0.15u wbias=0.15u
.param m6=1 m7=4 m8=8
.param linpair=3u winpair=20u
.param lload=5u wload=10u
.param lcs=3u wcs=20u
.param Cc=2p
.param v_g0=0 v_g1=0 v_g2=0 v_g3=0
"
}
C {code_shown.sym} 450 120 0 0 {
name=NGSPICE
only_toplevel=false
value="
.control
  save all v(VOUT) v(x1.v_ia) v(x1.v_stage1) v(x1.v_stage2)
  echo ==========================================================================
  echo === TOP-LEVEL PGIA CO-SIMULATION BATTERY (MILESTONES 3, 4, 5) ===
  echo ==========================================================================

  * 1. DC Operating Point Verification
  echo
  echo --- Phase A: DC Operating Point Audit ---
  op
  let v_ia_dc     = v(x1.v_ia)
  let v_st1_dc    = v(x1.v_stage1)
  let v_st2_dc    = v(x1.v_stage2)
  let v_out_dc    = v(VOUT)
  let v_diff_dc   = v(VINP) - v(VINN)
  let i_avdd_dc   = -i(v_avdd)
  let i_vpwr_dc   = -i(v_vpwr)
  let p_tot_uW    = (i_avdd_dc + i_vpwr_dc) * 1.2 * 1e6

  echo Target Common-Mode: 0.600 V
  echo V(VINP) - V(VINN) = $&v_diff_dc V
  echo V(v_ia)           = $&v_ia_dc V
  echo V(v_stage1)       = $&v_st1_dc V
  echo V(v_stage2)       = $&v_st2_dc V
  echo V(VOUT)           = $&v_out_dc V
  echo Total Static DC Power = $&p_tot_uW uW (Target < 500 uW)

  * 2. Small-Signal AC Gain Sweeps Across All 11 Valid Gain Steps (0 to 10)
  echo
  echo --- Phase B: Small-Signal AC Frequency Response (11 Steps) ---

  * Step 0: 0000 (Target: 18.06 dB / 8x)
  alterparam v_g0=0
  alterparam v_g1=0
  alterparam v_g2=0
  alterparam v_g3=0
  reset
  ac dec 10 10 100Meg
  let gain0 = db(v(VOUT))
  let g0_1k = gain0[20]
  echo Step 0  (0000): Gain @ 1kHz = $&g0_1k dB

  * Step 1: 0001 (Target: 24.08 dB / 16x)
  alterparam v_g0=1.2
  alterparam v_g1=0
  alterparam v_g2=0
  alterparam v_g3=0
  reset
  ac dec 10 10 100Meg
  let gain1 = db(v(VOUT))
  let g1_1k = gain1[20]
  echo Step 1  (0001): Gain @ 1kHz = $&g1_1k dB

  * Step 2: 0010 (Target: 30.10 dB / 32x)
  alterparam v_g0=0
  alterparam v_g1=1.2
  alterparam v_g2=0
  alterparam v_g3=0
  reset
  ac dec 10 10 100Meg
  let gain2 = db(v(VOUT))
  let g2_1k = gain2[20]
  echo Step 2  (0010): Gain @ 1kHz = $&g2_1k dB

  * Step 3: 0011 (Target: 36.12 dB / 64x)
  alterparam v_g0=1.2
  alterparam v_g1=1.2
  alterparam v_g2=0
  alterparam v_g3=0
  reset
  ac dec 10 10 100Meg
  let gain3 = db(v(VOUT))
  let g3_1k = gain3[20]
  echo Step 3  (0011): Gain @ 1kHz = $&g3_1k dB

  * Step 4: 0100 (Target: 42.14 dB / 128x)
  alterparam v_g0=0
  alterparam v_g1=0
  alterparam v_g2=1.2
  alterparam v_g3=0
  reset
  ac dec 10 10 100Meg
  let gain4 = db(v(VOUT))
  let g4_1k = gain4[20]
  echo Step 4  (0100): Gain @ 1kHz = $&g4_1k dB

  * Step 5: 0101 (Target: 48.16 dB / 256x)
  alterparam v_g0=1.2
  alterparam v_g1=0
  alterparam v_g2=1.2
  alterparam v_g3=0
  reset
  ac dec 10 10 100Meg
  let gain5 = db(v(VOUT))
  let g5_1k = gain5[20]
  echo Step 5  (0101): Gain @ 1kHz = $&g5_1k dB

  * Step 6: 0110 (Target: 54.18 dB / 512x)
  alterparam v_g0=0
  alterparam v_g1=1.2
  alterparam v_g2=1.2
  alterparam v_g3=0
  reset
  ac dec 10 10 100Meg
  let gain6 = db(v(VOUT))
  let g6_1k = gain6[20]
  echo Step 6  (0110): Gain @ 1kHz = $&g6_1k dB

  * Step 7: 0111 (Target: 60.20 dB / 1024x)
  alterparam v_g0=1.2
  alterparam v_g1=1.2
  alterparam v_g2=1.2
  alterparam v_g3=0
  reset
  ac dec 10 10 100Meg
  let gain7 = db(v(VOUT))
  let g7_1k = gain7[20]
  echo Step 7  (0111): Gain @ 1kHz = $&g7_1k dB

  * Step 8: 1000 (Target: 66.22 dB / 2048x)
  alterparam v_g0=0
  alterparam v_g1=0
  alterparam v_g2=0
  alterparam v_g3=1.2
  reset
  ac dec 10 10 100Meg
  let gain8 = db(v(VOUT))
  let g8_1k = gain8[20]
  echo Step 8  (1000): Gain @ 1kHz = $&g8_1k dB

  * Step 9: 1001 (Target: 72.24 dB / 4096x)
  alterparam v_g0=1.2
  alterparam v_g1=0
  alterparam v_g2=0
  alterparam v_g3=1.2
  reset
  ac dec 10 10 100Meg
  let gain9 = db(v(VOUT))
  let g9_1k = gain9[20]
  echo Step 9  (1001): Gain @ 1kHz = $&g9_1k dB

  * Step 10: 1010 (Target: 78.26 dB / 8192x)
  alterparam v_g0=0
  alterparam v_g1=1.2
  alterparam v_g2=0
  alterparam v_g3=1.2
  reset
  ac dec 10 10 100Meg
  let gain10 = db(v(VOUT))
  let g10_1k = gain10[20]
  echo Step 10 (1010): Gain @ 1kHz = $&g10_1k dB

  * Step 11: 1011 (Out-of-range Clamp Target)
  alterparam v_g0=1.2
  alterparam v_g1=1.2
  alterparam v_g2=0
  alterparam v_g3=1.2
  reset
  ac dec 10 10 100Meg
  let gain11 = db(v(VOUT))
  let g11_1k = gain11[20]
  echo Step 11 (1011): Gain @ 1kHz = $&g11_1k dB (Expected Clamp to Step 0)

  * 3. Dynamic Transient Co-Simulation Across All 16 States (0 to 15)
  echo
  echo --- Phase C: Dynamic Transient Stepping (16 States x 100us) ---
  tran 1u 1.6m
  meas tran vpp_st0  pp v(VOUT) from=50u to=90u
  meas tran vpp_st1  pp v(VOUT) from=150u to=190u
  meas tran vpp_st2  pp v(VOUT) from=250u to=290u
  meas tran vpp_st3  pp v(VOUT) from=350u to=390u
  meas tran vpp_st4  pp v(VOUT) from=450u to=490u
  meas tran vpp_st5  pp v(VOUT) from=550u to=590u
  meas tran vpp_st6  pp v(VOUT) from=650u to=690u
  meas tran vpp_st7  pp v(VOUT) from=750u to=790u
  meas tran vpp_st8  pp v(VOUT) from=850u to=890u
  meas tran vpp_st9  pp v(VOUT) from=950u to=990u
  meas tran vpp_st10 pp v(VOUT) from=1050u to=1090u
  meas tran vpp_st11 pp v(VOUT) from=1150u to=1190u
  meas tran vpp_st12 pp v(VOUT) from=1250u to=1290u
  meas tran vpp_st15 pp v(VOUT) from=1550u to=1590u

  echo
  echo Transient Output Peak-to-Peak:
  echo State 0  (0000): $&vpp_st0 Vpp
  echo State 1  (0001): $&vpp_st1 Vpp
  echo State 2  (0010): $&vpp_st2 Vpp
  echo State 3  (0011): $&vpp_st3 Vpp
  echo State 4  (0100): $&vpp_st4 Vpp
  echo State 5  (0101): $&vpp_st5 Vpp
  echo State 6  (0110): $&vpp_st6 Vpp
  echo State 7  (0111): $&vpp_st7 Vpp
  echo State 8  (1000): $&vpp_st8 Vpp
  echo State 9  (1001): $&vpp_st9 Vpp
  echo State 10 (1010): $&vpp_st10 Vpp
  echo State 11 (1011): $&vpp_st11 Vpp (Clamped)
  echo State 12 (1100): $&vpp_st12 Vpp (Clamped)
  echo State 15 (1111): $&vpp_st15 Vpp (Clamped)

  echo ==========================================================================
  echo === SIMULATION COMPLETE ===
  echo ==========================================================================
.endc
"
}
C {title.sym} 0 350 0 0 {name=l_title author="Alden Cimahi"}
