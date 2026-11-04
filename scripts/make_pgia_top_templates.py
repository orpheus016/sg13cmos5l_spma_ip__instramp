#!/usr/bin/env python3
"""Build CACE templates for pgia_top in cace/templates/pgia_top/
Generated templates (matching tb_pgia_top.sch co-simulation battery):
  - dc_op.sch      (Phase A: DC operating point, offset, power, supply current)
  - ac_gain.sch    (Phase B: AC small-signal gain, bandwidth, 0dB frequency, phase)
  - tran.sch       (Phase C: Dynamic transient amplitude tracking and effective gain)
"""

import os
import shutil

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TDIR = os.path.join(ROOT, "cace", "templates", "pgia_top")
os.makedirs(TDIR, exist_ok=True)

# Copy DUT symbol so CACE / xschem finds it locally as a blackbox subcircuit
sym_src = os.path.join(ROOT, "xschem", "pgia_top", "pgia_top.sym")
sym_dst = os.path.join(TDIR, "pgia_top.sym")
with open(sym_src, "r") as f:
    sym_txt = f.read()
# Use type=primitive so Xschem does not generate an empty .subckt definition
sym_txt = sym_txt.replace("type=subcircuit", "type=primitive")
with open(sym_dst, "w") as f:
    f.write(sym_txt)

# Remove any old schematic copy to prevent xschem from attempting descending netlists
sch_in_tdir = os.path.join(TDIR, "pgia_top.sch")
if os.path.isfile(sch_in_tdir):
    os.remove(sch_in_tdir)

# Copy gain_decoder_4b.spice so ngspice can include it locally
shutil.copyfile(
    os.path.join(ROOT, "gds", "gain_decoder_4b", "final", "spice", "gain_decoder_4b.spice"),
    os.path.join(TDIR, "gain_decoder_4b.spice")
)

