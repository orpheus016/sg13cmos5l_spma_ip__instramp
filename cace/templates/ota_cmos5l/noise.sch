v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
T {POWER & BIASING} 80 -550 0 0 0.3 0.3 {}
N 130 -470 130 -460 {lab=VDD}
N 210 -480 210 -460 {lab=I_B}
N 210 -400 210 -380 {lab=VSS}
N 130 -400 130 -380 {lab=0}
N 50 -400 50 -380 {lab=0}
N 50 -470 50 -460 {lab=VSS}
N 290 -480 290 -460 {lab=VINP2
}
N 290 -400 290 -380 {lab=VSS
}
N 370 -400 370 -390 {lab=VSS
}
N 370 -480 370 -460 {lab=OUT2
}
N 100 -180 120 -180 {lab=OUT2
}
N 280 -180 300 -180 {lab=VINN2
}
N 690 -450 690 -420 {lab=VSS
}
N 810 -290 830 -290 {lab=OUT2
}
N 650 -450 650 -420 {lab=VDD
}
N 550 -330 570 -330 {lab=VINP2
}
N 730 -440 730 -420 {lab=I_B
}
N 550 -250 570 -250 {lab=VINN2
}
C {simulator_commands_shown.sym} 1410 -810 0 0 {
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
C {simulator_commands_shown.sym} 1080 -410 0 0 {name=loopgainprobe1
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
C {simulator_commands_shown.sym} 1080 -810 0 0 {name=General_Params
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
C {simulator_commands_shown.sym} 1080 -620 0 0 {name=OTA_Params
simulator=ngspice
only_toplevel=false
value=".param lbias=0.15u wbias=0.15u
.param m6=1 m7=4 m8=8
.param linpair=3u winpair=20u
.param lload=5u wload=10u
.param lcs=3u wcs=20u
.param Cc=2p
"
      }
C {isource.sym} 210 -430 0 0 {name=I1 value=\{ib\}}
C {vsource.sym} 130 -430 0 0 {name=V5 value=\{vdd\} savecurrent=false}
C {gnd.sym} 130 -380 0 0 {name=l7 lab=0}
C {vdd.sym} 130 -470 0 0 {name=l8 lab=VDD}
C {lab_pin.sym} 210 -480 1 0 {name=p3 sig_type=std_logic lab=I_B}
C {vsource.sym} 50 -430 0 0 {name=V6 value=0 savecurrent=false}
C {gnd.sym} 50 -380 0 0 {name=l9 lab=0}
C {lab_pin.sym} 50 -470 1 0 {name=p6 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} 210 -380 3 0 {name=p11 sig_type=std_logic lab=VSS
}
C {vsource.sym} 290 -430 0 0 {name=V4 value=\{vicm\} savecurrent=false
}
C {lab_pin.sym} 290 -480 1 0 {name=p20 sig_type=std_logic lab=VINP2
}
C {lab_pin.sym} 290 -380 3 0 {name=p21 sig_type=std_logic lab=VSS
}
C {capa.sym} 370 -430 0 0 {name=C3
m=1
value=\{cl\}
footprint=1206
device="ceramic capacitor"
}
C {lab_pin.sym} 370 -390 3 0 {name=p25 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} 370 -480 1 0 {name=p26 sig_type=std_logic lab=OUT2
}
C {lab_pin.sym} 100 -180 0 0 {name=p8 sig_type=std_logic lab=OUT2
}
C {lab_pin.sym} 300 -180 2 0 {name=p10 sig_type=std_logic lab=VINN2
}
C {lab_pin.sym} 550 -250 0 0 {name=p12 sig_type=std_logic lab=VINN2
}
C {lab_pin.sym} 690 -450 1 0 {name=p15 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} 550 -330 0 0 {name=p16 sig_type=std_logic lab=VINP2
}
C {lab_pin.sym} 830 -290 2 0 {name=p17 sig_type=std_logic lab=OUT2
}
C {vdd.sym} 650 -450 0 0 {name=l10 lab=VDD
}
C {lab_pin.sym} 730 -440 1 0 {name=p18 sig_type=std_logic lab=I_B
}
C {ota_cmos5l.sym} 690 -290 0 0 {name=x2
}
C {loopgainprobe.sym} 200 -180 0 0 {name=X3 device=loopgainprobe
}
C {simulator_commands.sym} 1400 -560 0 0 {name=Noise
simulator=ngspice
only_toplevel=false 
value=".control
set num_threads=CACE\{jobs\}
save all
destroy all
* noise referred to the input source v4 (vicm)
alter @v4[acmag]=1
noise v(out2) v4 dec 20 10 100MEG
setplot noise1
let IRN_100 = inoise_spectrum[20]
let IRN_1K = inoise_spectrum[40]
let IRN_10K = inoise_spectrum[60]
let IRN_1M = inoise_spectrum[100]
let ORN_1K = onoise_spectrum[40]
let INOISE_TOT = noise2.inoise_total
let ONOISE_TOT = noise2.onoise_total
echo $&IRN_100 $&IRN_1K $&IRN_10K $&IRN_1M $&ORN_1K $&INOISE_TOT $&ONOISE_TOT > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"=======================================================\\"
echo \\" Total Output Noise (10 Hz - 100 MHz): \\" $&onoise_total_uv \\" uV_rms\\"
echo \\" Total Input Noise (10 Hz - 100 MHz): \\" $&inoise_total_uv \\" uV_rms\\"
echo \\"-------------------------------------------------------\\"
echo \\" IRN @ 10 Hz (Flicker Noise): \\" $&irn_10 \\" nV/sqrt(Hz)\\"
echo \\" IRN @ 100 Hz: \\" $&irn_100 \\" nV/sqrt(Hz)\\"
echo \\" IRN @ 1 kHz: \\" $&irn_1k \\" nV/sqrt(Hz)\\"
echo \\" IRN @ 10 kHz: \\" $&irn_10k \\" nV/sqrt(Hz)\\"
echo \\" IRN @ 100 kHz: \\" $&irn_100k \\" nV/sqrt(Hz)\\"
echo \\" IRN @ 1 MHz (Thermal Noise Floor): \\" $&irn_1meg \\" nV/sqrt(Hz)\\"
echo \\"=======================================================\\"

.endc
"
}

