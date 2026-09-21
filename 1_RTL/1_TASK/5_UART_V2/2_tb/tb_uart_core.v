`timescale 1ns/1ps

module tb_uart_core;


localparam BAUD_DIV = 16'd312;

localparam PARITY_NONE = 2'b00;
localparam PARITY_EVEN = 2'b01;
localparam PARITY_ODD  = 2'b10;


reg             clk;
reg             rst_n;

reg             r_enable;
reg     [15:0]  r_baudDiv;

reg             r_data7;
reg     [1:0]   r_parityMode;
reg             r_stop2;

reg             r_txWrEn;
reg     [7:0]   r_txData;

reg             r_rxRdEn;


wire            w_uartLine;

wire            w_txFifoFull;
wire            w_txFifoEmpty;
wire    [4:0]   w_txFifoCount;

wire            w_txReady;
wire            w_txBusy;
wire            w_txDone;

wire    [7:0]   w_rxData;

wire            w_rxFifoFull;
wire            w_rxFifoEmpty;
wire    [4:0]   w_rxFifoCount;

wire            w_rxValid;
wire            w_rxBusy;

wire            w_parityErr;
wire            w_frameErr;
wire            w_falseStart;


integer         r_errorCnt;
integer         r_protocolErrorCnt;


// ---------------------------------------------------------
// UART CORE
// External TX -> RX Loopback
// ---------------------------------------------------------
uart_core uut (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_enable       (r_enable),
        .i_baudDiv      (r_baudDiv),

        .i_data7        (r_data7),
        .i_parityMode   (r_parityMode),
        .i_stop2        (r_stop2),

        .i_txWrEn       (r_txWrEn),
        .i_txData       (r_txData),

        .i_rxRdEn       (r_rxRdEn),

        .i_uartRx       (w_uartLine),
        .o_uartTx       (w_uartLine),

        .o_txFifoFull   (w_txFifoFull),
        .o_txFifoEmpty  (w_txFifoEmpty),
        .o_txFifoCount  (w_txFifoCount),

        .o_txReady      (w_txReady),
        .o_txBusy       (w_txBusy),
        .o_txDone       (w_txDone),

        .o_rxData       (w_rxData),

        .o_rxFifoFull   (w_rxFifoFull),
        .o_rxFifoEmpty  (w_rxFifoEmpty),
        .o_rxFifoCount  (w_rxFifoCount),

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
// RX Protocol Error Monitor
// ---------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
                r_protocolErrorCnt <= 0;

        end else begin

                if (w_parityErr)
                        r_protocolErrorCnt <=
                                r_protocolErrorCnt + 1;

                if (w_frameErr)
                        r_protocolErrorCnt <=
                                r_protocolErrorCnt + 1;

                if (w_falseStart)
                        r_protocolErrorCnt <=
                                r_protocolErrorCnt + 1;

        end
end


// ---------------------------------------------------------
// TX FIFO Write
// ---------------------------------------------------------
task tx_write;

        input [7:0] data;

        begin

                wait (!w_txFifoFull);

                @(negedge clk);

                r_txData = data;
                r_txWrEn = 1'b1;


                @(negedge clk);

                r_txWrEn = 1'b0;
                r_txData = 8'd0;

        end

endtask


// ---------------------------------------------------------
// RX FIFO Read + Check
// ---------------------------------------------------------
task rx_read_check;

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


                wait (!w_rxFifoEmpty);


                @(negedge clk);

                r_rxRdEn = 1'b1;


                @(posedge clk);

                #1;


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


                @(negedge clk);

                r_rxRdEn = 1'b0;

        end

endtask


// ---------------------------------------------------------
// Wait Until Current Transfer Group Completes
// ---------------------------------------------------------
task wait_transfer_done;

        input [4:0] expectedCount;

        begin

                wait (w_rxFifoCount == expectedCount);

                wait (w_txFifoEmpty);
                wait (!w_txBusy);
                wait (!w_rxBusy);

                repeat (2)
                        @(posedge clk);

        end

endtask


// ---------------------------------------------------------
// Main Test
// ---------------------------------------------------------
initial begin

        $dumpfile("uart_core.vcd");
        $dumpvars(0, tb_uart_core);


        clk                 = 1'b0;
        rst_n               = 1'b0;

        r_enable            = 1'b0;
        r_baudDiv           = BAUD_DIV;

        r_data7             = 1'b0;
        r_parityMode        = PARITY_NONE;
        r_stop2             = 1'b0;

        r_txWrEn            = 1'b0;
        r_txData            = 8'd0;

        r_rxRdEn            = 1'b0;

        r_errorCnt          = 0;


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
        $display(" TEST 1 : UART CORE 8BIT / NONE / 1 STOP");
        $display("----------------------------------------");


        r_data7      = 1'b0;
        r_parityMode = PARITY_NONE;
        r_stop2      = 1'b0;


        tx_write(8'h55);
        tx_write(8'hAA);
        tx_write(8'h12);
        tx_write(8'h34);


        wait_transfer_done(5'd4);


        if (w_rxFifoCount !== 5'd4) begin

                $display(
                        "FAIL: RX FIFO COUNT expected=4 actual=%0d",
                        w_rxFifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO COUNT = 4"
                );

        end


        rx_read_check(8'h55);
        rx_read_check(8'hAA);
        rx_read_check(8'h12);
        rx_read_check(8'h34);


        wait (w_rxFifoEmpty);


        if (w_rxFifoEmpty)
                $display("PASS: RX FIFO EMPTY");


        // =================================================
        // TEST 2
        // 8-bit / Even Parity / 2 Stop
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : UART CORE 8BIT / EVEN / 2 STOP");
        $display("----------------------------------------");


        r_data7      = 1'b0;
        r_parityMode = PARITY_EVEN;
        r_stop2      = 1'b1;


        tx_write(8'h5A);
        tx_write(8'hA5);
        tx_write(8'h3C);


        wait_transfer_done(5'd3);


        if (w_rxFifoCount !== 5'd3) begin

                $display(
                        "FAIL: RX FIFO COUNT expected=3 actual=%0d",
                        w_rxFifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO COUNT = 3"
                );

        end


        rx_read_check(8'h5A);
        rx_read_check(8'hA5);
        rx_read_check(8'h3C);


        wait (w_rxFifoEmpty);


        // =================================================
        // TEST 3
        // 7-bit / Odd Parity / 1 Stop
        //
        // High bit is intentionally set in TX data.
        // RX must return only lower 7 bits.
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : UART CORE 7BIT / ODD / 1 STOP");
        $display("----------------------------------------");


        r_data7      = 1'b1;
        r_parityMode = PARITY_ODD;
        r_stop2      = 1'b0;


        tx_write(8'hD5);
        tx_write(8'hAA);
        tx_write(8'hCD);


        wait_transfer_done(5'd3);


        if (w_rxFifoCount !== 5'd3) begin

                $display(
                        "FAIL: RX FIFO COUNT expected=3 actual=%0d",
                        w_rxFifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO COUNT = 3"
                );

        end


        // Expected:
        // D5 -> 55
        // AA -> 2A
        // CD -> 4D
        rx_read_check(8'hD5);
        rx_read_check(8'hAA);
        rx_read_check(8'hCD);


        wait (w_rxFifoEmpty);


        // =================================================
        // Final FIFO State
        // =================================================
        if (w_txFifoCount !== 5'd0) begin

                $display(
                        "FAIL: TX FIFO COUNT expected=0 actual=%0d",
                        w_txFifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX FIFO COUNT = 0"
                );

        end


        if (w_rxFifoCount !== 5'd0) begin

                $display(
                        "FAIL: RX FIFO COUNT expected=0 actual=%0d",
                        w_rxFifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO COUNT = 0"
                );

        end


        // =================================================
        // Protocol Error Check
        // =================================================
        if (r_protocolErrorCnt !== 0) begin

                $display(
                        "FAIL: UART protocol error count=%0d",
                        r_protocolErrorCnt
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: UART PROTOCOL ERROR COUNT = 0"
                );

        end


        // =================================================
        // Final Result
        // =================================================
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V2 CORE: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V2 CORE: %0d ERROR(S)",
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

        #300000000;

        $display("");
        $display("========================================");
        $display(" FAIL: UART CORE SIMULATION TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule
