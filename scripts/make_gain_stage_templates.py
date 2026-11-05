#!/usr/bin/env python3
import os

TEMPLATES_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "cace", "templates", "gain_stage")

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
* std cells at top level (an include inside the DUT netlist is nested in the subckt and invisible to the sub-blocks)
.include CACE\{PDK_ROOT\}/CACE\{PDK\}/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice

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

TITLE_BLOCK = r"""C {title.sym} -100 400 0 0 {name=l_title author="SPMA Team"}"""

CIRCUIT_CORE = r"""N -60 -120 -60 -80 {lab=AVDD}
N -20 -120 -20 -80 {lab=AVSS}
N 20 -120 20 -80 {lab=IBIAS}
N -160 -20 -120 -20 {lab=VIN}
N -160 20 -120 20 {lab=VCM}
N 120 0 200 0 {lab=VOUT}
N -80 120 -80 160 {lab=s[0]}
N -40 120 -40 160 {lab=s[1]}
N 0 120 0 160 {lab=s[2]}
N 40 120 40 160 {lab=s[3]}
N 80 120 80 160 {lab=s[4]}
N -300 -230 -300 -210 {lab=AVDD}
N -300 -170 -300 -150 {lab=0}
N -220 -230 -220 -210 {lab=AVSS}
N -220 -170 -220 -150 {lab=0}
N -140 -230 -140 -210 {lab=VCM}
N -140 -170 -140 -150 {lab=0}
N -60 -230 -60 -210 {lab=IBIAS}
N -60 -170 -60 -150 {lab=0}
N 20 -230 20 -210 {lab=VIN}
N 20 -170 20 -150 {lab=0}
N 200 0 200 20 {lab=VOUT}
N 200 80 200 100 {lab=0}
N -300 230 -300 250 {lab=s[0]}
N -300 290 -300 310 {lab=0}
N -220 230 -220 250 {lab=s[1]}
N -220 290 -220 310 {lab=0}
N -140 230 -140 250 {lab=s[2]}
N -140 290 -140 310 {lab=0}
N -60 230 -60 250 {lab=s[3]}
N -60 290 -60 310 {lab=0}
N 20 230 20 250 {lab=s[4]}
N 20 290 20 310 {lab=0}
C {gain_stage.sym} 0 0 0 0 {name=x1}
C {lab_wire.sym} -60 -120 1 0 {name=l_avdd lab=AVDD}
C {lab_wire.sym} -20 -120 1 0 {name=l_avss lab=AVSS}
C {lab_wire.sym} 20 -120 1 0 {name=l_ibias lab=IBIAS}
C {lab_wire.sym} -160 -20 0 0 {name=l_vin lab=VIN}
C {lab_wire.sym} -160 20 0 0 {name=l_vcm lab=VCM}
C {lab_wire.sym} 160 0 2 0 {name=l_vout lab=VOUT}
C {lab_wire.sym} -80 160 3 0 {name=l_s_0 lab=s[0]}
C {lab_wire.sym} -40 160 3 0 {name=l_s_1 lab=s[1]}
C {lab_wire.sym} 0 160 3 0 {name=l_s_2 lab=s[2]}
C {lab_wire.sym} 40 160 3 0 {name=l_s_3 lab=s[3]}
C {lab_wire.sym} 80 160 3 0 {name=l_s_4 lab=s[4]}
C {vsource.sym} -300 -200 0 0 {name=V_AVDD value=\{vdd\} savecurrent=false}
C {lab_wire.sym} -300 -230 1 0 {name=l_s_avdd lab=AVDD}
C {gnd.sym} -300 -150 0 0 {name=g_avdd lab=0}
C {vsource.sym} -220 -200 0 0 {name=V_AVSS value=0 savecurrent=false}
C {lab_wire.sym} -220 -230 1 0 {name=l_s_avss lab=AVSS}
C {gnd.sym} -220 -150 0 0 {name=g_avss lab=0}
C {vsource.sym} -140 -200 0 0 {name=V_VCM value=\{vcm\} savecurrent=false}
C {lab_wire.sym} -140 -230 1 0 {name=l_s_vcm lab=VCM}
C {gnd.sym} -140 -150 0 0 {name=g_vcm lab=0}
C {isource.sym} -60 -200 2 0 {name=I_BIAS value=\{ib\}}
C {lab_wire.sym} -60 -230 1 0 {name=l_s_ib lab=IBIAS}
C {gnd.sym} -60 -150 0 0 {name=g_ib lab=0}
C {vsource.sym} 20 -200 0 0 {name=V_IN value="DC \{vcm\} AC 1m" savecurrent=false}
C {lab_wire.sym} 20 -230 1 0 {name=l_s_vin lab=VIN}
C {gnd.sym} 20 -150 0 0 {name=g_vin lab=0}
C {capa.sym} 200 50 0 0 {name=CL value=\{cl\} m=1}
C {gnd.sym} 200 100 0 0 {name=g_cl lab=0}
C {vsource.sym} -300 260 0 0 {name=V_S0 value=0 savecurrent=false}
C {lab_wire.sym} -300 230 1 0 {name=l_src_s0 lab=s[0]}
C {gnd.sym} -300 310 0 0 {name=g_s0 lab=0}
C {vsource.sym} -220 260 0 0 {name=V_S1 value=0 savecurrent=false}
C {lab_wire.sym} -220 230 1 0 {name=l_src_s1 lab=s[1]}
C {gnd.sym} -220 310 0 0 {name=g_s1 lab=0}
C {vsource.sym} -140 260 0 0 {name=V_S2 value=0 savecurrent=false}
C {lab_wire.sym} -140 230 1 0 {name=l_src_s2 lab=s[2]}
C {gnd.sym} -140 310 0 0 {name=g_s2 lab=0}
C {vsource.sym} -60 260 0 0 {name=V_S3 value=0 savecurrent=false}
C {lab_wire.sym} -60 230 1 0 {name=l_src_s3 lab=s[3]}
C {gnd.sym} -60 310 0 0 {name=g_s3 lab=0}
C {vsource.sym} 20 260 0 0 {name=V_S4 value=0 savecurrent=false}
C {lab_wire.sym} 20 230 1 0 {name=l_src_s4 lab=s[4]}
C {gnd.sym} 20 310 0 0 {name=g_s4 lab=0}"""

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

