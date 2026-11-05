v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {title.sym} 160 -30 0 0 {name=l4 author="SPMA"}
C {central_bias.sym} 0 0 0 0 {name=x1}
C {lab_wire.sym} -100 0 2 0 {name=l_in lab=IB_IN}
C {lab_wire.sym} 100 -60 0 0 {name=l_ia lab=IB_IA}
C {lab_wire.sym} 100 -20 0 0 {name=l_buf lab=IB_BUF}
C {lab_wire.sym} 100 20 0 0 {name=l_g1 lab=IB_G1}
C {lab_wire.sym} 100 60 0 0 {name=l_g2 lab=IB_G2}
C {lab_wire.sym} 0 -90 1 0 {name=l_vdd lab=AVDD}
C {lab_wire.sym} 0 90 3 0 {name=l_vss lab=AVSS}
C {vsource.sym} -500 -250 0 0 {name=V_AVDD value=\{vdd\} savecurrent=true}
C {lab_wire.sym} -500 -280 1 0 {name=l_V_AVDD_p lab=AVDD}
C {lab_wire.sym} -500 -220 3 0 {name=l_V_AVDD_m lab=0}
C {vsource.sym} -420 -250 0 0 {name=V_AVSS value=0 savecurrent=false}
C {lab_wire.sym} -420 -280 1 0 {name=l_V_AVSS_p lab=AVSS}
C {lab_wire.sym} -420 -220 3 0 {name=l_V_AVSS_m lab=0}
C {isource.sym} -340 -250 0 0 {name=I_IN value=\{-ib0\}}
C {lab_wire.sym} -340 -280 1 0 {name=l_iin_p lab=IB_IN}
C {lab_wire.sym} -340 -220 3 0 {name=l_iin_m lab=0}
C {vsource.sym} 300 -180 0 0 {name=V_SIA value=0 savecurrent=true}
C {lab_wire.sym} 300 -210 1 0 {name=l_V_SIA_p lab=n_ia}
C {lab_wire.sym} 300 -150 3 0 {name=l_V_SIA_m lab=IB_IA}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 380 -180 0 0 {name=M_LIA
l=0.15u
w=0.15u
ng=1
m=3
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_wire.sym} 400 -210 1 0 {name=l_M_LIA_t lab=AVDD}
C {lab_wire.sym} 400 -150 3 0 {name=l_M_LIA_b lab=n_ia}
C {lab_wire.sym} 360 -180 2 0 {name=l_M_LIA_g lab=n_ia}
C {lab_wire.sym} 400 -180 0 0 {name=l_M_LIA_bk lab=AVDD}
C {vsource.sym} 300 -80 0 0 {name=V_SBUF value=0 savecurrent=true}
C {lab_wire.sym} 300 -110 1 0 {name=l_V_SBUF_p lab=n_buf}
C {lab_wire.sym} 300 -50 3 0 {name=l_V_SBUF_m lab=IB_BUF}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} 380 -80 0 0 {name=M_LBUF
l=0.15u
w=0.15u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_wire.sym} 400 -110 1 0 {name=l_M_LBUF_t lab=AVDD}
C {lab_wire.sym} 400 -50 3 0 {name=l_M_LBUF_b lab=n_buf}
C {lab_wire.sym} 360 -80 2 0 {name=l_M_LBUF_g lab=n_buf}
C {lab_wire.sym} 400 -80 0 0 {name=l_M_LBUF_bk lab=AVDD}
C {vsource.sym} 300 20 0 0 {name=V_SG1 value=0 savecurrent=true}
C {lab_wire.sym} 300 -10 1 0 {name=l_V_SG1_p lab=IB_G1}
C {lab_wire.sym} 300 50 3 0 {name=l_V_SG1_m lab=n_g1}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 380 20 0 0 {name=M_LG1
l=2u
w=0.87u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_wire.sym} 400 -10 1 0 {name=l_M_LG1_t lab=n_g1}
C {lab_wire.sym} 400 50 3 0 {name=l_M_LG1_b lab=AVSS}
C {lab_wire.sym} 360 20 2 0 {name=l_M_LG1_g lab=n_g1}
C {lab_wire.sym} 400 20 0 0 {name=l_M_LG1_bk lab=AVSS}
C {vsource.sym} 300 120 0 0 {name=V_SG2 value=0 savecurrent=true}
C {lab_wire.sym} 300 90 1 0 {name=l_V_SG2_p lab=IB_G2}
C {lab_wire.sym} 300 150 3 0 {name=l_V_SG2_m lab=n_g2}
C {sg13cmos5l_pr/sg13_lv_nmos.sym} 380 120 0 0 {name=M_LG2
l=2u
w=0.87u
ng=1
m=1
mm_ok=1
model=sg13_lv_nmos
spiceprefix=X
}
C {lab_wire.sym} 400 90 1 0 {name=l_M_LG2_t lab=n_g2}
C {lab_wire.sym} 400 150 3 0 {name=l_M_LG2_b lab=AVSS}
C {lab_wire.sym} 360 120 2 0 {name=l_M_LG2_g lab=n_g2}
C {lab_wire.sym} 400 120 0 0 {name=l_M_LG2_bk lab=AVSS}
C {simulator_commands_shown.sym} 600 -700 0 0 {name=Libs_Ngspice
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
C {simulator_commands_shown.sym} 600 -480 0 0 {name=General_Params
simulator=ngspice
only_toplevel=false
value=".param temp=CACE\{temperature\}
.param vdd=CACE\{vdd\}
.param ib0=CACE\{ib0\}
"
      }
C {simulator_commands.sym} 600 -280 0 0 {name=Control
simulator=ngspice
only_toplevel="false"
value=".control
set num_threads=CACE\{jobs\}
save all
op

let i_ia = abs(i(v_sia))
let i_buf = abs(i(v_sbuf))
let i_g1 = abs(i(v_sg1))
let i_g2 = abs(i(v_sg2))
let ib0 = CACE\{ib0\}

let cace_I_IA = i_ia
let cace_I_BUF = i_buf
let cace_I_G1 = i_g1
let cace_I_G2 = i_g2
let cace_R_IA = i_ia / ib0
let cace_R_BUF = i_buf / ib0
let cace_R_G = (i_g1 + i_g2) / 2 / ib0
let cace_ERR_G = 100 * (i_g1 - i_g2) / ((i_g1 + i_g2) / 2)
let cace_PWR = -i(v_avdd) * CACE\{vdd\}

echo $&cace_I_IA $&cace_I_BUF $&cace_I_G1 $&cace_I_G2 $&cace_R_IA $&cace_R_BUF $&cace_R_G $&cace_ERR_G $&cace_PWR > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"
}
