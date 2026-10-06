v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 770 -550 770 -510 {lab=VDD}
N 810 -550 810 -510 {lab=vss}
N 730 -550 730 -510 {lab=ibias}
N 960 -380 960 -350 {lab=out}
N 960 -290 960 -260 {lab=0}
N 180 -480 180 -440 {lab=ibias}
N 180 -380 180 -340 {lab=vss}
N 80 -340 80 -300 {lab=vss}
N 80 -480 80 -440 {lab=VDD}
N 80 -240 80 -200 {lab=0}
N 280 -480 280 -440 {lab=vinp}
N 280 -380 280 -340 {lab=vss}
N 380 -380 380 -340 {lab=vss}
N 380 -480 380 -440 {lab=vinn}
N 280 -340 380 -340 {lab=vss}
N 80 -340 180 -340 {lab=vss}
N 180 -340 280 -340 {lab=vss}
N 80 -380 80 -340 {lab=vss}
N 580 -430 640 -430 {lab=vinn}
N 580 -330 640 -330 {lab=vinp}
N 580 -380 640 -380 {lab=vcm}
N 960 -380 1000 -380 {lab=out}
N 900 -380 960 -380 {lab=out}
N 480 -480 480 -440 {lab=vcm}
N 480 -380 480 -340 {lab=vss}
N 380 -340 480 -340 {lab=vss}
C {simulator_commands_shown.sym} 1070 -970 0 0 {name=SimulatorNGSPICE
simulator=ngspice
only_toplevel=false 
value="
.param temp=27
.param lbias=0.15u wbias=0.15u
.param m6=1 m7=4 m8=8
.param linpair=3u winpair=20u
.param lload=5u wload=10u
.param lcs=3u wcs=20u
.param Cc=2p
.ac DEC

.control
save all

** Set sources
alter @V3[AC] = 1

** Simulations
ac dec 100 1 10G

** Plots
setplot ac1
let gain_db = db(v(out))
plot gain_db
let phase_deg = cph(v(out))*180/pi
plot phase_deg

** Measurements
meas ac DC_gain FIND gain_db AT=1Hz
let gain_3db = DC_gain-3
meas ac f_3db WHEN gain_db=$&gain_3db
meas ac f_0db WHEN gain_db=0
meas ac phase_0db FIND phase_deg WHEN gain_db=0
let phase_margin = 180 + phase_0db
print phase_margin

write tb_instramp_cmos5l_ac.raw

.endc
* ngspice commands
"}
C {simulator_commands_shown.sym} 1560 -300 0 0 {
name=Libs_Ngspice
simulator=ngspice
only_toplevel=false
value="
.lib cornerMOSlv.lib mos_tt
.lib cornerMOShv.lib mos_tt
.lib cornerRES.lib res_typ
.lib cornerDIO.lib dio_tt
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
C {vdd.sym} 770 -550 0 0 {name=l1 lab=VDD}
C {lab_wire.sym} 810 -550 0 0 {name=p1 sig_type=std_logic lab=vss}
C {lab_wire.sym} 730 -550 0 0 {name=p2 sig_type=std_logic lab=ibias}
C {capa.sym} 960 -320 0 0 {name=C1
m=1
value=3p
footprint=1206
device="ceramic capacitor"}
C {lab_wire.sym} 1000 -380 0 0 {name=p4 sig_type=std_logic lab=out}
C {lab_wire.sym} 180 -480 0 0 {name=p5 sig_type=std_logic lab=ibias}
C {isource.sym} 180 -410 0 0 {name=I0 value=4.2u}
C {vdd.sym} 80 -480 0 0 {name=l2 lab=VDD}
C {vsource.sym} 80 -410 0 0 {name=V1 value=1.5 savecurrent=false}
C {lab_wire.sym} 80 -340 0 0 {name=p7 sig_type=std_logic lab=vss}
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
C {lab_wire.sym} 280 -480 0 0 {name=p9 sig_type=std_logic lab=vinp}
C {vsource.sym} 280 -410 0 0 {name=V3 value=0.75 savecurrent=false}
C {vsource.sym} 380 -410 0 0 {name=V4 value=0.75 savecurrent=false}
C {lab_wire.sym} 380 -480 0 0 {name=p12 sig_type=std_logic lab=vinn}
C {lab_wire.sym} 580 -330 2 0 {name=p13 sig_type=std_logic lab=vinp}
C {lab_wire.sym} 580 -430 2 0 {name=p14 sig_type=std_logic lab=vinn}
C {gnd.sym} 960 -260 0 0 {name=l5 lab=0}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/instramp_cmos5l/instramp_cmos5l.sym} 770 -380 0 0 {name=x1}
C {lab_wire.sym} 580 -380 2 0 {name=p3 sig_type=std_logic lab=vcm}
C {vsource.sym} 480 -410 0 0 {name=V5 value=0.75 savecurrent=false}
C {lab_wire.sym} 480 -480 0 0 {name=p6 sig_type=std_logic lab=vcm}
