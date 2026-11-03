v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {title.sym} -100 400 0 0 {name=l_title author="SPMA Team"}
N -60 -120 -60 -80 {lab=AVDD}
N -20 -120 -20 -80 {lab=AVSS}
N 20 -120 20 -80 {lab=IBIAS}
N -160 -20 -120 -20 {lab=VIN}
N -160 20 -120 20 {lab=VCM}
N 120 0 200 0 {lab=VOUT}
N -80 120 -80 160 {lab=s[0]}
N -40 120 -40 160 {lab=s[1]}
N 0 120 0 160 {lab=s[2]}
N 40 120 40 160 {lab=s[3]}
N 80 120 80 160 {lab=s[4]}
N -300 -230 -300 -210 {lab=AVDD}
N -300 -170 -300 -150 {lab=0}
N -220 -230 -220 -210 {lab=AVSS}
N -220 -170 -220 -150 {lab=0}
N -140 -230 -140 -210 {lab=VCM}
N -140 -170 -140 -150 {lab=0}
N -60 -230 -60 -210 {lab=IBIAS}
N -60 -170 -60 -150 {lab=0}
N 20 -230 20 -210 {lab=VIN}
N 20 -170 20 -150 {lab=0}
N 200 0 200 20 {lab=VOUT}
N 200 80 200 100 {lab=0}
N -300 230 -300 250 {lab=s[0]}
N -300 290 -300 310 {lab=0}
N -220 230 -220 250 {lab=s[1]}
N -220 290 -220 310 {lab=0}
N -140 230 -140 250 {lab=s[2]}
N -140 290 -140 310 {lab=0}
N -60 230 -60 250 {lab=s[3]}
N -60 290 -60 310 {lab=0}
N 20 230 20 250 {lab=s[4]}
N 20 290 20 310 {lab=0}
C {gain_stage.sym} 0 0 0 0 {name=x1}
C {lab_wire.sym} -60 -120 1 0 {name=l_avdd lab=AVDD}
C {lab_wire.sym} -20 -120 1 0 {name=l_avss lab=AVSS}
C {lab_wire.sym} 20 -120 1 0 {name=l_ibias lab=IBIAS}
C {lab_wire.sym} -160 -20 0 0 {name=l_vin lab=VIN}
C {lab_wire.sym} -160 20 0 0 {name=l_vcm lab=VCM}
C {lab_wire.sym} 160 0 2 0 {name=l_vout lab=VOUT}
C {lab_wire.sym} -80 160 3 0 {name=l_s_0 lab=s[0]}
C {lab_wire.sym} -40 160 3 0 {name=l_s_1 lab=s[1]}
C {lab_wire.sym} 0 160 3 0 {name=l_s_2 lab=s[2]}
C {lab_wire.sym} 40 160 3 0 {name=l_s_3 lab=s[3]}
C {lab_wire.sym} 80 160 3 0 {name=l_s_4 lab=s[4]}
C {vsource.sym} -300 -200 0 0 {name=V_AVDD value=\{vdd\} savecurrent=false}
C {lab_wire.sym} -300 -230 1 0 {name=l_s_avdd lab=AVDD}
C {gnd.sym} -300 -150 0 0 {name=g_avdd lab=0}
C {vsource.sym} -220 -200 0 0 {name=V_AVSS value=0 savecurrent=false}
C {lab_wire.sym} -220 -230 1 0 {name=l_s_avss lab=AVSS}
C {gnd.sym} -220 -150 0 0 {name=g_avss lab=0}
C {vsource.sym} -140 -200 0 0 {name=V_VCM value=\{vcm\} savecurrent=false}
C {lab_wire.sym} -140 -230 1 0 {name=l_s_vcm lab=VCM}
C {gnd.sym} -140 -150 0 0 {name=g_vcm lab=0}
C {isource.sym} -60 -200 2 0 {name=I_BIAS value=\{ib\}}
C {lab_wire.sym} -60 -230 1 0 {name=l_s_ib lab=IBIAS}
C {gnd.sym} -60 -150 0 0 {name=g_ib lab=0}
C {vsource.sym} 20 -200 0 0 {name=V_IN value="DC \{vcm\} AC 1m" savecurrent=false}
C {lab_wire.sym} 20 -230 1 0 {name=l_s_vin lab=VIN}
C {gnd.sym} 20 -150 0 0 {name=g_vin lab=0}
C {capa.sym} 200 50 0 0 {name=CL value=\{cl\} m=1}
C {gnd.sym} 200 100 0 0 {name=g_cl lab=0}
C {vsource.sym} -300 260 0 0 {name=V_S0 value=0 savecurrent=false}
C {lab_wire.sym} -300 230 1 0 {name=l_src_s0 lab=s[0]}
C {gnd.sym} -300 310 0 0 {name=g_s0 lab=0}
C {vsource.sym} -220 260 0 0 {name=V_S1 value=0 savecurrent=false}
C {lab_wire.sym} -220 230 1 0 {name=l_src_s1 lab=s[1]}
C {gnd.sym} -220 310 0 0 {name=g_s1 lab=0}
C {vsource.sym} -140 260 0 0 {name=V_S2 value=0 savecurrent=false}
C {lab_wire.sym} -140 230 1 0 {name=l_src_s2 lab=s[2]}
C {gnd.sym} -140 310 0 0 {name=g_s2 lab=0}
C {vsource.sym} -60 260 0 0 {name=V_S3 value=0 savecurrent=false}
C {lab_wire.sym} -60 230 1 0 {name=l_src_s3 lab=s[3]}
C {gnd.sym} -60 310 0 0 {name=g_s3 lab=0}
C {vsource.sym} 20 260 0 0 {name=V_S4 value=0 savecurrent=false}
C {lab_wire.sym} 20 230 1 0 {name=l_src_s4 lab=s[4]}
C {gnd.sym} 20 310 0 0 {name=g_s4 lab=0}
C {simulator_commands_shown.sym} 1070 -990 0 0 {name=Libs_Ngspice
simulator=ngspice
only_toplevel=false
value="
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOSlv.lib mos_CACE\{corner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOShv.lib mos_CACE\{corner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerRES.lib res_CACE\{rcorner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerCAP.lib cap_typ
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerDIO.lib dio_tt
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOSCAP.lib moscap_tt

.include CACE\{DUT_path\}

.temp CACE\{temperature\}

.option SEED=CACE[CACE\{seed=12345\} + CACE\{iterations=0\}]
"
      }
C {simulator_commands_shown.sym} 1070 -760 0 0 {name=General_Params
simulator=ngspice
only_toplevel=false
value=".param temp=CACE\{temperature\}
.param cl=CACE\{cl\}
.param ib=CACE\{ib\}
.param vdd=CACE\{vdd\}
.param vcm=CACE\{vcm\}
.param gain_tap=CACE\{gain_tap=0\}
"
      }
C {simulator_commands.sym} 1070 -580 0 0 {name=Control
simulator=ngspice
only_toplevel="false"
value=".control
set num_threads=CACE\{jobs\}
save all

set tap = CACE\{gain_tap=0\}
set vdd = CACE\{vdd\}

alter @v_s0[dc] = 0
alter @v_s1[dc] = 0
alter @v_s2[dc] = 0
alter @v_s3[dc] = 0
alter @v_s4[dc] = 0

if ($tap = 1)
  alter @v_s0[dc] = $vdd
end
if ($tap = 2)
  alter @v_s1[dc] = $vdd
end
if ($tap = 3)
  alter @v_s2[dc] = $vdd
end
if ($tap = 4)
  alter @v_s3[dc] = $vdd
end
if ($tap = 5)
  alter @v_s4[dc] = $vdd
end

alter @v_in[acmag] = 0
alter @v_in[dc] = CACE\{vcm\}

op

let v_out = v(VOUT)
let v_cm = v(VCM)
let vos = v_out - v_cm
let i_q = -1 * i(v_avdd)
let p_q = -1 * i(v_avdd) * CACE\{vdd\}

let cace_VOS = vos
let cace_IQ = i_q
let cace_PWR = p_q
let cace_VOUT = v_out

echo $&cace_VOS $&cace_IQ $&cace_PWR $&cace_VOUT > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"
}
