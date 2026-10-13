v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 720 -560 720 -520 {lab=VDD}
N 760 -560 760 -520 {lab=VSS}
N 800 -560 800 -520 {lab=I_B}
N 920 -390 940 -390 {lab=OUT3}
N 920 -390 920 -360 {lab=OUT3}
N 900 -390 920 -390 {lab=OUT3}
N 920 -300 920 -270 {lab=0}
N 280 -480 280 -440 {lab=I_B}
N 280 -380 280 -340 {lab=VSS}
N 180 -340 180 -300 {lab=VSS}
N 180 -480 180 -440 {lab=VDD}
N 180 -240 180 -200 {lab=0}
N 380 -480 380 -440 {lab=VINP3}
N 380 -380 380 -340 {lab=VSS}
N 600 -430 640 -430 {lab=VINP3}
N 600 -350 640 -350 {lab=OUT3
}
N 180 -340 280 -340 {lab=VSS}
N 280 -340 380 -340 {lab=VSS}
N 180 -380 180 -340 {lab=VSS}
N 600 -350 600 -240 {lab=OUT3}
N 600 -240 900 -240 {lab=OUT3}
N 900 -390 900 -240 {lab=OUT3}
N 880 -390 900 -390 {lab=OUT3}
C {ota_cmos5l.sym} 760 -390 0 0 {name=x1}
C {vdd.sym} 720 -560 0 0 {name=l1 lab=VDD}
C {lab_wire.sym} 760 -560 0 0 {name=p1 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 800 -560 0 0 {name=p2 sig_type=std_logic lab=I_B}
C {capa.sym} 920 -330 0 0 {name=C1
m=1
value=\{cl\}
footprint=1206
device="ceramic capacitor"}
C {lab_wire.sym} 940 -390 0 0 {name=p4 sig_type=std_logic lab=OUT3}
C {lab_wire.sym} 280 -480 0 0 {name=p5 sig_type=std_logic lab=I_B}
C {isource.sym} 280 -410 0 0 {name=I0 value=\{ib\}}
C {vdd.sym} 180 -480 0 0 {name=l2 lab=VDD}
C {vsource.sym} 180 -410 0 0 {name=V1 value=\{vdd\} savecurrent=false}
C {lab_wire.sym} 180 -340 0 0 {name=p7 sig_type=std_logic lab=VSS}
C {vsource.sym} 180 -270 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} 180 -200 0 0 {name=l3 lab=0}
C {lab_wire.sym} 380 -480 0 0 {name=p9 sig_type=std_logic lab=VINP3}
C {vsource.sym} 380 -410 0 0 {name=V3 value=\{vicm\} savecurrent=false}
C {lab_wire.sym} 600 -430 2 0 {name=p13 sig_type=std_logic lab=VINP3}
C {gnd.sym} 920 -270 0 0 {name=l5 lab=0}
C {simulator_commands_shown.sym} 1410 -580 0 0 {
name=Libs_Ngspice1
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
C {simulator_commands_shown.sym} 1080 -580 0 0 {name=General_Params
simulator=ngspice
only_toplevel=false
value=".param temp=CACE\{temperature\}
.param cl=CACE\{cl\}
.param ib=CACE\{ib\}
.param vdd=CACE\{vdd\}
.param vicm=CACE\{vcm\}
.param vid=0
"
      }
C {simulator_commands.sym} 1460 -380 0 0 {name=ICMR
simulator=ngspice
only_toplevel="false" 
value=".control
set num_threads=CACE\{jobs\}
destroy all
save all
dc v3 0 CACE\{vdd\} 2m
let v_in = v(vinp3)
let v_out = v(out3)
let buffer_gain = deriv(v_out)
* linear ICMR: follower gain > 0.98 (2 % gain error margin)
meas dc ICMR_MIN when buffer_gain=0.98 rise=1
meas dc ICMR_MAX when buffer_gain=0.98 fall=1
let ICMR_SPAN = ICMR_MAX - ICMR_MIN
echo $&ICMR_MIN $&ICMR_MAX $&ICMR_SPAN > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"=======================================================\\"
echo \\"       INPUT COMMON-MODE RANGE (ICMR) RESULTS          \\"
echo \\"=======================================================\\"
echo \\"  Lower ICMR Bound (Vmin, Gain > 0.98) : \\" $&icmr_min \\" V\\"
echo \\"  Upper ICMR Bound (Vmax, Gain > 0.98) : \\" $&icmr_max \\" V\\"
echo \\"  Total Linear ICMR Span               : \\" $&icmr_span \\" V\\"
echo \\"=======================================================\\"

* Display transfer characteristics and tracking performance curves
plot v_out vs v_in
plot buffer_gain vs v_in
plot track_error_mv vs v_in

.endc"
}

