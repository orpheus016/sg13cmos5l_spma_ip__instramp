v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -290 10 -270 10 {lab=gain_sel[0]}
N -290 30 -270 30 {lab=gain_sel[1]}
N -290 50 -270 50 {lab=gain_sel[2]}
N -290 70 -270 70 {lab=gain_sel[3]}
N -190 -50 -190 -30 {lab=VPWR}
N -190 430 -190 450 {lab=VGND}
N -110 10 -90 10 {lab=s1[0]}
N -110 30 -90 30 {lab=s1[1]}
N -110 50 -90 50 {lab=s1[2]}
N -110 70 -90 70 {lab=s1[3]}
N -110 90 -90 90 {lab=s1[4]}
N -110 210 -90 210 {lab=s2[0]}
N -110 230 -90 230 {lab=s2[1]}
N -110 250 -90 250 {lab=s2[2]}
N -110 270 -90 270 {lab=s2[3]}
N -110 290 -90 290 {lab=s2[4]}
N 250 -200 250 -180 {lab=AVDD}
N 290 -200 290 -180 {lab=AVSS}
N 210 -200 210 -180 {lab=IBIAS_IA}
N 100 -100 120 -100 {lab=VINN}
N 100 0 120 0 {lab=VINP}
N 100 -50 120 -50 {lab=VCM}
N 590 -170 590 -150 {lab=AVDD}
N 630 -170 630 -150 {lab=AVSS}
N 670 -170 670 -150 {lab=IBIAS_G1}
N 490 -30 510 -30 {lab=VCM}
N 790 -50 830 -50 {lab=v_stage1}
N 570 90 570 110 {lab=s1[0]}
N 610 90 610 110 {lab=s1[1]}
N 650 90 650 110 {lab=s1[2]}
N 690 90 690 110 {lab=s1[3]}
N 730 90 730 110 {lab=s1[4]}
N 990 -170 990 -150 {lab=AVDD}
N 1030 -170 1030 -150 {lab=AVSS}
N 1070 -170 1070 -150 {lab=IBIAS_G2}
N 890 -70 910 -70 {lab=v_stage1}
N 890 -30 910 -30 {lab=VCM}
N 1190 -50 1230 -50 {lab=v_stage2}
N 970 90 970 110 {lab=s2[0]}
N 1010 90 1010 110 {lab=s2[1]}
N 1050 90 1050 110 {lab=s2[2]}
N 1090 90 1090 110 {lab=s2[3]}
N 1130 90 1130 110 {lab=s2[4]}
N 1270 -150 1270 -130 {lab=AVDD}
N 1270 70 1270 90 {lab=AVSS}
N 1320 50 1320 70 {lab=IBIAS_BUF}
N 1190 -60 1210 -60 {lab=v_stage2}
N 1190 -10 1210 -10 {lab=VOUT}
N 1470 -30 1510 -30 {lab=VOUT}
N -150 -380 -150 -370 {lab=V_MID_N}
N -210 -340 -190 -340 {lab=V_MID_N}
N -210 -380 -210 -340 {lab=V_MID_N}
N -210 -380 -150 -380 {lab=V_MID_N}
N -150 -390 -150 -380 {lab=V_MID_N}
N -150 -470 -150 -450 {lab=VINN}
N -210 -420 -190 -420 {lab=V_MID_N}
N -210 -420 -210 -380 {lab=V_MID_N}
N -150 -310 -150 -290 {lab=VCM}
N 10 -380 10 -370 {lab=V_MID_P}
N -50 -340 -30 -340 {lab=V_MID_P}
N -50 -380 -50 -340 {lab=V_MID_P}
N -50 -380 10 -380 {lab=V_MID_P}
N 10 -390 10 -380 {lab=V_MID_P}
N 10 -470 10 -450 {lab=VCM}
N -50 -420 -30 -420 {lab=V_MID_P}
N -50 -420 -50 -380 {lab=V_MID_P}
N 10 -310 10 -290 {lab=VINP}
N -150 -340 -100 -340 {lab=AVDD}
N -100 -420 -100 -340 {lab=AVDD}
N -150 -420 -100 -420 {lab=AVDD}
N -100 -500 -100 -420 {lab=AVDD}
N -100 -500 90 -500 {lab=AVDD}
N 90 -500 90 -420 {lab=AVDD}
N 10 -420 90 -420 {lab=AVDD}
N 10 -340 90 -340 {lab=AVDD}
N 90 -420 90 -340 {lab=AVDD}
N 90 -500 110 -500 {lab=AVDD}
N 380 -50 390 -50 {lab=V_IA}
N 480 -70 510 -70 {lab=V_IA}
C {iopin.sym} -450 -250 0 0 {name=p_avdd lab=AVDD}
C {iopin.sym} -450 -220 0 0 {name=p_avss lab=AVSS}
C {iopin.sym} -450 -190 0 0 {name=p_vpwr lab=VPWR}
C {iopin.sym} -450 -160 0 0 {name=p_vgnd lab=VGND}
C {ipin.sym} -450 -100 0 0 {name=p_vinp lab=VINP}
C {ipin.sym} -450 -70 0 0 {name=p_vinn lab=VINN}
C {ipin.sym} -450 -40 0 0 {name=p_vcm lab=VCM}
C {ipin.sym} -450 20 0 0 {name=p_gsel0 lab=gain_sel[0]}
C {ipin.sym} -450 50 0 0 {name=p_gsel1 lab=gain_sel[1]}
C {ipin.sym} -450 80 0 0 {name=p_gsel2 lab=gain_sel[2]}
C {ipin.sym} -450 110 0 0 {name=p_gsel3 lab=gain_sel[3]}
C {ipin.sym} -450 170 0 0 {name=p_ibia lab=IBIAS_IA}
C {ipin.sym} -450 200 0 0 {name=p_ibg1 lab=IBIAS_G1}
C {ipin.sym} -450 230 0 0 {name=p_ibg2 lab=IBIAS_G2}
C {ipin.sym} -450 260 0 0 {name=p_ibbuf lab=IBIAS_BUF}
C {opin.sym} 1700 -20 0 0 {name=p_vout lab=VOUT}
C {gain_decoder_4b.sym} -200 50 0 0 {name=x_dec}
C {lab_wire.sym} -290 10 0 0 {name=l_dec_in0 lab=gain_sel[0]}
C {lab_wire.sym} -290 30 0 0 {name=l_dec_in1 lab=gain_sel[1]}
C {lab_wire.sym} -290 50 0 0 {name=l_dec_in2 lab=gain_sel[2]}
C {lab_wire.sym} -290 70 0 0 {name=l_dec_in3 lab=gain_sel[3]}
C {lab_wire.sym} -190 -50 1 0 {name=l_dec_vpwr lab=VPWR}
C {lab_wire.sym} -190 450 3 0 {name=l_dec_vgnd lab=VGND}
C {lab_wire.sym} -90 10 2 0 {name=l_dec_s1_0 lab=s1[0]}
C {lab_wire.sym} -90 30 2 0 {name=l_dec_s1_1 lab=s1[1]}
C {lab_wire.sym} -90 50 2 0 {name=l_dec_s1_2 lab=s1[2]}
C {lab_wire.sym} -90 70 2 0 {name=l_dec_s1_3 lab=s1[3]}
C {lab_wire.sym} -90 90 2 0 {name=l_dec_s1_4 lab=s1[4]}
C {lab_wire.sym} -90 210 2 0 {name=l_dec_s2_0 lab=s2[0]}
C {lab_wire.sym} -90 230 2 0 {name=l_dec_s2_1 lab=s2[1]}
C {lab_wire.sym} -90 250 2 0 {name=l_dec_s2_2 lab=s2[2]}
C {lab_wire.sym} -90 270 2 0 {name=l_dec_s2_3 lab=s2[3]}
C {lab_wire.sym} -90 290 2 0 {name=l_dec_s2_4 lab=s2[4]}
C {instramp_cmos5l.sym} 250 -50 0 0 {name=x_ia}
C {lab_wire.sym} 250 -200 1 0 {name=l_ia_vdd lab=AVDD}
C {lab_wire.sym} 290 -200 1 0 {name=l_ia_vss lab=AVSS}
C {lab_wire.sym} 210 -200 1 0 {name=l_ia_ib lab=IBIAS_IA}
C {lab_wire.sym} 100 -100 0 0 {name=l_ia_vinn lab=VINN}
C {lab_wire.sym} 100 0 0 0 {name=l_ia_vinp lab=VINP}
C {lab_wire.sym} 100 -50 0 0 {name=l_ia_vcm lab=VCM}
C {gain_stage.sym} 650 -50 0 0 {name=x_stage1}
C {lab_wire.sym} 590 -170 1 0 {name=l_st1_avdd lab=AVDD}
C {lab_wire.sym} 630 -170 1 0 {name=l_st1_avss lab=AVSS}
C {lab_wire.sym} 670 -170 1 0 {name=l_st1_ib lab=IBIAS_G1}
C {lab_wire.sym} 490 -30 0 0 {name=l_st1_vcm lab=VCM}
C {lab_wire.sym} 830 -50 2 0 {name=l_st1_vout lab=v_stage1}
C {lab_wire.sym} 570 110 3 0 {name=l_st1_s0 lab=s1[0]}
C {lab_wire.sym} 610 110 3 0 {name=l_st1_s1 lab=s1[1]}
C {lab_wire.sym} 650 110 3 0 {name=l_st1_s2 lab=s1[2]}
C {lab_wire.sym} 690 110 3 0 {name=l_st1_s3 lab=s1[3]}
C {lab_wire.sym} 730 110 3 0 {name=l_st1_s4 lab=s1[4]}
C {gain_stage.sym} 1050 -50 0 0 {name=x_stage2}
C {lab_wire.sym} 990 -170 1 0 {name=l_st2_avdd lab=AVDD}
C {lab_wire.sym} 1030 -170 1 0 {name=l_st2_avss lab=AVSS}
C {lab_wire.sym} 1070 -170 1 0 {name=l_st2_ib lab=IBIAS_G2}
C {lab_wire.sym} 890 -70 0 0 {name=l_st2_vin lab=v_stage1}
C {lab_wire.sym} 890 -30 0 0 {name=l_st2_vcm lab=VCM}
C {lab_wire.sym} 1230 -50 2 0 {name=l_st2_vout lab=v_stage2}
C {lab_wire.sym} 970 110 3 0 {name=l_st2_s0 lab=s2[0]}
C {lab_wire.sym} 1010 110 3 0 {name=l_st2_s1 lab=s2[1]}
C {lab_wire.sym} 1050 110 3 0 {name=l_st2_s2 lab=s2[2]}
C {lab_wire.sym} 1090 110 3 0 {name=l_st2_s3 lab=s2[3]}
C {lab_wire.sym} 1130 110 3 0 {name=l_st2_s4 lab=s2[4]}
C {output_buffer.sym} 1550 -50 0 0 {name=x_buf}
C {lab_wire.sym} 1270 -150 1 0 {name=l_buf_avdd lab=AVDD}
C {lab_wire.sym} 1270 90 3 0 {name=l_buf_avss lab=AVSS}
C {lab_wire.sym} 1320 70 3 0 {name=l_buf_ib lab=IBIAS_BUF}
C {lab_wire.sym} 1190 -60 0 0 {name=l_buf_vinp lab=v_stage2}
C {lab_wire.sym} 1190 -10 0 0 {name=l_buf_vinn lab=VOUT}
C {lab_wire.sym} 1510 -30 2 0 {name=l_buf_vout lab=VOUT}
C {title.sym} 100 400 0 0 {name=l_title author="Alden Cimahi"}
C {code_shown.sym} -450 350 0 0 {
name=DECODER_MODELS
value="
* Standard cell models & synthesized gain decoder macro
.include /foss/pdks/ihp-sg13cmos5l/libs.ref/sg13cmos5l_stdcell/spice/sg13cmos5l_stdcell.spice
.include /foss/designs/sg13cmos5l_spma_ip__instramp/gds/gain_decoder_4b/final/spice/gain_decoder_4b.spice
"
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -170 -340 2 1 {name=M1
l=2u
w=0.2u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -170 -420 0 0 {name=M2
l=2u
w=0.2u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_wire.sym} -150 -470 0 0 {name=l_ia_vinn1 lab=VINN}
C {lab_wire.sym} -150 -290 2 1 {name=l_ia_vcm1 lab=VCM}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -10 -340 2 1 {name=M3
l=2u
w=0.2u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {sg13cmos5l_pr/sg13_lv_pmos.sym} -10 -420 0 0 {name=M4
l=2u
w=0.2u
ng=1
m=1
mm_ok=1
model=sg13_lv_pmos
spiceprefix=X
}
C {lab_wire.sym} 10 -470 0 0 {name=l_ia_vinn2 lab=VCM}
C {lab_wire.sym} 10 -290 2 1 {name=l_ia_vcm2 lab=VINP}
C {lab_wire.sym} 110 -500 2 0 {name=l_ia_vdd1 lab=AVDD}
C {lab_wire.sym} -210 -380 0 0 {name=l_mid_n lab=V_MID_N}
C {lab_wire.sym} -50 -380 0 0 {name=l_mid_p lab=V_MID_P}
C {lab_wire.sym} 390 -50 0 1 {name=l_st3 lab=V_IA}
C {lab_wire.sym} 480 -70 0 0 {name=l_st6 lab=V_IA}
