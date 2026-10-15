v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 790 -570 790 -530 {lab=VDD}
N 830 -570 830 -530 {lab=VSS}
N 750 -570 750 -530 {lab=I_B}
N 960 -400 980 -400 {lab=OUT3}
N 960 -400 960 -370 {lab=OUT3}
N 960 -310 960 -280 {lab=0}
N 200 -500 200 -460 {lab=I_B}
N 200 -400 200 -360 {lab=VSS}
N 100 -360 100 -320 {lab=VSS}
N 100 -500 100 -460 {lab=VDD}
N 100 -260 100 -220 {lab=0}
N 300 -500 300 -460 {lab=VINP3}
N 300 -400 300 -360 {lab=VSS}
N 100 -360 200 -360 {lab=VSS}
N 200 -360 300 -360 {lab=VSS}
N 100 -400 100 -360 {lab=VSS}
N 920 -400 960 -400 {lab=OUT3}
N 620 -350 660 -350 {lab=VINP3}
N 620 -450 660 -450 {lab=VINN3}
N 620 -400 660 -400 {lab=VCM}
N 400 -500 400 -460 {lab=VINN3}
N 400 -400 400 -360 {lab=VSS}
N 300 -360 400 -360 {lab=VSS}
N 500 -500 500 -460 {lab=VCM}
N 500 -400 500 -360 {lab=VSS}
N 400 -360 500 -360 {lab=VSS}
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
C {simulator_commands.sym} 1460 -380 0 0 {name=PSRR
simulator=ngspice
only_toplevel="false" 
value=".control
save all
shell mkdir -p result

* PSRR (input-referred) = Adm / A_vdd,  A_vdd = v(out)/ripple on VDD
alter @v5[acmag]=0

* Run 1: differential gain (V3 = +0.5, V4 = -0.5 -> Vid = 1), supply quiet
alter @v1[acmag]=0
alter @v3[acmag]=0.5
alter @v3[acphase]=0
alter @v4[acmag]=0.5
alter @v4[acphase]=180
ac dec 20 1 10G
let vid = v(VINP3) - v(VINN3)
let adm = v(OUT3) / vid

* Run 2: 1 V ripple on VDD, inputs quiet
alter @v1[acmag]=1
alter @v3[acmag]=0
alter @v4[acmag]=0
ac dec 20 1 10G
let avdd = v(OUT3) / (v(VDD) - v(VSS))

let adm_db = db(ac1.adm)
let avdd_db = db(avdd)
let psrr_curve = db(ac1.adm / (avdd + 1e-15))

meas ac adm_dc find adm_db at=10
meas ac psrr_dc find psrr_curve at=10
meas ac psrr_100k find psrr_curve at=100k
meas ac psrr_1meg find psrr_curve at=1MEG

write ./result/tb_instramp_cmos5l_psrr.raw adm_db avdd_db psrr_curve

echo \\"=======================================================\\"
echo \\"  Adm  @ DC / 10 Hz        : \\" $&adm_dc    \\" dB\\"
echo \\"  PSRR @ DC / 10 Hz        : \\" $&psrr_dc   \\" dB (Target: > 60 dB)\\"
echo \\"  PSRR @ 100 kHz           : \\" $&psrr_100k \\" dB\\"
echo \\"  PSRR @ 1 MHz             : \\" $&psrr_1meg \\" dB\\"
echo \\"=======================================================\\"

plot psrr_curve xlog
.endc"
}
C {vdd.sym} 790 -570 0 0 {name=l1 lab=VDD}
C {lab_wire.sym} 830 -570 0 0 {name=p1 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 750 -570 0 0 {name=p2 sig_type=std_logic lab=I_B}
C {capa.sym} 960 -340 0 0 {name=C1
m=1
value=3p
footprint=1206
device="ceramic capacitor"}
C {lab_wire.sym} 980 -400 0 0 {name=p4 sig_type=std_logic lab=OUT3}
C {lab_wire.sym} 200 -500 0 0 {name=p5 sig_type=std_logic lab=I_B}
C {isource.sym} 200 -430 0 0 {name=I0 value=4.2u}
C {vdd.sym} 100 -500 0 0 {name=l2 lab=VDD}
C {vsource.sym} 100 -430 0 0 {name=V1 value=1.2 savecurrent=false}
C {lab_wire.sym} 100 -360 0 0 {name=p7 sig_type=std_logic lab=VSS}
C {vsource.sym} 100 -290 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} 100 -220 0 0 {name=l3 lab=0}
C {lab_wire.sym} 300 -500 0 0 {name=p9 sig_type=std_logic lab=VINP3}
C {vsource.sym} 300 -430 0 0 {name=V3 value=0.6 savecurrent=false}
C {lab_wire.sym} 620 -350 2 0 {name=p13 sig_type=std_logic lab=VINP3}
C {gnd.sym} 960 -280 0 0 {name=l5 lab=0}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/instramp_cmos5l/instramp_cmos5l.sym} 790 -400 0 0 {name=x2}
C {lab_wire.sym} 620 -450 2 0 {name=p3 sig_type=std_logic lab=VINN3}
C {lab_wire.sym} 620 -400 2 0 {name=p6 sig_type=std_logic lab=VCM}
C {lab_wire.sym} 400 -500 0 0 {name=p8 sig_type=std_logic lab=VINN3}
C {vsource.sym} 400 -430 0 0 {name=V4 value=0.6 savecurrent=false}
C {lab_wire.sym} 500 -500 0 0 {name=p10 sig_type=std_logic lab=VCM}
C {vsource.sym} 500 -430 0 0 {name=V5 value=0.6 savecurrent=false}
