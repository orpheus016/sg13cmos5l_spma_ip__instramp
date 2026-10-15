module gain_decoder_4b (VPWR,
    VGND,
    gain_sel,
    s1,
    s1_b,
    s2,
    s2_b);
 inout VPWR;
 inout VGND;
 input [3:0] gain_sel;
 output [4:0] s1;
 output [4:0] s1_b;
 output [4:0] s2;
 output [4:0] s2_b;

 wire _00_;
 wire _01_;
 wire _02_;
 wire _03_;
 wire _04_;
 wire _05_;
 wire _06_;
 wire _07_;
 wire _08_;
 wire _09_;
 wire _10_;
 wire net1;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net20;
 wire net21;
 wire net22;
 wire net23;
 wire net24;

 sg13cmos5l_fill_1 FILLER_0_102 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_0_15 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_0_22 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_0_29 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_0_37 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_0_42 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_0_49 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_0_77 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_0_8 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_1_0 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_1_109 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_1_14 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_1_21 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_1_58 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_1_7 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_2_15 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_2_22 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_2_29 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_2 FILLER_2_36 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_2_42 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_4 FILLER_2_49 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_2_53 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_2_61 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_fill_1 FILLER_2_78 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_decap_8 FILLER_2_8 (.VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 _11_ (.VDD(VPWR),
    .Y(_00_),
    .A(net1),
    .VSS(VGND));
 sg13cmos5l_nor3_1 _12_ (.A(net2),
    .B(_00_),
    .C(net3),
    .Y(_01_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nor2b_1 _13_ (.A(net4),
    .B_N(_01_),
    .Y(net5),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand2b_1 _14_ (.Y(net10),
    .B(_01_),
    .A_N(net4),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nor2b_1 _15_ (.A(net1),
    .B_N(net2),
    .Y(_02_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nor2_1 _16_ (.A(net4),
    .B(net3),
    .Y(_03_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand2_1 _17_ (.Y(net11),
    .A(_02_),
    .B(_03_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 _18_ (.VDD(VPWR),
    .Y(net6),
    .A(net11),
    .VSS(VGND));
 sg13cmos5l_nand2_1 _19_ (.Y(_04_),
    .A(net2),
    .B(net1),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand3_1 _20_ (.B(net1),
    .C(_03_),
    .A(net2),
    .Y(net12),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 _21_ (.VDD(VPWR),
    .Y(net7),
    .A(net12),
    .VSS(VGND));
 sg13cmos5l_nor2_1 _22_ (.A(net2),
    .B(net1),
    .Y(_05_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 _23_ (.VDD(VPWR),
    .Y(_06_),
    .A(_05_),
    .VSS(VGND));
 sg13cmos5l_nor2b_1 _24_ (.A(net4),
    .B_N(net3),
    .Y(_07_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand2b_1 _25_ (.Y(_08_),
    .B(net3),
    .A_N(net4),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand2_1 _26_ (.Y(net13),
    .A(_05_),
    .B(_07_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 _27_ (.VDD(VPWR),
    .Y(net8),
    .A(net13),
    .VSS(VGND));
 sg13cmos5l_nor2b_1 _28_ (.A(net3),
    .B_N(net4),
    .Y(_09_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand2_1 _29_ (.Y(_10_),
    .A(_04_),
    .B(_09_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_a22oi_1 _30_ (.Y(net14),
    .B1(_09_),
    .B2(_04_),
    .A2(_07_),
    .A1(_06_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_o21ai_1 _31_ (.B1(_10_),
    .VDD(VPWR),
    .Y(net9),
    .VSS(VGND),
    .A1(_05_),
    .A2(_08_));
 sg13cmos5l_nand2_1 _32_ (.Y(net20),
    .A(_02_),
    .B(_07_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 _33_ (.VDD(VPWR),
    .Y(net15),
    .A(net20),
    .VSS(VGND));
 sg13cmos5l_nand2b_1 _34_ (.Y(net21),
    .B(_07_),
    .A_N(_04_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 _35_ (.VDD(VPWR),
    .Y(net16),
    .A(net21),
    .VSS(VGND));
 sg13cmos5l_nand2_1 _36_ (.Y(net22),
    .A(_05_),
    .B(_09_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 _37_ (.VDD(VPWR),
    .Y(net17),
    .A(net22),
    .VSS(VGND));
 sg13cmos5l_and2_1 _38_ (.A(net4),
    .B(_01_),
    .X(net18),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand2_1 _39_ (.Y(net23),
    .A(net4),
    .B(_01_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_nand2_1 _40_ (.Y(net24),
    .A(_02_),
    .B(_09_),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_inv_1 _41_ (.VDD(VPWR),
    .Y(net19),
    .A(net24),
    .VSS(VGND));
 sg13cmos5l_buf_1 input1 (.A(gain_sel[0]),
    .X(net1),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 input2 (.A(gain_sel[1]),
    .X(net2),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 input3 (.A(gain_sel[2]),
    .X(net3),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 input4 (.A(gain_sel[3]),
    .X(net4),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output10 (.A(net10),
    .X(s1_b[0]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output11 (.A(net11),
    .X(s1_b[1]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output12 (.A(net12),
    .X(s1_b[2]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output13 (.A(net13),
    .X(s1_b[3]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output14 (.A(net14),
    .X(s1_b[4]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output15 (.A(net15),
    .X(s2[0]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output16 (.A(net16),
    .X(s2[1]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output17 (.A(net17),
    .X(s2[2]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output18 (.A(net18),
    .X(s2[3]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output19 (.A(net19),
    .X(s2[4]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output20 (.A(net20),
    .X(s2_b[0]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output21 (.A(net21),
    .X(s2_b[1]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output22 (.A(net22),
    .X(s2_b[2]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output23 (.A(net23),
    .X(s2_b[3]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output24 (.A(net24),
    .X(s2_b[4]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output5 (.A(net5),
    .X(s1[0]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output6 (.A(net6),
    .X(s1[1]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output7 (.A(net7),
    .X(s1[2]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output8 (.A(net8),
    .X(s1[3]),
    .VDD(VPWR),
    .VSS(VGND));
 sg13cmos5l_buf_1 output9 (.A(net9),
    .X(s1[4]),
    .VDD(VPWR),
    .VSS(VGND));
endmodule
