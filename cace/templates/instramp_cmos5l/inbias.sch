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
C {title.sym} 160 -30 0 0 {name=l4 author="James Patrick"}
C {vdd.sym} 770 -550 0 0 {name=l1 lab=VDD}
C {lab_wire.sym} 810 -550 0 0 {name=p1 sig_type=std_logic lab=vss}
C {lab_wire.sym} 730 -550 0 0 {name=p2 sig_type=std_logic lab=ibias}
C {capa.sym} 960 -320 0 0 {name=C1
m=1
value=\{cl\}
footprint=1206
device="ceramic capacitor"}
C {lab_wire.sym} 1000 -380 0 0 {name=p4 sig_type=std_logic lab=out}
C {lab_wire.sym} 180 -480 0 0 {name=p5 sig_type=std_logic lab=ibias}
C {isource.sym} 180 -410 0 0 {name=I0 value=\{ib\}}
C {vdd.sym} 80 -480 0 0 {name=l2 lab=VDD}
C {vsource.sym} 80 -410 0 0 {name=V1 value=\{vdd\} savecurrent=false}
C {lab_wire.sym} 80 -340 0 0 {name=p7 sig_type=std_logic lab=vss}
C {vsource.sym} 80 -270 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} 80 -200 0 0 {name=l3 lab=0}
C {lab_wire.sym} 280 -480 0 0 {name=p9 sig_type=std_logic lab=vsp}
C {vsource.sym} 280 -410 0 0 {name=V3 value="sin(\{vcm\} \{vamp\} \{fin\})" savecurrent=false}
C {vsource.sym} 380 -410 0 0 {name=V4 value=\{vcm\} savecurrent=false}
C {lab_wire.sym} 380 -480 0 0 {name=p12 sig_type=std_logic lab=vsn}
C {lab_wire.sym} 580 -330 2 0 {name=p13 sig_type=std_logic lab=vinp}
C {lab_wire.sym} 580 -430 2 0 {name=p14 sig_type=std_logic lab=vinn}
C {gnd.sym} 960 -260 0 0 {name=l5 lab=0}
C {instramp_cmos5l.sym} 770 -380 0 0 {name=x1}
C {lab_wire.sym} 580 -380 2 0 {name=p3 sig_type=std_logic lab=vcm}
C {vsource.sym} 480 -410 0 0 {name=V5 value=\{vcm\} savecurrent=false}
C {lab_wire.sym} 480 -480 0 0 {name=p6 sig_type=std_logic lab=vcm}
C {simulator_commands_shown.sym} 1070 -990 0 0 {name=Libs_Ngspice
simulator=ngspice
only_toplevel=false
value="
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOSlv.lib mos_CACE\{corner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOShv.lib mos_CACE\{corner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerRES.lib res_CACE\{rcorner\}
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerCAP.lib cap_typ
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerDIO.lib dio_tt
.lib CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.tech/ngspice/models/cornerMOSCAP.lib moscap_tt

.include CACE\{DUT_path\}

.temp CACE\{temperature\}

.option SEED=CACE[CACE\{seed=12345\} + CACE\{iterations=0\}]
"
      }
C {simulator_commands_shown.sym} 1070 -760 0 0 {name=General_Params
simulator=ngspice
only_toplevel=false
value=".param ib=CACE\{ib\}
.param vdd=CACE\{vdd\}
.param vcm=CACE\{vcm\}
.param cl=CACE\{cl\}
.param fin=CACE\{fin\}
.param vamp=CACE\{vin_amp\}
.param rs=CACE\{rs\}
.param ncyc=8 nskip=2
"
      }
C {simulator_commands_shown.sym} 1070 -1200 0 0 {name=InputNetwork
simulator=ngspice
only_toplevel=false
value="
* source impedance in front of both inputs
Rsp vsp vinp \{rs\}
Rsn vsn vinn \{rs\}
* pseudo-resistor network of pgia_top.sch (generated from netlist/pgia_top/lvs/pgia_top.spice, scripts/make_instramp_inbias_template.py)
XM1 pr_n1 pr_n1 vcm VDD sg13_lv_pmos w=0.2u l=2u ng=1 m=1 mm_ok=1
XM2 pr_n1 pr_n1 vinn VDD sg13_lv_pmos w=0.2u l=2u ng=1 m=1 mm_ok=1
XM3 pr_n2 pr_n2 vinp VDD sg13_lv_pmos w=0.2u l=2u ng=1 m=1 mm_ok=1
XM4 pr_n2 pr_n2 vcm VDD sg13_lv_pmos w=0.2u l=2u ng=1 m=1 mm_ok=1
"
}
C {simulator_commands.sym} 1070 -600 0 0 {name=InputNetworkSim
simulator=ngspice
only_toplevel="false"
value=".control
set num_threads=CACE\{jobs\}
save all
* 1) DC: output level with the network and the source impedance in place
op
let vos_net = v(out)[0] - CACE\{vcm\}
set s_vos = $&vos_net
* 2) small signal: gain at 1 kHz and the resistance one input sees (V3 drives VINP through Rs; VINN is held at DC)
alter @v3[acmag]=1
ac dec 10 0.1 1meg
let gdb = db(v(out))
meas ac gain_1k find gdb at=1k
let a_net = gain_1k
set s_gain = $&a_net
let r_in = 1 / abs(i(v3)[0]) - CACE\{rs\}
set s_rin = $&r_in
* 3) noise referred to V3, source impedance included (Rs and the network are part of the circuit)
noise v(out) v3 dec 20 10 100k
alter @v3[acmag]=0
setplot noise1
let irn_100 = noise1.inoise_spectrum[20]
let irn_1k = noise1.inoise_spectrum[40]
set s_irn100 = $&irn_100
set s_irn1k = $&irn_1k
* 4) distortion: vin_amp sine on VINP behind Rs, coherent sampling (ncyc periods, 128 points each)
let fin_ = CACE\{fin\}
let tstep = 1 / (fin_ * 128)
let tstop = (2 + 8) / fin_ - tstep
let tstart = 2 / fin_
tran $&tstep $&tstop $&tstart $&tstep
set specwindow=none
linearize v(out)
fft v(out)
let nc = floor(2 * (length(v(out)) - 1) / 128 + 0.5)
let mag_f = mag(v(out))
let h1 = mag_f[nc]
let h2 = mag_f[2*nc]
let h3 = mag_f[3*nc]
let hsq = 0
let k = 2
while k <= 9
  let hsq = hsq + mag_f[k*nc]^2
  let k = k + 1
end
let thd_db = 20 * log10(sqrt(hsq) / h1)
let hd3_db = 20 * log10(h3 / h1)
set s_thd = $&thd_db
set s_hd3 = $&hd3_db
echo $s_rin $s_gain $s_irn100 $s_irn1k $s_vos $s_thd $s_hd3 > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"
}