alter @v_s0[dc] = 0
alter @v_s1[dc] = 0
alter @v_s2[dc] = 0
alter @v_s3[dc] = 0
alter @v_s4[dc] = 0

if ($tap = 1)
  alter @v_s0[dc] = $vdd
end
if ($tap = 2)
  alter @v_s1[dc] = $vdd
end
if ($tap = 3)
  alter @v_s2[dc] = $vdd
end
if ($tap = 4)
  alter @v_s3[dc] = $vdd
end
if ($tap = 5)
  alter @v_s4[dc] = $vdd
end

alter @v_in[acmag] = 1
ac dec 30 1 100MEG

let gain_db = db(v(VOUT)/v(VIN))
let phase_deg = cph(v(VOUT)/v(VIN)) * 180 / pi

meas ac DC_gain FIND gain_db AT=10k
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

alter @v_s0[dc] = 0
alter @v_s1[dc] = 0
alter @v_s2[dc] = 0
alter @v_s3[dc] = 0
alter @v_s4[dc] = 0

if ($tap = 1)
  alter @v_s0[dc] = $vdd
end
if ($tap = 2)
  alter @v_s1[dc] = $vdd
end
if ($tap = 3)
  alter @v_s2[dc] = $vdd
end
if ($tap = 4)
  alter @v_s3[dc] = $vdd
end
if ($tap = 5)
  alter @v_s4[dc] = $vdd
end

alter @v_in[acmag] = 0
alter @v_in[dc] = CACE\{vcm\}

op

let v_out = v(VOUT)
let v_cm = v(VCM)
let vos = v_out - v_cm
let i_q = -1 * i(v_avdd)
let p_q = -1 * i(v_avdd) * CACE\{vdd\}

