v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 160 -1010 960 -610 {flags=graph
y1=0
y2=2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=-5e-07
x2=9.5e-06
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node=""
color=""
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 160 -1440 960 -1040 {flags=graph
y1=0
y2=2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=10e-6
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node=""
color=""
dataset=-1
unitx=1
logx=0
logy=0
}
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
name=Libs_Ngspice
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
C {simulator_commands_shown.sym} 1080 -810 0 0 {name=General_Params
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
C {simulator_commands_shown.sym} 1080 -620 0 0 {name=OTA_Params
simulator=ngspice
only_toplevel=false
value=".param temp=27
"
      }
C {isource.sym} 210 -430 0 0 {name=I1 value=\{ib\}}
C {vsource.sym} 130 -430 0 0 {name=V5 value=\{vdd\} savecurrent=false}
C {gnd.sym} 130 -380 0 0 {name=l6 lab=0}
C {vdd.sym} 130 -470 0 0 {name=l7 lab=VDD}
C {lab_pin.sym} 210 -480 1 0 {name=p3 sig_type=std_logic lab=I_B}
C {vsource.sym} 50 -430 0 0 {name=V6 value=0 savecurrent=false}
C {gnd.sym} 50 -380 0 0 {name=l8 lab=0}
C {lab_pin.sym} 50 -470 1 0 {name=p6 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} 210 -380 3 0 {name=p11 sig_type=std_logic lab=VSS
}
C {vsource.sym} 290 -430 0 0 {name=V1 value=\{vicm\} savecurrent=false
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
C {lab_pin.sym} 100 -180 0 0 {name=p19 sig_type=std_logic lab=OUT2
}
C {lab_pin.sym} 300 -180 2 0 {name=p22 sig_type=std_logic lab=VINN2
}
C {lab_pin.sym} 550 -250 0 0 {name=p5 sig_type=std_logic lab=VINN2
}
C {lab_pin.sym} 690 -450 1 0 {name=p15 sig_type=std_logic lab=VSS
}
C {lab_pin.sym} 550 -330 0 0 {name=p16 sig_type=std_logic lab=VINP2
}
C {lab_pin.sym} 830 -290 2 0 {name=p17 sig_type=std_logic lab=OUT2
}
C {vdd.sym} 650 -450 0 0 {name=l2 lab=VDD
}
C {lab_pin.sym} 730 -440 1 0 {name=p18 sig_type=std_logic lab=I_B
}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/ota_cmos5l/ota_cmos5l.sym} 690 -290 0 0 {name=x2
}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/coarse_gain/tb/tb_cg_ota/loopgainprobe.sym} 200 -180 0 0 {name=X999 device=loopgainprobe
}
C {simulator_commands.sym} 1460 -600 0 0 {name=AC
simulator=ngspice
only_toplevel="false" 
value=".control
save all
shell mkdir -p result

* 1st Injection: AC Voltage + 1st AC sim
alter i.x999.ii acmag=0
alter v.x999.vi acmag=1
ac dec 50 1 10G

* 2nd Injection: AC Current + 2nd AC sim
alter i.x999.ii acmag=1
alter v.x999.vi acmag=0
ac dec 50 1 10G

* Set default plot to 1st AC sim
setplot ac1

let t_gain = tian_loop()
let loop_mag = db(t_gain)
let loop_ph = 180 + (180 * cph(t_gain) / pi)

meas ac dc_gain find loop_mag at=10
let dc_gain_lin = 10^(dc_gain / 20)
let target_3db = dc_gain - 3
meas ac f_3db when loop_mag=target_3db
meas ac ph_3db find loop_ph when loop_mag=target_3db

meas ac ugbw when loop_mag=0
meas ac pm find loop_ph when loop_mag=0

meas ac f_180 when loop_ph=0
meas ac gain_margin find loop_mag when loop_ph=0
let gm_db=-gain_margin

let gbw_calc=dc_gain_lin * f_3db

write ./result/tb_cg_ota_ac.raw loop_mag loop_ph

echo \\"=======================================================\\"
echo \\" DC Gain (dB): \\" $&dc_gain \\" dB\\"
echo \\" DC Gain (Lin): \\" $&dc_gain_lin \\" V/V\\"
echo \\" Bandwidth 3dB (f_3dB): \\" $&f_3db \\" Hz\\"
echo \\" Phase 3dB (f_3dB): \\" $&ph_3db \\" deg (Ideally, ~135 deg)\\"
echo \\" Unity-Gain BW (UGBW): \\" $&ugbw \\" Hz\\"
echo \\" Phase Margin (PM): \\" $&pm \\" deg (Ideally, > 60 deg)\\"
echo \\" Gain Margin (GM): \\" $&gm_db \\" dB\\"
echo \\" Phase Crossover (f_180): \\" $&f_180 \\" Hz\\"
echo \\" GBW Product (PM): \\" $&gbw_calc \\" Hz\\"


plot re(loop_mag) re(loop_ph) xlog

.endc"
}
