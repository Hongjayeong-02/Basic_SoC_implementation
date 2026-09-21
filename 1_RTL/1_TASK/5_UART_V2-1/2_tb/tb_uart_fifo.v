`timescale 1ns/1ps

module tb_uart_fifo;

reg             clk;
reg             rst_n;

reg             r_wrEn;
reg     [7:0]   r_wrData;

reg             r_rdEn;

wire    [7:0]   w_rdData;
wire            w_full;
wire            w_empty;
wire    [4:0]   w_count;

integer         r_errorCnt;
integer         i;


// ---------------------------------------------------------
// DUT
// ---------------------------------------------------------
uart_fifo uut (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_wrEn         (r_wrEn),
        .i_wrData       (r_wrData),

        .i_rdEn         (r_rdEn),

        .o_rdData       (w_rdData),
        .o_full         (w_full),
        .o_empty        (w_empty),
        .o_count        (w_count)
);


// ---------------------------------------------------------
// Clock
// ---------------------------------------------------------
initial begin
        clk = 1'b0;

        forever #5 clk = ~clk;
end


// ---------------------------------------------------------
// Write Task
// ---------------------------------------------------------
task fifo_write;

        input [7:0] data;

        begin

                @(negedge clk);

                r_wrEn   = 1'b1;
                r_wrData = data;

                @(negedge clk);

                r_wrEn   = 1'b0;
                r_wrData = 8'd0;

        end

endtask


// ---------------------------------------------------------
// Read and Check Task
// ---------------------------------------------------------
task fifo_read_check;

        input [7:0] expectedData;

        begin

                @(negedge clk);

                r_rdEn = 1'b1;

                @(posedge clk);

                #1;

                if (w_rdData !== expectedData) begin

                        $display(
                                "FAIL: READ expected=%02h actual=%02h",
                                expectedData,
                                w_rdData
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: READ expected=%02h actual=%02h",
                                expectedData,
                                w_rdData
                        );

                end


                @(negedge clk);

                r_rdEn = 1'b0;

        end

endtask


// ---------------------------------------------------------
// Main Test
// ---------------------------------------------------------
initial begin

        $dumpfile("uart_fifo.vcd");
        $dumpvars(0, tb_uart_fifo);


        rst_n       = 1'b0;

        r_wrEn      = 1'b0;
        r_wrData    = 8'd0;

        r_rdEn      = 1'b0;

        r_errorCnt  = 0;


        // -------------------------------------------------
        // Reset
        // -------------------------------------------------
        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        @(posedge clk);


        // -------------------------------------------------
        // TEST 1
        // Reset State
        // -------------------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : RESET STATE");
        $display("----------------------------------------");


        if (w_empty !== 1'b1) begin
                $display("FAIL: FIFO should be EMPTY after reset");
                r_errorCnt = r_errorCnt + 1;
        end


        if (w_full !== 1'b0) begin
                $display("FAIL: FIFO should not be FULL after reset");
                r_errorCnt = r_errorCnt + 1;
        end


        if (w_count !== 5'd0) begin
                $display(
                        "FAIL: COUNT expected=0 actual=%0d",
                        w_count
                );

                r_errorCnt = r_errorCnt + 1;
        end


        if (
                (w_empty == 1'b1) &&
                (w_full  == 1'b0) &&
                (w_count == 5'd0)
        )
                $display("PASS: RESET STATE");


        // -------------------------------------------------
        // TEST 2
        // Basic Write / Read
        // -------------------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : BASIC WRITE / READ");
        $display("----------------------------------------");


        fifo_write(8'h11);
        fifo_write(8'h22);
        fifo_write(8'h33);
        fifo_write(8'h44);


        if (w_count !== 5'd4) begin

                $display(
                        "FAIL: COUNT expected=4 actual=%0d",
                        w_count
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display("PASS: WRITE COUNT = 4");

        end


        fifo_read_check(8'h11);
        fifo_read_check(8'h22);
        fifo_read_check(8'h33);
        fifo_read_check(8'h44);


        if (w_empty !== 1'b1) begin

                $display("FAIL: FIFO should be EMPTY");

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display("PASS: FIFO EMPTY");

        end


        // -------------------------------------------------
        // TEST 3
        // FIFO Full
        // -------------------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : FIFO FULL");
        $display("----------------------------------------");


        for (
                i = 0;
                i < 16;
                i = i + 1
        ) begin

                fifo_write(i);

        end


        if (w_full !== 1'b1) begin

                $display("FAIL: FIFO should be FULL");

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display("PASS: FIFO FULL");

        end


        if (w_count !== 5'd16) begin

                $display(
                        "FAIL: COUNT expected=16 actual=%0d",
                        w_count
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display("PASS: FIFO COUNT = 16");

        end


        // -------------------------------------------------
        // TEST 4
        // Overflow Protection
        // -------------------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : OVERFLOW PROTECTION");
        $display("----------------------------------------");


        fifo_write(8'hFF);


        if (w_count !== 5'd16) begin

                $display(
                        "FAIL: Overflow changed COUNT=%0d",
                        w_count
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display("PASS: OVERFLOW BLOCKED");

        end


        // Read FIFO contents
        for (
                i = 0;
                i < 16;
                i = i + 1
        ) begin

                fifo_read_check(i);

        end


        // -------------------------------------------------
        // TEST 5
        // Underflow Protection
        // -------------------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 5 : UNDERFLOW PROTECTION");
        $display("----------------------------------------");


        @(negedge clk);

        r_rdEn = 1'b1;

        @(negedge clk);

        r_rdEn = 1'b0;


        if (w_count !== 5'd0) begin

                $display(
                        "FAIL: Underflow changed COUNT=%0d",
                        w_count
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display("PASS: UNDERFLOW BLOCKED");

        end


        // -------------------------------------------------
        // TEST 6
        // Simultaneous Write / Read
        // -------------------------------------------------
        $display("");
        $display("----------------------------------------");
        $display(" TEST 6 : SIMULTANEOUS WRITE / READ");
        $display("----------------------------------------");


        fifo_write(8'hAA);
        fifo_write(8'hBB);
        fifo_write(8'hCC);


        if (w_count !== 5'd3) begin

                $display(
                        "FAIL: COUNT expected=3 actual=%0d",
                        w_count
                );

                r_errorCnt = r_errorCnt + 1;

        end


        // Read AA and Write DD at same time
        @(negedge clk);

        r_wrEn   = 1'b1;
        r_wrData = 8'hDD;
        r_rdEn   = 1'b1;


        @(posedge clk);

        #1;


        if (w_rdData !== 8'hAA) begin

                $display(
                        "FAIL: SIMULTANEOUS READ expected=AA actual=%02h",
                        w_rdData
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: SIMULTANEOUS READ = %02h",
                        w_rdData
                );

        end


        @(negedge clk);

        r_wrEn   = 1'b0;
        r_wrData = 8'd0;
        r_rdEn   = 1'b0;


        // Count must remain 3
        if (w_count !== 5'd3) begin

                $display(
                        "FAIL: COUNT expected=3 actual=%0d",
                        w_count
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display("PASS: SIMULTANEOUS COUNT = 3");

        end


        // Remaining Data
        fifo_read_check(8'hBB);
        fifo_read_check(8'hCC);
        fifo_read_check(8'hDD);


        // -------------------------------------------------
        // Final Result
        // -------------------------------------------------
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART FIFO: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART FIFO: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");

        end


        #100;

        $finish;

end


// ---------------------------------------------------------
// Timeout
// ---------------------------------------------------------
initial begin

        #1000000;

        $display("");
        $display("========================================");
        $display(" FAIL: FIFO SIMULATION TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end

endmodule
