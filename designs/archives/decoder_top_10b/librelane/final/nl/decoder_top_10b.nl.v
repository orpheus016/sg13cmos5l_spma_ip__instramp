module decoder_top_10b (d,
    s,
    sb,
    y);
 input [9:0] d;
 output [9:4] s;
 output [9:4] sb;
 output [15:0] y;

 wire _00_;
 wire _01_;
 wire _02_;
 wire _03_;
 wire _04_;
 wire _05_;
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
 wire net25;
 wire net26;
 wire net27;
 wire net28;
 wire net29;
 wire net30;
 wire net31;
 wire net32;
 wire net33;
 wire net34;
 wire net35;
 wire net36;
 wire net37;
 wire net38;
 wire net39;
 wire net40;

 sg13g2_decap_8 FILLER_0_0 ();
 sg13g2_decap_8 FILLER_0_106 ();
 sg13g2_decap_8 FILLER_0_113 ();
 sg13g2_decap_8 FILLER_0_120 ();
 sg13g2_decap_4 FILLER_0_127 ();
 sg13g2_fill_1 FILLER_0_131 ();
 sg13g2_decap_8 FILLER_0_14 ();
 sg13g2_decap_8 FILLER_0_21 ();
 sg13g2_decap_8 FILLER_0_28 ();
 sg13g2_decap_8 FILLER_0_35 ();
 sg13g2_decap_8 FILLER_0_42 ();
 sg13g2_decap_4 FILLER_0_49 ();
 sg13g2_decap_4 FILLER_0_61 ();
 sg13g2_fill_2 FILLER_0_65 ();
 sg13g2_decap_8 FILLER_0_7 ();
 sg13g2_decap_8 FILLER_0_75 ();
 sg13g2_decap_4 FILLER_0_82 ();
 sg13g2_fill_1 FILLER_0_86 ();
 sg13g2_decap_8 FILLER_10_0 ();
 sg13g2_decap_8 FILLER_10_106 ();
 sg13g2_decap_8 FILLER_10_113 ();
 sg13g2_decap_8 FILLER_10_120 ();
 sg13g2_decap_4 FILLER_10_127 ();
 sg13g2_fill_1 FILLER_10_131 ();
 sg13g2_decap_8 FILLER_10_14 ();
 sg13g2_decap_8 FILLER_10_21 ();
 sg13g2_decap_4 FILLER_10_28 ();
 sg13g2_fill_2 FILLER_10_32 ();
 sg13g2_decap_8 FILLER_10_7 ();
 sg13g2_decap_8 FILLER_10_71 ();
 sg13g2_decap_8 FILLER_10_78 ();
 sg13g2_decap_8 FILLER_10_85 ();
 sg13g2_decap_8 FILLER_10_92 ();
 sg13g2_decap_8 FILLER_10_99 ();
 sg13g2_decap_8 FILLER_1_105 ();
 sg13g2_decap_8 FILLER_1_112 ();
 sg13g2_decap_8 FILLER_1_119 ();
 sg13g2_decap_4 FILLER_1_126 ();
 sg13g2_fill_2 FILLER_1_130 ();
 sg13g2_decap_8 FILLER_1_14 ();
 sg13g2_decap_8 FILLER_1_21 ();
 sg13g2_decap_8 FILLER_1_28 ();
 sg13g2_decap_8 FILLER_1_35 ();
 sg13g2_decap_4 FILLER_1_4 ();
 sg13g2_decap_8 FILLER_1_42 ();
 sg13g2_decap_8 FILLER_1_49 ();
 sg13g2_decap_8 FILLER_1_56 ();
 sg13g2_decap_8 FILLER_1_63 ();
 sg13g2_decap_8 FILLER_1_70 ();
 sg13g2_decap_8 FILLER_1_77 ();
 sg13g2_fill_2 FILLER_1_8 ();
 sg13g2_decap_8 FILLER_1_84 ();
 sg13g2_decap_8 FILLER_1_91 ();
 sg13g2_decap_8 FILLER_1_98 ();
 sg13g2_decap_8 FILLER_2_106 ();
 sg13g2_decap_8 FILLER_2_113 ();
 sg13g2_decap_8 FILLER_2_120 ();
 sg13g2_decap_4 FILLER_2_127 ();
 sg13g2_fill_1 FILLER_2_131 ();
 sg13g2_decap_8 FILLER_2_15 ();
 sg13g2_decap_8 FILLER_2_22 ();
 sg13g2_decap_8 FILLER_2_29 ();
 sg13g2_decap_8 FILLER_2_36 ();
 sg13g2_decap_8 FILLER_2_43 ();
 sg13g2_decap_8 FILLER_2_50 ();
 sg13g2_decap_8 FILLER_2_57 ();
 sg13g2_decap_8 FILLER_2_64 ();
 sg13g2_decap_8 FILLER_2_71 ();
 sg13g2_decap_8 FILLER_2_78 ();
 sg13g2_decap_8 FILLER_2_85 ();
 sg13g2_decap_8 FILLER_2_92 ();
 sg13g2_decap_8 FILLER_2_99 ();
 sg13g2_decap_8 FILLER_3_104 ();
 sg13g2_decap_8 FILLER_3_111 ();
 sg13g2_decap_8 FILLER_3_118 ();
 sg13g2_decap_8 FILLER_3_125 ();
 sg13g2_decap_8 FILLER_3_14 ();
 sg13g2_decap_8 FILLER_3_21 ();
 sg13g2_decap_8 FILLER_3_28 ();
 sg13g2_decap_8 FILLER_3_35 ();
 sg13g2_decap_8 FILLER_3_42 ();
 sg13g2_decap_8 FILLER_3_49 ();
 sg13g2_fill_1 FILLER_3_56 ();
 sg13g2_decap_8 FILLER_3_69 ();
 sg13g2_decap_8 FILLER_3_76 ();
 sg13g2_fill_2 FILLER_3_8 ();
 sg13g2_decap_8 FILLER_3_83 ();
 sg13g2_decap_8 FILLER_3_90 ();
 sg13g2_decap_8 FILLER_3_97 ();
 sg13g2_decap_8 FILLER_4_100 ();
 sg13g2_decap_8 FILLER_4_107 ();
 sg13g2_decap_8 FILLER_4_114 ();
 sg13g2_decap_8 FILLER_4_121 ();
 sg13g2_decap_4 FILLER_4_128 ();
 sg13g2_fill_2 FILLER_4_18 ();
 sg13g2_fill_1 FILLER_4_20 ();
 sg13g2_decap_8 FILLER_4_30 ();
 sg13g2_decap_8 FILLER_4_37 ();
 sg13g2_decap_8 FILLER_4_44 ();
 sg13g2_decap_8 FILLER_4_51 ();
 sg13g2_fill_2 FILLER_4_58 ();
 sg13g2_decap_8 FILLER_4_72 ();
 sg13g2_decap_8 FILLER_4_79 ();
 sg13g2_decap_8 FILLER_4_86 ();
 sg13g2_decap_8 FILLER_4_93 ();
 sg13g2_decap_8 FILLER_5_102 ();
 sg13g2_decap_8 FILLER_5_109 ();
 sg13g2_decap_8 FILLER_5_116 ();
 sg13g2_fill_1 FILLER_5_123 ();
 sg13g2_decap_8 FILLER_5_18 ();
 sg13g2_fill_2 FILLER_5_25 ();
 sg13g2_fill_1 FILLER_5_27 ();
 sg13g2_decap_8 FILLER_5_38 ();
 sg13g2_decap_8 FILLER_5_45 ();
 sg13g2_decap_4 FILLER_5_52 ();
 sg13g2_fill_2 FILLER_5_56 ();
 sg13g2_decap_4 FILLER_5_61 ();
 sg13g2_fill_1 FILLER_5_65 ();
 sg13g2_decap_8 FILLER_5_74 ();
 sg13g2_fill_1 FILLER_5_8 ();
 sg13g2_decap_8 FILLER_5_81 ();
 sg13g2_decap_8 FILLER_5_88 ();
 sg13g2_decap_8 FILLER_5_95 ();
 sg13g2_decap_8 FILLER_6_100 ();
 sg13g2_decap_8 FILLER_6_107 ();
 sg13g2_decap_8 FILLER_6_114 ();
 sg13g2_fill_2 FILLER_6_121 ();
 sg13g2_fill_1 FILLER_6_123 ();
 sg13g2_decap_8 FILLER_6_23 ();
 sg13g2_decap_8 FILLER_6_30 ();
 sg13g2_decap_8 FILLER_6_37 ();
 sg13g2_decap_8 FILLER_6_44 ();
 sg13g2_decap_8 FILLER_6_51 ();
 sg13g2_decap_4 FILLER_6_58 ();
 sg13g2_fill_2 FILLER_6_62 ();
 sg13g2_decap_8 FILLER_6_79 ();
 sg13g2_decap_8 FILLER_6_86 ();
 sg13g2_decap_8 FILLER_6_93 ();
 sg13g2_decap_8 FILLER_7_105 ();
 sg13g2_decap_8 FILLER_7_112 ();
 sg13g2_decap_4 FILLER_7_119 ();
 sg13g2_fill_1 FILLER_7_123 ();
 sg13g2_decap_8 FILLER_7_14 ();
 sg13g2_decap_8 FILLER_7_21 ();
 sg13g2_decap_8 FILLER_7_28 ();
 sg13g2_decap_8 FILLER_7_35 ();
 sg13g2_decap_8 FILLER_7_42 ();
 sg13g2_decap_8 FILLER_7_49 ();
 sg13g2_decap_8 FILLER_7_56 ();
 sg13g2_decap_8 FILLER_7_63 ();
 sg13g2_decap_8 FILLER_7_70 ();
 sg13g2_decap_8 FILLER_7_77 ();
 sg13g2_fill_2 FILLER_7_8 ();
 sg13g2_decap_8 FILLER_7_84 ();
 sg13g2_decap_8 FILLER_7_91 ();
 sg13g2_decap_8 FILLER_7_98 ();
 sg13g2_decap_8 FILLER_8_105 ();
 sg13g2_decap_8 FILLER_8_112 ();
 sg13g2_decap_8 FILLER_8_119 ();
 sg13g2_decap_4 FILLER_8_126 ();
 sg13g2_fill_2 FILLER_8_130 ();
 sg13g2_decap_8 FILLER_8_14 ();
 sg13g2_decap_8 FILLER_8_21 ();
 sg13g2_decap_8 FILLER_8_28 ();
 sg13g2_decap_8 FILLER_8_35 ();
 sg13g2_decap_4 FILLER_8_4 ();
 sg13g2_decap_8 FILLER_8_42 ();
 sg13g2_decap_8 FILLER_8_49 ();
 sg13g2_decap_8 FILLER_8_56 ();
 sg13g2_decap_8 FILLER_8_63 ();
 sg13g2_decap_8 FILLER_8_70 ();
 sg13g2_decap_8 FILLER_8_77 ();
 sg13g2_fill_2 FILLER_8_8 ();
 sg13g2_decap_8 FILLER_8_84 ();
 sg13g2_decap_8 FILLER_8_91 ();
 sg13g2_decap_8 FILLER_8_98 ();
 sg13g2_decap_8 FILLER_9_105 ();
 sg13g2_decap_8 FILLER_9_112 ();
 sg13g2_decap_8 FILLER_9_119 ();
 sg13g2_decap_4 FILLER_9_126 ();
 sg13g2_decap_8 FILLER_9_13 ();
 sg13g2_fill_2 FILLER_9_130 ();
 sg13g2_decap_8 FILLER_9_20 ();
 sg13g2_decap_8 FILLER_9_27 ();
 sg13g2_decap_8 FILLER_9_34 ();
 sg13g2_fill_2 FILLER_9_57 ();
 sg13g2_decap_8 FILLER_9_63 ();
 sg13g2_decap_8 FILLER_9_70 ();
 sg13g2_decap_8 FILLER_9_77 ();
 sg13g2_fill_2 FILLER_9_8 ();
 sg13g2_decap_8 FILLER_9_84 ();
 sg13g2_decap_8 FILLER_9_91 ();
 sg13g2_decap_8 FILLER_9_98 ();
 sg13g2_inv_1 _06_ (.Y(net17),
    .A(net5));
 sg13g2_inv_1 _07_ (.Y(net18),
    .A(net6));
 sg13g2_inv_1 _08_ (.Y(net19),
    .A(net7));
 sg13g2_inv_1 _09_ (.Y(net20),
    .A(net8));
 sg13g2_inv_1 _10_ (.Y(net21),
    .A(net9));
 sg13g2_inv_1 _11_ (.Y(net22),
    .A(net10));
 sg13g2_inv_1 _12_ (.Y(_00_),
    .A(net39));
 sg13g2_inv_1 _13_ (.Y(_01_),
    .A(net40));
 sg13g2_nor4_1 _14_ (.A(net39),
    .B(net1),
    .C(net2),
    .D(net3),
    .Y(net23));
 sg13g2_nand2b_1 _15_ (.Y(_02_),
    .B(net1),
    .A_N(net2));
 sg13g2_nor3_1 _16_ (.A(net39),
    .B(net40),
    .C(_02_),
    .Y(net30));
 sg13g2_nand2b_1 _17_ (.Y(_03_),
    .B(net2),
    .A_N(net1));
 sg13g2_nor3_1 _18_ (.A(net39),
    .B(net40),
    .C(_03_),
    .Y(net31));
 sg13g2_nand2_1 _19_ (.Y(_04_),
    .A(net1),
    .B(net2));
 sg13g2_nor3_1 _20_ (.A(net39),
    .B(net40),
    .C(_04_),
    .Y(net32));
 sg13g2_nor4_1 _21_ (.A(net39),
    .B(net1),
    .C(net2),
    .D(_01_),
    .Y(net33));
 sg13g2_nor3_1 _22_ (.A(net39),
    .B(_01_),
    .C(_02_),
    .Y(net34));
 sg13g2_nor3_1 _23_ (.A(net4),
    .B(_01_),
    .C(_03_),
    .Y(net35));
 sg13g2_nand3_1 _24_ (.B(net2),
    .C(net40),
    .A(net1),
    .Y(_05_));
 sg13g2_nor2_1 _25_ (.A(net39),
    .B(_05_),
    .Y(net36));
 sg13g2_nor4_1 _26_ (.A(_00_),
    .B(net1),
    .C(net2),
    .D(net3),
    .Y(net37));
 sg13g2_nor3_1 _27_ (.A(_00_),
    .B(net40),
    .C(_02_),
    .Y(net38));
 sg13g2_nor3_1 _28_ (.A(_00_),
    .B(net40),
    .C(_03_),
    .Y(net24));
 sg13g2_nor3_1 _29_ (.A(_00_),
    .B(net40),
    .C(_04_),
    .Y(net25));
 sg13g2_nor4_1 _30_ (.A(_00_),
    .B(net1),
    .C(net2),
    .D(_01_),
    .Y(net26));
 sg13g2_nor3_1 _31_ (.A(_00_),
    .B(_01_),
    .C(_02_),
    .Y(net27));
 sg13g2_nor3_1 _32_ (.A(_00_),
    .B(_01_),
    .C(_03_),
    .Y(net28));
 sg13g2_nor2_1 _33_ (.A(_00_),
    .B(_05_),
    .Y(net29));
 sg13g2_buf_1 _34_ (.A(net5),
    .X(net11));
 sg13g2_buf_1 _35_ (.A(net6),
    .X(net12));
 sg13g2_buf_1 _36_ (.A(net7),
    .X(net13));
 sg13g2_buf_1 _37_ (.A(net8),
    .X(net14));
 sg13g2_buf_1 _38_ (.A(net9),
    .X(net15));
 sg13g2_buf_1 _39_ (.A(net10),
    .X(net16));
 sg13g2_buf_1 fanout39 (.A(net4),
    .X(net39));
 sg13g2_buf_1 fanout40 (.A(net3),
    .X(net40));
 sg13g2_buf_1 input1 (.A(d[0]),
    .X(net1));
 sg13g2_buf_1 input10 (.A(d[9]),
    .X(net10));
 sg13g2_buf_1 input2 (.A(d[1]),
    .X(net2));
 sg13g2_buf_1 input3 (.A(d[2]),
    .X(net3));
 sg13g2_buf_1 input4 (.A(d[3]),
    .X(net4));
 sg13g2_buf_1 input5 (.A(d[4]),
    .X(net5));
 sg13g2_buf_1 input6 (.A(d[5]),
    .X(net6));
 sg13g2_buf_1 input7 (.A(d[6]),
    .X(net7));
 sg13g2_buf_1 input8 (.A(d[7]),
    .X(net8));
 sg13g2_buf_1 input9 (.A(d[8]),
    .X(net9));
 sg13g2_buf_1 output11 (.A(net11),
    .X(s[4]));
 sg13g2_buf_1 output12 (.A(net12),
    .X(s[5]));
 sg13g2_buf_1 output13 (.A(net13),
    .X(s[6]));
 sg13g2_buf_1 output14 (.A(net14),
    .X(s[7]));
 sg13g2_buf_1 output15 (.A(net15),
    .X(s[8]));
 sg13g2_buf_1 output16 (.A(net16),
    .X(s[9]));
 sg13g2_buf_1 output17 (.A(net17),
    .X(sb[4]));
 sg13g2_buf_1 output18 (.A(net18),
    .X(sb[5]));
 sg13g2_buf_1 output19 (.A(net19),
    .X(sb[6]));
 sg13g2_buf_1 output20 (.A(net20),
    .X(sb[7]));
 sg13g2_buf_1 output21 (.A(net21),
    .X(sb[8]));
 sg13g2_buf_1 output22 (.A(net22),
    .X(sb[9]));
 sg13g2_buf_1 output23 (.A(net23),
    .X(y[0]));
 sg13g2_buf_1 output24 (.A(net24),
    .X(y[10]));
 sg13g2_buf_1 output25 (.A(net25),
    .X(y[11]));
 sg13g2_buf_1 output26 (.A(net26),
    .X(y[12]));
 sg13g2_buf_1 output27 (.A(net27),
    .X(y[13]));
 sg13g2_buf_1 output28 (.A(net28),
    .X(y[14]));
 sg13g2_buf_1 output29 (.A(net29),
    .X(y[15]));
 sg13g2_buf_1 output30 (.A(net30),
    .X(y[1]));
 sg13g2_buf_1 output31 (.A(net31),
    .X(y[2]));
 sg13g2_buf_1 output32 (.A(net32),
    .X(y[3]));
 sg13g2_buf_1 output33 (.A(net33),
    .X(y[4]));
 sg13g2_buf_1 output34 (.A(net34),
    .X(y[5]));
 sg13g2_buf_1 output35 (.A(net35),
    .X(y[6]));
 sg13g2_buf_1 output36 (.A(net36),
    .X(y[7]));
 sg13g2_buf_1 output37 (.A(net37),
    .X(y[8]));
 sg13g2_buf_1 output38 (.A(net38),
    .X(y[9]));
endmodule
