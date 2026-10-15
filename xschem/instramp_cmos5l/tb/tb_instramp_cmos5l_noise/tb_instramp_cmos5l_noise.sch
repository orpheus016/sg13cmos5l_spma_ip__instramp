v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 790 -520 790 -480 {lab=VDD}
N 830 -520 830 -480 {lab=vss}
N 750 -520 750 -480 {lab=ibias}
N 980 -350 980 -320 {lab=out}
N 980 -260 980 -230 {lab=0}
N 200 -450 200 -410 {lab=ibias}
N 200 -350 200 -310 {lab=vss}
N 100 -310 100 -270 {lab=vss}
N 100 -450 100 -410 {lab=VDD}
N 100 -210 100 -170 {lab=0}
N 300 -450 300 -410 {lab=vinp}
N 300 -350 300 -310 {lab=vss}
N 400 -350 400 -310 {lab=vss}
N 400 -450 400 -410 {lab=vinn}
N 300 -310 400 -310 {lab=vss}
N 100 -310 200 -310 {lab=vss}
N 200 -310 300 -310 {lab=vss}
N 100 -350 100 -310 {lab=vss}
N 600 -400 660 -400 {lab=vinn}
N 600 -300 660 -300 {lab=vinp}
N 600 -350 660 -350 {lab=vcm}
N 980 -350 1020 -350 {lab=out}
N 920 -350 980 -350 {lab=out}
N 500 -450 500 -410 {lab=vcm}
N 500 -350 500 -310 {lab=vss}
N 400 -310 500 -310 {lab=vss}
C {simulator_commands_shown.sym} 1400 -600 0 0 {
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
C {launcher.sym} 1140 -160 0 0 {name=h1
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
C {title.sym} 160 -30 0 0 {name=l6 author="James Patrick"}
C {devices/launcher.sym} 1140 -110 0 0 {name=h5
descr="OP annotate" 
tclcommand="xschem annotate_op"
}
C {devices/launcher.sym} 1440 -160 0 0 {name=h6
descr="Load waves" 
tclcommand="
xschem raw_read $netlist_dir/[file rootname [file tail [xschem get current_name]]].raw dc
xschem setprop rect 2 0 fullxzoom
"
}
C {simulator_commands_shown.sym} 1070 -600 0 0 {name=General_Params
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
C {simulator_commands_shown.sym} 1070 -410 0 0 {name=OTA_Params
simulator=ngspice
only_toplevel=false
value=".param temp=27
"
      }
C {simulator_commands.sym} 1390 -350 0 0 {name=Noise
simulator=ngspice
only_toplevel=false 
value=".control
save all
destroy all
shell mkdir -p result

* Noise referred to V3 (VINP): gain VINP->OUT = Adm, so inoise = differential-input noise.
* VINN / VCM are held at DC.
alter @v3[acmag]=1
noise v(out) v3 dec 20 10 100MEG
alter @v3[acmag]=0

setplot noise1

* Parameters #1
let inoise_total_uv = noise2.inoise_total * 1e6
let onoise_total_uv = noise2.onoise_total * 1e6
let irn_nv = noise1.inoise_spectrum * 1e9
let orn_nv = noise1.onoise_spectrum * 1e9

* inoise_total integrates out to 100 MHz where the closed-loop gain has rolled off, so it is
* inflated. In-band equivalent = output noise / low-frequency gain (gain = onoise/inoise @ 10 Hz).
let gain_lf = noise1.onoise_spectrum[0] / noise1.inoise_spectrum[0]
let inoise_eq_uv = onoise_total_uv / gain_lf

* IRN extraction at certain frequencies (20 pts/dec from 10 Hz)
let irn_10 = irn_nv[0]
let irn_100 = irn_nv[20]
let irn_1k = irn_nv[40]
let irn_10k = irn_nv[60]
let irn_100k = irn_nv[80]
let irn_1meg = irn_nv[100]

write ./result/tb_instramp_cmos5l_noise.raw irn_nv orn_nv inoise_spectrum onoise_spectrum

echo \\"=======================================================\\"
echo \\" Total Output Noise (10 Hz - 100 MHz): \\" $&onoise_total_uv \\" uV_rms\\"
echo \\" Total Input Noise (10 Hz - 100 MHz): \\" $&inoise_total_uv \\" uV_rms (inflated, see above)\\"
echo \\" In-band Input-Referred (Vout_n/Gain): \\" $&inoise_eq_uv \\" uV_rms\\"
echo \\"-------------------------------------------------------\\"
echo \\" IRN @ 10 Hz (Flicker Noise): \\" $&irn_10 \\" nV/sqrt(Hz)\\"
echo \\" IRN @ 100 Hz: \\" $&irn_100 \\" nV/sqrt(Hz)\\"
echo \\" IRN @ 1 kHz: \\" $&irn_1k \\" nV/sqrt(Hz)\\"
echo \\" IRN @ 10 kHz: \\" $&irn_10k \\" nV/sqrt(Hz)\\"
echo \\" IRN @ 100 kHz: \\" $&irn_100k \\" nV/sqrt(Hz)\\"
echo \\" IRN @ 1 MHz (Thermal Noise Floor): \\" $&irn_1meg \\" nV/sqrt(Hz)\\"
echo \\"=======================================================\\"

plot irn_nv orn_nv loglog
.endc"
}
C {vdd.sym} 790 -520 0 0 {name=l1 lab=VDD}
C {lab_wire.sym} 830 -520 0 0 {name=p1 sig_type=std_logic lab=vss}
C {lab_wire.sym} 750 -520 0 0 {name=p2 sig_type=std_logic lab=ibias}
C {capa.sym} 980 -290 0 0 {name=C1
m=1
value=3p
footprint=1206
device="ceramic capacitor"}
C {lab_wire.sym} 1020 -350 0 0 {name=p4 sig_type=std_logic lab=out}
C {lab_wire.sym} 200 -450 0 0 {name=p5 sig_type=std_logic lab=ibias}
C {isource.sym} 200 -380 0 0 {name=I0 value=4.2u}
C {vdd.sym} 100 -450 0 0 {name=l2 lab=VDD}
C {vsource.sym} 100 -380 0 0 {name=V1 value=1.2 savecurrent=false}
C {lab_wire.sym} 100 -310 0 0 {name=p7 sig_type=std_logic lab=vss}
C {vsource.sym} 100 -240 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} 100 -170 0 0 {name=l3 lab=0}
C {lab_wire.sym} 300 -450 0 0 {name=p9 sig_type=std_logic lab=vinp}
C {vsource.sym} 300 -380 0 0 {name=V3 value=0.6 savecurrent=false}
C {vsource.sym} 400 -380 0 0 {name=V4 value=0.6 savecurrent=false}
C {lab_wire.sym} 400 -450 0 0 {name=p12 sig_type=std_logic lab=vinn}
C {lab_wire.sym} 600 -300 2 0 {name=p13 sig_type=std_logic lab=vinp}
C {lab_wire.sym} 600 -400 2 0 {name=p14 sig_type=std_logic lab=vinn}
C {gnd.sym} 980 -230 0 0 {name=l5 lab=0}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/instramp_cmos5l/instramp_cmos5l.sym} 790 -350 0 0 {name=x1}
C {lab_wire.sym} 600 -350 2 0 {name=p3 sig_type=std_logic lab=vcm}
C {vsource.sym} 500 -380 0 0 {name=V5 value=0.6 savecurrent=false}
C {lab_wire.sym} 500 -450 0 0 {name=p6 sig_type=std_logic lab=vcm}
