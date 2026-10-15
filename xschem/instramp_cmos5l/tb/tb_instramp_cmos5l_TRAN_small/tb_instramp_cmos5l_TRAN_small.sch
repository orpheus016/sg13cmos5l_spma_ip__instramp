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
x1=-1e-06
x2=9e-06
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
x1=-1e-06
x2=9e-06
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
N 750 -560 750 -520 {lab=VDD}
N 790 -560 790 -520 {lab=VSS}
N 710 -560 710 -520 {lab=I_B}
N 920 -390 940 -390 {lab=OUT3}
N 920 -390 920 -360 {lab=OUT3}
N 920 -300 920 -270 {lab=0}
N 180 -480 180 -440 {lab=I_B}
N 180 -380 180 -340 {lab=VSS}
N 80 -340 80 -300 {lab=VSS}
N 80 -480 80 -440 {lab=VDD}
N 80 -240 80 -200 {lab=0}
N 280 -480 280 -440 {lab=VINP3}
N 280 -380 280 -340 {lab=VSS}
N 580 -340 620 -340 {lab=VINP3}
N 580 -440 620 -440 {lab=VINN3
}
N 80 -340 180 -340 {lab=VSS}
N 180 -340 280 -340 {lab=VSS}
N 80 -380 80 -340 {lab=VSS}
N 880 -390 920 -390 {lab=OUT3}
N 580 -390 620 -390 {lab=VCM}
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
C {vdd.sym} 750 -560 0 0 {name=l1 lab=VDD}
C {lab_wire.sym} 790 -560 0 0 {name=p1 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 710 -560 0 0 {name=p2 sig_type=std_logic lab=I_B}
C {capa.sym} 920 -330 0 0 {name=C1
m=1
value=3p
footprint=1206
device="ceramic capacitor"}
C {lab_wire.sym} 940 -390 0 0 {name=p4 sig_type=std_logic lab=OUT3}
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
C {lab_wire.sym} 580 -340 2 0 {name=p13 sig_type=std_logic lab=VINP3}
C {gnd.sym} 920 -270 0 0 {name=l5 lab=0}
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
C {simulator_commands.sym} 1460 -380 0 0 {name=TRAN_small
simulator=ngspice
only_toplevel="false" 
value=".control
save all
shell mkdir -p result

* SMALL-SIGNAL TRANSIENT
* Stimulus: 1 uV (peak) 10 Hz sine on 0.6 V common
alter @v3 sin = [ 0.6 1u 10 ]

tran 1m 1

let v_ins  = v(vinp3)
let v_outs = v(out3)

* Gain and mean output level over the last 5 periods
meas tran vo_pp pp v(out3) from=0.5 to=1
meas tran vi_pp pp v(vinp3) from=0.5 to=1
meas tran vo_avg avg v(out3) from=0.5 to=1

* Save output waveforms to the specified rawfile
write ./result/tb_instramp_cmos5l_tran_small.raw v_ins v_outs

echo \\"=======================================================\\"
echo \\"  Small-signal gain (pp/pp) : \\" $&vo_pp \\" / \\" $&vi_pp
echo \\"  Mean output level         : \\" $&vo_avg \\" V\\"
echo \\"=======================================================\\"

plot v_outs
.endc"
}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/instramp_cmos5l/instramp_cmos5l.sym} 750 -390 0 0 {name=x2}
C {lab_wire.sym} 580 -390 2 0 {name=p3 sig_type=std_logic lab=VCM}
C {lab_wire.sym} 580 -440 2 0 {name=p6 sig_type=std_logic lab=VINN3}
C {lab_wire.sym} 380 -480 0 0 {name=p8 sig_type=std_logic lab=VINN3}
C {vsource.sym} 380 -410 0 0 {name=V4 value=0.6 savecurrent=false}
C {lab_wire.sym} 480 -480 0 0 {name=p10 sig_type=std_logic lab=VCM}
C {vsource.sym} 480 -410 0 0 {name=V5 value=0.6 savecurrent=false}
