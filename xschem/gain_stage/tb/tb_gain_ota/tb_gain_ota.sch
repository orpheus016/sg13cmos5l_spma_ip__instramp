v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
L 4 -320 30 20 30 {}
L 4 -320 -660 -320 30 {}
L 4 20 30 760 30 {}
L 4 550 -760 550 30 {}
L 4 20 -760 760 -760 {}
L 4 -320 -760 20 -760 {}
L 4 -320 -760 -320 -660 {}
L 4 -10 -760 -10 30 {}
L 4 -320 -1040 -320 -760 {}
L 4 1280 -760 1280 30 {}
L 4 760 30 1280 30 {}
L 4 760 -760 1280 -760 {}
L 4 1280 30 2060 30 {}
L 4 2060 -760 2060 30 {}
L 4 1270 -760 2060 -760 {}
L 4 -320 -1280 -320 -1040 {}
L 4 -320 -1280 2060 -1280 {}
L 4 -320 -230 -10 -230 {}
L 4 -320 -540 -10 -540 {}
L 4 -320 -370 -10 -370 {}
L 4 650 -1010 650 -760 {}
L 4 -320 30 -320 1620 {}
L 4 -320 1620 1700 1620 {}
L 4 -320 830 340 830 {}
L 4 340 30 340 830 {}
L 4 1700 30 1700 830 {}
L 4 1700 830 1700 1250 {}
L 4 1700 1250 1700 1620 {}
L 4 650 -1010 880 -1010 {}
L 4 990 -1010 990 -760 {}
L 4 2060 -1280 2060 -760 {}
L 4 340 830 340 1620 {}
L 4 1000 830 1000 1620 {}
L 4 340 830 1000 830 {}
L 4 1000 460 1000 830 {}
L 4 1000 460 1700 460 {}
L 4 1000 1260 1700 1260 {}
L 4 880 -1010 990 -1010 {}
B 2 -300 100 320 420 {flags=graph
y1=-0.1
y2=1.5
ypos1=0
ypos2=2
divy=10
subdivy=1
unity="V"
x1=-2.5
x2=7.5
divx=20
subdivx=1
xlabmag=1.25
ylabmag=1.75
legendmag=1.0
node="vout_sw"
color=""
dataset=-1
unitx="V"
logx=0
logy=0
}
B 2 -300 470 320 790 {flags=graph
y1=0
y2=1.4k
ypos1=-0.1
ypos2=1
divy=5
subdivy=1
unity=1
x1=-2.5
x2=7.5
divx=20
subdivx=1
xlabmag=1.5
ylabmag=1.0
legendmag=1.0
node="diff_gain"
color=""
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 -300 900 320 1220 {flags=graph
y1=-0.05
y2=1.8
ypos1="0"
ypos2=1
divy=8
subdivy=1
unity=A
x1=-2.5
x2=7.5
divx=6
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.5
node="i_outp_ma
i_outn_ma"
color="4 6"
dataset=0
unitx=V
logx=0
logy=0
}
B 2 -300 1250 320 1570 {flags=graph
y1=0
y2=120
ypos1=0
ypos2=2
divy=20
subdivy=1
unity=1
x1=-2.5
x2=7.5
divx=5
subdivx=1
xlabmag=1.0
ylabmag=3.0
legendmag=1.0
node="gm_eff_ms"
color=""
dataset=-1
unitx=1
logx=0
logy=0
}
B 2 360 100 980 420 {flags=graph
y1=-180
y2=190
ypos1=0
ypos2=2
divy=20
subdivy=1
unity="dB"
x1=-2.5
x2=7.5
divx=20
subdivx=1
xlabmag=1.25
ylabmag=1.75
legendmag=1.0
node="re(loop_mag)
re(loop_ph)"
color="4 5"
dataset=-1
unitx="Hz"
logx=1
logy=0
}
B 2 360 470 980 790 {flags=graph
y1=0
y2=5500
ypos1=0
ypos2=1
divy=20
subdivy=1
unity="V/rtHz"
x1=-2.5
x2=7.5
divx=20
subdivx=1
xlabmag=1
ylabmag=1.5
legendmag=1.0
node="irn_nv"
color="4"
dataset=-1
unitx="Hz"
logx=1
logy=0
}
B 2 1030 100 1650 420 {flags=graph
y1=-200
y2=380
ypos1=0
ypos2=1
divy=20
subdivy=1
unity="dB
deg"
x1=-2.5
x2=7.5
divx=20
subdivx=1
xlabmag=1.25
ylabmag=2
legendmag=1.0
node="re(loop_magnitude)
re(loop_phase)"
color="4 6"
dataset=-1
unitx="Hz"
logx=1
logy=0
}
B 2 360 880 980 1200 {flags="graphs"
y1=0
y2=1.2
ypos1=0
ypos2=2
divy=10
subdivy=1
unity="V V"
x1=-2.5
x2=7.5
divx=5
subdivx=1
xlabmag=1
ylabmag=1.25
legendmag=1.0
node="v_outl
v_inl"
color="1 4"
dataset=-1
unitx="time"
logx=0
logy=0
}
B 2 1040 900 1660 1220 {flags=graph
y1=-10
y2=80
ypos1=0
ypos2=1
divy=10
subdivy=1
unity="dB"
x1=-2.5
x2=7.5
divx=15
subdivx=1
xlabmag=1
ylabmag=1.25
legendmag=1.0
node="re(cmrr_curve)"
color=""
dataset=-1
unitx="Hz"
logx=1
logy=0
}
B 2 1040 530 1660 850 {flags=graph
y1=-5
y2=40
ypos1=0
ypos2=1
divy=15
subdivy=1
unity="dB"
x1=-2.5
x2=7.5
divx=15
subdivx=1
xlabmag=1
ylabmag=1.5
legendmag=1.0
node="re(psrr_curve)"
color=""
dataset=-1
unitx="Hz"
logx=1
logy=0
}
B 2 360 1240 980 1560 {flags=graph
y1=0.55
y2=0.7
ypos1=0
ypos2=2
divy=15
subdivy=1
unity="V"
x1=-2.5
x2=7.5
divx=6
subdivx=1
xlabmag=1
ylabmag=1.25
legendmag=1.0
node="v_outs
v_ins"
color="1 4"
dataset=-1
unitx="time"
logx=0
logy=0
}
B 2 1040 1300 1340 1440 {flags=graph
y1=0
y2=1.2
ypos1=0
ypos2=1
divy=10
subdivy=1
unity="V"
x1=-2.5
x2=7.5
divx=10
subdivx=1
xlabmag=1.25
ylabmag=1.5
legendmag=1.0
node="v_out"
color=""
dataset=-1
unitx="V"
logx=0
logy=0
}
B 2 1360 1300 1660 1440 {flags=graph
y1=0
y2=30
ypos1=0
ypos2=1
divy=10
subdivy=1
unity="V"
x1=-2.5
x2=7.5
divx=10
subdivx=1
xlabmag=1.25
ylabmag=1.5
legendmag=1.0
node="buffer_gain"
color=""
dataset=-1
unitx="V"
logx=0
logy=0
}
B 2 1040 1460 1660 1600 {flags=graph
y1=0
y2=300
ypos1=0
ypos2=1
divy=10
subdivy=1
unity="V"
x1=-2.5
x2=7.5
divx=10
subdivx=1
xlabmag=1.25
ylabmag=1.5
legendmag=1.0
node="track_error_mv"
color=""
dataset=-1
unitx="V"
logx=0
logy=0
}
T {To simulate and generate .raw data
and print results, press this
button above with Ctrl+Click} -310 -710 0 0 0.2 0.2 {}
T {Disable/activate 
scripts/blocks by
pressing Shift+T.} -310 -660 0 0 0.2 0.2 {}
T {These buttons below
are for plotting
graphs below} -310 -610 0 0 0.2 0.2 {}
T {OPEN-LOOP CIRCUIT} 140 -740 0 0 0.4 0.4 {}
T {LOOP-GAIN CIRCUIT (Tian Method)} 740 -740 0 0 0.4 0.4 {}
T {Recommended:
Do simulation per script
with "SimulateNGSPICE"
button then click
each plot buttons
to view the graphs} -180 -670 0 0 0.2 0.2 {}
T {All .raw files
are saved on
./simulations/result} -180 -590 0 0 0.2 0.2 {}
T {CLOSE-LOOP CIRCUIT} 1320 -740 0 0 0.4 0.4 {}
T {Change general simulation parameters here!} 410 -1260 0 0 0.3 0.3 {}
T {POWER & BIASING} 690 -990 0 0 0.3 0.3 {}
T {DC Swing Plots} -80 50 0 0 0.5 0.5 {}
T {Enable x1 and all of its pins

Activate C1, v1, and v4 with all of its pins for
dc swing and dc open-loop operating simulations.

Enable all of vsource, C1, and all of its pins
for widespread AB simulation.} 110 -700 0 0 0.2 0.2 {}
T {Enable all vsources, C3, probe, x2, and all of their pins
for each simulation.

For PVT scripts, parameters must be changed per corner simulation.
Options are "tt", "ss", "ff", "sf", or "fs". Also, PVT results
will be appended. For each corner, simulation can be done once.
If you want to retry the simulation, please remove all files first.
"rm -rf ./result/tb_cg_ota_pvt_all.txt ./result/tb_cg_ota_pvt_*.raw"} 760 -700 0 0 0.2 0.2 {}
T {Enable all for each simulation.} 1320 -700 0 0 0.2 0.2 {}
T {vout_sw (V) vs v4 (V)} -30 430 0 0 0.25 0.25 {}
T {diff_gain (V/V) vs v4 (V)} -40 800 0 0 0.25 0.25 {}
T {Wingspread AB Plots} -120 850 0 0 0.5 0.5 {}
T {i_out (mA) vs vid_vec (V)} -90 1230 0 0 0.25 0.25 {}
T {gm_eff (mA/V or mS) vs vid_vec (V)} -90 1580 0 0 0.25 0.25 {}
T {AC, Noise, and PVT Plots} 850 50 0 0 0.5 0.5 {}
T {loop_mag (dB) & loop_phase (deg) vs frequency log. (Hz)} 510 440 0 0 0.25 0.25 {}
T {IRN (nV/sqrt(Hz)) vs frequency log. (Hz)} 570 800 0 0 0.25 0.25 {}
T {PVT Plots} 1340 430 0 0 0.25 0.25 {}
T {Transient Plot} 580 840 0 0 0.5 0.5 {}
T {PSRR and CMRR Plots} 1220 480 0 0 0.5 0.5 {}
T {} 2700 50 0 0 0.5 0.5 {}
T {Large Transient Plot (Slew Rate, Time Rise, Time Fall, and Propagation Delay)} 420 1210 0 0 0.25 0.25 {}
T {Small Transient Plot (Delay, Rise Time, Settling Time, and Overshoot)} 440 1570 0 0 0.25 0.25 {}
T {ICMR Plots} 1300 1270 0 0 0.4 0.4 {}
T {PSRR (dB) vs frequency log. (Hz)} 1240 860 0 0 0.25 0.25 {}
T {CMRR (dB) vs frequency log. (Hz)} 1250 1230 0 0 0.25 0.25 {}
T {Change simulation blocks for PVT simulations here!
For typical libraries (tt), use "Libs_Ngspice_Typ"!} -280 -1250 0 0 0.3 0.3 {}
T {V_out (V) vs V_in (V)} 1150 1440 0 0 0.15 0.15 {}
T {buffer_gain (V/V) vs V_in (V)} 1470 1440 0 0 0.15 0.15 {}
T {track_error (mV) vs V_in (V)} 1300 1600 0 0 0.15 0.15 {}
T {If raw files didn't exist in ./result directory,
you have to simulate all of them first.
If raw files existed in ./result directory,
you can plot them all.

Status:
All raw files have existed. Plot ready.
Just launch the "Plot" and "Op" launcher arrows on the right side.

To know the simulation results in text, simulations must be redone.
Except PVT simulations, the results can be accessed on "tb_cg_ota_pvt.txt"} 1720 50 0 0 0.4 0.4 {}
N 170 -160 170 -130 {lab=VSS
spice_ignore=true}
N 270 -230 290 -230 {lab=OUT1
spice_ignore=true}
N 170 -330 170 -300 {lab=VDD
spice_ignore=true}
N 740 -910 740 -900 {lab=VDD}
N 820 -910 820 -890 {lab=VDD}
N 820 -830 820 -810 {lab=I_B}
N 80 -250 100 -250 {lab=VINP1
spice_ignore=true}
N 80 -210 100 -210 {lab=I_B
spice_ignore=true}
N 80 -230 100 -230 {lab=VINN1
spice_ignore=true}
N 50 -450 50 -430 {lab=VSS
spice_ignore=true}
N 160 -460 160 -450 {lab=VSS
spice_ignore=true}
N 160 -540 160 -520 {lab=OUT1
spice_ignore=true}
N 850 -200 850 -170 {lab=VSS
spice_ignore=true}
N 950 -270 970 -270 {lab=OUT2
spice_ignore=true}
N 850 -370 850 -340 {lab=VDD
spice_ignore=true}
N 760 -290 780 -290 {lab=VINP2
spice_ignore=true}
N 760 -250 780 -250 {lab=I_B
spice_ignore=true}
N 630 -570 630 -550 {lab=VINP2
spice_ignore=true}
N 630 -490 630 -470 {lab=VSS
spice_ignore=true}
N 710 -490 710 -480 {lab=VSS
spice_ignore=true}
N 710 -570 710 -550 {lab=OUT2
spice_ignore=true}
N 50 -650 50 -630 {lab=VINP1
spice_ignore=true}
N 250 -550 250 -530 {lab=OUT1
spice_ignore=true}
N 250 -470 250 -440 {lab=VSS
spice_ignore=true}
N 760 -270 780 -270 {lab=VINN2
spice_ignore=true}
N 820 -520 840 -520 {lab=OUT2
spice_ignore=true}
N 1000 -520 1020 -520 {lab=VINN2
spice_ignore=true}
N 1460 -130 1460 -120 {lab=VSS
spice_ignore=true}
N 1610 -220 1650 -220 {lab=OUT3
spice_ignore=true}
N 1460 -320 1460 -290 {lab=VDD
spice_ignore=true}
N 1370 -240 1390 -240 {lab=VINP3
spice_ignore=true}
N 1370 -200 1390 -200 {lab=I_B
spice_ignore=true}
N 1350 -560 1350 -540 {lab=VINP3
spice_ignore=true}
N 1350 -480 1350 -460 {lab=VSS
spice_ignore=true}
N 1380 -220 1390 -220 {lab=OUT3
spice_ignore=true}
N 1380 -360 1380 -220 {lab=OUT3
spice_ignore=true}
N 1380 -360 1570 -360 {lab=OUT3
spice_ignore=true}
N 1570 -360 1570 -220 {lab=OUT3
spice_ignore=true}
N 1560 -220 1570 -220 {lab=OUT3
spice_ignore=true}
N 1610 -220 1610 -190 {lab=OUT3
spice_ignore=true}
N 1570 -220 1610 -220 {lab=OUT3
spice_ignore=true}
N 1460 -130 1610 -130 {lab=VSS
spice_ignore=true}
N 1460 -150 1460 -130 {lab=VSS
spice_ignore=true}
N 740 -840 740 -820 {lab=0}
N 680 -840 680 -820 {lab=0}
N 680 -910 680 -900 {lab=VSS}
N 50 -540 60 -540 {lab=VINN1
spice_ignore=true}
N 50 -540 50 -510 {lab=VINN1
spice_ignore=true}
N 50 -570 50 -540 {lab=VINN1
spice_ignore=true}
N 910 -950 910 -920 {lab=OUT3
spice_ignore=true}
N 910 -860 910 -830 {lab=0
spice_ignore=true}
C {lab_pin.sym} 80 -230 0 0 {name=p2 sig_type=std_logic lab=VINN1
spice_ignore=true}
C {lab_pin.sym} 170 -130 3 0 {name=p5 sig_type=std_logic lab=VSS
spice_ignore=true}
C {lab_pin.sym} 80 -250 0 0 {name=p6 sig_type=std_logic lab=VINP1
spice_ignore=true}
C {lab_pin.sym} 290 -230 2 0 {name=p1 sig_type=std_logic lab=OUT1
spice_ignore=true}
C {launcher.sym} -250 -480 0 0 {name=h1
descr=Op_Open_Loop
tclcommand="set raw_path [file join $netlist_dir result tb_cg_ota_dc-open-op.raw]
if \{[file exists $raw_path]\} \{
    xschem annotate_op $raw_path
\} else \{
    puts \\"File $raw_path didn't exist. Please simulate DC_op first and run it!\\"
\}"}
C {simulator_commands_shown.sym} 650 -1170 0 0 {name=General_Params
simulator=ngspice
only_toplevel=false
value=".param temp=27
.param cl=2p
.param ib=1u
.param vdd=1.2
.param vicm=vdd/2
.param vid=0
"
      }
C {vsource.sym} 50 -480 0 0 {name=V1 value=\{vicm\} savecurrent=false
spice_ignore=true}
C {isource.sym} 820 -860 0 0 {name=I0 value=\{ib\}}
C {vsource.sym} 740 -870 0 0 {name=V2 value=\{vdd\} savecurrent=false}
C {gnd.sym} 740 -820 0 0 {name=l1 lab=0}
C {vdd.sym} 170 -330 0 0 {name=l2 lab=VDD
spice_ignore=true}
C {vdd.sym} 740 -910 0 0 {name=l3 lab=VDD}
C {vdd.sym} 820 -910 0 0 {name=l4 lab=VDD}
C {lab_pin.sym} 80 -210 0 0 {name=p4 sig_type=std_logic lab=I_B
spice_ignore=true}
C {lab_pin.sym} 820 -810 3 0 {name=p7 sig_type=std_logic lab=I_B}
C {lab_pin.sym} 50 -650 1 0 {name=p9 sig_type=std_logic lab=VINP1
spice_ignore=true}
C {lab_pin.sym} 60 -540 2 0 {name=p10 sig_type=std_logic lab=VINN1
spice_ignore=true}
C {capa.sym} 160 -490 0 0 {name=C1
m=1
value=\{cl\}
footprint=1206
device="ceramic capacitor"
spice_ignore=true}
C {lab_pin.sym} 160 -450 3 0 {name=p12 sig_type=std_logic lab=VSS
spice_ignore=true}
C {lab_pin.sym} 160 -540 1 0 {name=p13 sig_type=std_logic lab=OUT1
spice_ignore=true}
C {launcher.sym} -250 -440 0 0 {name=h2
descr=Plot_DC_Swing
tclcommand="xschem raw_read [file join $netlist_dir result tb_cg_ota_dc-sweep.raw] dc"}
C {launcher.sym} -250 -400 0 0 {name=h3
descr=Plot_Wingspread_AB
tclcommand="xschem raw_read [file join $netlist_dir result tb_cg_ota_wingspread.raw] dc"}
C {launcher.sym} -250 -730 0 0 {name=h5
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
xschem simulate
"}
C {simulator_commands.sym} 380 -660 0 0 {name=DC_open_loop_op
simulator=ngspice
only_toplevel=false 
value=".op
.control
save all
op
shell mkdir -p result
run
write ./result/tb_cg_ota_dc-open-op.raw
show all : vgs, vds, vth, ids
let v_in = v(vinp1)
let v_out = v(out1)
let vos_mv = (v_in - v_out) * 1000
let i_q = -i(v2)
let p_q = i_q * 1.2
let p_q_uw = p_q * 1e6
let i_q_ua = i_q * 1e6
echo \\"=======================================================\\"
echo \\" Input Common-Mode (Vin+): \\" $&v_in \\" V\\"
echo \\" Output Voltage (Vout): \\" $&v_out \\" V\\"
echo \\" Systematic Offset (Vos): \\" $&vos_mv \\" mV\\"
echo \\" Quiescent Current (I_q): \\" $&i_q_ua \\" uA\\"
echo \\" Quiescent Power (P_q): \\" $&p_q_uw \\" uW\\"
echo \\"=======================================================\\"
.endc
"
spice_ignore=true}
C {simulator_commands_shown.sym} -300 -960 0 0 {name=Libs_Ngspice_Typ
simulator=ngspice
only_toplevel=false
value="tcleval(
.lib $::MODELS_NGSPICE/cornerMOSlv.lib mos_tt
.lib $::MODELS_NGSPICE/cornerMOShv.lib mos_tt
.lib $::MODELS_NGSPICE/cornerRES.lib res_typ
.lib $::MODELS_NGSPICE/cornerDIO.lib dio_tt
.lib $::MODELS_NGSPICE/cornerCAP.lib cap_typ
.lib $::MODELS_NGSPICE/cornerMOSCAP.lib moscap_tt 
)"
      spice_ignore=true}
C {launcher.sym} -250 -340 0 0 {name=h4
descr=Plot_AC
tclcommand="xschem raw_read [file join $netlist_dir result tb_cg_ota_ac.raw]"}
C {launcher.sym} -250 -300 0 0 {name=h6
descr=Plot_Noise
tclcommand="xschem raw_read [file join $netlist_dir result tb_cg_ota_noise.raw]"}
C {launcher.sym} -250 -80 0 0 {name=h8
descr=Plot_ICMR
tclcommand="xschem raw_read [file join $netlist_dir result tb_cg_ota_icmr.raw]"}
C {launcher.sym} -250 -40 0 0 {name=h10
descr=Plot_PSRR
tclcommand="xschem raw_read [file join $netlist_dir result tb_cg_ota_psrr.raw]"}
C {simulator_commands.sym} 380 -460 0 0 {name=DC_Swing
simulator=ngspice
only_toplevel="false" 
value=".control
save all
shell mkdir -p result
* DC sweep simulation
dc v4 -0.6 0.6 0.2m

* Variables
let vid_vec = v(vinp1) - v(vinn1)
let vout_sw = v(out1)
let diff_gain = deriv(vout_sw)

* Maximum DC Gain
meas dc max_gain max diff_gain
let max_gain_db = db(max_gain)

* Save vectors as .raw files
write ./result/tb_cg_ota_dc-sweep.raw vout_sw diff_gain max_gain max_gain_db

echo \\"==========================================\\"
print max_gain max_gain_db
echo \\"==========================================\\"

.endc"
spice_ignore=true}
C {simulator_commands.sym} 380 -260 0 0 {name=Wingspread-AB
simulator=ngspice
only_toplevel=false 
value="* Enable v7 and its lab_pins
.control
save all @n.x1.xm_outp.nsg13_lv_pmos[ids] @n.x1.xm_outn.nsg13_lv_nmos[ids]
shell mkdir -p result

dc v4 -50m 50m 0.2m

* Parameters
let vid_vec = v(vinp1) - v(vinn1)
let i_out = i(v7)
let i_out_ma = i_out * 1e3
let i_outp_ma = @n.x1.xm_outp.nsg13_lv_pmos[ids] * 1e3
let i_outn_ma = @n.x1.xm_outn.nsg13_lv_nmos[ids] * 1e3

* gm_eff
let gm_eff = deriv(i_out)
let gm_eff_ms = gm_eff * 1e3

write ./result/tb_cg_ota_wingspread.raw vid_vec i_out_ma i_outp_ma i_outn_ma gm_eff_ms

meas dc gm_center find gm_eff_ms at=0
let iq_outp_stage2 = i_outp_ma[250]
let iq_outn_stage2 = i_outn_ma[250]

echo \\"=======================================================\\"
echo \\" gm on Vid = 0V: \\" $&gm_center \\" mA/V\\"
echo \\" Quiescent Current of Stage 2 (Vid = 0V) on M_outp: \\" $&iq_outp_stage2 \\" mA\\"
echo \\" Quiescent Current of Stage 2 (Vid = 0V) on M_outn: \\" $&iq_outn_stage2 \\" mA\\"
echo \\"=======================================================\\"

plot gm_eff_ms vs vid_vec
plot i_outp_ma i_outn_ma vs vid_vec

.endc
"
spice_ignore=true}
C {lab_pin.sym} 50 -430 3 0 {name=p8 sig_type=std_logic lab=VSS
spice_ignore=true}
C {lab_pin.sym} 760 -270 0 0 {name=p14 sig_type=std_logic lab=VINN2
spice_ignore=true}
C {lab_pin.sym} 850 -170 3 0 {name=p15 sig_type=std_logic lab=VSS
spice_ignore=true}
C {lab_pin.sym} 760 -290 0 0 {name=p16 sig_type=std_logic lab=VINP2
spice_ignore=true}
C {lab_pin.sym} 970 -270 2 0 {name=p17 sig_type=std_logic lab=OUT2
spice_ignore=true}
C {vdd.sym} 850 -370 0 0 {name=l5 lab=VDD
spice_ignore=true}
C {lab_pin.sym} 760 -250 0 0 {name=p18 sig_type=std_logic lab=I_B
spice_ignore=true}
C {vsource.sym} 630 -520 0 0 {name=V6 value=\{vicm\} savecurrent=false
spice_ignore=true}
C {lab_pin.sym} 630 -570 1 0 {name=p20 sig_type=std_logic lab=VINP2
spice_ignore=true}
C {lab_pin.sym} 630 -470 3 0 {name=p21 sig_type=std_logic lab=VSS
spice_ignore=true}
C {capa.sym} 710 -520 0 0 {name=C3
m=1
value=\{cl\}
footprint=1206
device="ceramic capacitor"
spice_ignore=true}
C {lab_pin.sym} 710 -480 3 0 {name=p25 sig_type=std_logic lab=VSS
spice_ignore=true}
C {lab_pin.sym} 710 -570 1 0 {name=p26 sig_type=std_logic lab=OUT2
spice_ignore=true}
C {vsource.sym} 50 -600 0 0 {name=V4 value=\{vid\} savecurrent=false
spice_ignore=true}
C {simulator_commands.sym} 1110 -550 0 0 {name=AC
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
spice_ignore=true}
C {simulator_commands.sym} 1110 -370 0 0 {name=Noise
simulator=ngspice
only_toplevel=false 
value=".control
save all
destroy all
shell mkdir -p result

* Tian probe idled
alter i.x999.ii acmag=0
alter v.x999.vi acmag=0

* Add AC 1 to Vicm
alter @v6[acmag]=1

* Noise simulation
noise v(out2) v6 dec 20 10 100MEG

* Return to initial condition
alter @v6[acmag]=0

setplot noise1

* Parameters #1
let inoise_total_uv = noise2.inoise_total * 1e6
let onoise_total_uv = noise2.onoise_total * 1e6
let irn_nv = noise1.inoise_spectrum * 1e9
let orn_nv = noise1.onoise_spectrum * 1e9

* IRN extraction at certain frequencies
let irn_10 = irn_nv[0]
let irn_100 = irn_nv[20]
let irn_1k = irn_nv[40]
let irn_10k = irn_nv[60]
let irn_100k = irn_nv[80]
let irn_1meg = irn_nv[100]
* meas noise irn_10 find irn_nv at=10
* meas noise irn_100 find irn_nv at=100
* meas noise irn_1k find irn_nv at=1k
* meas noise irn_10k find irn_nv at=10k
* meas noise irn_100k find irn_nv at=100k
* meas noise irn_1meg find irn_nv at=1MEG

write ./result/tb_cg_ota_noise.raw irn_nv orn_nv inoise_spectrum onoise_spectrum

echo \\"=======================================================\\"
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
spice_ignore=true}
C {vsource.sym} 250 -500 0 0 {name=V7 value=\{vicm\} savecurrent=false
spice_ignore=true}
C {lab_pin.sym} 250 -550 1 0 {name=p11 sig_type=std_logic lab=OUT1
spice_ignore=true}
C {lab_pin.sym} 250 -440 3 0 {name=p27 sig_type=std_logic lab=VSS
spice_ignore=true}
C {loopgainprobe.sym} 920 -520 0 0 {spice_ignore=true}
C {lab_pin.sym} 820 -520 0 0 {name=p19 sig_type=std_logic lab=OUT2
spice_ignore=true}
C {lab_pin.sym} 1020 -520 2 0 {name=p22 sig_type=std_logic lab=VINN2
spice_ignore=true}
C {simulator_commands_shown.sym} 880 -1200 0 0 {name=loopgainprobe
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
C {lab_pin.sym} 1460 -120 3 0 {name=p24 sig_type=std_logic lab=VSS
spice_ignore=true}
C {lab_pin.sym} 1370 -240 0 0 {name=p28 sig_type=std_logic lab=VINP3
spice_ignore=true}
C {lab_pin.sym} 1650 -220 2 0 {name=p29 sig_type=std_logic lab=OUT3
spice_ignore=true}
C {vdd.sym} 1460 -320 0 0 {name=l6 lab=VDD
spice_ignore=true}
C {lab_pin.sym} 1370 -200 0 0 {name=p30 sig_type=std_logic lab=I_B
spice_ignore=true}
C {vsource.sym} 1350 -510 0 0 {name=V5 value=\{vicm\} savecurrent=false
spice_ignore=true}
C {lab_pin.sym} 1350 -560 1 0 {name=p31 sig_type=std_logic lab=VINP3
spice_ignore=true}
C {lab_pin.sym} 1350 -460 3 0 {name=p32 sig_type=std_logic lab=VSS
spice_ignore=true}
C {capa.sym} 1610 -160 0 0 {name=C2
m=1
value=\{cl\}
footprint=1206
device="ceramic capacitor"
spice_ignore=true}
C {simulator_commands.sym} 1870 -480 0 0 {name=PSRR
simulator=ngspice
only_toplevel="false" 
value=".control
save all
shell mkdir -p result

* PSRR
alter @v2[acmag]=1
alter @v5[acmag]=0

ac dec 20 1 10G

let psrr_curve = db(1 / (v(OUT3) + 1e-15))

meas ac psrr_dc find psrr_curve at=10
meas ac psrr_100k find psrr_curve at=100k
meas ac psrr_1meg find psrr_curve at=1MEG

write ./result/tb_cg_ota_psrr.raw psrr_curve

echo \\"=======================================================\\"
echo \\"  PSRR @ DC / 10 Hz        : \\" $&psrr_dc   \\" dB (Target: > 60 dB)\\"
echo \\"  PSRR @ 100 kHz           : \\" $&psrr_100k \\" dB\\"
echo \\"  PSRR @ 1 MHz             : \\" $&psrr_1meg \\" dB\\"
echo \\"=======================================================\\"

plot psrr_curve xlog
.endc"
spice_ignore=true}
C {simulator_commands.sym} 1870 -680 0 0 {name=DC_close_loop_op
simulator=ngspice
only_toplevel=false 
value=".op
.control
save all
op
shell mkdir -p result
run
write ./result/tb_cg_ota_dc-close-op.raw
show all : vgs, vds, vth, ids
let v_in = v(vinp3)
let v_out = v(out3)
let vos_mv = (v_in - v_out) * 1000
let i_q = -i(v2)
let p_q = i_q * 1.2
let p_q_uw = p_q * 1e6
let i_q_ua = i_q * 1e6
echo \\"=======================================================\\"
echo \\" Input Common-Mode (Vin+): \\" $&v_in \\" V\\"
echo \\" Output Voltage (Vout): \\" $&v_out \\" V\\"
echo \\" Systematic Offset (Vos): \\" $&vos_mv \\" mV\\"
echo \\" Quiescent Current (I_q): \\" $&i_q_ua \\" uA\\"
echo \\" Quiescent Power (P_q): \\" $&p_q_uw \\" uW\\"
echo \\"=======================================================\\"
.endc
"
spice_ignore=true}
C {vsource.sym} 680 -870 0 0 {name=V3 value=0 savecurrent=false}
C {gnd.sym} 680 -820 0 0 {name=l7 lab=0}
C {lab_pin.sym} 680 -910 1 0 {name=p3 sig_type=std_logic lab=VSS
}
C {simulator_commands.sym} 1870 -280 0 0 {name=CMRR
simulator=ngspice
only_toplevel="false" 
value=".control
save all
shell mkdir -p result

* CMRR
alter @v2[acmag]=0
alter @v5[acmag]=1

ac dec 20 1 10G

let v_diff_res = v(VINP3) - v(OUT3)
let cmrr_curve = db(1 / (v_diff_res + 1e-15))

meas ac cmrr_dc find cmrr_curve at=10
meas ac cmrr_100k find cmrr_curve at=100k
meas ac cmrr_1meg find cmrr_curve at=1MEG

write ./result/tb_cg_ota_cmrr.raw v_diff_res cmrr_curve

echo \\"=======================================================\\"
echo \\"  CMRR @ DC / 10 Hz        : \\" $&cmrr_dc   \\" dB (Target: > 60 dB)\\"
echo \\"  CMRR @ 100 kHz           : \\" $&cmrr_100k \\" dB\\"
echo \\"  CMRR @ 1 MHz             : \\" $&cmrr_1meg \\" dB\\"
echo \\"=======================================================\\"

plot cmrr_curve xlog
.endc"
spice_ignore=true}
C {simulator_commands.sym} 1730 -680 0 0 {name=TRAN_large
simulator=ngspice
only_toplevel="false" 
value=".control
shell mkdir -p result

* LARGE-SIGNAL STEP RESPONSE (SLEW RATE & PROPAGATION DELAYS)
* Stimulus: Pulse swing 0.2 V to 1.0 V (Delta V = 0.8 V, Vcm = 0.6 V)
alter @v5[pulse] = [ 0.2 1.0 20n 1n 1n 1u 2.5u ]

tran 0.2n 2.5u
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
spice_ignore=true}
C {simulator_commands.sym} 1730 -480 0 0 {name=TRAN_small
simulator=ngspice
only_toplevel="false" 
value=".control
save all
shell mkdir -p result

* SMALL-SIGNAL STEP RESPONSE (SETTLING TIME & OVERSHOOT)
* Stimulus: Small step 0.55 V to 0.65 V (Delta V = 100 mV)
alter @v5[pulse] = [ 0.55 0.65 20n 1n 1n 500n 1.2u ]

tran 0.1n 1.2u
run

let v_ins  = v(vinp3)
let v_outs = v(out3)

* --- Small-Signal Delay and Rise Time ---
meas tran t_in_s50  when v_ins=0.60 rise=1
meas tran t_out_s10 when v_outs=0.56 rise=1
meas tran t_out_s50 when v_outs=0.60 rise=1
meas tran t_out_s90 when v_outs=0.64 rise=1

let t_delay_ns = (t_out_s50 - t_in_s50) * 1e9
let t_rise_ns  = (t_out_s90 - t_out_s10) * 1e9

* --- Overshoot Percentage ---
meas tran v_peak max v_outs from=20n to=300n
let overshoot_pct = ((v_peak - 0.65) / 0.1) * 100

* --- Settling Time Calculation ---
* Target value = 0.65 V (Step amplitude = 100 mV)
* 1% Band   : 0.65 V +/- 1 mV   -> 0.649 V to 0.651 V
* 0.1% Band : 0.65 V +/- 0.1 mV -> 0.6499 V to 0.6501 V
meas tran t_set1 when v_outs=0.649 cross=last
let ts_1pct_ns = (t_set1 - 20n) * 1e9

meas tran t_set01 when v_outs=0.6499 cross=last
let ts_01pct_ns = (t_set01 - 20n) * 1e9

* Save output waveforms to the specified rawfile
write ./result/tb_cg_ota_tran_small.raw v_ins v_outs

* Print execution summary
echo \\"=======================================================\\"
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
spice_ignore=true}
C {simulator_commands.sym} 1730 -270 0 0 {name="Monte_Carlo"
simulator=ngspice
only_toplevel="false" 
value="* ===============================================================
* MONTE CARLO MISMATCH & PROCESS SIMULATION
* Topology: Closed-Loop Unity-Gain Follower (x3)
* PDK     : IHP SG13CMOSL (PSP103 via OSDI)
* ===============================================================

* Critical IHP PDK parameter switches to activate statistical variations
.param mm_ok=1
.param mc_ok=1
.param temp=27

.control
* 1. Clear previous session datasets and prepare output directory
destroy all
save all
shell mkdir -p result

echo \\"=======================================================\\"
echo \\"   STARTING MONTE CARLO SIMULATION (OTA FOLLOWER)      \\"
echo \\"=======================================================\\"

* 2. Initialize iteration counter and dedicated scratch plot
let mc_runs = 100
let run = 0

* Create a dedicated container plot to safely aggregate all run results
set curplot = new
set scratch = $curplot
setplot $scratch

* Pre-allocate vectors in the scratch plot
let vos_vec = unitvec(mc_runs)
let iq_vec  = unitvec(mc_runs)

* Initialize summary text file header
echo \\"Run_ID  Vos_mV      Iq_uA\\" >> ./result/tb_cg_ota_mc.txt

* ===============================================================
* 3. MONTE CARLO EXECUTION LOOP
* ===============================================================
dowhile run < mc_runs
  set rnd_seed=$&run
  * Execute DC operating point (evaluates new statistical sample)
  op

  * Capture current loop index and temporary plot pointer
  set run_idx = $&run
  set dt = $curplot

  * Calculate parameters inside the active op dataset ($dt)
  setplot $dt
  let cur_vos = (v(vinp3) - v(out3)) * 1000
  let cur_iq  = -i(v2) * 1e6

  * Lock values to shell variables while still in $dt plot context
  set s_vos = \\"$&cur_vos\\"
  set s_iq  = \\"$&cur_iq\\"

  * Switch context to scratch plot and store scalar values into arrays
  setplot $scratch
  let vos_vec[run] = \{$dt\}.cur_vos
  let iq_vec[run]  = \{$dt\}.cur_iq

  * Append individual iteration data to text log
  set s_idx = \\"$&run\\"
  echo \\"$s_idx   $s_vos   $s_iq\\" >> ./result/tb_cg_ota_mc.txt

  * Return to run plot and clear circuit state for next sample
  setplot $dt
  reset

  let run = run + 1
end

* ===============================================================
* 4. STATISTICAL POST-PROCESSING (IN SCRATCH PLOT)
* ===============================================================
setplot $scratch

* A. Mean calculation (mu)
let sum_vos = 0
let sum_iq  = 0
let i = 0
dowhile i < mc_runs
  let sum_vos = sum_vos + vos_vec[i]
  let sum_iq  = sum_iq  + iq_vec[i]
  let i = i + 1
end
let mean_vos = sum_vos / mc_runs
let mean_iq  = sum_iq  / mc_runs

* B. Sample standard deviation calculation (sigma)
let sum_sq_vos = 0
let sum_sq_iq  = 0
let i = 0
dowhile i < mc_runs
  let diff_vos = vos_vec[i] - mean_vos
  let diff_iq  = iq_vec[i]  - mean_iq
  let sum_sq_vos = sum_sq_vos + (diff_vos * diff_vos)
  let sum_sq_iq  = sum_sq_iq  + (diff_iq  * diff_iq)
  let i = i + 1
end
let sigma_vos = sqrt(sum_sq_vos / (mc_runs - 1))
let sigma_iq  = sqrt(sum_sq_iq  / (mc_runs - 1))
let span_6sigma_vos = 6 * sigma_vos

* C. Extreme values search across the allocated array
let min_vos = vos_vec[0]
let max_vos = vos_vec[0]
let k = 1
dowhile k < mc_runs
  if vos_vec[k] < min_vos
    let min_vos = vos_vec[k]
  end
  if vos_vec[k] > max_vos
    let max_vos = vos_vec[k]
  end
  let k = k + 1
end

* ===============================================================
* 5. STATISTICAL SUMMARY REPORT
* ===============================================================
echo \\"=======================================================\\"
echo \\"       MONTE CARLO STATISTICAL ANALYSIS RESULTS        \\"
echo \\"=======================================================\\"
echo \\" Total Iterations (Runs)     : \\" $&mc_runs
echo \\"-------------------------------------------------------\\"
echo \\" INPUT OFFSET VOLTAGE (Vos) DISTRIBUTION:\\"
echo \\"   - Mean / Systematic (mu)  : \\" $&mean_vos \\" mV\\"
echo \\"   - Std Deviation (sigma)   : \\" $&sigma_vos \\" mV\\"
echo \\"   - Full Spread (6*sigma)   : \\" $&span_6sigma_vos \\" mV\\"
echo \\"   - Minimum Measured Offset : \\" $&min_vos \\" mV\\"
echo \\"   - Maximum Measured Offset : \\" $&max_vos \\" mV\\"
echo \\"-------------------------------------------------------\\"
echo \\" TOTAL QUIESCENT CURRENT (Iq) DISTRIBUTION:\\"
echo \\"   - Mean Quiescent Current  : \\" $&mean_iq \\" uA\\"
echo \\"   - Std Deviation (sigma)   : \\" $&sigma_iq \\" uA\\"
echo \\"=======================================================\\"
echo \\" Numerical dataset exported to: ./result/tb_cg_ota_mc.txt\\"
echo \\"=======================================================\\"

* Save aggregated scratch vectors into rawfile and CSV format
write ./result/tb_cg_ota_mc.raw \{$scratch\}.vos_vec \{$scratch\}.iq_vec
wrdata ./result/tb_cg_ota_mc.csv \{$scratch\}.vos_vec \{$scratch\}.iq_vec

.endc"
spice_ignore=true}
C {simulator_commands.sym} 1110 -190 0 0 {name=PVT
simulator=ngspice
only_toplevel=false 
value="* ===============================================================
* SIMULATION 8: MULTI-CORNER PVT STABILITY ANALYSIS (TIAN PROBE)
* Topology : Folded-Cascode OTA with Class-AB Output Stage (x2)
* PDK      : IHP SG13CMOS5L (130nm BiCMOS)
* ===============================================================

.control
* 1. Clear previous simulation memory and initialize output directory
destroy all
shell mkdir -p result

* 2. Active process corner configuration (Update both per corner run)
*    Available corners: \\"tt\\", \\"ss\\", \\"ff\\", \\"sf\\", \\"fs\\"
set corner_name = \\"tt\\"
set raw_file    = \\"./result/tb_cg_ota_pvt_tt.raw\\"
set txt_file    = \\"./result/tb_cg_ota_pvt.txt\\"

* 3. Initialize table header safely without ngspice redirection truncation
*    Uses python to create the file and header ONLY if it does not exist yet
shell python3 -c 'import os; f=\\"./result/tb_cg_ota_pvt_all.txt\\"; os.path.exists(f) or open(f,\\"w\\").write(\\"==========================================================================================\\\\n Corner | Temp(C) | VDD(V) | Vicm(V) | Av0(dB)  | Av0(V/V)  | UGBW(MHz) | PM(deg)  | GM(dB)   \\\\n==========================================================================================\\\\n\\")'

* Enable sequential dataset appending for the per-corner rawfile
set appendwrite

echo \\"==========================================================================================\\"
echo \\" STARTING PVT STABILITY SWEEP FOR CORNER: \\" $corner_name
echo \\"==========================================================================================\\"

* 4. Outer Loop: Operational Temperature Sweep (-40 C, 27 C, 125 C)
foreach c_temp -40 27 125

  * Update internal SPICE simulator temperature options
  set temper = $c_temp
  option temp = $c_temp

  * 5. Inner Loop: Supply Voltage Sweep (VDD +/- 10%: 1 V, 1.08 V, 1.20 V, 1.32 V. 1.45 V, 1.5 V)
  foreach v_vdd 1 1.08 1.20 1.32 1.45 1.5

    * Calculate symmetrical mid-rail common-mode reference (Vicm = VDD / 2)
    let c_vicm = $v_vdd / 2

    * Dynamically alter DC supply and common-mode input bias voltages
    alter @v2[dc] = $v_vdd
    alter @v6[dc] = $&c_vicm

    * -----------------------------------------------------------
    * TIAN CYCLE 1: VOLTAGE INJECTION (V-test)
    * -----------------------------------------------------------
    alter i.x999.ii acmag=0
    alter v.x999.vi acmag=1
    ac dec 30 1 10G
    set plot_v = $curplot

    * -----------------------------------------------------------
    * TIAN CYCLE 2: CURRENT INJECTION (I-test)
    * -----------------------------------------------------------
    alter i.x999.ii acmag=1
    alter v.x999.vi acmag=0
    ac dec 30 1 10G
    set plot_i = $curplot

    * -----------------------------------------------------------
    * DYNAMIC TIAN RECONSTRUCTION & STABILITY EXTRACTION
    * -----------------------------------------------------------
    setplot $plot_v

    * Retrieve nodal voltages and branch currents from matched AC cycles
    let v1_x = \{$plot_v\}.v(x999.x)
    let i1_b = \{$plot_v\}.v.x999.vi#branch
    let v2_x = \{$plot_i\}.v(x999.x)
    let i2_b = \{$plot_i\}.v.x999.vi#branch

    * General bilateral Tian determinant formula: D = 2*(I1*V2 - V1*I2) + V1 + I2
    let d_tian = 2 * (i1_b * v2_x - v1_x * i2_b) + v1_x + i2_b
    let t_gain = 1 / (1 - 1 / d_tian)

    * Extract real scalar vectors to avoid complex data rectification in raw files
    let loop_magnitude = real(db(t_gain))
    let loop_phase = real(180 * cph(t_gain) / pi) + 180

    * Extract key stability figures of merit
    meas ac pvt_gain find loop_magnitude at=10
    let pvt_gain_lin = 10^(pvt_gain / 20)

    meas ac pvt_ugbw when loop_magnitude=0
    meas ac pvt_pm_raw find loop_phase when loop_magnitude=0
    let pvt_pm = pvt_pm_raw - 180

    * Gain Margin evaluated at phase crossover (0 degrees)
    meas ac pvt_gm_loss find loop_magnitude when loop_phase=180
    let pvt_gm = -pvt_gm_loss

    let pvt_ugbw_mhz = pvt_ugbw / 1e6

    * Print current iteration summary to console
    echo \\" [\\" $corner_name \\"] T=\\" $c_temp \\"C | VDD=\\" $v_vdd \\"V | Av0=\\" $&pvt_gain \\"dB | UGBW=\\" $&pvt_ugbw_mhz \\"MHz | PM=\\" $&pvt_pm \\"deg | GM=\\" $&pvt_gm \\"dB\\"

    * -----------------------------------------------------------
    * SAFE TABLE DATA APPENDING
    * -----------------------------------------------------------
    * Lock numerical values to shell variables before writing
    set s_vicm     = \\"$&c_vicm\\"
    set s_gain     = \\"$&pvt_gain\\"
    set s_gain_lin = \\"$&pvt_gain_lin\\"
    set s_ugbw     = \\"$&pvt_ugbw_mhz\\"
    set s_pm       = \\"$&pvt_pm\\"
    set s_gm       = \\"$&pvt_gm\\"

    * Append row cleanly using a single consolidated string
    echo \\" $corner_name    | $c_temp     | $v_vdd    | $s_vicm     | $s_gain   | $s_gain_lin   | $s_ugbw     | $s_pm    | $s_gm\\" >> $txt_file

    * Export Bode curves to dedicated per-corner rawfile
    write $raw_file loop_magnitude loop_phase
    write ./result/tb_cg_ota_pvt_all.raw loop_magnitude loop_phase
  end
end

* 6. Restore Tian probe sources, supply voltages, and simulator options to nominal state
alter i.x999.ii acmag=0
alter v.x999.vi acmag=0
alter @v2[dc] = 1.20
alter @v6[dc] = 0.60
set temper = 27
option temp = 27

echo \\"==========================================================================================\\"
echo \\" Corner \\" $corner_name \\" completed and appended to \\" $txt_file
echo \\" Bode curves saved to \\" $raw_file
echo \\"==========================================================================================\\"
.endc
"
spice_ignore=true}
C {launcher.sym} -250 -260 0 0 {name=h7
descr=Plot_PVT
tclcommand="set all_raw [file join $netlist_dir result tb_cg_ota_pvt_all.raw]
if \{[file exists $all_raw]\} \{
    xschem raw_read $all_raw ac
    puts \\"Successfully loaded all PVT graphs\\"
\} else \{
    puts \\"$all_raw not exist!\\"
\}"}
C {launcher.sym} -250 -160 0 0 {name=h9
descr=Plot_Tran_Small
tclcommand="xschem raw_read [file join $netlist_dir result tb_cg_ota_tran_small.raw] tran"}
C {launcher.sym} -250 -120 0 0 {name=h11
descr=Plot_CMRR
tclcommand="xschem raw_read [file join $netlist_dir result tb_cg_ota_cmrr.raw]"}
C {launcher.sym} -250 -200 0 0 {name=h12
descr=Plot_Tran_Large
tclcommand="xschem raw_read [file join $netlist_dir result tb_cg_ota_tran_large.raw] tran"}
C {launcher.sym} -250 0 0 0 {name=h13
descr=Plot_Monte_Carlo
tclcommand="set sim_dir [file join $netlist_dir result]
exec python3 [file join $sim_dir plot_mc.py] &"}
C {simulator_commands.sym} 1870 -100 0 0 {name=ICMR
simulator=ngspice
only_toplevel="false" 
value=".control
destroy all
save all
shell mkdir -p result

alter @v5[acmag] = 0

dc v5 0 1.2 2m

let v_in  = v(vinp3)
let v_out = v(out3)

let track_error_mv = abs(v_out - v_in) * 1000

let buffer_gain = deriv(v_out)

* Extract linear ICMR boundary points
* Threshold set at buffer gain > 0.98 (2% gain error margin)
meas dc icmr_min when buffer_gain=0.98 rise=1
meas dc icmr_max when buffer_gain=0.98 fall=1
let icmr_span = icmr_max - icmr_min

write ./result/tb_cg_ota_icmr.raw v_in v_out buffer_gain track_error_mv

* Print summary report to ngspice terminal console
echo \\"=======================================================\\"
echo \\"       INPUT COMMON-MODE RANGE (ICMR) RESULTS          \\"
echo \\"=======================================================\\"
echo \\"  Lower ICMR Bound (Vmin, Gain > 0.98) : \\" $&icmr_min \\" V\\"
echo \\"  Upper ICMR Bound (Vmax, Gain > 0.98) : \\" $&icmr_max \\" V\\"
echo \\"  Total Linear ICMR Span               : \\" $&icmr_span \\" V\\"
echo \\"=======================================================\\"

* Display transfer characteristics and tracking performance curves
plot v_out vs v_in
plot buffer_gain vs v_in
plot track_error_mv vs v_in

.endc"
spice_ignore=true}
C {launcher.sym} -250 -520 0 0 {name=h14
descr=Op_Close_Loop
tclcommand="set raw_path [file join $netlist_dir result tb_cg_ota_dc-close-op.raw]
if \{[file exists $raw_path]\} \{
    xschem annotate_op $raw_path
\} else \{
    puts \\"File $raw_path didn't exist. Please simulate DC_op first and run it!\\"
\}"}
C {simulator_commands_shown.sym} 1080 -990 0 0 {name=Libs_Ngspice_Mismatch_Monte_Carlo
simulator=ngspice
only_toplevel=false
value="tcleval(
.lib $::MODELS_NGSPICE/cornerMOSlv.lib mos_tt
.lib $::MODELS_NGSPICE/cornerMOShv.lib mos_tt
.lib $::MODELS_NGSPICE/cornerRES.lib res_typ_mismatch
.lib $::MODELS_NGSPICE/cornerRES.lib res_stat
.lib $::MODELS_NGSPICE/cornerDIO.lib dio_tt
.lib $::MODELS_NGSPICE/cornerCAP.lib cap_typ
.lib $::MODELS_NGSPICE/cornerMOSCAP.lib moscap_tt_mismatch
.lib $::MODELS_NGSPICE/cornerMOSCAP.lib moscap_tt_stat
)"
      }
C {simulator_commands.sym} -290 -1150 0 0 {name=Worst-Case_SS
simulator=ngspice
only_toplevel=false 
value="tcleval(
.lib $::MODELS_NGSPICE/cornerMOSlv.lib mos_ss
.lib $::MODELS_NGSPICE/cornerMOShv.lib mos_ss
.lib $::MODELS_NGSPICE/cornerRES.lib res_typ
.lib $::MODELS_NGSPICE/cornerDIO.lib dio_tt
.lib $::MODELS_NGSPICE/cornerCAP.lib cap_typ
.lib $::MODELS_NGSPICE/cornerMOSCAP.lib moscap_tt 
)"
spice_ignore=true}
C {simulator_commands.sym} -150 -1150 0 0 {name=Best-Case_FF
simulator=ngspice
only_toplevel=false 
value="tcleval(
.lib $::MODELS_NGSPICE/cornerMOSlv.lib mos_ff
.lib $::MODELS_NGSPICE/cornerMOShv.lib mos_ff
.lib $::MODELS_NGSPICE/cornerRES.lib res_typ
.lib $::MODELS_NGSPICE/cornerDIO.lib dio_tt
.lib $::MODELS_NGSPICE/cornerCAP.lib cap_typ
.lib $::MODELS_NGSPICE/cornerMOSCAP.lib moscap_tt 
)"
spice_ignore=true}
C {simulator_commands.sym} -10 -1150 0 0 {name=Slow-n-Fast-p_SF
simulator=ngspice
only_toplevel=false 
value="tcleval(
.lib $::MODELS_NGSPICE/cornerMOSlv.lib mos_sf
.lib $::MODELS_NGSPICE/cornerMOShv.lib mos_sf
.lib $::MODELS_NGSPICE/cornerRES.lib res_typ
.lib $::MODELS_NGSPICE/cornerDIO.lib dio_tt
.lib $::MODELS_NGSPICE/cornerCAP.lib cap_typ
.lib $::MODELS_NGSPICE/cornerMOSCAP.lib moscap_tt 
)
"
spice_ignore=true}
C {simulator_commands.sym} 150 -1150 0 0 {name=Fast-n-Slow-p_FS
simulator=ngspice
only_toplevel=false 
value="tcleval(
.lib $::MODELS_NGSPICE/cornerMOSlv.lib mos_fs
.lib $::MODELS_NGSPICE/cornerMOShv.lib mos_fs
.lib $::MODELS_NGSPICE/cornerRES.lib res_typ
.lib $::MODELS_NGSPICE/cornerDIO.lib dio_tt
.lib $::MODELS_NGSPICE/cornerCAP.lib cap_typ
.lib $::MODELS_NGSPICE/cornerMOSCAP.lib moscap_tt 
)"
spice_ignore=true}
C {res.sym} 910 -890 0 0 {name=R1
value=2k
footprint=1206
device=resistor
m=1
spice_ignore=true}
C {lab_pin.sym} 910 -950 2 0 {name=p23 sig_type=std_logic lab=OUT3
spice_ignore=true}
C {gnd.sym} 910 -830 0 0 {name=l8 lab=0
spice_ignore=true}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/gain_stage/gain_ota.sym} 200 -210 0 0 {name=x1
spice_ignore=true}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/gain_stage/gain_ota.sym} 880 -250 0 0 {name=x2
spice_ignore=true}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/gain_stage/gain_ota.sym} 1490 -200 0 0 {name=x3
spice_ignore=true}
