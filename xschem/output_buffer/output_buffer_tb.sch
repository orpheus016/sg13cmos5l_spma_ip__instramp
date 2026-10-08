v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
B 2 1320 150 2120 550 {flags=graph
y1=-2
y2=2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=20m
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node="v(vin_buf)
v(vo)
tracking_error
abs_tracking_error"
color="5 6 4"
dataset=-1
unitx=1
logx=0
logy=0
sim_type=tran
rawfile=$netlist_dir/output_buffer_tb_tran.raw}
B 2 2140 -260 2940 140 {flags=graph
y1=-10
y2=2
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=7
divx=5
subdivx=8
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node="acl_db"
color="5 6 4"
dataset=-1
unitx=1
logx=1
logy=0
sim_type=ac
rawfile=$netlist_dir/output_buffer_tb_ac.raw}
B 2 1320 -260 2120 140 {flags=graph
y1=0
y2=3.3
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=3.1
divx=5
subdivx=1
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node="v(vo)
v(vin_buf)
dc_error
abs_dc_error"
color="5 4 6"
dataset=-1
unitx=1
logx=0
logy=0
sim_type=dc
rawfile=$netlist_dir/output_buffer_tb_dc.raw}
B 2 2140 150 2940 550 {flags=graph
y1=-180
y2=20
ypos1=0
ypos2=2
divy=5
subdivy=1
unity=1
x1=0
x2=7
divx=5
subdivx=8
xlabmag=1.0
ylabmag=1.0
legendmag=1.0
node="acl_phase"
color=5
dataset=-1
unitx=1
logx=1
logy=0
sim_type=ac
rawfile=$netlist_dir/output_buffer_tb_ac.raw
}
N 415 230 450 230 {lab=0}
N 110 50 110 70 {lab=VO}
N 80 50 110 50 {lab=VO}
N 110 130 110 150 {lab=0}
N 380 210 380 230 {lab=0}
N 450 210 450 230 {lab=0}
N 415 230 415 245 {lab=0}
N 380 230 415 230 {lab=0}
N 380 130 380 150 {lab=VIN_BUF}
N 450 130 450 150 {lab=AVDD}
N 170 50 170 270 {lab=VO}
N -70 210 -70 230 {lab=0}
N -120 -70 -120 -50 {lab=AVDD}
N -70 130 -70 150 {lab=#net1}
N 170 50 190 50 {lab=VO}
N 140 130 140 150 {lab=0}
N -120 150 -120 170 {lab=0}
N -300 270 170 270 {lab=VO}
N -300 70 -300 270 {lab=VO}
N -300 70 -180 70 {lab=VO}
N -200 20 -180 20 {lab=VIN_BUF}
N 110 50 170 50 {lab=VO}
C {vsource.sym} 380 180 0 1 {name=V1 value="DC 1.65 AC 1 0 PULSE(1.64 1.66 1m 1u 1u 9m 20m)" savecurrent=false}
C {vsource.sym} 450 180 0 0 {name=V2 value="DC 3.3" savecurrent=false}
C {lab_pin.sym} 380 130 0 0 {name=p1 sig_type=std_logic lab=VIN_BUF}
C {lab_pin.sym} 450 130 0 1 {name=p2 sig_type=std_logic lab=AVDD}
C {lab_pin.sym} -120 -70 1 0 {name=p3 sig_type=std_logic lab=AVDD}
C {lab_pin.sym} -200 20 0 0 {name=p5 sig_type=std_logic lab=VIN_BUF}
C {gnd.sym} 415 245 0 0 {name=l1 lab=0}
C {iopin.sym} 190 50 0 0 {name=p4 lab=VO}
C {capa.sym} 110 100 0 1 {name=CLOAD
m=1
value=100f
footprint=1206
device="ceramic capacitor"}
C {gnd.sym} 110 150 0 0 {name=l3 lab=0}
C {isource.sym} -70 180 0 0 {name=I0 value=10u}
C {gnd.sym} -70 230 0 0 {name=l6 lab=0}
C {code_shown.sym} 540 -230 0 0 {name=MODEL only_toplevel=false
format="tcleval( @value )"
value="
.lib cornerMOShv.lib mos_tt
.include /foss/pdks/ihp-sg13cmos5l/libs.tech/ngspice/models/cap_mfringe.lib 
"
}
C {code_shown.sym} 550 -90 0 0 {name=NGSPICE only_toplevel=false 
value="
.param VCM=1.65
.param CLOAD_VALUE=100f
.param RLOAD_VALUE=100Meg

.control
set noaskquit
save all

* Operating point at the nominal output common-mode voltage.
op
write output_buffer_tb_op.raw
let vout_op = v(vo)
print vout_op

* Closed-loop small-signal response of the voltage follower.
ac dec 100 1 10Meg
let acl = v(vo)/v(vin_buf)
let acl_db = db(acl)
let acl_phase = 180/pi*cph(acl)
write output_buffer_tb_ac.raw

* Small-signal tracking and settling around VCM.
tran 1u 20m
let tracking_error = v(vo)-v(vin_buf)
let abs_tracking_error = abs(tracking_error)
meas tran t_band_entry when abs_tracking_error=0.2m fall=1 from=1m to=10m
meas tran vo_final find v(vo) at=19m
meas tran error_final find v(tracking_error) at=19m
meas tran error_peak max abs_tracking_error from=1m to=10m
meas tran vo_peak max v(vo) from=1m to=10m
meas tran vo_min min v(vo) from=1m to=10m
write output_buffer_tb_tran.raw

* DC transfer of the closed-loop follower.
dc V1 0.2 3.1 0.01
let dc_error = v(vo)-v(vin_buf)
let abs_dc_error = abs(dc_error)
write output_buffer_tb_dc.raw
.endc
"
}
C {launcher.sym} 220 410 0 0 {name=h5
descr="Load Transient waves" 
tclcommand="xschem raw_read $netlist_dir/output_buffer_tb_tran.raw tran"}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/output_buffer/output_buffer.sym} 160 30 0 0 {name=x1}
C {res.sym} 140 100 0 0 {name=RLOAD
value=100M
footprint=1206
device=resistor
m=1}
C {gnd.sym} 140 150 0 0 {name=l2 lab=0}
C {gnd.sym} -120 170 0 0 {name=l4 lab=0}
C {launcher.sym} 220 380 0 0 {name=h1
descr="Load AC Waves" 
tclcommand="xschem raw_read $netlist_dir/output_buffer_tb_ac.raw ac"}
C {launcher.sym} 220 350 0 0 {name=h2
descr="Load DC Sweep" 
tclcommand="xschem raw_read $netlist_dir/output_buffer_tb_dc.raw dc"}
C {launcher.sym} 220 320 0 0 {name=h3
descr="Annotate Operating Points" 
tclcommand="set show_hidden_texts 1; xschem annotate_op"}
C {title.sym} -200 710 0 0 {name=l5 author="Mamang Garox"}
