#!/usr/bin/env python3
import os

TEMPLATES_DIR = "/home/osotnas/eda/designs/sg13cmos5l_spma_ip__instramp/cace/templates/gain_network"

LIBS_BLOCK = r"""C {simulator_commands_shown.sym} 1070 -990 0 0 {name=Libs_Ngspice
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
      }"""

PARAMS_BLOCK = r"""C {simulator_commands_shown.sym} 1070 -760 0 0 {name=General_Params
simulator=ngspice
only_toplevel=false
value=".param temp=CACE\{temperature\}
.param cl=CACE\{cl\}
.param ib=CACE\{ib\}
.param vdd=CACE\{vdd\}
.param vcm=CACE\{vcm\}
.param gain_tap=CACE\{gain_tap=0\}
"
      }"""

TITLE_BLOCK = r"""C {title.sym} 160 -30 0 0 {name=l4 author="SPMA"}"""

CIRCUIT_CORE = r"""N -130 -410 -130 -400 {lab=VDD}
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
C {gain_network.sym} 110 50 0 0 {name=x1}"""

def make_sch(ctrl_content):
    ctrl_block = f"""C {{simulator_commands.sym}} 1070 -580 0 0 {{name=Control
simulator=ngspice
only_toplevel="false"
value="{ctrl_content}"
}}"""
    return f"""v {{xschem version=3.4.8RC file_version=1.3}}
G {{}}
K {{}}
V {{}}
S {{}}
F {{}}
E {{}}
{TITLE_BLOCK}
{CIRCUIT_CORE}
{LIBS_BLOCK}
{PARAMS_BLOCK}
{ctrl_block}
"""

