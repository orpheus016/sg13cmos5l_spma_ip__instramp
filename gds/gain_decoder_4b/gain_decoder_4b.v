// SPDX-FileCopyrightText: 2026 SPMA / Chipalooza Team
// SPDX-License-Identifier: Apache-2.0
//
// =============================================================================
// Module: gain_decoder_4b
// Project: Programmable Instrumentation Amplifier IP (Chipalooza #2)
// Technology: IHP SG13G2 / SG13CMOS5L (130nm BiCMOS)
// Description:
//   4-bit binary to two-stage complementary one-hot gain decoder.
//   Translates a 4-bit binary gain selection code (gain_sel[3:0], Levels 0..10)
//   into true and complementary steering control lines for CMOS transmission
//   gates in two cascaded analog amplifier stages:
//     - Stage 1: s1[4:0] (active-high), s1_b[4:0] (active-low)
//     - Stage 2: s2[4:0] (active-high), s2_b[4:0] (active-low)
//
// Ports:
//   gain_sel [3:0] (IN)  : 4-bit binary gain selection word (0..10 valid)
//   s1       [4:0] (OUT) : Stage 1 active-high switch lines (S0=2x..S4=32x)
//   s1_b     [4:0] (OUT) : Stage 1 active-low switch lines (~s1)
//   s2       [4:0] (OUT) : Stage 2 active-high switch lines (S0=2x..S4=32x)
//   s2_b     [4:0] (OUT) : Stage 2 active-low switch lines (~s2)
// =============================================================================

`timescale 1ns / 1ps

module gain_decoder_4b (
    input  wire [3:0] gain_sel,
    output reg  [4:0] s1,
    output wire [4:0] s1_b,
    output reg  [4:0] s2,
    output wire [4:0] s2_b
);

    always @(*) begin
        case (gain_sel)
            // Level 0: 1x, 1x (PGA = 1x, System = 8x / 18.06 dB)
            4'd0: begin
                s1 = 5'b00000;
                s2 = 5'b00000;
            end

            // Level 1: 2x, 1x (PGA = 2x, System = 16x / 24.08 dB)
            4'd1: begin
                s1 = 5'b00001;
                s2 = 5'b00000;
            end

            // Level 2: 4x, 1x (PGA = 4x, System = 32x / 30.10 dB)
            4'd2: begin
                s1 = 5'b00010;
                s2 = 5'b00000;
            end

            // Level 3: 8x, 1x (PGA = 8x, System = 64x / 36.12 dB)
            4'd3: begin
                s1 = 5'b00100;
                s2 = 5'b00000;
            end

            // Level 4: 16x, 1x (PGA = 16x, System = 128x / 42.14 dB)
            4'd4: begin
                s1 = 5'b01000;
                s2 = 5'b00000;
            end

            // Level 5: 32x, 1x (PGA = 32x, System = 256x / 48.16 dB)
            4'd5: begin
                s1 = 5'b10000;
                s2 = 5'b00000;
            end

            // Level 6: 32x, 2x (PGA = 64x, System = 512x / 54.19 dB)
            4'd6: begin
                s1 = 5'b10000;
                s2 = 5'b00001;
            end

            // Level 7: 32x, 4x (PGA = 128x, System = 1024x / 60.21 dB)
            4'd7: begin
                s1 = 5'b10000;
                s2 = 5'b00010;
            end

            // Level 8: 32x, 8x (PGA = 256x, System = 2048x / 66.23 dB)
            4'd8: begin
                s1 = 5'b10000;
                s2 = 5'b00100;
            end

            // Level 9: 32x, 16x (PGA = 512x, System = 4096x / 72.25 dB)
            4'd9: begin
                s1 = 5'b10000;
                s2 = 5'b01000;
            end

            // Level 10: 32x, 32x (PGA = 1024x, System = 8192x / 78.27 dB)
            4'd10: begin
                s1 = 5'b10000;
                s2 = 5'b10000;
            end

            // Invalid codes (11..15): Safe default clamp to Level 0 (1x, 1x)
            default: begin
                s1 = 5'b00000;
                s2 = 5'b00000;
            end
        endcase
    end

    // Complementary outputs for CMOS Transmission Gate PMOS control
    assign s1_b = ~s1;
    assign s2_b = ~s2;

endmodule