# Write local xschemrc
with open(os.path.join(TDIR, "xschemrc"), "w") as f:
    f.write("""# xschemrc for pgia_top CACE templates
set _here [file dirname [file normalize [info script]]]
source [file normalize "$_here/../xschemrc"]
append XSCHEM_LIBRARY_PATH :$_here
append XSCHEM_LIBRARY_PATH :$_here/../../xschem/pgia_top
append XSCHEM_LIBRARY_PATH :$_here/../../xschem/gain_stage
append XSCHEM_LIBRARY_PATH :$_here/../../xschem/output_buffer
append XSCHEM_LIBRARY_PATH :$_here/../../xschem/gain_decoder_4b
append XSCHEM_LIBRARY_PATH :$_here/../../xschem/instramp_cmos5l
append XSCHEM_LIBRARY_PATH :$_here/../../xschem/ota_cmos5l
append XSCHEM_LIBRARY_PATH :$_here/../../xschem/tgate
""")

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
.param rl=CACE\{rl\}
.param vdd=CACE\{vdd\}
.param vcm=CACE\{vcm\}
.param ib_ia=CACE\{ib_ia=4.2u\}
.param ib_buf=CACE\{ib_buf=1.4u\}
.param ib_g1=CACE\{ib_g1=1.0u\}
.param ib_g2=CACE\{ib_g2=1.0u\}
.param gain_code=CACE\{gain_code=0\}
"
      }"""

TITLE_BLOCK = r"""C {title.sym} 160 -30 0 0 {name=l4 author="SPMA"}"""

CIRCUIT_CORE = r"""N -180 -100 -150 -100 {lab=VINP}
N -180 -60 -150 -60 {lab=VINN}
N -180 -20 -150 -20 {lab=VCM}
N -180 40 -150 40 {lab=gain_sel[0]}
N -180 70 -150 70 {lab=gain_sel[1]}
N -180 100 -150 100 {lab=gain_sel[2]}
N -180 130 -150 130 {lab=gain_sel[3]}
N 150 -60 190 -60 {lab=VOUT}
N -80 -220 -80 -190 {lab=AVDD}
N -40 -220 -40 -190 {lab=VPWR}
N 0 -220 0 -190 {lab=IBIAS_IA}
N 30 -220 30 -190 {lab=IBIAS_G1}
N 60 -220 60 -190 {lab=IBIAS_G2}
N 90 -220 90 -190 {lab=IBIAS_BUF}
N -60 190 -60 220 {lab=AVSS}
N -20 190 -20 220 {lab=VGND}
N -540 -410 -540 -390 {lab=AVDD}
N -540 -330 -540 -310 {lab=0}
N -460 -410 -460 -390 {lab=AVSS}
N -460 -330 -460 -310 {lab=0}
N -380 -410 -380 -390 {lab=VPWR}
N -380 -330 -380 -310 {lab=0}
N -300 -410 -300 -390 {lab=VGND}
N -300 -330 -300 -310 {lab=0}
N -540 -240 -540 -220 {lab=IBIAS_IA}
N -540 -160 -540 -140 {lab=0}
N -460 -240 -460 -220 {lab=IBIAS_BUF}
N -460 -160 -460 -140 {lab=0}
N -380 -240 -380 -220 {lab=AVDD}
N -380 -160 -380 -140 {lab=IBIAS_G1}
N -300 -240 -300 -220 {lab=AVDD}
N -300 -160 -300 -140 {lab=IBIAS_G2}
N -500 -60 -500 -40 {lab=VCM}
N -500 20 -500 40 {lab=0}
N -420 -60 -420 -40 {lab=VINP}
N -420 20 -420 40 {lab=VCM}
N -340 -60 -340 -40 {lab=VINN}
N -340 20 -340 40 {lab=VCM}
N -540 120 -540 140 {lab=gain_sel[0]}
N -540 200 -540 220 {lab=0}
N -460 120 -460 140 {lab=gain_sel[1]}
N -460 200 -460 220 {lab=0}
N -380 120 -380 140 {lab=gain_sel[2]}
N -380 200 -380 220 {lab=0}
N -300 120 -300 140 {lab=gain_sel[3]}
N -300 200 -300 220 {lab=0}
N 250 -60 250 -40 {lab=VOUT}
N 250 20 250 40 {lab=0}
N 330 -60 330 -40 {lab=VOUT}
N 330 20 330 40 {lab=0}
C {pgia_top.sym} 0 0 0 0 {name=x1}
C {lab_wire.sym} -180 -100 0 0 {name=l_dut_vinp lab=VINP}
C {lab_wire.sym} -180 -60 0 0 {name=l_dut_vinn lab=VINN}
C {lab_wire.sym} -180 -20 0 0 {name=l_dut_vcm lab=VCM}
C {lab_wire.sym} -180 40 0 0 {name=l_dut_g0 lab=gain_sel[0]}
C {lab_wire.sym} -180 70 0 0 {name=l_dut_g1 lab=gain_sel[1]}
C {lab_wire.sym} -180 100 0 0 {name=l_dut_g2 lab=gain_sel[2]}
C {lab_wire.sym} -180 130 0 0 {name=l_dut_g3 lab=gain_sel[3]}
C {lab_wire.sym} 190 -60 2 0 {name=l_dut_vout lab=VOUT}
C {lab_wire.sym} -80 -220 1 0 {name=l_dut_avdd lab=AVDD}
C {lab_wire.sym} -40 -220 1 0 {name=l_dut_vpwr lab=VPWR}
C {lab_wire.sym} 0 -220 1 0 {name=l_dut_ibia lab=IBIAS_IA}
C {lab_wire.sym} 30 -220 1 0 {name=l_dut_ibg1 lab=IBIAS_G1}
C {lab_wire.sym} 60 -220 1 0 {name=l_dut_ibg2 lab=IBIAS_G2}
C {lab_wire.sym} 90 -220 1 0 {name=l_dut_ibbuf lab=IBIAS_BUF}
C {lab_wire.sym} -60 220 3 0 {name=l_dut_avss lab=AVSS}
C {lab_wire.sym} -20 220 3 0 {name=l_dut_vgnd lab=VGND}
C {vsource.sym} -540 -360 0 0 {name=V_AVDD value=\{vdd\} savecurrent=false}
C {lab_wire.sym} -540 -410 1 0 {name=l_p_avdd lab=AVDD}
C {gnd.sym} -540 -310 0 0 {name=g_avdd lab=0}
C {vsource.sym} -460 -360 0 0 {name=V_AVSS value=0 savecurrent=false}
C {lab_wire.sym} -460 -410 1 0 {name=l_p_avss lab=AVSS}
C {gnd.sym} -460 -310 0 0 {name=g_avss lab=0}
C {vsource.sym} -380 -360 0 0 {name=V_VPWR value=\{vdd\} savecurrent=false}
C {lab_wire.sym} -380 -410 1 0 {name=l_p_vpwr lab=VPWR}
C {gnd.sym} -380 -310 0 0 {name=g_vpwr lab=0}
C {vsource.sym} -300 -360 0 0 {name=V_VGND value=0 savecurrent=false}
C {lab_wire.sym} -300 -410 1 0 {name=l_p_vgnd lab=VGND}
C {gnd.sym} -300 -310 0 0 {name=g_vgnd lab=0}
C {isource.sym} -540 -190 0 0 {name=I_IA value=\{ib_ia\}}
C {lab_wire.sym} -540 -240 1 0 {name=l_src_ibia lab=IBIAS_IA}
C {gnd.sym} -540 -140 0 0 {name=g_src_ibia lab=0}
C {isource.sym} -460 -190 0 0 {name=I_BUF value=\{ib_buf\}}
C {lab_wire.sym} -460 -240 1 0 {name=l_src_ibbuf lab=IBIAS_BUF}
C {gnd.sym} -460 -140 0 0 {name=g_src_ibbuf lab=0}
C {isource.sym} -380 -190 0 0 {name=I_G1 value=\{ib_g1\}}
C {lab_wire.sym} -380 -240 1 0 {name=l_src_ibg1_vdd lab=AVDD}
C {lab_wire.sym} -380 -140 3 0 {name=l_src_ibg1 lab=IBIAS_G1}
C {isource.sym} -300 -190 0 0 {name=I_G2 value=\{ib_g2\}}
C {lab_wire.sym} -300 -240 1 0 {name=l_src_ibg2_vdd lab=AVDD}
C {lab_wire.sym} -300 -140 3 0 {name=l_src_ibg2 lab=IBIAS_G2}
C {vsource.sym} -500 -10 0 0 {name=V_CM value=\{vcm\} savecurrent=false}
C {lab_wire.sym} -500 -60 1 0 {name=l_src_vcm lab=VCM}
C {gnd.sym} -500 40 0 0 {name=g_src_vcm lab=0}
C {vsource.sym} -540 170 0 0 {name=V_G0 value="DC 0" savecurrent=false}
C {lab_wire.sym} -540 120 1 0 {name=l_src_g0 lab=gain_sel[0]}
C {gnd.sym} -540 220 0 0 {name=g_src_g0 lab=0}
C {vsource.sym} -460 170 0 0 {name=V_G1 value="DC 0" savecurrent=false}
C {lab_wire.sym} -460 120 1 0 {name=l_src_g1 lab=gain_sel[1]}
C {gnd.sym} -460 220 0 0 {name=g_src_g1 lab=0}
C {vsource.sym} -380 170 0 0 {name=V_G2 value="DC 0" savecurrent=false}
C {lab_wire.sym} -380 120 1 0 {name=l_src_g2 lab=gain_sel[2]}
C {gnd.sym} -380 220 0 0 {name=g_src_g2 lab=0}
C {vsource.sym} -300 170 0 0 {name=V_G3 value="DC 0" savecurrent=false}
C {lab_wire.sym} -300 120 1 0 {name=l_src_g3 lab=gain_sel[3]}
C {gnd.sym} -300 220 0 0 {name=g_src_g3 lab=0}
C {capa.sym} 250 -10 0 0 {name=CL value=\{cl\} m=1}
C {lab_wire.sym} 250 -60 1 0 {name=l_load_cl lab=VOUT}
C {gnd.sym} 250 40 0 0 {name=g_load_cl lab=0}
C {res.sym} 330 -10 0 0 {name=RL value=\{rl\} m=1}
C {lab_wire.sym} 330 -60 1 0 {name=l_load_rl lab=VOUT}
C {gnd.sym} 330 40 0 0 {name=g_load_rl lab=0}
"""

def make_inputs(vinp_val, vinn_val):
    return f"""C {{vsource.sym}} -420 -10 0 0 {{name=V_INP value="{vinp_val}" savecurrent=false}}