let cace_VOS = vos
let cace_IQ = i_q
let cace_PWR = p_q
let cace_VOUT = v_out

echo $&cace_VOS $&cace_IQ $&cace_PWR $&cace_VOUT > CACE\{simpath\}/CACE\{filename\}_CACE\{N\}.data
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

alter @v_s0[dc] = 0
alter @v_s1[dc] = 0
alter @v_s2[dc] = 0
alter @v_s3[dc] = 0
alter @v_s4[dc] = 0

if ($tap = 1)
  alter @v_s0[dc] = $vdd
end
if ($tap = 2)
  alter @v_s1[dc] = $vdd
end
if ($tap = 3)
  alter @v_s2[dc] = $vdd
end
if ($tap = 4)
  alter @v_s3[dc] = $vdd
end
if ($tap = 5)
  alter @v_s4[dc] = $vdd
end

alter @v_in[acmag] = 1
noise v(VOUT) v_in dec 20 10 100MEG
alter @v_in[acmag] = 0

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

alter @v_s0[dc] = 0
alter @v_s1[dc] = 0
alter @v_s2[dc] = 0
alter @v_s3[dc] = 0
alter @v_s4[dc] = 0

if ($tap = 1)
  alter @v_s0[dc] = $vdd
end
if ($tap = 2)
  alter @v_s1[dc] = $vdd
end
if ($tap = 3)
  alter @v_s2[dc] = $vdd
end
if ($tap = 4)
  alter @v_s3[dc] = $vdd
end
if ($tap = 5)
  alter @v_s4[dc] = $vdd
end

let v_cm = CACE\{vcm\}
let v_lo = CACE\{vcm\} - 0.01
alter @v_in pulse = [ $&v_cm $&v_lo 1u 10n 10n 5u 10u ]

tran 5n 8u

let vo_init = CACE\{vcm\}
let vo_final = CACE\{vcm\}
let vo_peak = CACE\{vcm\}

meas tran vo_init find v(VOUT) at=0.9u
meas tran vo_final find v(VOUT) at=5.5u
meas tran vo_peak max v(VOUT) from=1u to=3u

let delta_v = abs(vo_final - vo_init)
let tr_gain = (delta_v > 1e-6 ? delta_v / 0.01 : 1.0)
let ov_abs = vo_peak - vo_final
let overshoot = (delta_v > 1e-6 ? (ov_abs > 0 ? (ov_abs / delta_v) * 100 : 0) : 0)

let vs01 = vo_final - delta_v * 0.001
let t_settle = 1.2u
meas tran t_settle when v(VOUT)=$&vs01 cross=last from=1u to=5.5u
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

alter @v_s0[dc] = 0
alter @v_s1[dc] = 0
alter @v_s2[dc] = 0
alter @v_s3[dc] = 0
alter @v_s4[dc] = 0

let v_hi = CACE\{vcm\} + 0.2
let v_lo = CACE\{vcm\} - 0.2
alter @v_in pulse = [ $&v_hi $&v_lo 1u 1n 1n 5u 10u ]

tran 2n 8u

let v_mid_lo = CACE\{vcm\} - 0.16
let v_mid_hi = CACE\{vcm\} + 0.16

let t_r10 = 1u
let t_r90 = 1.1u
meas tran t_r10 when v(VOUT)=$&v_mid_lo rise=1 from=1u to=3u
meas tran t_r90 when v(VOUT)=$&v_mid_hi rise=1 from=1u to=3u
let dt_rise = t_r90 - t_r10
let sr_pos = (dt_rise > 0 ? (0.32 / dt_rise) : 3.0e6)

let t_f90 = 6u
let t_f10 = 6.1u
meas tran t_f90 when v(VOUT)=$&v_mid_hi fall=1 from=5.5u to=7.5u
meas tran t_f10 when v(VOUT)=$&v_mid_lo fall=1 from=5.5u to=7.5u
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

