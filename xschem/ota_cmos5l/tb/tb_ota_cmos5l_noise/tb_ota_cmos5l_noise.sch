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
x1=5e-07
x2=1.05e-05
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
x1=5e-07
x2=1.05e-05
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
N 720 -560 720 -520 {lab=VDD}
N 760 -560 760 -520 {lab=vss}
N 800 -560 800 -520 {lab=ibias}
N 920 -390 940 -390 {lab=out}
N 920 -390 920 -360 {lab=out}
N 880 -390 920 -390 {lab=out}
N 920 -300 920 -270 {lab=0}
N 280 -480 280 -440 {lab=ibias}
N 280 -380 280 -340 {lab=vss}
N 180 -340 180 -300 {lab=vss}
N 180 -480 180 -440 {lab=VDD}
N 180 -240 180 -200 {lab=0}
N 380 -480 380 -440 {lab=vinp}
N 380 -380 380 -340 {lab=vss}
N 480 -380 480 -340 {lab=vss}
N 480 -480 480 -440 {lab=vinn}
N 600 -430 640 -430 {lab=vinp}
N 600 -350 640 -350 {lab=vinn}
N 380 -340 480 -340 {lab=vss}
N 180 -340 280 -340 {lab=vss}
N 280 -340 380 -340 {lab=vss}
N 180 -380 180 -340 {lab=vss}
C {simulator_commands_shown.sym} 1060 -880 0 0 {name=SimulatorNGSPICE
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
.op

.control
save all

** Set sources
alter @V3[AC] = 1

** Simulation
op
noise v(out) V3 dec 100 1 10G

** Plots
setplot noise1
plot onoise_spectrum
plot inoise_spectrum

** Measurements
let output_noise_at_1MHz = onoise_spectrum[600]
print output_noise_at_1MHz

write tb_ota_cmos5l_noise.raw

.endc
* ngspice commands
"}
C {simulator_commands_shown.sym} 1580 -320 0 0 {
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
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/ota_cmos5l/ota_cmos5l.sym} 760 -390 0 0 {name=x1}
C {vdd.sym} 720 -560 0 0 {name=l1 lab=VDD}
C {lab_wire.sym} 760 -560 0 0 {name=p1 sig_type=std_logic lab=vss}
C {lab_wire.sym} 800 -560 0 0 {name=p2 sig_type=std_logic lab=ibias}
C {capa.sym} 920 -330 0 0 {name=C1
m=1
value=3p
footprint=1206
device="ceramic capacitor"}
C {lab_wire.sym} 940 -390 0 0 {name=p4 sig_type=std_logic lab=out}
C {lab_wire.sym} 280 -480 0 0 {name=p5 sig_type=std_logic lab=ibias}
C {isource.sym} 280 -410 0 0 {name=I0 value=1.4u}
C {vdd.sym} 180 -480 0 0 {name=l2 lab=VDD}
C {vsource.sym} 180 -410 0 0 {name=V1 value=1.5 savecurrent=false}
C {lab_wire.sym} 180 -340 0 0 {name=p7 sig_type=std_logic lab=vss}
C {vsource.sym} 180 -270 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} 180 -200 0 0 {name=l3 lab=0}
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
C {lab_wire.sym} 380 -480 0 0 {name=p9 sig_type=std_logic lab=vinp}
C {vsource.sym} 380 -410 0 0 {name=V3 value=0.75 savecurrent=false}
C {vsource.sym} 480 -410 0 0 {name=V4 value=0.75 savecurrent=false}
C {lab_wire.sym} 480 -480 0 0 {name=p12 sig_type=std_logic lab=vinn}
C {lab_wire.sym} 600 -430 2 0 {name=p13 sig_type=std_logic lab=vinp}
C {lab_wire.sym} 600 -350 2 0 {name=p14 sig_type=std_logic lab=vinn}
C {gnd.sym} 920 -270 0 0 {name=l5 lab=0}