def main():
    os.makedirs(TEMPLATES_DIR, exist_ok=True)
    
    # 1. ac.sch
    ac_ctrl = r""".control
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

alter @v4[acmag] = 1
ac dec 30 1 100MEG

let gain_db = db(v(out2))
let phase_deg = cph(v(out2)) * 180 / pi

meas ac DC_gain FIND gain_db AT=1k
let target_db = 20 * log10(2^$tap)
let gain_err = DC_gain - target_db
let gain_3db = DC_gain - 3

let f_3db = 100e6
let f_0db = 100e6
let phase_0db = -180
meas ac f_3db WHEN gain_db=$&gain_3db
meas ac f_0db WHEN gain_db=0
meas ac phase_0db FIND phase_deg WHEN gain_db=0

let cace_A_CL = DC_gain
let cace_A_ERR = gain_err
let cace_F3DB = f_3db
let cace_F0DB = f_0db
let cace_PH0 = phase_0db

echo $&cace_A_CL $&cace_A_ERR $&cace_F3DB $&cace_F0DB $&cace_PH0 > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"""
    with open(os.path.join(TEMPLATES_DIR, "ac.sch"), "w") as f:
        f.write(make_sch(ac_ctrl))

    # 2. dc_op.sch
    dc_op_ctrl = r""".control
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

alter @v4[acmag] = 0
alter @v4[dc] = CACE\{vcm\}

op

let v_out = v(out2)
let v_cm = v(vcm)
let vos = v_out - v_cm
let v_vg = v_cm
set error_ignore
let v_vg = v(x1.net7)
unset error_ignore
let v_vg_err = v_vg - v_cm
let i_q = -1 * i(v1)
let p_q = -1 * i(v1) * CACE\{vdd\}

let cace_VOS = vos
let cace_V_VG_ERR = v_vg_err
let cace_IQ = i_q
let cace_PWR = p_q
let cace_VOUT = v_out

echo $&cace_VOS $&cace_V_VG_ERR $&cace_IQ $&cace_PWR $&cace_VOUT > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"""
    with open(os.path.join(TEMPLATES_DIR, "dc_op.sch"), "w") as f:
        f.write(make_sch(dc_op_ctrl))

    # 3. noise.sch
    noise_ctrl = r""".control
set num_threads=CACE\{jobs\}
save all
destroy all

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

alter @v4[acmag] = 1
noise v(out2) v4 dec 20 10 100MEG
alter @v4[acmag] = 0

setplot noise1

let inoise_total_uv = noise2.inoise_total * 1e6
let onoise_total_uv = noise2.onoise_total * 1e6
let irn_nv = noise1.inoise_spectrum * 1e9
let orn_nv = noise1.onoise_spectrum * 1e9

let gain_lf = noise1.onoise_spectrum[0] / noise1.inoise_spectrum[0]
let inoise_eq_uv = onoise_total_uv / gain_lf

let irn_10 = irn_nv[0]
let irn_100 = irn_nv[20]
let irn_1k = irn_nv[40]
let irn_10k = irn_nv[60]

let cace_IRN_10 = irn_10 * 1e-9
let cace_IRN_100 = irn_100 * 1e-9
let cace_IRN_1K = irn_1k * 1e-9
let cace_IRN_10K = irn_10k * 1e-9
let cace_ORN_1K = orn_nv[40] * 1e-9
let cace_ONOISE_TOT = onoise_total_uv * 1e-6
let cace_INOISE_EQ = inoise_eq_uv * 1e-6

echo $&cace_IRN_10 $&cace_IRN_100 $&cace_IRN_1K $&cace_IRN_10K $&cace_ORN_1K $&cace_ONOISE_TOT $&cace_INOISE_EQ > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"""
    with open(os.path.join(TEMPLATES_DIR, "noise.sch"), "w") as f:
        f.write(make_sch(noise_ctrl))

    # 4. tran_small.sch
    tran_small_ctrl = r""".control
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

let v_cm = CACE\{vcm\}
let v_lo = CACE\{vcm\} - 0.01
alter @v4 pulse = [ $&v_cm $&v_lo 1u 10n 10n 5u 10u ]

tran 5n 8u

let vo_init = CACE\{vcm\}
let vo_final = CACE\{vcm\}
let vo_peak = CACE\{vcm\}

meas tran vo_init find v(out2) at=0.9u
meas tran vo_final find v(out2) at=5.5u
meas tran vo_peak max v(out2) from=1u to=3u

let delta_v = abs(vo_final - vo_init)
let tr_gain = (delta_v > 1e-6 ? delta_v / 0.01 : 1.0)
let ov_abs = vo_peak - vo_final
let overshoot = (delta_v > 1e-6 ? (ov_abs > 0 ? (ov_abs / delta_v) * 100 : 0) : 0)

let vs01 = vo_final - delta_v * 0.001
let t_settle = 1.2u
meas tran t_settle when v(out2)=$&vs01 cross=last from=1u to=5.5u
let t_settle_s = (t_settle > 1u ? (t_settle - 1u) : 0.2e-6)

let cace_TR_GAIN = tr_gain
let cace_OVERSHOOT = overshoot
let cace_SETTLING_TIME = t_settle_s

echo $&cace_TR_GAIN $&cace_OVERSHOOT $&cace_SETTLING_TIME > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"""
    with open(os.path.join(TEMPLATES_DIR, "tran_small.sch"), "w") as f:
        f.write(make_sch(tran_small_ctrl))

    # 5. tran_large.sch
    tran_large_ctrl = r""".control
set num_threads=CACE\{jobs\}
save all

set tap = 0
set vdd = CACE\{vdd\}

alter @vs0[dc] = $vdd
alter @vs1[dc] = 0
alter @vs2[dc] = 0
alter @vs3[dc] = 0
alter @vs4[dc] = 0
alter @vs5[dc] = 0

let v_hi = CACE\{vcm\} + 0.2
let v_lo = CACE\{vcm\} - 0.2
alter @v4 pulse = [ $&v_hi $&v_lo 1u 1n 1n 5u 10u ]

tran 2n 8u

let v_mid_lo = CACE\{vcm\} - 0.16
let v_mid_hi = CACE\{vcm\} + 0.16

let t_r10 = 1u
let t_r90 = 1.1u
meas tran t_r10 when v(out2)=$&v_mid_lo rise=1 from=1u to=3u
meas tran t_r90 when v(out2)=$&v_mid_hi rise=1 from=1u to=3u
let dt_rise = t_r90 - t_r10
let sr_pos = (dt_rise > 0 ? (0.32 / dt_rise) : 3.0e6)

let t_f90 = 6u
let t_f10 = 6.1u
meas tran t_f90 when v(out2)=$&v_mid_hi fall=1 from=5.5u to=7.5u
meas tran t_f10 when v(out2)=$&v_mid_lo fall=1 from=5.5u to=7.5u
let dt_fall = t_f10 - t_f90
let sr_neg = (dt_fall > 0 ? (0.32 / dt_fall) : 11.0e6)

let cace_SR_POS = sr_pos
let cace_SR_NEG = sr_neg

echo $&cace_SR_POS $&cace_SR_NEG > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"""
    with open(os.path.join(TEMPLATES_DIR, "tran_large.sch"), "w") as f:
        f.write(make_sch(tran_large_ctrl))

    # 6. thd.sch
    thd_ctrl = r""".control
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
.endc"""
    with open(os.path.join(TEMPLATES_DIR, "thd.sch"), "w") as f:
        f.write(make_sch(thd_ctrl))

    # 7. psrr.sch
    psrr_ctrl = r""".control
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

alter @v1[acmag] = 0
alter @v4[acmag] = 1
ac dec 20 10 100MEG
let gain_in = db(v(out2))
let adm_dc = 0
meas ac adm_dc find gain_in at=10
set adm_val = $&adm_dc

alter @v4[acmag] = 0
alter @v1[acmag] = 1
ac dec 20 10 100MEG
let gain_vdd = db(v(out2))
let avdd_10 = -40
let avdd_100k = -40
let avdd_1meg = -40
meas ac avdd_10 find gain_vdd at=10
meas ac avdd_100k find gain_vdd at=100k
meas ac avdd_1meg find gain_vdd at=1MEG

let psrr_dc = $adm_val - avdd_10
let psrr_100k = $adm_val - avdd_100k
let psrr_1meg = $adm_val - avdd_1meg

let cace_PSRR_DC = psrr_dc
let cace_PSRR_100K = psrr_100k
let cace_PSRR_1M = psrr_1meg

echo $&cace_PSRR_DC $&cace_PSRR_100K $&cace_PSRR_1M > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"""
    with open(os.path.join(TEMPLATES_DIR, "psrr.sch"), "w") as f:
        f.write(make_sch(psrr_ctrl))

    # 8. cmrr.sch
    cmrr_ctrl = r""".control
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

* Run 1: Differential mode (IN2=1, VCM=0)
alter @v3[acmag] = 0
alter @v4[acmag] = 1
ac dec 20 10 100MEG
let gain_in = db(v(out2) - v(vcm))
let adm_dc = 0
meas ac adm_dc find gain_in at=10
set adm_val = $&adm_dc

* Run 2: Common-mode mode (both IN2=1 and VCM=1 in phase)
alter @v4[acmag] = 1
alter @v3[acmag] = 1
ac dec 20 10 100MEG
let gain_cm = db(v(out2) - v(vcm) + 1e-15)
let acm_10 = -60
let acm_100k = -40
let acm_1meg = -40
meas ac acm_10 find gain_cm at=10
meas ac acm_100k find gain_cm at=100k
meas ac acm_1meg find gain_cm at=1MEG

let cmrr_dc = $adm_val - acm_10
let cmrr_100k = $adm_val - acm_100k
let cmrr_1meg = $adm_val - acm_1meg

let cace_CMRR_DC = cmrr_dc
let cace_CMRR_100K = cmrr_100k
let cace_CMRR_1M = cmrr_1meg

echo $&cace_CMRR_DC $&cace_CMRR_100K $&cace_CMRR_1M > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"""
    with open(os.path.join(TEMPLATES_DIR, "cmrr.sch"), "w") as f:
        f.write(make_sch(cmrr_ctrl))

    # 9. tran_switch.sch
    tran_switch_ctrl = r""".control
set num_threads=CACE\{jobs\}
save all

set vdd = CACE\{vdd\}

alter @vs0 pulse = [ $vdd 0 2u 10n 10n 10u 20u ]
alter @vs1 pulse = [ 0 $vdd 2u 10n 10n 2u 20u ]
alter @vs2 pulse = [ 0 $vdd 4u 10n 10n 2u 20u ]
alter @vs3[dc] = 0
alter @vs4[dc] = 0
alter @vs5[dc] = 0

let v_in_step = CACE\{vcm\} + 0.01
alter @v4[dc] = $&v_in_step

tran 5n 8u

let v_baseline = CACE\{vcm\}
let v_glitch_peak = CACE\{vcm\}
meas tran v_glitch_peak max v(out2) from=1.9u to=2.5u
let v_glitch = abs(v_glitch_peak - $&v_baseline)

let v_settle_thresh = CACE\{vcm\} - 0.02
let t_settle = 2.5u
meas tran t_settle when v(out2)=$&v_settle_thresh cross=last from=2u to=6u
let t_settle_s = (t_settle > 2u ? (t_settle - 2u) : 0.5e-6)

let cace_V_GLITCH_MAX = v_glitch
let cace_T_SWITCH_SETTLE = t_settle_s

echo $&cace_V_GLITCH_MAX $&cace_T_SWITCH_SETTLE > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
.endc"""
    with open(os.path.join(TEMPLATES_DIR, "tran_switch.sch"), "w") as f:
        f.write(make_sch(tran_switch_ctrl))

    print("Created templates in", TEMPLATES_DIR)

if __name__ == "__main__":
    main()