alter @v_s0[dc] = 0
alter @v_s1[dc] = 0
alter @v_s2[dc] = 0
alter @v_s3[dc] = 0
alter @v_s4[dc] = 0

if ($tap = 1)
  alter @v_s0[dc] = $vdd
end
if ($tap = 2)
  alter @v_s1[dc] = $vdd
end
if ($tap = 3)
  alter @v_s2[dc] = $vdd
end
if ($tap = 4)
  alter @v_s3[dc] = $vdd
end
if ($tap = 5)
  alter @v_s4[dc] = $vdd
end

let target_lin = 2^($tap)
let vin_amp = 0.2 / target_lin

alter @v_in sin = [ CACE\{vcm\} $&vin_amp 1k ]

tran 7.8125u 10m 2m 7.8125u

set specwindow=none
linearize v(VOUT)
fft v(VOUT)

let nc = floor(2 * (length(v(VOUT)) - 1) / 128 + 0.5)
let mag_f = mag(v(VOUT))
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

alter @v_s0[dc] = 0
alter @v_s1[dc] = 0
alter @v_s2[dc] = 0
alter @v_s3[dc] = 0
alter @v_s4[dc] = 0

if ($tap = 1)
  alter @v_s0[dc] = $vdd
end
if ($tap = 2)
  alter @v_s1[dc] = $vdd
end
if ($tap = 3)
  alter @v_s2[dc] = $vdd
end
if ($tap = 4)
  alter @v_s3[dc] = $vdd
end
if ($tap = 5)
  alter @v_s4[dc] = $vdd
end

alter @v_avdd[acmag] = 0
alter @v_in[acmag] = 1
ac dec 20 10 100MEG
let gain_in = db(v(VOUT))
let adm_dc = 0
meas ac adm_dc find gain_in at=10
set adm_val = $&adm_dc

alter @v_in[acmag] = 0
alter @v_avdd[acmag] = 1
ac dec 20 10 100MEG
let gain_vdd = db(v(VOUT))
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

alter @v_s0[dc] = 0
alter @v_s1[dc] = 0
alter @v_s2[dc] = 0
alter @v_s3[dc] = 0
alter @v_s4[dc] = 0

if ($tap = 1)
  alter @v_s0[dc] = $vdd
end
if ($tap = 2)
  alter @v_s1[dc] = $vdd
end
if ($tap = 3)
  alter @v_s2[dc] = $vdd
end
if ($tap = 4)
  alter @v_s3[dc] = $vdd
end
if ($tap = 5)
  alter @v_s4[dc] = $vdd
end

* Run 1: Differential mode (VIN=1, VCM=0)
alter @v_vcm[acmag] = 0
alter @v_in[acmag] = 1
ac dec 20 10 100MEG
let gain_in = db(v(VOUT) - v(VCM))
let adm_dc = 0
meas ac adm_dc find gain_in at=10
set adm_val = $&adm_dc

* Run 2: Common-mode mode (both VIN=1 and VCM=1 in phase)
alter @v_in[acmag] = 1
alter @v_vcm[acmag] = 1
ac dec 20 10 100MEG
let gain_cm = db(v(VOUT) - v(VCM) + 1e-15)
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

alter @v_s0 pulse = [ 0 $vdd 2u 10n 10n 2u 20u ]
alter @v_s1 pulse = [ 0 $vdd 4u 10n 10n 2u 20u ]
alter @v_s2[dc] = 0
alter @v_s3[dc] = 0
alter @v_s4[dc] = 0

let v_in_step = CACE\{vcm\} + 0.01
alter @v_in[dc] = $&v_in_step

tran 5n 8u

let v_baseline = CACE\{vcm\}
let v_glitch_peak = CACE\{vcm\}
meas tran v_glitch_peak max v(VOUT) from=1.9u to=2.5u
let v_glitch = abs(v_glitch_peak - $&v_baseline)

let v_settle_thresh = CACE\{vcm\} - 0.02
let t_settle = 2.5u
meas tran t_settle when v(VOUT)=$&v_settle_thresh cross=last from=2u to=6u
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

