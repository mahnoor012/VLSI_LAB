`timescale 1ns / 1ps

module full_adder_8bit_v2_tb_dynamic;

    // Inputs
    reg A0, A1, A2, A3, A4, A5, A6, A7;
    reg B0, B1, B2, B3, B4, B5, B6, B7;
    reg Cin;

    // Outputs
    wire S0, S1, S2, S3, S4, S5, S6, S7;
    wire Cout;

    // Temporary 8-bit values
    reg [7:0] a_temp;
    reg [7:0] b_temp;

    // Expected and actual 9-bit results
    reg [8:0] expected;
    reg [8:0] actual;

    integer i;
    integer pass_count;
    integer fail_count;

    // Instantiate the 8-bit Full Adder
    full_adder_8bit uut (
        .A0(A0), .A1(A1), .A2(A2), .A3(A3),
        .A4(A4), .A5(A5), .A6(A6), .A7(A7),

        .B0(B0), .B1(B1), .B2(B2), .B3(B3),
        .B4(B4), .B5(B5), .B6(B6), .B7(B7),

        .Cin(Cin),

        .S0(S0), .S1(S1), .S2(S2), .S3(S3),
        .S4(S4), .S5(S5), .S6(S6), .S7(S7),

        .Cout(Cout)
    );

    // Dynamic testing
    initial begin

        pass_count = 0;
        fail_count = 0;

        // Generate 15 random test cases
        for (i = 0; i < 15; i = i + 1) begin

            // Generate random 8-bit inputs
            a_temp = $random;
            b_temp = $random;

            // Generate random Carry-in
            Cin = $random;

            // Apply random inputs to individual ports
            {A7,A6,A5,A4,A3,A2,A1,A0} = a_temp;
            {B7,B6,B5,B4,B3,B2,B1,B0} = b_temp;

            // Wait for circuit response
            #100;

            // Calculate expected result
            expected = {1'b0, a_temp}
                     + {1'b0, b_temp}
                     + Cin;

            // Collect actual circuit output
            actual = {Cout,S7,S6,S5,S4,S3,S2,S1,S0};

            // Compare expected and actual
            if (actual === expected) begin

                $display(
                    "Test %0d: PASS | A=%0d B=%0d Cin=%b | Expected=%0d Actual=%0d",
                    i + 1,
                    a_temp,
                    b_temp,
                    Cin,
                    expected,
                    actual
                );

                pass_count = pass_count + 1;

            end
            else begin

                $display(
                    "Test %0d: FAIL | A=%0d B=%0d Cin=%b | Expected=%0d Actual=%0d",
                    i + 1,
                    a_temp,
                    b_temp,
                    Cin,
                    expected,
                    actual
                );

                fail_count = fail_count + 1;

            end

        end

        // Final summary
        $display("-----------------------------------");
        $display("Total Tests = %0d", pass_count + fail_count);
        $display("PASS = %0d", pass_count);
        $display("FAIL = %0d", fail_count);
        $display("-----------------------------------");

        $finish;

    end

endmodule