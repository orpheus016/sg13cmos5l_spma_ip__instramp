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
C {simulator_commands.sym} 1460 -380 0 0 {name=TRAN_small
simulator=ngspice
only_toplevel="false" 
value=".control
set num_threads=CACE\{jobs\}
save all
* small step vcm-50mV -> vcm+50mV on the follower
let vlo = CACE\{vcm\} - 0.05
let vhi = CACE\{vcm\} + 0.05
alter @v3[pulse] = [ $&vlo $&vhi 20n 1n 1n 500n 1.2u ]
tran 0.1n 1.2u
let v_ins = v(vinp3)
let v_outs = v(out3)
let vmid = CACE\{vcm\}
let v10 = vlo + 0.1*(vhi-vlo)
let v90 = vlo + 0.9*(vhi-vlo)
let vs1 = vhi - 0.01*(vhi-vlo)
let vs01 = vhi - 0.001*(vhi-vlo)
meas tran t_in50 when v_ins=$&vmid rise=1
meas tran t_out10 when v_outs=$&v10 rise=1
meas tran t_out50 when v_outs=$&vmid rise=1
meas tran t_out90 when v_outs=$&v90 rise=1
let T_DELAY = t_out50 - t_in50
let T_RISE = t_out90 - t_out10
meas tran v_peak max v_outs from=20n to=300n
let OVERSHOOT = (v_peak - vhi) / (vhi - vlo)
meas tran t_set1 when v_outs=$&vs1 cross=last from=20n to=500n
let TS_1PCT = t_set1 - 20n
meas tran t_set01 when v_outs=$&vs01 cross=last from=20n to=500n
let TS_01PCT = t_set01 - 20n
echo $&T_DELAY $&T_RISE $&OVERSHOOT $&TS_1PCT $&TS_01PCT > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"=======================================================\\"
echo \\"   OTA SMALL-SIGNAL TRANSIENT SIMULATION RESULTS       \\"
echo \\"=======================================================\\"
echo \\" Small-Signal Delay        : \\" $&t_delay_ns   \\" ns\\"
echo \\" Small-Signal Rise Time    : \\" $&t_rise_ns    \\" ns\\"
echo \\" Peak Voltage (Vpeak)      : \\" $&v_peak       \\" V\\"
echo \\" Overshoot                 : \\" $&overshoot_pct \\" % (Target: < 10%)\\"
echo \\" Settling Time (1% Band)   : \\" $&ts_1pct_ns   \\" ns\\"
echo \\" Settling Time (0.1% Band) : \\" $&ts_01pct_ns  \\" ns\\"
echo \\"=======================================================\\"

* Reset v5 source back to clean DC operating point
alter @v5[pulse] = [ 0.6 0.6 0 0 0 1u 2u ]

plot v_outs v_ins
.endc"
}

