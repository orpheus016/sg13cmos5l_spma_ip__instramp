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
N -110 110 -90 110 {lab=s1_b[0]}
N -110 210 -90 210 {lab=s2[0]}
N -110 230 -90 230 {lab=s2[1]}
N -110 250 -90 250 {lab=s2[2]}
N -110 270 -90 270 {lab=s2[3]}
N -110 290 -90 290 {lab=s2[4]}
N -110 310 -90 310 {lab=s2_b[0]}
N 250 -200 250 -180 {lab=AVDD}
N 290 -200 290 -180 {lab=AVSS}
N 210 -200 210 -180 {lab=IBIAS_IA}
N 100 -100 120 -100 {lab=VINN}
N 100 0 120 0 {lab=VINP}
N 100 -50 120 -50 {lab=VCM}
N 380 -50 420 -50 {lab=v_ia}
N 630 -230 630 -210 {lab=AVDD}
N 610 -230 610 -210 {lab=IBIAS_IA}
N 680 -80 680 -60 {lab=AVSS}
N 480 -150 500 -150 {lab=v_ia}
N 480 -130 500 -130 {lab=VCM}
N 740 -140 780 -140 {lab=v_stage1}
N 660 -80 660 -60 {lab=s1_b[0]}
N 640 -80 640 -60 {lab=s1[0]}
N 620 -80 620 -60 {lab=s1[1]}
N 600 -80 600 -60 {lab=s1[2]}
N 580 -80 580 -60 {lab=s1[3]}
N 560 -80 560 -60 {lab=s1[4]}
N 1030 -230 1030 -210 {lab=AVDD}
N 1010 -230 1010 -210 {lab=IBIAS_IA}
N 1080 -80 1080 -60 {lab=AVSS}
N 880 -150 900 -150 {lab=v_stage1}
N 880 -130 900 -130 {lab=VCM}
N 1140 -140 1180 -140 {lab=v_stage2}
N 1060 -80 1060 -60 {lab=s2_b[0]}
N 1040 -80 1040 -60 {lab=s2[0]}
N 1020 -80 1020 -60 {lab=s2[1]}
N 1000 -80 1000 -60 {lab=s2[2]}
N 980 -80 980 -60 {lab=s2[3]}
N 960 -80 960 -60 {lab=s2[4]}
N 1250 -130 1270 -130 {lab=AVDD}
N 1250 70 1270 70 {lab=AVSS}
N 1320 30 1320 50 {lab=IBIAS_IA}
N 1190 -10 1210 -10 {lab=v_stage2}
N 1470 -30 1510 -30 {lab=VOUT}
N -490 -250 -450 -250 {lab=AVDD}
N -490 -220 -450 -220 {lab=AVSS}
N -490 -190 -450 -190 {lab=VPWR}
N -490 -160 -450 -160 {lab=VGND}
N -520 -100 -470 -100 {lab=VINP}
N -520 -70 -470 -70 {lab=VINN}
N -520 -40 -470 -40 {lab=VCM}
N -520 20 -420 20 {lab=gain_sel[0]}
N -520 50 -420 50 {lab=gain_sel[1]}
N -520 80 -420 80 {lab=gain_sel[2]}
N -520 110 -420 110 {lab=gain_sel[3]}
N -520 170 -420 170 {lab=IBIAS_IA}
N 1630 -20 1700 -20 {lab=VOUT}
C {iopin.sym} -450 -250 0 0 {name=p_avdd lab=AVDD}
C {iopin.sym} -450 -220 0 0 {name=p_avss lab=AVSS}
C {iopin.sym} -450 -190 0 0 {name=p_vpwr lab=VPWR}
C {iopin.sym} -450 -160 0 0 {name=p_vgnd lab=VGND}
C {ipin.sym} -520 -100 0 0 {name=p_vinp lab=VINP}
C {ipin.sym} -520 -70 0 0 {name=p_vinn lab=VINN}
C {ipin.sym} -520 -40 0 0 {name=p_vcm lab=VCM}
C {ipin.sym} -520 20 0 0 {name=p_gsel0 lab=gain_sel[0]}
C {ipin.sym} -520 50 0 0 {name=p_gsel1 lab=gain_sel[1]}
C {ipin.sym} -520 80 0 0 {name=p_gsel2 lab=gain_sel[2]}
C {ipin.sym} -520 110 0 0 {name=p_gsel3 lab=gain_sel[3]}
C {ipin.sym} -520 170 0 0 {name=p_ibia lab=IBIAS_IA}
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
C {lab_wire.sym} -90 110 2 0 {name=l_dec_s1_b0 lab=s1_b[0]}
C {lab_wire.sym} -90 210 2 0 {name=l_dec_s2_0 lab=s2[0]}
C {lab_wire.sym} -90 230 2 0 {name=l_dec_s2_1 lab=s2[1]}
C {lab_wire.sym} -90 250 2 0 {name=l_dec_s2_2 lab=s2[2]}
C {lab_wire.sym} -90 270 2 0 {name=l_dec_s2_3 lab=s2[3]}
C {lab_wire.sym} -90 290 2 0 {name=l_dec_s2_4 lab=s2[4]}
C {lab_wire.sym} -90 310 2 0 {name=l_dec_s2_b0 lab=s2_b[0]}
C {instramp_cmos5l.sym} 250 -50 0 0 {name=x_ia}
C {lab_wire.sym} 250 -200 1 0 {name=l_ia_vdd lab=AVDD}
C {lab_wire.sym} 290 -200 1 0 {name=l_ia_vss lab=AVSS}
C {lab_wire.sym} 210 -200 1 0 {name=l_ia_ib lab=IBIAS_IA}
C {lab_wire.sym} 100 -100 0 0 {name=l_ia_vinn lab=VINN}
C {lab_wire.sym} 100 0 0 0 {name=l_ia_vinp lab=VINP}
C {lab_wire.sym} 100 -50 0 0 {name=l_ia_vcm lab=VCM}
C {lab_wire.sym} 420 -50 2 0 {name=l_ia_vout lab=v_ia}
C {gain_network.sym} 650 0 0 0 {name=x_stage1}
C {lab_wire.sym} 630 -230 1 0 {name=l_st1_avdd lab=AVDD}
C {lab_wire.sym} 610 -230 1 0 {name=l_st1_ib lab=IBIAS_IA}
C {lab_wire.sym} 680 -80 3 0 {name=l_st1_avss lab=AVSS}
C {lab_wire.sym} 480 -150 0 0 {name=l_st1_vin lab=v_ia}
C {lab_wire.sym} 480 -130 0 0 {name=l_st1_vcm lab=VCM}
C {lab_wire.sym} 780 -140 2 0 {name=l_st1_vout lab=v_stage1}
C {lab_wire.sym} 660 -80 3 0 {name=l_st1_s0 lab=s1_b[0]}
C {lab_wire.sym} 640 -80 3 0 {name=l_st1_s1 lab=s1[0]}
C {lab_wire.sym} 620 -80 3 0 {name=l_st1_s2 lab=s1[1]}
C {lab_wire.sym} 600 -80 3 0 {name=l_st1_s3 lab=s1[2]}
C {lab_wire.sym} 580 -80 3 0 {name=l_st1_s4 lab=s1[3]}
C {lab_wire.sym} 560 -80 3 0 {name=l_st1_s5 lab=s1[4]}
C {gain_network.sym} 1050 0 0 0 {name=x_stage2}
C {lab_wire.sym} 1030 -230 1 0 {name=l_st2_avdd lab=AVDD}
C {lab_wire.sym} 1010 -230 1 0 {name=l_st2_ib lab=IBIAS_IA}
C {lab_wire.sym} 1080 -80 3 0 {name=l_st2_avss lab=AVSS}
C {lab_wire.sym} 880 -150 0 0 {name=l_st2_vin lab=v_stage1}
C {lab_wire.sym} 880 -130 0 0 {name=l_st2_vcm lab=VCM}
C {lab_wire.sym} 1180 -140 2 0 {name=l_st2_vout lab=v_stage2}
C {lab_wire.sym} 1060 -80 3 0 {name=l_st2_s0 lab=s2_b[0]}
C {lab_wire.sym} 1040 -80 3 0 {name=l_st2_s1 lab=s2[0]}
C {lab_wire.sym} 1020 -80 3 0 {name=l_st2_s2 lab=s2[1]}
C {lab_wire.sym} 1000 -80 3 0 {name=l_st2_s3 lab=s2[2]}
C {lab_wire.sym} 980 -80 3 0 {name=l_st2_s4 lab=s2[3]}
C {lab_wire.sym} 960 -80 3 0 {name=l_st2_s5 lab=s2[4]}
C {output_buffer.sym} 1550 -50 0 0 {name=x_buf}
C {lab_wire.sym} 1250 -130 0 0 {name=l_buf_avdd lab=AVDD}
C {lab_wire.sym} 1250 70 0 0 {name=l_buf_avss lab=AVSS}
C {lab_wire.sym} 1320 30 1 0 {name=l_buf_ib lab=IBIAS_IA}
C {lab_wire.sym} 1190 -10 0 0 {name=l_buf_vin lab=v_stage2}
C {lab_wire.sym} 1510 -30 2 0 {name=l_buf_vout lab=VOUT}
C {title.sym} 100 400 0 0 {name=l_title author="Alden Cimahi"}
C {lab_wire.sym} -490 -250 2 0 {name=l_ia_vdd1 lab=AVDD}
C {lab_wire.sym} -490 -220 2 0 {name=l_ia_vss1 lab=AVSS}
C {lab_wire.sym} -490 -190 2 0 {name=l_dec_vpwr1 lab=VPWR}
C {lab_wire.sym} -490 -160 2 0 {name=l_dec_vgnd1 lab=VGND}
C {lab_wire.sym} -470 -100 0 0 {name=l_ia_vinp1 lab=VINP}
C {lab_wire.sym} -470 -70 0 0 {name=l_ia_vinn1 lab=VINN}
C {lab_wire.sym} -470 -40 0 0 {name=l_ia_vcm1 lab=VCM}
C {lab_wire.sym} -420 20 0 0 {name=l_dec_in4 lab=gain_sel[0]}
C {lab_wire.sym} -420 50 0 0 {name=l_dec_in5 lab=gain_sel[1]}
C {lab_wire.sym} -420 80 0 0 {name=l_dec_in6 lab=gain_sel[2]}
C {lab_wire.sym} -420 110 0 0 {name=l_dec_in7 lab=gain_sel[3]}
C {lab_wire.sym} -420 170 0 0 {name=l_ia_ib1 lab=IBIAS_IA}
C {lab_wire.sym} 1630 -20 2 0 {name=l_buf_vout1 lab=VOUT}
