`timescale 1ns/1ps

module tb_uart_loopback;

localparam BAUD_DIV = 16'd312;

localparam PARITY_NONE = 2'b00;
localparam PARITY_EVEN = 2'b01;
localparam PARITY_ODD  = 2'b10;


reg             clk;
reg             rst_n;

reg             r_enable;
reg     [15:0]  r_baudDiv;

reg             r_txValid;
reg     [7:0]   r_txData;

reg             r_data7;
reg     [1:0]   r_parityMode;
reg             r_stop2;


wire            w_txReady;
wire            w_txBusy;
wire            w_txDone;

wire    [7:0]   w_rxData;
wire            w_rxValid;
wire            w_rxBusy;

wire            w_parityErr;
wire            w_frameErr;
wire            w_falseStart;

wire            w_uartTx;


integer         r_errorCnt;


// ---------------------------------------------------------
// DUT
// ---------------------------------------------------------
uart_loopback uut (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_enable       (r_enable),
        .i_baudDiv      (r_baudDiv),

        .i_txValid      (r_txValid),
        .i_txData       (r_txData),

        .i_data7        (r_data7),
        .i_parityMode   (r_parityMode),
        .i_stop2        (r_stop2),

        .o_txReady      (w_txReady),
        .o_txBusy       (w_txBusy),
        .o_txDone       (w_txDone),

        .o_rxData       (w_rxData),
        .o_rxValid      (w_rxValid),
        .o_rxBusy       (w_rxBusy),

        .o_parityErr    (w_parityErr),
        .o_frameErr     (w_frameErr),
        .o_falseStart   (w_falseStart),

        .o_uartTx       (w_uartTx)
);


// ---------------------------------------------------------
// 48 MHz Clock
// ---------------------------------------------------------
always #10.41667 clk = ~clk;


// ---------------------------------------------------------
// TX -> RX Loopback Verification
// ---------------------------------------------------------
task send_and_check;

        input   [7:0]   data;
        input           data7;
        input   [1:0]   parityMode;
        input           stop2;

        reg     [7:0]   expectedData;
        integer         previousErrorCount;

        begin

                previousErrorCount = r_errorCnt;


                // Configuration
                r_data7         = data7;
                r_parityMode    = parityMode;
                r_stop2         = stop2;


                // Expected Data
                if (data7)
                        expectedData = {1'b0, data[6:0]};
                else
                        expectedData = data;


                // Wait until TX is ready
                wait (w_txReady);


                // TX Request
                @(negedge clk);

                r_txData  = data;
                r_txValid = 1'b1;


                @(negedge clk);

                r_txValid = 1'b0;


                // Wait until RX receives data
                wait (w_rxValid);

                #1;


                // RX Data Check
                if (w_rxData !== expectedData) begin

                        $display(
                                "FAIL: RX DATA expected=%02h actual=%02h",
                                expectedData,
                                w_rxData
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // Parity Error Check
                if (w_parityErr !== 1'b0) begin

                        $display(
                                "FAIL: parityErr=%b",
                                w_parityErr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // Frame Error Check
                if (w_frameErr !== 1'b0) begin

                        $display(
                                "FAIL: frameErr=%b",
                                w_frameErr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // False Start Check
                if (w_falseStart !== 1'b0) begin

                        $display(
                                "FAIL: falseStart=%b",
                                w_falseStart
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // Test Result
                if (previousErrorCount == r_errorCnt) begin

                        $display(
                                "PASS: data=%02h data7=%b parity=%02b stop2=%b rxData=%02h",
                                data,
                                data7,
                                parityMode,
                                stop2,
                                w_rxData
                        );

                end else begin

                        $display(
                                "FAIL: data=%02h data7=%b parity=%02b stop2=%b",
                                data,
                                data7,
                                parityMode,
                                stop2
                        );

                end


                // Wait until TX and RX return to IDLE
                wait (!w_txBusy);
                wait (!w_rxBusy);

                repeat (2)
                        @(posedge clk);

        end

endtask


// ---------------------------------------------------------
// Test
// ---------------------------------------------------------
initial begin

        $dumpfile("uart_loopback.vcd");
        $dumpvars(0, tb_uart_loopback);


        clk             = 1'b0;
        rst_n           = 1'b0;

        r_enable        = 1'b0;
        r_baudDiv       = BAUD_DIV;

        r_txValid       = 1'b0;
        r_txData        = 8'd0;

        r_data7         = 1'b0;
        r_parityMode    = PARITY_NONE;
        r_stop2         = 1'b0;

        r_errorCnt      = 0;


        // Reset
        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        @(negedge clk);

        r_enable = 1'b1;


        // -------------------------------------------------
        // 8-bit / No Parity / 1 Stop
        // -------------------------------------------------
        send_and_check(
                8'h55,
                1'b0,
                PARITY_NONE,
                1'b0
        );


        send_and_check(
                8'hAA,
                1'b0,
                PARITY_NONE,
                1'b0
        );


        // -------------------------------------------------
        // 8-bit / Even Parity / 1 Stop
        // -------------------------------------------------
        send_and_check(
                8'h5A,
                1'b0,
                PARITY_EVEN,
                1'b0
        );


        // -------------------------------------------------
        // 8-bit / Odd Parity / 1 Stop
        // -------------------------------------------------
        send_and_check(
                8'hA5,
                1'b0,
                PARITY_ODD,
                1'b0
        );


        // -------------------------------------------------
        // 8-bit / Even Parity / 2 Stop
        // -------------------------------------------------
        send_and_check(
                8'h3C,
                1'b0,
                PARITY_EVEN,
                1'b1
        );


        // -------------------------------------------------
        // 8-bit / Odd Parity / 2 Stop
        // -------------------------------------------------
        send_and_check(
                8'hC3,
                1'b0,
                PARITY_ODD,
                1'b1
        );


        // -------------------------------------------------
        // 7-bit / No Parity / 1 Stop
        // -------------------------------------------------
        send_and_check(
                8'h55,
                1'b1,
                PARITY_NONE,
                1'b0
        );


        // -------------------------------------------------
        // 7-bit / Even Parity / 1 Stop
        // -------------------------------------------------
        send_and_check(
                8'h35,
                1'b1,
                PARITY_EVEN,
                1'b0
        );


        // -------------------------------------------------
        // 7-bit / Odd Parity / 1 Stop
        // -------------------------------------------------
        send_and_check(
                8'h2A,
                1'b1,
                PARITY_ODD,
                1'b0
        );


        // -------------------------------------------------
        // 7-bit / Even Parity / 2 Stop
        // -------------------------------------------------
        send_and_check(
                8'h6B,
                1'b1,
                PARITY_EVEN,
                1'b1
        );


        // -------------------------------------------------
        // 7-bit / Odd Parity / 2 Stop
        // -------------------------------------------------
        send_and_check(
                8'h4D,
                1'b1,
                PARITY_ODD,
                1'b1
        );


        // -------------------------------------------------
        // Final Result
        // -------------------------------------------------
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V2 LOOPBACK: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V2 LOOPBACK: %0d ERROR(S)",
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

        #100000000;

        $display("");
        $display("========================================");
        $display(" FAIL: LOOPBACK SIMULATION TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end

endmodule