C {{lab_wire.sym}} -420 -60 1 0 {{name=l_src_vinp lab=VINP}}
C {{lab_wire.sym}} -420 40 3 0 {{name=l_src_vinp_cm lab=VCM}}
C {{vsource.sym}} -340 -10 0 0 {{name=V_INN value="{vinn_val}" savecurrent=false}}
C {{lab_wire.sym}} -340 -60 1 0 {{name=l_src_vinn lab=VINN}}
C {{lab_wire.sym}} -340 40 3 0 {{name=l_src_vinn_cm lab=VCM}}
"""

def make_control(ctrl_text):
    return f"""C {{simulator_commands.sym}} 1070 -580 0 0 {{name=Control
simulator=ngspice
only_toplevel="false"
value="{ctrl_text}"
}}"""

BIT_LOGIC = """let code = CACE\\{gain_code=0\\}
let vdd = CACE\\{vdd\\}
let b0 = (code % 2 >= 1) ? vdd : 0
let b1 = (floor(code / 2) % 2 >= 1) ? vdd : 0
let b2 = (floor(code / 4) % 2 >= 1) ? vdd : 0
let b3 = (floor(code / 8) % 2 >= 1) ? vdd : 0
alter @v_g0[dc] = $&b0
alter @v_g1[dc] = $&b1
alter @v_g2[dc] = $&b2
alter @v_g3[dc] = $&b3
"""

# -----------------------------------------------------------------------------
# 1. dc_op.sch (Phase A: Values in SI base units: V, A, W)
# -----------------------------------------------------------------------------
ctrl_dc_op = f""".control
set num_threads=CACE\\{{jobs\\}}
save all v(VOUT) v(x1.v_ia) v(x1.v_stage1) v(x1.v_stage2)

{BIT_LOGIC}
op

