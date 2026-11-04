v {xschem version=3.4.8RC file_version=1.3}
G {}
K {}
V {}
S {}
F {}
E {}
N -240 -150 -220 -150 {lab=gain_sel[0]}
N -240 -130 -220 -130 {lab=gain_sel[1]}
N -240 -110 -220 -110 {lab=gain_sel[2]}
N -240 -90 -220 -90 {lab=gain_sel[3]}
N -140 -210 -140 -190 {lab=VPWR}
N -140 270 -140 290 {lab=VGND}
N -60 -150 -40 -150 {lab=s1[0]}
N -60 -130 -40 -130 {lab=s1[1]}
N -60 -110 -40 -110 {lab=s1[2]}
N -60 -90 -40 -90 {lab=s1[3]}
N -60 -70 -40 -70 {lab=s1[4]}
N -60 50 -40 50 {lab=s2[0]}
N -60 70 -40 70 {lab=s2[1]}
N -60 90 -40 90 {lab=s2[2]}
N -60 110 -40 110 {lab=s2[3]}
N -60 130 -40 130 {lab=s2[4]}
N 250 -200 250 -180 {lab=AVDD}
N 290 -200 290 -180 {lab=AVSS}
N 210 -200 210 -180 {lab=IBIAS_IA}
N 100 -100 120 -100 {lab=VINN}
N 100 0 120 0 {lab=VINP}
N 100 -50 120 -50 {lab=VCM}
N 590 -170 590 -150 {lab=AVDD}
N 630 -170 630 -150 {lab=AVSS}
N 670 -170 670 -150 {lab=IBIAS_IA}
N 490 -30 510 -30 {lab=VCM}
N 790 -50 840 -50 {lab=v_stage1}
N 570 90 570 110 {lab=s1[0]}
N 610 90 610 110 {lab=s1[1]}
N 650 90 650 110 {lab=s1[2]}
N 690 90 690 110 {lab=s1[3]}
N 730 90 730 110 {lab=s1[4]}
N 990 -170 990 -150 {lab=AVDD}
N 1030 -170 1030 -150 {lab=AVSS}
N 1070 -170 1070 -150 {lab=IBIAS_IA}
N 890 -70 910 -70 {lab=v_stage1}
N 890 -30 910 -30 {lab=VCM}
N 970 90 970 110 {lab=s2[0]}
N 1010 90 1010 110 {lab=s2[1]}
N 1050 90 1050 110 {lab=s2[2]}
N 1090 90 1090 110 {lab=s2[3]}
N 1130 90 1130 110 {lab=s2[4]}
N 1400 -150 1400 -130 {lab=AVDD}
N 1400 70 1400 90 {lab=AVSS}
N 1450 50 1450 70 {lab=IBIAS_BUF}
N 1790 -20 1830 -20 {lab=VOUT}
N -150 -380 -150 -370 {lab=#net1}
N -210 -340 -190 -340 {lab=#net1}
N -210 -380 -210 -340 {lab=#net1}
N -210 -380 -150 -380 {lab=#net1}
N -150 -390 -150 -380 {lab=#net1}
N -150 -470 -150 -450 {lab=VINN}
N -210 -420 -190 -420 {lab=#net1}
N -210 -420 -210 -380 {lab=#net1}
N -150 -310 -150 -290 {lab=VCM}
N 10 -380 10 -370 {lab=#net2}
N -50 -340 -30 -340 {lab=#net2}
N -50 -380 -50 -340 {lab=#net2}
N -50 -380 10 -380 {lab=#net2}
N 10 -390 10 -380 {lab=#net2}
N 10 -470 10 -450 {lab=VCM}
N -50 -420 -30 -420 {lab=#net2}
N -50 -420 -50 -380 {lab=#net2}
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
N 1190 -50 1230 -50 {lab=v_stage2}
N 1600 -30 1640 -30 {lab=VOUT}
N 1260 -10 1340 -10 {lab=v_stage2}
N -500 -250 -450 -250 {lab=AVDD}
N -500 -220 -450 -220 {lab=AVSS}
N -500 -190 -450 -190 {lab=VPWR}
N -500 -160 -450 -160 {lab=VGND}
N -450 -100 -380 -100 {lab=VINP}
N -450 -70 -380 -70 {lab=VINN}
N -450 -40 -380 -40 {lab=VCM}
N -450 20 -380 20 {lab=gain_sel[0]}
N -450 50 -380 50 {lab=gain_sel[1]}
N -450 80 -380 80 {lab=gain_sel[2]}
N -450 170 -380 170 {lab=IBIAS_IA}
N -450 110 -380 110 {lab=gain_sel[3]}
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
C {opin.sym} 1830 -20 0 0 {name=p_vout lab=VOUT}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/gain_decoder_4b/gain_decoder_4b.sym} -150 -110 0 0 {name=x_dec}
C {lab_wire.sym} -240 -150 0 0 {name=l_dec_in0 lab=gain_sel[0]}
C {lab_wire.sym} -240 -130 0 0 {name=l_dec_in1 lab=gain_sel[1]}
C {lab_wire.sym} -240 -110 0 0 {name=l_dec_in2 lab=gain_sel[2]}
C {lab_wire.sym} -240 -90 0 0 {name=l_dec_in3 lab=gain_sel[3]}
C {lab_wire.sym} -140 -210 1 0 {name=l_dec_vpwr lab=VPWR}
C {lab_wire.sym} -140 290 3 0 {name=l_dec_vgnd lab=VGND}
C {lab_wire.sym} -40 -150 2 0 {name=l_dec_s1_0 lab=s1[0]}
C {lab_wire.sym} -40 -130 2 0 {name=l_dec_s1_1 lab=s1[1]}
C {lab_wire.sym} -40 -110 2 0 {name=l_dec_s1_2 lab=s1[2]}
C {lab_wire.sym} -40 -90 2 0 {name=l_dec_s1_3 lab=s1[3]}
C {lab_wire.sym} -40 -70 2 0 {name=l_dec_s1_4 lab=s1[4]}
C {lab_wire.sym} -40 50 2 0 {name=l_dec_s2_0 lab=s2[0]}
C {lab_wire.sym} -40 70 2 0 {name=l_dec_s2_1 lab=s2[1]}
C {lab_wire.sym} -40 90 2 0 {name=l_dec_s2_2 lab=s2[2]}
C {lab_wire.sym} -40 110 2 0 {name=l_dec_s2_3 lab=s2[3]}
C {lab_wire.sym} -40 130 2 0 {name=l_dec_s2_4 lab=s2[4]}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/instramp_cmos5l/instramp_cmos5l.sym} 250 -50 0 0 {name=x_ia}
C {lab_wire.sym} 250 -200 1 0 {name=l_ia_vdd lab=AVDD}
C {lab_wire.sym} 290 -200 1 0 {name=l_ia_vss lab=AVSS}
C {lab_wire.sym} 210 -200 1 0 {name=l_ia_ib lab=IBIAS_IA}
C {lab_wire.sym} 100 -100 0 0 {name=l_ia_vinn lab=VINN}
C {lab_wire.sym} 100 0 0 0 {name=l_ia_vinp lab=VINP}
C {lab_wire.sym} 100 -50 0 0 {name=l_ia_vcm lab=VCM}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/gain_stage/gain_stage.sym} 650 -50 0 0 {name=x_stage1}
C {lab_wire.sym} 590 -170 1 0 {name=l_st1_avdd lab=AVDD}
C {lab_wire.sym} 630 -170 1 0 {name=l_st1_avss lab=AVSS}
C {lab_wire.sym} 670 -170 1 0 {name=l_st1_ib lab=IBIAS_IA}
C {lab_wire.sym} 490 -30 0 0 {name=l_st1_vcm lab=VCM}
C {lab_wire.sym} 840 -50 0 0 {name=l_st1_vout lab=v_stage1}
C {lab_wire.sym} 570 110 3 0 {name=l_st1_s0 lab=s1[0]}
C {lab_wire.sym} 610 110 3 0 {name=l_st1_s1 lab=s1[1]}
C {lab_wire.sym} 650 110 3 0 {name=l_st1_s2 lab=s1[2]}
C {lab_wire.sym} 690 110 3 0 {name=l_st1_s3 lab=s1[3]}
C {lab_wire.sym} 730 110 3 0 {name=l_st1_s4 lab=s1[4]}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/gain_stage/gain_stage.sym} 1050 -50 0 0 {name=x_stage2}
C {lab_wire.sym} 990 -170 1 0 {name=l_st2_avdd lab=AVDD}
C {lab_wire.sym} 1030 -170 1 0 {name=l_st2_avss lab=AVSS}
C {lab_wire.sym} 1070 -170 1 0 {name=l_st2_ib lab=IBIAS_IA}
C {lab_wire.sym} 890 -70 0 0 {name=l_st2_vin lab=v_stage1}
C {lab_wire.sym} 890 -30 0 0 {name=l_st2_vcm lab=VCM}
C {lab_wire.sym} 970 110 3 0 {name=l_st2_s0 lab=s2[0]}
C {lab_wire.sym} 1010 110 3 0 {name=l_st2_s1 lab=s2[1]}
C {lab_wire.sym} 1050 110 3 0 {name=l_st2_s2 lab=s2[2]}
C {lab_wire.sym} 1090 110 3 0 {name=l_st2_s3 lab=s2[3]}
C {lab_wire.sym} 1130 110 3 0 {name=l_st2_s4 lab=s2[4]}
C {/foss/designs/sg13cmos5l_spma_ip__instramp/xschem/output_buffer/output_buffer.sym} 1680 -50 0 0 {name=x_buf}
C {lab_wire.sym} 1400 -150 1 0 {name=l_buf_avdd lab=AVDD}
C {lab_wire.sym} 1400 90 3 0 {name=l_buf_avss lab=AVSS}
C {lab_wire.sym} 1450 70 3 0 {name=l_buf_ib lab=IBIAS_IA}
C {lab_wire.sym} 1640 -30 2 0 {name=l_buf_vinn lab=VOUT}
C {lab_wire.sym} 1790 -20 0 0 {name=l_buf_vout lab=VOUT}
C {title.sym} 100 400 0 0 {name=l_title author="Alden Cimahi"}
C {code_shown.sym} 120 230 0 0 {
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
C {lab_wire.sym} 390 -50 0 1 {name=l_st3 lab=V_IA}
C {lab_wire.sym} 480 -70 0 0 {name=l_st6 lab=V_IA}
C {lab_wire.sym} 1230 -50 2 0 {name=l_buf_vout1 lab=v_stage2}
C {lab_wire.sym} 1260 -10 2 0 {name=l_buf_vout2 lab=v_stage2}
C {lab_wire.sym} -500 -250 0 0 {name=l_ia_vdd2 lab=AVDD}
C {lab_wire.sym} -500 -220 0 0 {name=l_ia_vdd3 lab=AVSS}
C {lab_wire.sym} -500 -190 0 0 {name=l_ia_vdd4 lab=VPWR}
C {lab_wire.sym} -500 -160 0 0 {name=l_ia_vdd5 lab=VGND}
C {lab_wire.sym} -380 -100 0 1 {name=l_ia_vcm3 lab=VINP}
C {lab_wire.sym} -380 -70 0 1 {name=l_ia_vcm4 lab=VINN}
C {lab_wire.sym} -380 -40 0 1 {name=l_ia_vcm5 lab=VCM}
C {lab_wire.sym} -380 20 0 1 {name=l_ia_vcm6 lab=gain_sel[0]}
C {lab_wire.sym} -380 50 0 1 {name=l_ia_vcm7 lab=gain_sel[1]}
C {lab_wire.sym} -380 80 0 1 {name=l_ia_vcm8 lab=gain_sel[2]}
C {lab_wire.sym} -380 170 0 1 {name=l_ia_vcm9 lab=IBIAS_IA}
C {lab_wire.sym} -380 110 0 1 {name=l_ia_vcm12 lab=gain_sel[3]}
