v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
C {title.sym} 160 -30 0 0 {name=l4 author="SPMA"}
N -130 -410 -130 -400 {lab=VDD}
N -50 -410 -50 -390 {lab=VDD}
N -50 -330 -50 -310 {lab=I_B}
N -130 -340 -130 -320 {lab=0}
N -190 -340 -190 -320 {lab=0}
N -190 -410 -190 -400 {lab=VSS}
N 70 -180 70 -160 {lab=I_B}
N 50 -180 70 -180 {lab=I_B}
N 90 -180 90 -160 {lab=VDD}
N 140 -10 140 10 {lab=VSS}
N 140 10 150 10 {lab=VSS}
N 10 -330 10 -310 {lab=VSS}
N 10 -420 20 -420 {lab=VCM}
N 10 -420 10 -390 {lab=VCM}
N -60 -80 -40 -80 {lab=VCM}
N -60 -100 -40 -100 {lab=IN2}
N 200 -90 220 -90 {lab=OUT2}
N 100 -310 100 -300 {lab=VSS}
N 100 -390 100 -370 {lab=OUT2}
N 20 -10 20 20 {lab=S5}
N 40 -10 40 20 {lab=S4}
N 60 -10 60 20 {lab=S3}
N 80 -10 80 20 {lab=S2}
N 100 -10 100 20 {lab=S1}
N 120 -10 120 20 {lab=S0}
N -370 -70 -370 -60 {lab=VSS}
N -310 -70 -310 -60 {lab=VSS}
N -370 -60 -310 -60 {lab=VSS}
N -370 -170 -370 -160 {lab=VSS}
N -250 -160 -190 -160 {lab=VSS}
N -190 -170 -190 -160 {lab=VSS}
N -310 -170 -310 -160 {lab=VSS}
N -370 -160 -310 -160 {lab=VSS}
N -250 -170 -250 -160 {lab=VSS}
N -310 -160 -250 -160 {lab=VSS}
N -190 -160 -170 -160 {lab=VSS}
N -310 -60 -290 -60 {lab=VSS}
N -370 -250 -370 -230 {lab=S0}
N -310 -250 -310 -230 {lab=S1}
N -250 -250 -250 -230 {lab=S2}
N -190 -250 -190 -230 {lab=S3}
N -370 -150 -370 -130 {lab=S4}
N -310 -150 -310 -130 {lab=S5}
N 180 -320 180 -300 {lab=VSS}
N 180 -410 190 -410 {lab=IN2}
N 180 -410 180 -380 {lab=IN2}
C {isource.sym} -50 -360 0 0 {name=I0 value=\{ib\}}
C {vsource.sym} -130 -370 0 0 {name=V1 value=\{vdd\} savecurrent=false}
C {gnd.sym} -130 -320 0 0 {name=l1 lab=0}
C {vdd.sym} -130 -410 0 0 {name=l3 lab=VDD}
C {vdd.sym} -50 -410 0 0 {name=l4 lab=VDD}
C {lab_pin.sym} -50 -310 3 0 {name=p7 sig_type=std_logic lab=I_B}
C {vsource.sym} -190 -370 0 0 {name=V2 value=0 savecurrent=false}
C {gnd.sym} -190 -320 0 0 {name=l7 lab=0}
C {lab_pin.sym} -190 -410 1 0 {name=p3 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 50 -180 0 0 {name=p1 sig_type=std_logic lab=I_B}
C {vdd.sym} 90 -180 0 0 {name=l2 lab=VDD}
C {lab_pin.sym} 150 10 2 0 {name=p2 sig_type=std_logic lab=VSS}
C {vsource.sym} 10 -360 0 0 {name=V3 value=\{vcm\} savecurrent=false}
C {lab_pin.sym} 20 -420 2 0 {name=p10 sig_type=std_logic lab=VCM}
C {lab_pin.sym} 10 -310 3 0 {name=p8 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -60 -80 0 0 {name=p4 sig_type=std_logic lab=VCM}
C {lab_pin.sym} -60 -100 0 0 {name=p5 sig_type=std_logic lab=IN2}
C {lab_pin.sym} 220 -90 2 0 {name=p6 sig_type=std_logic lab=OUT2}
C {capa.sym} 100 -340 0 0 {name=C1 m=1 value=\{cl\} footprint=1206 device="ceramic capacitor"}
C {lab_pin.sym} 100 -300 3 0 {name=p12 sig_type=std_logic lab=VSS}
C {lab_pin.sym} 100 -390 1 0 {name=p13 sig_type=std_logic lab=OUT2}
C {lab_pin.sym} 20 20 3 0 {name=p22 sig_type=std_logic lab=S5}
C {lab_pin.sym} 40 20 3 0 {name=p23 sig_type=std_logic lab=S4}
C {lab_pin.sym} 60 20 3 0 {name=p24 sig_type=std_logic lab=S3}
C {lab_pin.sym} 80 20 3 0 {name=p25 sig_type=std_logic lab=S2}
C {lab_pin.sym} 100 20 3 0 {name=p26 sig_type=std_logic lab=S1}
C {lab_pin.sym} 120 20 3 0 {name=p27 sig_type=std_logic lab=S0}
C {vsource.sym} -370 -200 0 0 {name=VS0 value=0 savecurrent=false}
C {vsource.sym} -310 -200 0 0 {name=VS1 value=0 savecurrent=false}
C {vsource.sym} -250 -200 0 0 {name=VS2 value=0 savecurrent=false}
C {vsource.sym} -190 -200 0 0 {name=VS3 value=0 savecurrent=false}
C {vsource.sym} -370 -100 0 0 {name=VS4 value=0 savecurrent=false}
C {vsource.sym} -310 -100 0 0 {name=VS5 value=0 savecurrent=false}
C {lab_pin.sym} -170 -160 2 0 {name=p28 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -290 -60 2 0 {name=p29 sig_type=std_logic lab=VSS}
C {lab_pin.sym} -370 -250 1 0 {name=p32 sig_type=std_logic lab=S0}
C {lab_pin.sym} -310 -250 1 0 {name=p33 sig_type=std_logic lab=S1}
C {lab_pin.sym} -250 -250 1 0 {name=p34 sig_type=std_logic lab=S2}
C {lab_pin.sym} -190 -250 1 0 {name=p35 sig_type=std_logic lab=S3}
C {lab_pin.sym} -370 -150 0 0 {name=p36 sig_type=std_logic lab=S4}
C {lab_pin.sym} -310 -150 0 0 {name=p37 sig_type=std_logic lab=S5}
C {vsource.sym} 180 -350 0 0 {name=V4 value=\{vcm\} savecurrent=false}
C {lab_pin.sym} 190 -410 2 0 {name=p48 sig_type=std_logic lab=IN2}
C {lab_pin.sym} 180 -300 3 0 {name=p49 sig_type=std_logic lab=VSS}
C {gain_network.sym} 110 50 0 0 {name=x1}
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
value=".param temp=CACE\{temperature\}
.param cl=CACE\{cl\}
.param ib=CACE\{ib\}
.param vdd=CACE\{vdd\}
.param vcm=CACE\{vcm\}
.param gain_tap=CACE\{gain_tap=0\}
"
      }
C {simulator_commands.sym} 1070 -580 0 0 {name=Control
simulator=ngspice
only_toplevel="false"
value=".control
set num_threads=CACE\{jobs\}
save all

set tap = CACE\{gain_tap=0\}
set vdd = CACE\{vdd\}

alter @vs0[dc] = 0
alter @vs1[dc] = 0
alter @vs2[dc] = 0
alter @vs3[dc] = 0
alter @vs4[dc] = 0
alter @vs5[dc] = 0

if ($tap = 0)
  alter @vs0[dc] = $vdd
end
if ($tap = 1)
  alter @vs1[dc] = $vdd
end
if ($tap = 2)
  alter @vs2[dc] = $vdd
end
if ($tap = 3)
  alter @vs3[dc] = $vdd
end
if ($tap = 4)
  alter @vs4[dc] = $vdd
end
if ($tap = 5)
  alter @vs5[dc] = $vdd
end

let target_lin = 2^($tap)
let vin_amp = 0.2 / target_lin

alter @v4 sin = [ CACE\{vcm\} $&vin_amp 1k ]

tran 7.8125u 10m 2m 7.8125u

set specwindow=none
linearize v(out2)
fft v(out2)

let nc = floor(2 * (length(v(out2)) - 1) / 128 + 0.5)
let mag_f = mag(v(out2))
let h1 = mag_f[nc]
let h2 = mag_f[2*nc]
let h3 = mag_f[3*nc]
let hsq = 0
let k = 2
while k <= 9
  let hsq = hsq + mag_f[k*nc]^2
  let k = k + 1
end
let thd = sqrt(hsq) / h1
let VO1 = h1
let THD_DB = 20 * log10(thd)
let THD_PCT = thd
let HD2_DB = 20 * log10(h2 / h1)
let HD3_DB = 20 * log10(h3 / h1)

let cace_THD_DB = THD_DB
let cace_THD_PCT = THD_PCT
let cace_HD2_DB = HD2_DB
let cace_HD3_DB = HD3_DB
let cace_VO1 = VO1

echo $&cace_THD_DB $&cace_THD_PCT $&cace_HD2_DB $&cace_HD3_DB $&cace_VO1 > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"
}
