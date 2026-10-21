v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {title.sym} 160 -30 0 0 {name=l4 author="SPMA"}
C {simulator_commands_shown.sym} 1080 -410 0 0 {name=loopgainprobe
simulator=ngspice
only_toplevel=false
value=".subckt loopgainprobe a b
Ii 0 x DC 0 AC 0
Vi x a DC 0 AC 1
Vnodebuffer b x 0
.ends loopgainprobe

.func tian_loop() \{1/(1/(2*(ac1.i(v.x999.Vi)*ac2.v(x999.x)-ac1.v(x999.x)*ac2.i(v.x999.Vi))+ac1.v(x999.x)+ac2.i(v.x999.Vi))-1)\}
"
}
N 130 -470 130 -460 {lab=VDD}
N 130 -400 130 -380 {lab=0}
C {vdd.sym} 130 -470 0 0 {name=l7 lab=VDD}
C {vsource.sym} 130 -430 0 0 {name=V5 value=\{vdd\} savecurrent=false}
C {gnd.sym} 130 -380 0 0 {name=l6 lab=0}

N 50 -470 50 -460 {lab=VSS}
N 50 -400 50 -380 {lab=0}
C {lab_pin.sym} 50 -470 1 0 {name=p6 sig_type=std_logic lab=VSS}
C {vsource.sym} 50 -430 0 0 {name=V6 value=0 savecurrent=false}
C {gnd.sym} 50 -380 0 0 {name=l8 lab=0}

N 210 -470 210 -460 {lab=VDD}
N 210 -400 210 -380 {lab=I_B}
C {vdd.sym} 210 -470 0 0 {name=l9 lab=VDD}
C {isource.sym} 210 -430 0 0 {name=I1 value=\{ib\}}
C {lab_pin.sym} 210 -380 3 0 {name=p3 sig_type=std_logic lab=I_B}

N 290 -480 290 -460 {lab=VINP2}
N 290 -400 290 -380 {lab=VSS}
C {lab_pin.sym} 290 -480 1 0 {name=p20 sig_type=std_logic lab=VINP2}
C {vsource.sym} 290 -430 0 0 {name=V1 value=\{vicm\} savecurrent=false}
C {lab_pin.sym} 290 -380 3 0 {name=p21 sig_type=std_logic lab=VSS}

N 370 -480 370 -460 {lab=OUT2}
N 370 -400 370 -390 {lab=0}
C {lab_pin.sym} 370 -480 1 0 {name=p26 sig_type=std_logic lab=OUT2}
C {capa.sym} 370 -430 0 0 {name=C3 m=1 value=\{cl\} footprint=1206 device="ceramic capacitor"}
C {gnd.sym} 370 -390 0 0 {name=l10 lab=0}

N 100 -180 120 -180 {lab=OUT2}
N 280 -180 300 -180 {lab=VINN2}
C {lab_pin.sym} 100 -180 0 0 {name=p19 sig_type=std_logic lab=OUT2}
C {loopgainprobe.sym} 200 -180 0 0 {name=X999 device=loopgainprobe}
C {lab_pin.sym} 300 -180 2 0 {name=p22 sig_type=std_logic lab=VINN2}

N 650 -370 650 -340 {lab=VDD}
C {vdd.sym} 650 -370 0 0 {name=l2 lab=VDD}

N 560 -290 580 -290 {lab=VINP2}
C {lab_pin.sym} 560 -290 0 0 {name=p16 sig_type=std_logic lab=VINP2}

N 560 -270 580 -270 {lab=VINN2}
C {lab_pin.sym} 560 -270 0 0 {name=p5 sig_type=std_logic lab=VINN2}

N 750 -270 770 -270 {lab=OUT2}
C {lab_pin.sym} 770 -270 2 0 {name=p17 sig_type=std_logic lab=OUT2}

N 560 -250 580 -250 {lab=I_B}
C {lab_pin.sym} 560 -250 0 0 {name=p18 sig_type=std_logic lab=I_B}

N 650 -200 650 -170 {lab=VSS}
C {lab_pin.sym} 650 -170 0 0 {name=p15 sig_type=std_logic lab=VSS}

C {gain_ota.sym} 680 -250 0 0 {name=x2}

C {simulator_commands.sym} 1460 -600 0 0 {name=Noise
simulator=ngspice
only_toplevel="false"
value=".control
set num_threads=CACE\{jobs\}
save all
destroy all

* Tian probe idled
alter i.x999.ii acmag=0
alter v.x999.vi acmag=0

* Add AC 1 to Vicm source V1
alter @v1[acmag]=1

* Noise simulation (referred to V1, 10 Hz to 100 MHz)
noise v(OUT2) v1 dec 20 10 100MEG

* Return to initial condition
alter @v1[acmag]=0

setplot noise1

* Parameters #1
let inoise_total_uv = noise2.inoise_total * 1e6
let onoise_total_uv = noise2.onoise_total * 1e6
let irn_nv = noise1.inoise_spectrum * 1e9
let orn_nv = noise1.onoise_spectrum * 1e9

* IRN extraction at certain frequencies
let irn_100 = irn_nv[20]
let irn_1k = irn_nv[40]
let irn_10k = irn_nv[60]
let irn_1meg = irn_nv[100]

let cace_IRN_100 = irn_100*1e-9
let cace_IRN_1K = irn_1k*1e-9
let cace_IRN_10K = irn_10k*1e-9
let cace_IRN_1M = irn_1meg*1e-9
let cace_ORN_1K = orn_nv[40]*1e-9
let cace_INOISE_TOT = inoise_total_uv*1e-6
let cace_ONOISE_TOT = onoise_total_uv*1e-6
echo $&cace_IRN_100 $&cace_IRN_1K $&cace_IRN_10K $&cace_IRN_1M $&cace_ORN_1K $&cace_INOISE_TOT $&cace_ONOISE_TOT > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"
}
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
.param vicm=CACE\{vcm\}
.param vid=0
"
}
