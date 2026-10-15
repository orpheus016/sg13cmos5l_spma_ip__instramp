v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 770 -550 770 -510 {lab=VDD}
N 810 -550 810 -510 {lab=VSS}
N 730 -550 730 -510 {lab=I_B}
N 940 -380 960 -380 {lab=OUT3}
N 940 -380 940 -350 {lab=OUT3}
N 940 -290 940 -260 {lab=0}
N 180 -480 180 -440 {lab=I_B}
N 180 -380 180 -340 {lab=VSS}
N 80 -340 80 -300 {lab=VSS}
N 80 -480 80 -440 {lab=VDD}
N 80 -240 80 -200 {lab=0}
N 280 -480 280 -440 {lab=VINP3}
N 280 -380 280 -340 {lab=VSS}
N 80 -340 180 -340 {lab=VSS}
N 180 -340 280 -340 {lab=VSS}
N 80 -380 80 -340 {lab=VSS}
N 900 -380 940 -380 {lab=OUT3}
N 600 -330 640 -330 {lab=VINP3}
N 600 -430 640 -430 {lab=VINN3}
N 600 -380 640 -380 {lab=VCM}
N 380 -480 380 -440 {lab=VINN3}
N 380 -380 380 -340 {lab=VSS}
N 280 -340 380 -340 {lab=VSS}
N 480 -480 480 -440 {lab=VCM}
N 480 -380 480 -340 {lab=VSS}
N 380 -340 480 -340 {lab=VSS}
C {launcher.sym} 1140 -160 0 0 {name=h4
descr=SimulateNGSPICE
tclcommand="
# Setup the default simulation commands if not already set up
# for example by already launched simulations.
set_sim_defaults
puts $sim(spice,1,cmd) 

# Change the Xyce command. In the spice category there are currently
# 5 commands (0, 1, 2, 3, 4). Command 3 is the Xyce batch
# you can get the number by querying $sim(spice,n)
set sim(spice,1,cmd) \{ngspice  \\"$N\\" -a\}

# change the simulator to be used (Xyce)
set sim(spice,default) 0

# Create FET .save file
mkdir -p $netlist_dir
write_data [save_params] $netlist_dir/[file rootname [file tail [xschem get current_name]]].save

# run netlist and simulation
xschem netlist
simulate
"}
C {title.sym} 160 -30 0 0 {name=l4 author="James Patrick"}
C {vdd.sym} 770 -550 0 0 {name=l1 lab=VDD}
C {lab_wire.sym} 810 -550 0 0 {name=p1 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 730 -550 0 0 {name=p2 sig_type=std_logic lab=I_B}
C {capa.sym} 940 -320 0 0 {name=C1
m=1
value=3p
footprint=1206
device="ceramic capacitor"}
C {lab_wire.sym} 960 -380 0 0 {name=p4 sig_type=std_logic lab=OUT3}
C {lab_wire.sym} 180 -480 0 0 {name=p5 sig_type=std_logic lab=I_B}
C {isource.sym} 180 -410 0 0 {name=I0 value=4.2u}
C {vdd.sym} 80 -480 0 0 {name=l2 lab=VDD}
C {vsource.sym} 80 -410 0 0 {name=V1 value=1.2 savecurrent=false}
C {lab_wire.sym} 80 -340 0 0 {name=p7 sig_type=std_logic lab=VSS}
C {vsource.sym} 80 -270 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} 80 -200 0 0 {name=l3 lab=0}
C {devices/launcher.sym} 1140 -110 0 0 {name=h2
descr="OP annotate" 
tclcommand="xschem annotate_op"
}
C {devices/launcher.sym} 1440 -160 0 0 {name=h3
descr="Load waves" 
tclcommand="
xschem raw_read $netlist_dir/[file rootname [file tail [xschem get current_name]]].raw dc
xschem setprop rect 2 0 fullxzoom
"
}
C {lab_wire.sym} 280 -480 0 0 {name=p9 sig_type=std_logic lab=VINP3}
C {vsource.sym} 280 -410 0 0 {name=V3 value=0.6 savecurrent=false}
C {lab_wire.sym} 600 -330 2 0 {name=p13 sig_type=std_logic lab=VINP3}
C {gnd.sym} 940 -260 0 0 {name=l5 lab=0}
C {simulator_commands_shown.sym} 1410 -580 0 0 {
name=Libs_Ngspice1
simulator=ngspice
only_toplevel=false
value="
.lib cornerMOSlv.lib mos_tt
.lib cornerMOShv.lib mos_tt
.lib cornerRES.lib res_typ
.lib cornerDIO.lib dio_tt
.lib cornerCAP.lib cap_typ
.lib cornerMOSCAP.lib moscap_tt
"
      }
C {simulator_commands_shown.sym} 1080 -580 0 0 {name=General_Params
simulator=ngspice
only_toplevel=false
value=".param temp=27
.param cl=3p
.param ib=1.4u
.param vdd=1.2
.param vicm=vdd/2
.param vid=0
"
      }
C {simulator_commands_shown.sym} 1080 -390 0 0 {name=OTA_Params
simulator=ngspice
only_toplevel=false
value=".param temp=27
"
      }
C {simulator_commands.sym} 1460 -380 0 0 {name=CMRR
simulator=ngspice
only_toplevel="false" 
value=".control
save all
shell mkdir -p result

* CMRR = Adm / Acm  (VCM is a DC reference, no AC)
alter @v1[acmag]=0
alter @v5[acmag]=0

* Run 1: differential (V3 = +0.5, V4 = -0.5 -> Vid = 1)
alter @v3[acmag]=0.5
alter @v3[acphase]=0
alter @v4[acmag]=0.5
alter @v4[acphase]=180
ac dec 20 1 10G
let vid = v(VINP3) - v(VINN3)
let adm = v(OUT3) / vid

* Run 2: common-mode (V3 = V4 = 1)
alter @v3[acmag]=1
alter @v3[acphase]=0
alter @v4[acmag]=1
alter @v4[acphase]=0
ac dec 20 1 10G
let vicm = (v(VINP3) + v(VINN3)) / 2
let acm = v(OUT3) / vicm

let adm_db = db(ac1.adm)
let acm_db = db(acm)
let cmrr_curve = db(ac1.adm / (acm + 1e-15))

meas ac adm_dc find adm_db at=10
meas ac cmrr_dc find cmrr_curve at=10
meas ac cmrr_100k find cmrr_curve at=100k
meas ac cmrr_1meg find cmrr_curve at=1MEG

write ./result/tb_instramp_cmos5l_cmrr.raw adm_db acm_db cmrr_curve

echo \\"=======================================================\\"
echo \\"  Adm  @ DC / 10 Hz        : \\" $&adm_dc    \\" dB\\"
echo \\"  CMRR @ DC / 10 Hz        : \\" $&cmrr_dc   \\" dB (Target: > 60 dB)\\"
echo \\"  CMRR @ 100 kHz           : \\" $&cmrr_100k \\" dB\\"
echo \\"  CMRR @ 1 MHz             : \\" $&cmrr_1meg \\" dB\\"
echo \\"=======================================================\\"

plot cmrr_curve xlog
.endc"
}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/instramp_cmos5l/instramp_cmos5l.sym} 770 -380 0 0 {name=x2}
C {lab_wire.sym} 600 -430 2 0 {name=p3 sig_type=std_logic lab=VINN3}
C {lab_wire.sym} 600 -380 2 0 {name=p6 sig_type=std_logic lab=VCM}
C {lab_wire.sym} 380 -480 0 0 {name=p8 sig_type=std_logic lab=VINN3}
C {vsource.sym} 380 -410 0 0 {name=V4 value=0.6 savecurrent=false}
C {lab_wire.sym} 480 -480 0 0 {name=p10 sig_type=std_logic lab=VCM}
C {vsource.sym} 480 -410 0 0 {name=V5 value=0.6 savecurrent=false}
