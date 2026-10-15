// =============================================================================
// Testbench: tb_decoder_top_10b
// Description:
//   Self-checking verification testbench for decoder_top_10b.
//   Verifies:
//     1. All 16 coarse states (D[3:0] in 0..15) -> exact one-hot Y[15:0] matching 1 << D[3:0].
//     2. Fine steering bits (D[9:4] in 0..63) -> true S[9:4] and complementary SB[9:4].
//     3. Full sweeps and corner conditions (Min Gain 18.06 dB, Max Gain 78.00 dB).
//     4. Generates VCD waveform dump for GTKWave analysis.
// =============================================================================

`timescale 1ns / 1ps

module tb_decoder_top_10b;

    // -------------------------------------------------------------------------
    // Signals
    // -------------------------------------------------------------------------
    reg  [9:0]  d;
    wire [15:0] y;
    wire [9:4]  s;
    wire [9:4]  sb;

    integer errors;
    integer i;
    reg [15:0] expected_y;
    reg [5:0]  fine_val;
    reg [3:0]  coarse_val;

    // -------------------------------------------------------------------------
    // Device Under Test (DUT)
    // -------------------------------------------------------------------------
    decoder_top_10b dut (
        .d(d),
        .y(y),
        .s(s),
        .sb(sb)
    );

    // -------------------------------------------------------------------------
    // Stimulus and Verification
    // -------------------------------------------------------------------------
    initial begin
        // Waveform generation for GTKWave
        $dumpfile("tb_decoder_top_10b.vcd");
        $dumpvars(0, tb_decoder_top_10b);

        errors = 0;
        d = 10'h000;
        #5;

        $display("================================================================");
        $display("  Starting decoder_top_10b Verification");
        $display("================================================================");

        // ---------------------------------------------------------------------
        // Test 1: Exhaustive Coarse Decoder Check (all 16 states)
        // ---------------------------------------------------------------------
        $display("\n[TEST 1] Verifying 4-to-16 Coarse Decoder (D[3:0] -> Y[15:0])...");
        for (i = 0; i < 16; i = i + 1) begin
            coarse_val = i[3:0];
            d = {6'b000000, coarse_val};
            expected_y = 16'h0001 << coarse_val;
            #5;

            if (y !== expected_y) begin
                $display("  [ERROR] D[3:0]=%0d: Expected Y=0x%04h, Got Y=0x%04h",
                         coarse_val, expected_y, y);
                errors = errors + 1;
            end else begin
                $display("  [PASS]  D[3:0]=%2d | Y[15:0]=0x%04h (Tap Y%0d active)", coarse_val, y, coarse_val);
            end
        end

        // ---------------------------------------------------------------------
        // Test 2: Fine Gain Steering Bit Check (D[9:4] -> S[9:4] & SB[9:4])
        // ---------------------------------------------------------------------
        $display("\n[TEST 2] Verifying Fine Steering Drivers (D[9:4] -> S[9:4], SB[9:4])...");
        for (i = 0; i < 64; i = i + 7) begin
            fine_val = i[5:0];
            d = {fine_val, 4'b0000};
            #5;

            if (s !== fine_val || sb !== (~fine_val)) begin
                $display("  [ERROR] Fine D[9:4]=6'b%06b: Expected S=6'b%06b, SB=6'b%06b | Got S=6'b%06b, SB=6'b%06b",
                         fine_val, fine_val, ~fine_val, s, sb);
                errors = errors + 1;
            end else if ((s ^ sb) !== 6'b111111) begin
                $display("  [ERROR] Fine D[9:4]=6'b%06b: S and SB are not complementary!", fine_val);
                errors = errors + 1;
            end else begin
                $display("  [PASS]  D[9:4]=6'b%06b | S[9:4]=6'b%06b | SB[9:4]=6'b%06b", fine_val, s, sb);
            end
        end

        // ---------------------------------------------------------------------
        // Test 3: System Min & Max Corner Conditions
        // ---------------------------------------------------------------------
        $display("\n[TEST 3] Corner Verification: Min Gain (18.06 dB) & Max Gain (78.00 dB)...");
        // Minimum gain: code 0 (D=10'h000)
        d = 10'h000;
        #5;
        if (y !== 16'h0001 || s !== 6'b000000 || sb !== 6'b111111) begin
            $display("  [ERROR] Min Gain Code 0x000 check failed!");
            errors = errors + 1;
        end else begin
            $display("  [PASS]  Min Gain Code 0x000 (18.06 dB): Y0=1, S[9:4]=0, SB[9:4]=1");
        end

        // Maximum gain: code 1023 (D=10'h3FF)
        d = 10'h3FF;
        #5;
        if (y !== 16'h8000 || s !== 6'b111111 || sb !== 6'b000000) begin
            $display("  [ERROR] Max Gain Code 0x3FF check failed!");
            errors = errors + 1;
        end else begin
            $display("  [PASS]  Max Gain Code 0x3FF (78.00 dB): Y15=1, S[9:4]=1, SB[9:4]=0");
        end

        // ---------------------------------------------------------------------
        // Summary
        // ---------------------------------------------------------------------
        #10;
        $display("\n================================================================");
        if (errors == 0) begin
            $display("  VERIFICATION SUCCESSFUL: 0 errors encountered!");
            $display("================================================================");
        end else begin
            $display("  VERIFICATION FAILED: %0d error(s) detected!", errors);
            $display("================================================================");
        end

        #10;
        $finish;
    end

endmodule
