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
C {lab_wire.sym} 760 -560 0 0 {name=p1 sig_type=std_logic lab=VSS}
C {lab_wire.sym} 800 -560 0 0 {name=p2 sig_type=std_logic lab=I_B}
C {capa.sym} 920 -330 0 0 {name=C1
m=1
value=3p
footprint=1206
device="ceramic capacitor"}
C {lab_wire.sym} 940 -390 0 0 {name=p4 sig_type=std_logic lab=OUT3}
C {lab_wire.sym} 280 -480 0 0 {name=p5 sig_type=std_logic lab=I_B}
C {isource.sym} 280 -410 0 0 {name=I0 value=1.4u}
C {vdd.sym} 180 -480 0 0 {name=l2 lab=VDD}
C {vsource.sym} 180 -410 0 0 {name=V1 value=1.2 savecurrent=false}
C {lab_wire.sym} 180 -340 0 0 {name=p7 sig_type=std_logic lab=VSS}
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
C {lab_wire.sym} 380 -480 0 0 {name=p9 sig_type=std_logic lab=VINP3}
C {vsource.sym} 380 -410 0 0 {name=V3 value=0.6 savecurrent=false}
C {lab_wire.sym} 600 -430 2 0 {name=p13 sig_type=std_logic lab=VINP3}
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
.param lbias=0.15u wbias=0.15u
.param m6=1 m7=4 m8=8
.param linpair=3u winpair=20u
.param lload=5u wload=10u
.param lcs=3u wcs=20u
.param Cc=2p
"
      }
C {simulator_commands.sym} 1460 -380 0 0 {name=TRAN_large
simulator=ngspice
only_toplevel="false" 
value=".control
shell mkdir -p result

* LARGE-SIGNAL STEP RESPONSE (SLEW RATE & PROPAGATION DELAYS)
* Stimulus: Pulse swing 0.2 V to 1.0 V (Delta V = 0.8 V, Vcm = 0.6 V)
alter @v3[pulse] = [ 0.2 1.0 20n 1n 1n 2u 5u ]

tran 0.2n 5u
run

let v_inl  = v(vinp3)
let v_outl = v(out3)

* --- Rising Edge Analysis ---
* Input 50% crossing (0.60 V)
meas tran t_in_r50  when v_inl=0.60 rise=1

* Output 10% (0.28 V), 50% (0.60 V), and 90% (0.92 V) crossings
meas tran t_out_r10 when v_outl=0.28 rise=1
meas tran t_out_r50 when v_outl=0.60 rise=1
meas tran t_out_r90 when v_outl=0.92 rise=1

* Compute Rise Time, Positive Slew Rate (SR+), and Propagation Delay (tpLH)
let t_rise_ns = (t_out_r90 - t_out_r10) * 1e9
let sr_pos    = (0.92 - 0.28) / (t_out_r90 - t_out_r10) / 1e6
let t_plh_ns  = (t_out_r50 - t_in_r50) * 1e9

* --- Falling Edge Analysis ---
* Input 50% crossing (0.60 V)
meas tran t_in_f50  when v_inl=0.60 fall=1

* Output 90% (0.92 V), 50% (0.60 V), and 10% (0.28 V) crossings
meas tran t_out_f90 when v_outl=0.92 fall=1
meas tran t_out_f50 when v_outl=0.60 fall=1
meas tran t_out_f10 when v_outl=0.28 fall=1

* Compute Fall Time, Negative Slew Rate (SR-), and Propagation Delay (tpHL)
let t_fall_ns = (t_out_f10 - t_out_f90) * 1e9
let sr_neg    = (0.92 - 0.28) / (t_out_f10 - t_out_f90) / 1e6
let t_phl_ns  = (t_out_f50 - t_in_f50) * 1e9

* Save output waveforms to the specified rawfile
write ./result/tb_cg_ota_tran_large.raw v_inl v_outl

* Print execution summary
echo \\"=======================================================\\"
echo \\"   OTA LARGE-SIGNAL TRANSIENT SIMULATION RESULTS       \\"
echo \\"=======================================================\\"
echo \\" Positive Slew Rate (SR+)  : \\" $&sr_pos    \\" V/us\\"
echo \\" Negative Slew Rate (SR-)  : \\" $&sr_neg    \\" V/us\\"
echo \\" Rise Time 10% - 90% (tr)  : \\" $&t_rise_ns \\" ns\\"
echo \\" Fall Time 90% - 10% (tf)  : \\" $&t_fall_ns \\" ns\\"
echo \\" Propagation Delay (tpLH)  : \\" $&t_plh_ns  \\" ns\\"
echo \\" Propagation Delay (tpHL)  : \\" $&t_phl_ns  \\" ns\\"
echo \\"=======================================================\\"

* Reset v5 source back to clean DC operating point
alter @v5[pulse] = [ 0.6 0.6 0 0 0 1u 2u ]

plot v_outl v_inl
.endc"
}
