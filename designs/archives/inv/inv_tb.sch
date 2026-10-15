v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N 110 -260 110 -240 {lab=IN}
N 110 -260 170 -260 {lab=IN}
N 110 -180 110 -160 {lab=0}
N 50 -180 50 -160 {lab=0}
N 50 -260 50 -240 {lab=VDD}
N 260 -380 260 -350 {lab=VDD}
N 350 -260 410 -260 {lab=OUT}
N 260 -170 260 -140 {lab=0}
C {title.sym} 170 -50 0 0 {name=l1 author="Rafi Ananta Alden"}
C {vsource.sym} 50 -210 0 0 {name=V1 value=1.2 savecurrent=false}
C {vsource.sym} 110 -210 0 0 {name=VIN value=1.2 savecurrent=false}
C {inv.sym} 270 -190 0 0 {name=xinv1}
C {vdd.sym} 50 -260 0 0 {name=l2 lab=VDD}
C {gnd.sym} 50 -160 0 0 {name=l3 lab=0}
C {noconn.sym} 410 -260 0 1 {name=l4}
C {gnd.sym} 110 -160 0 0 {name=l5 lab=0}
C {gnd.sym} 260 -140 0 0 {name=l6 lab=0}
C {vdd.sym} 260 -380 0 0 {name=l7 lab=VDD}
C {lab_wire.sym} 140 -260 0 0 {name=p1 sig_type=std_logic lab=IN}
C {lab_wire.sym} 380 -260 0 1 {name=p2 sig_type=std_logic lab=OUT}
C {simulator_commands_shown.sym} 60 -490 0 0 {name=Libs_Ngspice
simulator=ngspice
only_toplevel=false 
value="
.lib cornerMOSlv.lib mos_tt
"}
C {launcher.sym} 540 -150 0 0 {name=h2
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

# run netlist and simulation
xschem netlist
simulate
"}
C {simulator_commands_shown.sym} 440 -880 0 0 {name=SIMULATOR
simulator=ngspice
only_toplevel=true 
value="
.param temp=27
.control
save all

** Define Input Signals
let fsig = 1k
let tper = 1 / fsig
let tfr = 0.01 * tper
let ton = 0.5 * tper - 2 * tfr

** Define Transient Parameters
let tstop = 2 * tper
let tstep = 0.001 * tper

** Set Sources
alter @VIN[DC] = 0.0
alter @VIN[PULSE] = [ 0 1.2 0 $&tfr $&tfr $&ton $&tper 0 ]

** Simulations
op
dc VIN 0 1.2 0.01
tran $&tstep $&tstop

** Plots
setplot dc1
let vout = v(out)
plot vout

setplot tran1
let vout = v(out)
let vin = v(in)
let ivdd = v1#branch * 1e4
plot vout vin ivdd

setplot op1
write inv_tb.raw
.endc
"}
C {launcher.sym} 800 -150 0 0 {name=h1
descr="Annotate OP" 
tclcommand="set show_hidden_texts 1; xschem annotate_op"}
