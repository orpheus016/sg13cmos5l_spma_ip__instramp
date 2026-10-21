v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 180 -470 180 -440 {lab=VDD}
N 180 -380 180 -350 {lab=0}
C {vdd.sym} 180 -470 0 0 {name=l2 lab=VDD}
C {vsource.sym} 180 -410 0 0 {name=V1 value=\{vdd\} savecurrent=false}
C {gnd.sym} 180 -350 0 0 {name=l3 lab=0}

N 180 -330 180 -300 {lab=VSS}
N 180 -240 180 -210 {lab=0}
C {lab_wire.sym} 180 -330 0 0 {name=p7 sig_type=std_logic lab=VSS}
C {vsource.sym} 180 -270 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} 180 -210 0 0 {name=l4 lab=0}

N 280 -470 280 -440 {lab=VDD}
N 280 -380 280 -350 {lab=I_B}
C {vdd.sym} 280 -470 0 0 {name=l5 lab=VDD}
C {isource.sym} 280 -410 0 0 {name=I0 value=\{ib\}}
C {lab_wire.sym} 280 -350 0 0 {name=p5 sig_type=std_logic lab=I_B}

N 380 -470 380 -440 {lab=VINP3}
N 380 -380 380 -350 {lab=VSS}
C {lab_wire.sym} 380 -470 0 0 {name=p9 sig_type=std_logic lab=VINP3}
C {vsource.sym} 380 -410 0 0 {name=V3 value="pulse(0.55 0.65 20n 1n 1n 500n 1.2u)"}
C {lab_wire.sym} 380 -350 0 0 {name=p10 sig_type=std_logic lab=VSS}

N 720 -480 720 -440 {lab=VDD}
C {vdd.sym} 720 -480 0 0 {name=l1 lab=VDD}

N 720 -300 720 -260 {lab=VSS}
C {lab_wire.sym} 720 -260 0 0 {name=p1 sig_type=std_logic lab=VSS}

N 610 -350 650 -350 {lab=I_B}
C {lab_wire.sym} 610 -350 2 0 {name=p2 sig_type=std_logic lab=I_B}

N 610 -390 650 -390 {lab=VINP3}
C {lab_wire.sym} 610 -390 2 0 {name=p13 sig_type=std_logic lab=VINP3}

N 610 -370 650 -370 {lab=OUT3}
C {lab_wire.sym} 610 -370 2 0 {name=p14 sig_type=std_logic lab=OUT3}

N 820 -370 860 -370 {lab=OUT3}
N 860 -370 920 -370 {lab=OUT3}
N 920 -370 920 -360 {lab=OUT3}
C {lab_wire.sym} 860 -370 0 0 {name=p4 sig_type=std_logic lab=OUT3}

C {capa.sym} 920 -330 0 0 {name=C1 m=1 value=\{cl\} footprint=1206 device="ceramic capacitor"}
N 920 -300 920 -270 {lab=0}
C {gnd.sym} 920 -270 0 0 {name=l6 lab=0}

C {gain_ota.sym} 750 -350 0 0 {name=x3}
C {simulator_commands.sym} 1460 -380 0 0 {name=TRAN_small
simulator=ngspice
only_toplevel=false
value=".control
set num_threads=CACE\{jobs\}
save all

* small step vcm-50mV -> vcm+50mV on the follower
let vlo = CACE\{vcm\} - 0.05
let vhi = CACE\{vcm\} + 0.05
alter @v3[pulse] = [ $&vlo $&vhi 20n 1n 1n 500n 1.2u ]

tran 0.1n 1.2u
run

let v_ins  = v(vinp3)
let v_outs = v(out3)

let v50 = CACE\{vcm\}
let v10 = CACE\{vcm\} - 0.04
let v90 = CACE\{vcm\} + 0.04

meas tran t_in_50  when v_ins=$&v50  rise=1
meas tran t_out_10 when v_outs=$&v10 rise=1
meas tran t_out_90 when v_outs=$&v90 rise=1
meas tran t_out_50 when v_outs=$&v50 rise=1

let T_DELAY = t_out_50 - t_in_50
let T_RISE  = t_out_90 - t_out_10

meas tran v_final find v_outs at=480n
meas tran v_max max v_outs from=20n to=520n
let OVERSHOOT = max(0, ((v_max - v_final) / (vhi - vlo)) * 100)

let vs01 = v_final - (vhi - vlo) * 0.001
let vs1  = v_final - (vhi - vlo) * 0.01

let TS_1PCT = 0
let TS_01PCT = 0
meas tran t_set1  when v_outs=$&vs1  cross=last from=20n to=500n
let TS_1PCT = max(0, t_set1 - 20n)
meas tran t_set01 when v_outs=$&vs01 cross=last from=20n to=500n
let TS_01PCT = max(0, t_set01 - 20n)
echo $&T_DELAY $&T_RISE $&OVERSHOOT $&TS_1PCT $&TS_01PCT > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"
}
C {simulator_commands_shown.sym} 1410 -580 0 0 {name=Libs_Ngspice1
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
