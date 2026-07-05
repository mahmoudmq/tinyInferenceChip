`timescale 1ns/1ps

module linear_classifier_tb;

    localparam DW = 8;
    localparam AW = 32;
    localparam N  = 4;

    //-------------------------------------------------------
    // DUT Signals
    //-------------------------------------------------------

    reg clk;
    reg rst_n;
    reg load_weight;

    reg signed [DW-1:0] weights [0:N-1][0:N-1];
    reg signed [DW-1:0] act_in  [0:N-1];

    wire signed [AW-1:0] psum_out [0:N-1];

    //-------------------------------------------------------
    // DUT
    //-------------------------------------------------------

    systolic_4x4 #(
        .DW(DW),
        .AW(AW),
        .N(N)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .load_weight(load_weight),
        .weights(weights),
        .act_in(act_in),
        .psum_out(psum_out)
    );

    //-------------------------------------------------------
    // Clock
    //-------------------------------------------------------

    initial clk = 0;
    always #5 clk = ~clk;

    //-------------------------------------------------------
    // Expected Results
    //-------------------------------------------------------

    integer expected [0:3];

    integer errors;
    
    integer max_idx;
    integer max_val;

    //-------------------------------------------------------
    // Test
    //-------------------------------------------------------

    initial begin

        errors = 0;

        $display("");
        $display("====================================================");
        $display("        4x4 LINEAR CLASSIFIER VERIFICATION");
        $display("====================================================");

        //---------------------------------------------
        // Reset
        //---------------------------------------------

        rst_n = 0;
        load_weight = 0;

        repeat(3) @(posedge clk);

        rst_n = 1;

        $display("[PASS] Reset complete");

        //---------------------------------------------
        // Load Weight Matrix
        //
        // Classes:
        // 0,1,7,8
        //---------------------------------------------

        weights[0][0]=1;
        weights[0][1]=2;
        weights[0][2]=5;
        weights[0][3]=0;

        weights[1][0]=6;
        weights[1][1]=0;
        weights[1][2]=0;
        weights[1][3]=1;

        weights[2][0]=3;
        weights[2][1]=4;
        weights[2][2]=-1;
        weights[2][3]=5;

        weights[3][0]=2;
        weights[3][1]=2;
        weights[3][2]=6;
        weights[3][3]=0;

        load_weight = 1;
        @(posedge clk);
        load_weight = 0;

        $display("[PASS] Weights loaded");

        //---------------------------------------------
        // Feature Vector
        //
        // vertical
        // horizontal
        // loop
        // diagonal
        //---------------------------------------------

        act_in[0] = 8;
        act_in[1] = 2;
        act_in[2] = 15;
        act_in[3] = 0;

        $display("[PASS] Feature vector applied");

        //---------------------------------------------
        // Wait for pipeline latency
        //---------------------------------------------

        repeat(7) @(posedge clk);

        //---------------------------------------------
        // Expected values
        //---------------------------------------------

        expected[0] = 87;
        expected[1] = 48;
        expected[2] = 17;
        expected[3] = 110;

        //---------------------------------------------
        // Print Results
        //---------------------------------------------

        $display("");
        $display("---------------- RESULTS ----------------");

        for (int i=0;i<4;i++) begin

            $display("Class %0d : Expected = %0d | Actual = %0d",
                     i,
                     expected[i],
                     psum_out[i]);

            if (psum_out[i] !== expected[i]) begin
                $display("   --> FAIL");
                errors = errors + 1;
            end
            else begin
                $display("   --> PASS");
            end

        end

        //---------------------------------------------
        // Prediction
        //---------------------------------------------


        max_idx = 0;
        max_val = psum_out[0];

        for(int i=1;i<4;i++) begin
            if(psum_out[i] > max_val) begin
                max_val = psum_out[i];
                max_idx = i;
            end
        end

        $display("");
        $display("Predicted Class = %0d", max_idx);

        //---------------------------------------------
        // Final Report
        //---------------------------------------------

        $display("");
        $display("====================================================");

        if(errors==0)
            $display("ALL TESTS PASSED");
        else
            $display("%0d TEST(S) FAILED", errors);

        $display("====================================================");

        #20;
        $finish;

    end

endmodule