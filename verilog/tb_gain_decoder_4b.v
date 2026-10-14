// SPDX-FileCopyrightText: 2026 SPMA / Chipalooza Team
// SPDX-License-Identifier: Apache-2.0
//
// =============================================================================
// Testbench: tb_gain_decoder_4b
// Project: Programmable Instrumentation Amplifier IP (Chipalooza #2)
// Technology: IHP SG13G2 / SG13CMOS5L (130nm BiCMOS)
// Description:
//   Self-checking functional verification testbench for gain_decoder_4b.
//   Exhaustively tests all 16 input combinations (4'd0 to 4'd15), verifying:
//     1. Exact one-hot steering match for Stage 1 (s1) and Stage 2 (s2).
//     2. Strict complementary inversion on s1_b (~s1) and s2_b (~s2).
//     3. Safe clamping to Level 0 (1x, 1x) for out-of-range codes (4'd11..4'd15).
// =============================================================================

`timescale 1ns / 1ps

module tb_gain_decoder_4b;

    // -------------------------------------------------------------------------
    // Signals
    // -------------------------------------------------------------------------
    reg  [3:0] gain_sel;
    wire [4:0] s1;
    wire [4:0] s1_b;
    wire [4:0] s2;
    wire [4:0] s2_b;

    // Expected signals for verification
    reg [4:0] exp_s1;
    reg [4:0] exp_s2;
    integer   exp_pga_gain;
    real      exp_total_db;

    reg [8*8:1] str_stage1;
    reg [8*8:1] str_stage2;
    reg [8*8:1] str_level;

    integer i;
    integer error_count;

    // -------------------------------------------------------------------------
    // Device Under Test (DUT)
    // -------------------------------------------------------------------------
    gain_decoder_4b dut (
        .gain_sel (gain_sel),
        .s1       (s1),
        .s1_b     (s1_b),
        .s2       (s2),
        .s2_b     (s2_b)
    );

    // -------------------------------------------------------------------------
    // Main Test Stimulus
    // -------------------------------------------------------------------------
    initial begin
        // Setup VCD dumping
        $dumpfile("tb_gain_decoder_4b.vcd");
        $dumpvars(0, tb_gain_decoder_4b);

        error_count = 0;
        gain_sel = 4'd0;

        $display("=========================================================================================================");
        $display("  STARTING FUNCTIONAL VERIFICATION: gain_decoder_4b (4-bit to 2-Stage Complementary)");
        $display("=========================================================================================================");
        $display(" Sel | Level |  s1   | s1_b  |  s2   | s2_b  | Stage 1 | Stage 2 | PGA Gain | Total (dB) | Status");
        $display("-----+-------+-------+-------+-------+-------+---------+---------+----------+------------+-------");

        for (i = 0; i < 16; i = i + 1) begin
            gain_sel = i[3:0];
            #10; // Allow combinational propagation

            // Determine expected values based on architectural spec
            case (gain_sel)
                4'd0:  begin exp_s1 = 5'b00000; exp_s2 = 5'b00000; exp_pga_gain = 1;    exp_total_db = 18.06; str_level = "  0  "; str_stage1 = " 1x"; str_stage2 = " 1x"; end
                4'd1:  begin exp_s1 = 5'b00001; exp_s2 = 5'b00000; exp_pga_gain = 2;    exp_total_db = 24.08; str_level = "  1  "; str_stage1 = " 2x"; str_stage2 = " 1x"; end
                4'd2:  begin exp_s1 = 5'b00010; exp_s2 = 5'b00000; exp_pga_gain = 4;    exp_total_db = 30.10; str_level = "  2  "; str_stage1 = " 4x"; str_stage2 = " 1x"; end
                4'd3:  begin exp_s1 = 5'b00100; exp_s2 = 5'b00000; exp_pga_gain = 8;    exp_total_db = 36.12; str_level = "  3  "; str_stage1 = " 8x"; str_stage2 = " 1x"; end
                4'd4:  begin exp_s1 = 5'b01000; exp_s2 = 5'b00000; exp_pga_gain = 16;   exp_total_db = 42.14; str_level = "  4  "; str_stage1 = "16x"; str_stage2 = " 1x"; end
                4'd5:  begin exp_s1 = 5'b10000; exp_s2 = 5'b00000; exp_pga_gain = 32;   exp_total_db = 48.16; str_level = "  5  "; str_stage1 = "32x"; str_stage2 = " 1x"; end
                4'd6:  begin exp_s1 = 5'b10000; exp_s2 = 5'b00001; exp_pga_gain = 64;   exp_total_db = 54.19; str_level = "  6  "; str_stage1 = "32x"; str_stage2 = " 2x"; end
                4'd7:  begin exp_s1 = 5'b10000; exp_s2 = 5'b00010; exp_pga_gain = 128;  exp_total_db = 60.21; str_level = "  7  "; str_stage1 = "32x"; str_stage2 = " 4x"; end
                4'd8:  begin exp_s1 = 5'b10000; exp_s2 = 5'b00100; exp_pga_gain = 256;  exp_total_db = 66.23; str_level = "  8  "; str_stage1 = "32x"; str_stage2 = " 8x"; end
                4'd9:  begin exp_s1 = 5'b10000; exp_s2 = 5'b01000; exp_pga_gain = 512;  exp_total_db = 72.25; str_level = "  9  "; str_stage1 = "32x"; str_stage2 = "16x"; end
                4'd10: begin exp_s1 = 5'b10000; exp_s2 = 5'b10000; exp_pga_gain = 1024; exp_total_db = 78.27; str_level = " 10  "; str_stage1 = "32x"; str_stage2 = "32x"; end
                default: begin // 4'd11..4'd15
                    exp_s1 = 5'b00000;
                    exp_s2 = 5'b00000;
                    exp_pga_gain = 1;
                    exp_total_db = 18.06;
                    str_level  = "CLAMP";
                    str_stage1 = " 1x";
                    str_stage2 = " 1x";
                end
            endcase

            // Check correctness
            if ((s1 !== exp_s1) || (s2 !== exp_s2) || (s1_b !== ~exp_s1) || (s2_b !== ~exp_s2)) begin
                $display("  %2d | %s | %5b | %5b | %5b | %5b |  MISMATCH! Exp s1=%5b, s2=%5b | FAIL",
                         gain_sel, str_level, s1, s1_b, s2, s2_b, exp_s1, exp_s2);
                error_count = error_count + 1;
            end else begin
                $display("  %2d | %s | %5b | %5b | %5b | %5b |   %s   |   %s   |   %4dx   |  %5.2f dB  | PASS",
                         gain_sel, str_level, s1, s1_b, s2, s2_b, str_stage1, str_stage2, exp_pga_gain, exp_total_db);
            end
        end

        $display("---------------------------------------------------------------------------------------------------------");
        if (error_count == 0) begin
            $display(">>> ALL 16 VECTORS PASSED FUNCTIONAL VERIFICATION (0 ERRORS) <<<");
            $display("=========================================================================================================");
        end else begin
            $display(">>> VERIFICATION FAILED WITH %0d ERRORS <<<", error_count);
            $display("=========================================================================================================");
            $finish(1);
        end

        $finish;
    end

endmodule
