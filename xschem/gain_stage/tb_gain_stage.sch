v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {gain_stage.sym} 0 0 0 0 {name=x1}
N -60 -120 -60 -80 {lab=AVDD}
C {lab_wire.sym} -60 -120 1 0 {name=l_avdd lab=AVDD}
N -20 -120 -20 -80 {lab=AVSS}
C {lab_wire.sym} -20 -120 1 0 {name=l_avss lab=AVSS}
N 20 -120 20 -80 {lab=IBIAS}
C {lab_wire.sym} 20 -120 1 0 {name=l_ibias lab=IBIAS}
N -160 -20 -120 -20 {lab=VIN}
C {lab_wire.sym} -160 -20 0 0 {name=l_vin lab=VIN}
N -160 20 -120 20 {lab=VCM}
C {lab_wire.sym} -160 20 0 0 {name=l_vcm lab=VCM}
N 120 0 160 0 {lab=VOUT}
C {lab_wire.sym} 160 0 2 0 {name=l_vout lab=VOUT}
N -80 120 -80 160 {lab=s[0]}
C {lab_wire.sym} -80 160 3 0 {name=l_s_0 lab=s[0]}
N -40 120 -40 160 {lab=s[1]}
C {lab_wire.sym} -40 160 3 0 {name=l_s_1 lab=s[1]}
N 0 120 0 160 {lab=s[2]}
C {lab_wire.sym} 0 160 3 0 {name=l_s_2 lab=s[2]}
N 40 120 40 160 {lab=s[3]}
C {lab_wire.sym} 40 160 3 0 {name=l_s_3 lab=s[3]}
N 80 120 80 160 {lab=s[4]}
C {lab_wire.sym} 80 160 3 0 {name=l_s_4 lab=s[4]}
C {vsource.sym} -300 -200 0 0 {name=V_AVDD value=1.2 savecurrent=false}
N -300 -230 -300 -210 {lab=AVDD}
C {lab_wire.sym} -300 -230 1 0 {name=l_s_avdd lab=AVDD}
N -300 -170 -300 -150 {lab=0}
C {gnd.sym} -300 -150 0 0 {name=g_avdd lab=0}
C {vsource.sym} -220 -200 0 0 {name=V_AVSS value=0 savecurrent=false}
N -220 -230 -220 -210 {lab=AVSS}
C {lab_wire.sym} -220 -230 1 0 {name=l_s_avss lab=AVSS}
N -220 -170 -220 -150 {lab=0}
C {gnd.sym} -220 -150 0 0 {name=g_avss lab=0}
C {vsource.sym} -140 -200 0 0 {name=V_VCM value=0.6 savecurrent=false}
N -140 -230 -140 -210 {lab=VCM}
C {lab_wire.sym} -140 -230 1 0 {name=l_s_vcm lab=VCM}
N -140 -170 -140 -150 {lab=0}
C {gnd.sym} -140 -150 0 0 {name=g_vcm lab=0}
C {isource.sym} -60 -200 2 0 {name=I_BIAS value=1.0u}
N -60 -230 -60 -210 {lab=IBIAS}
C {lab_wire.sym} -60 -230 1 0 {name=l_s_ib lab=IBIAS}
N -60 -170 -60 -150 {lab=0}
C {gnd.sym} -60 -150 0 0 {name=g_ib lab=0}
C {vsource.sym} 20 -200 0 0 {name=V_IN value="DC 0.6 AC 1m" savecurrent=false}
N 20 -230 20 -210 {lab=VIN}
C {lab_wire.sym} 20 -230 1 0 {name=l_s_vin lab=VIN}
N 20 -170 20 -150 {lab=0}
C {gnd.sym} 20 -150 0 0 {name=g_vin lab=0}
C {capa.sym} 200 50 0 0 {name=CL value=2p m=1}
N 200 0 200 20 {lab=VOUT}
N 160 0 200 0 {lab=VOUT}
N 200 80 200 100 {lab=0}
C {gnd.sym} 200 100 0 0 {name=g_cl lab=0}
C {vsource.sym} -300 260 0 0 {name=V_S0 value=v_s0 savecurrent=false}
N -300 230 -300 250 {lab=s[0]}
C {lab_wire.sym} -300 230 1 0 {name=l_src_s0 lab=s[0]}
N -300 290 -300 310 {lab=0}
C {gnd.sym} -300 310 0 0 {name=g_s0 lab=0}
C {vsource.sym} -220 260 0 0 {name=V_S1 value=v_s1 savecurrent=false}
N -220 230 -220 250 {lab=s[1]}
C {lab_wire.sym} -220 230 1 0 {name=l_src_s1 lab=s[1]}
N -220 290 -220 310 {lab=0}
C {gnd.sym} -220 310 0 0 {name=g_s1 lab=0}
C {vsource.sym} -140 260 0 0 {name=V_S2 value=v_s2 savecurrent=false}
N -140 230 -140 250 {lab=s[2]}
C {lab_wire.sym} -140 230 1 0 {name=l_src_s2 lab=s[2]}
N -140 290 -140 310 {lab=0}
C {gnd.sym} -140 310 0 0 {name=g_s2 lab=0}
C {vsource.sym} -60 260 0 0 {name=V_S3 value=v_s3 savecurrent=false}
N -60 230 -60 250 {lab=s[3]}
C {lab_wire.sym} -60 230 1 0 {name=l_src_s3 lab=s[3]}
N -60 290 -60 310 {lab=0}
C {gnd.sym} -60 310 0 0 {name=g_s3 lab=0}
C {vsource.sym} 20 260 0 0 {name=V_S4 value=v_s4 savecurrent=false}
N 20 230 20 250 {lab=s[4]}
C {lab_wire.sym} 20 230 1 0 {name=l_src_s4 lab=s[4]}
N 20 290 20 310 {lab=0}
C {gnd.sym} 20 310 0 0 {name=g_s4 lab=0}
C {code_shown.sym} 300 -200 0 0 {
name=MODELS
only_toplevel=false
value="
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerMOSlv.lib mos_tt
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerRES.lib res_typ
.lib /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cornerCAP.lib cap_typ
.include /foss/pdks/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice
"
}
C {code_shown.sym} 300 50 0 0 {
name=NGSPICE
only_toplevel=false
value="
.param v_s0=0 v_s1=0 v_s2=0 v_s3=0 v_s4=0

.control
  save all
  echo ==========================================================================
  echo === GAIN STAGE TAP CHARACTERIZATION (VERIFYING STANDARD CELL S0 LOGIC) ===
  echo ==========================================================================

  * Tap 0: s = 00000 (Target: 0.0 dB / 1x)
  alterparam v_s0=0
  alterparam v_s1=0
  alterparam v_s2=0
  alterparam v_s3=0
  alterparam v_s4=0
  reset
  op
  let s0_dc0 = v(x1.S0)
  ac dec 10 1k 100Meg
  let gain0 = db(v(VOUT)/v(VIN))
  let g0_val = gain0[10]
  echo Tap 0 (s=00000): S0 DC = $&s0_dc0 V | AC Gain @ 10kHz = $&g0_val dB (Target: 0.00 dB)

  * Tap 1: s = 00001 (Target: 6.02 dB / 2x)
  alterparam v_s0=1.2
  alterparam v_s1=0
  alterparam v_s2=0
  alterparam v_s3=0
  alterparam v_s4=0
  reset
  op
  let s0_dc1 = v(x1.S0)
  ac dec 10 1k 100Meg
  let gain1 = db(v(VOUT)/v(VIN))
  let g1_val = gain1[10]
  echo Tap 1 (s=00001): S0 DC = $&s0_dc1 V | AC Gain @ 10kHz = $&g1_val dB (Target: 6.02 dB)

  * Tap 2: s = 00010 (Target: 12.04 dB / 4x)
  alterparam v_s0=0
  alterparam v_s1=1.2
  alterparam v_s2=0
  alterparam v_s3=0
  alterparam v_s4=0
  reset
  op
  let s0_dc2 = v(x1.S0)
  ac dec 10 1k 100Meg
  let gain2 = db(v(VOUT)/v(VIN))
  let g2_val = gain2[10]
  echo Tap 2 (s=00010): S0 DC = $&s0_dc2 V | AC Gain @ 10kHz = $&g2_val dB (Target: 12.04 dB)

  * Tap 3: s = 00100 (Target: 18.06 dB / 8x)
  alterparam v_s0=0
  alterparam v_s1=0
  alterparam v_s2=1.2
  alterparam v_s3=0
  alterparam v_s4=0
  reset
  op
  let s0_dc3 = v(x1.S0)
  ac dec 10 1k 100Meg
  let gain3 = db(v(VOUT)/v(VIN))
  let g3_val = gain3[10]
  echo Tap 3 (s=00100): S0 DC = $&s0_dc3 V | AC Gain @ 10kHz = $&g3_val dB (Target: 18.06 dB)

  * Tap 4: s = 01000 (Target: 24.08 dB / 16x)
  alterparam v_s0=0
  alterparam v_s1=0
  alterparam v_s2=0
  alterparam v_s3=1.2
  alterparam v_s4=0
  reset
  op
  let s0_dc4 = v(x1.S0)
  ac dec 10 1k 100Meg
  let gain4 = db(v(VOUT)/v(VIN))
  let g4_val = gain4[10]
  echo Tap 4 (s=01000): S0 DC = $&s0_dc4 V | AC Gain @ 10kHz = $&g4_val dB (Target: 24.08 dB)

  * Tap 5: s = 10000 (Target: 30.10 dB / 32x)
  alterparam v_s0=0
  alterparam v_s1=0
  alterparam v_s2=0
  alterparam v_s3=0
  alterparam v_s4=1.2
  reset
  op
  let s0_dc5 = v(x1.S0)
  ac dec 10 1k 100Meg
  let gain5 = db(v(VOUT)/v(VIN))
  let g5_val = gain5[10]
  echo Tap 5 (s=10000): S0 DC = $&s0_dc5 V | AC Gain @ 10kHz = $&g5_val dB (Target: 30.10 dB)

  echo ==========================================================================
  echo === CHARACTERIZATION COMPLETE ===
  echo ==========================================================================
.endc
"
}
C {title.sym} -100 400 0 0 {name=l_title author="SPMA Team"}
