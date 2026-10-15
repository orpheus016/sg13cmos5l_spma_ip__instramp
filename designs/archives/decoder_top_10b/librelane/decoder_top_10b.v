// =============================================================================
// Module: decoder_top_10b
// Project: Programmable Instrumentation Amplifier IP (Chipalooza)
// Technology: IHP SG13G2 / SG13CMOS5L (130nm BiCMOS)
// Description:
//   Top-level 10-bit digital decoder subsystem combining:
//     1. Coarse Decoder: 4-to-16 active-high one-hot decoder (D[3:0] -> Y[15:0])
//        selecting one of 16 feedback resistor taps (6 dB nominal gain steps).
//     2. Fine Steering Drivers: 6-bit complementary drivers (D[9:4] -> S[9:4], SB[9:4])
//        controlling binary-weighted steering transmission gates.
//
// Ports:
//   d  [9:0]  (IN)  : 10-bit digital gain programming word
//                      - d[3:0]: Coarse gain code (0..15)
//                      - d[9:4]: Fine gain code (0..63)
//   y  [15:0] (OUT) : 16 active-high one-hot coarse tap selects (Y[k] = 1 iff d[3:0] == k)
//   s  [9:4]  (OUT) : 6 true fine gain steering lines (s[i] = d[i])
//   sb [9:4]  (OUT) : 6 complementary fine gain steering lines (sb[i] = ~d[i])
// =============================================================================

`timescale 1ns / 1ps

module decoder_top_10b (
    input  wire [9:0]  d,
    output wire [15:0] y,
    output wire [9:4]  s,
    output wire [9:4]  sb
);

    // -------------------------------------------------------------------------
    // Coarse Gain Decoder Logic (4-to-16 Active-High One-Hot)
    // -------------------------------------------------------------------------
    assign y = 16'h0001 << d[3:0];

    // -------------------------------------------------------------------------
    // Fine Gain Steering Logic (True & Complementary Buffer Pairs)
    // -------------------------------------------------------------------------
    assign s  =  d[9:4];
    assign sb = ~d[9:4];

endmodule