let v_ia = v(x1.v_ia)
let v_st1 = v(x1.v_stage1)
let v_st2 = v(x1.v_stage2)
let v_out = v(VOUT)
let i_avdd = -i(v_avdd)
let i_vpwr = -i(v_vpwr)
let i_tot = i_avdd + i_vpwr

let cace_VOS = abs(v_out - CACE\\{{vcm\\}})
let cace_V_IA = v_ia
let cace_V_ST1 = v_st1
let cace_V_ST2 = v_st2
let cace_VOUT = v_out
let cace_I_AVDD = i_avdd
let cace_I_VPWR = i_vpwr
let cace_IQ_TOT = i_tot
let cace_PWR = i_tot * CACE\\{{vdd\\}}

echo $&cace_VOS $&cace_V_IA $&cace_V_ST1 $&cace_V_ST2 $&cace_VOUT $&cace_I_AVDD $&cace_I_VPWR $&cace_IQ_TOT $&cace_PWR > CACE\\{{simpath\\}}/CACE\\{{filename\\}}_CACE\\{{N\\}}.data
.endc"""

# -----------------------------------------------------------------------------
# 2. ac_gain.sch (Phase B: Values in SI base units: dB, Hz, deg)
# -----------------------------------------------------------------------------
ctrl_ac = f""".control
set num_threads=CACE\\{{jobs\\}}
save all v(VOUT)

{BIT_LOGIC}
alter @v_inp[acmag] = 0.5
alter @v_inn[acmag] = -0.5

ac dec 20 0.1 100Meg

let gain_db = db(v(VOUT))
let phase_deg = cph(v(VOUT)) * 180 / pi

meas ac gain_1k find gain_db at=1k
meas ac ph_1k find phase_deg at=1k

let code_idx = (code <= 10 ? code : 0)
let target_db = 18.0618 + code_idx * 6.0206
let gain_err = gain_1k - target_db

let gain_3db = gain_1k - 3
let f_3db = 50e3
meas ac f_3db when gain_db = $&gain_3db fall=1

let f_0db = 10e6
meas ac f_0db when gain_db = 0 fall=1

let r_pseudo = 0.5 / (abs(i(v_inp)[0]) + 1e-18)
let cace_R_PSEUDO = r_pseudo

let cace_A_CL = gain_1k
let cace_A_ERR = gain_err
let cace_F3DB = f_3db
let cace_F0DB = f_0db
let cace_PH_1K = ph_1k

echo $&cace_A_CL $&cace_A_ERR $&cace_F3DB $&cace_F0DB $&cace_PH_1K $&cace_R_PSEUDO > CACE\\{{simpath\\}}/CACE\\{{filename\\}}_CACE\\{{N\\}}.data
.endc"""

# -----------------------------------------------------------------------------
# 3. tran.sch (Phase C: Values in SI base units: V, V/V)
# -----------------------------------------------------------------------------
ctrl_tran = f""".control
set num_threads=CACE\\{{jobs\\}}
save all v(VOUT)

{BIT_LOGIC}
tran 100n 300u 100u
meas tran vpp pp v(VOUT) from=200u to=300u
let cace_VPP_OUT = vpp
let cace_EFF_GAIN = vpp / 40e-6

echo $&cace_VPP_OUT $&cace_EFF_GAIN > CACE\\{{simpath\\}}/CACE\\{{filename\\}}_CACE\\{{N\\}}.data
.endc"""

def assemble(inputs, ctrl):
    head = "v {xschem version=3.4.8RC file_version=1.3}\nG {}\nK {}\nV {}\nS {}\nF {}\nE {}\n"
    return head + TITLE_BLOCK + "\n" + CIRCUIT_CORE + inputs + LIBS_BLOCK + "\n" + PARAMS_BLOCK + "\n" + make_control(ctrl) + "\n"

templates = {
    "dc_op.sch": assemble(make_inputs("0", "0"), ctrl_dc_op),
    "ac_gain.sch": assemble(make_inputs("0 AC 0.5", "0 AC -0.5"), ctrl_ac),
    "tran.sch": assemble(make_inputs("0 SIN(0 20u 10k 0 0 0)", "0 SIN(0 20u 10k 0 0 180)"), ctrl_tran),
}

# Clean any obsolete templates
for obs in ["cmrr.sch", "psrr.sch", "noise.sch"]:
    p_obs = os.path.join(TDIR, obs)
    if os.path.isfile(p_obs):
        os.remove(p_obs)
        print(f"[-] Removed obsolete template: {obs}")

for name, content in templates.items():
    p = os.path.join(TDIR, name)
    with open(p, "w") as f:
        f.write(content)
    print(f"[*] Wrote template: {os.path.relpath(p, ROOT)}")

print("[+] All CACE templates for pgia_top aligned with tb_pgia_top successfully.")
