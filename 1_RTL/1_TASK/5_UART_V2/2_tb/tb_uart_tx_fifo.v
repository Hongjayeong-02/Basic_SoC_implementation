`timescale 1ns/1ps

module tb_uart_tx_fifo;


localparam BAUD_DIV = 16'd312;

localparam PARITY_NONE = 2'b00;
localparam PARITY_EVEN = 2'b01;
localparam PARITY_ODD  = 2'b10;


reg             clk;
reg             rst_n;

reg             r_enable;
reg     [15:0]  r_baudDiv;

reg             r_wrEn;
reg     [7:0]   r_wrData;

reg             r_data7;
reg     [1:0]   r_parityMode;
reg             r_stop2;


wire            w_tick16;

wire            w_fifoFull;
wire            w_fifoEmpty;
wire    [4:0]   w_fifoCount;

wire            w_txReady;
wire            w_txBusy;
wire            w_txDone;
wire            w_uartTx;

wire    [7:0]   w_rxData;
wire            w_rxValid;
wire            w_rxBusy;

wire            w_parityErr;
wire            w_frameErr;
wire            w_falseStart;


integer         r_errorCnt;


// ---------------------------------------------------------
// Baud Generator
// ---------------------------------------------------------
uart_baud_gen uut_baud_gen (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_enable       (r_enable),
        .i_baudDiv      (r_baudDiv),

        .o_tick16       (w_tick16)
);


// ---------------------------------------------------------
// TX FIFO + UART TX
// ---------------------------------------------------------
uart_tx_fifo uut_tx_fifo (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (w_tick16),

        .i_wrEn         (r_wrEn),
        .i_wrData       (r_wrData),

        .i_data7        (r_data7),
        .i_parityMode   (r_parityMode),
        .i_stop2        (r_stop2),

        .o_fifoFull     (w_fifoFull),
        .o_fifoEmpty    (w_fifoEmpty),
        .o_fifoCount    (w_fifoCount),

        .o_txReady      (w_txReady),
        .o_txBusy       (w_txBusy),
        .o_txDone       (w_txDone),
        .o_uartTx       (w_uartTx)
);


// ---------------------------------------------------------
// UART RX Monitor
// ---------------------------------------------------------
uart_rx uut_rx (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (w_tick16),
        .i_uartRx       (w_uartTx),

        .i_data7        (r_data7),
        .i_parityMode   (r_parityMode),
        .i_stop2        (r_stop2),

        .o_rxData       (w_rxData),
        .o_rxValid      (w_rxValid),
        .o_rxBusy       (w_rxBusy),

        .o_parityErr    (w_parityErr),
        .o_frameErr     (w_frameErr),
        .o_falseStart   (w_falseStart)
);


// ---------------------------------------------------------
// 48 MHz Clock
// ---------------------------------------------------------
always #10.41667 clk = ~clk;


// ---------------------------------------------------------
// FIFO Write
// ---------------------------------------------------------
task fifo_write;

        input [7:0] data;

        begin

                wait (!w_fifoFull);

                @(negedge clk);

                r_wrData = data;
                r_wrEn   = 1'b1;

                @(negedge clk);

                r_wrEn   = 1'b0;
                r_wrData = 8'd0;

        end

endtask


// ---------------------------------------------------------
// RX Data Check
// ---------------------------------------------------------
task rx_check;

        input [7:0] expectedData;

        reg   [7:0] expectedRxData;

        begin

                if (r_data7)
                        expectedRxData = {
                                1'b0,
                                expectedData[6:0]
                        };
                else
                        expectedRxData = expectedData;


                // -----------------------------------------
                // Wait for NEW rxValid pulse
                // -----------------------------------------
                if (w_rxValid)
                        wait (!w_rxValid);

                @(posedge w_rxValid);

                #1;


                // -----------------------------------------
                // RX Data
                // -----------------------------------------
                if (w_rxData !== expectedRxData) begin

                        $display(
                                "FAIL: expected=%02h actual=%02h",
                                expectedRxData,
                                w_rxData
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: expected=%02h actual=%02h",
                                expectedRxData,
                                w_rxData
                        );

                end


                // -----------------------------------------
                // Parity Error
                // -----------------------------------------
                if (w_parityErr !== 1'b0) begin

                        $display(
                                "FAIL: parityErr=%b",
                                w_parityErr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // -----------------------------------------
                // Frame Error
                // -----------------------------------------
                if (w_frameErr !== 1'b0) begin

                        $display(
                                "FAIL: frameErr=%b",
                                w_frameErr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // -----------------------------------------
                // False Start
                // -----------------------------------------
                if (w_falseStart !== 1'b0) begin

                        $display(
                                "FAIL: falseStart=%b",
                                w_falseStart
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // Wait until current rxValid pulse ends
                wait (!w_rxValid);

        end

endtask


// ---------------------------------------------------------
// Main Test
// ---------------------------------------------------------
initial begin

        $dumpfile("uart_tx_fifo.vcd");
        $dumpvars(0, tb_uart_tx_fifo);


        clk             = 1'b0;
        rst_n           = 1'b0;

        r_enable        = 1'b0;
        r_baudDiv       = BAUD_DIV;

        r_wrEn          = 1'b0;
        r_wrData        = 8'd0;

        r_data7         = 1'b0;
        r_parityMode    = PARITY_NONE;
        r_stop2         = 1'b0;

        r_errorCnt      = 0;


        // -------------------------------------------------
        // Reset
        // -------------------------------------------------
        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        @(negedge clk);

        r_enable = 1'b1;


        // =================================================
        // TEST 1
        // 8-bit / No Parity / 1 Stop
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : 8BIT / NONE / 1 STOP");
        $display("----------------------------------------");


        r_data7      = 1'b0;
        r_parityMode = PARITY_NONE;
        r_stop2      = 1'b0;


        fifo_write(8'h55);
        fifo_write(8'hAA);
        fifo_write(8'h12);
        fifo_write(8'h34);


        rx_check(8'h55);
        rx_check(8'hAA);
        rx_check(8'h12);
        rx_check(8'h34);


        wait (!w_txBusy);
        wait (!w_rxBusy);
        wait (w_fifoEmpty);


        if (w_fifoEmpty !== 1'b1) begin

                $display(
                        "FAIL: TX FIFO should be EMPTY"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX FIFO EMPTY"
                );

        end


        // =================================================
        // TEST 2
        // 8-bit / Even Parity / 2 Stop
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : 8BIT / EVEN / 2 STOP");
        $display("----------------------------------------");


        r_data7      = 1'b0;
        r_parityMode = PARITY_EVEN;
        r_stop2      = 1'b1;


        fifo_write(8'h5A);
        fifo_write(8'hA5);
        fifo_write(8'h3C);


        rx_check(8'h5A);
        rx_check(8'hA5);
        rx_check(8'h3C);


        wait (!w_txBusy);
        wait (!w_rxBusy);
        wait (w_fifoEmpty);


        // =================================================
        // TEST 3
        // 7-bit / Odd Parity / 1 Stop
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : 7BIT / ODD / 1 STOP");
        $display("----------------------------------------");


        r_data7      = 1'b1;
        r_parityMode = PARITY_ODD;
        r_stop2      = 1'b0;


        fifo_write(8'h35);
        fifo_write(8'h2A);
        fifo_write(8'h4D);


        rx_check(8'h35);
        rx_check(8'h2A);
        rx_check(8'h4D);


        wait (!w_txBusy);
        wait (!w_rxBusy);
        wait (w_fifoEmpty);


        // =================================================
        // Final FIFO Check
        // =================================================
        if (w_fifoCount !== 5'd0) begin

                $display(
                        "FAIL: FIFO COUNT expected=0 actual=%0d",
                        w_fifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FIFO COUNT = 0"
                );

        end


        // =================================================
        // Final Result
        // =================================================
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART TX FIFO: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART TX FIFO: %0d ERROR(S)",
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

        #200000000;

        $display("");
        $display("========================================");
        $display(" FAIL: TX FIFO SIMULATION TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule
