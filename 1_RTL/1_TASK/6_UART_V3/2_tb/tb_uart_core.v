`timescale 1ns/1ps

module tb_uart_core;


localparam BAUD_DIV = 16'd312;

localparam PARITY_NONE = 2'b00;


reg             clk;
reg             rst_n;

reg             r_enable;
reg             r_txEn;
reg             r_rxEn;

reg     [15:0]  r_baudDiv;

reg             r_data7;
reg     [1:0]   r_parityMode;
reg             r_stop2;
reg             r_loopbackEn;

reg             r_txWrEn;
reg     [7:0]   r_txData;

reg             r_rxRdEn;

reg             r_uartRx;


wire            w_uartTx;

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


// DUT
uart_core uut (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_enable       (r_enable),
        .i_txEn         (r_txEn),
        .i_rxEn         (r_rxEn),

        .i_baudDiv      (r_baudDiv),

        .i_data7        (r_data7),
        .i_parityMode   (r_parityMode),
        .i_stop2        (r_stop2),
        .i_loopbackEn   (r_loopbackEn),

        .i_txWrEn       (r_txWrEn),
        .i_txData       (r_txData),

        .i_rxRdEn       (r_rxRdEn),

        .i_uartRx       (r_uartRx),
        .o_uartTx       (w_uartTx),

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


// 48 MHz Clock
always #10.41667 clk = ~clk;


// TX FIFO Write
task tx_write;

        input [7:0] data;

        begin

                @(negedge clk);

                r_txData = data;
                r_txWrEn = 1'b1;


                @(negedge clk);

                r_txWrEn = 1'b0;

        end

endtask


// RX FIFO Read
task rx_read_check;

        input [7:0] expectedData;

        begin

                @(negedge clk);

                r_rxRdEn = 1'b1;


                @(negedge clk);

                r_rxRdEn = 1'b0;


                #1;


                if (w_rxData !== expectedData) begin

                        $display(
                                "FAIL: RX expected=%02h actual=%02h",
                                expectedData,
                                w_rxData
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: RX expected=%02h actual=%02h",
                                expectedData,
                                w_rxData
                        );

                end

        end

endtask


initial begin

        $dumpfile("uart_core_v3_enable.vcd");
        $dumpvars(0, tb_uart_core);


        clk             = 1'b0;
        rst_n           = 1'b0;

        r_enable        = 1'b0;
        r_txEn          = 1'b0;
        r_rxEn          = 1'b0;

        r_baudDiv       = BAUD_DIV;

        r_data7         = 1'b0;
        r_parityMode    = PARITY_NONE;
        r_stop2         = 1'b0;
        r_loopbackEn    = 1'b1;

        r_txWrEn        = 1'b0;
        r_txData        = 8'd0;

        r_rxRdEn        = 1'b0;

        r_uartRx        = 1'b1;

        r_errorCnt      = 0;


        // Reset
        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        repeat (3)
                @(posedge clk);


        $display("");
        $display("========================================");
        $display(" UART V3 TX_EN / RX_EN TEST");
        $display("========================================");


        // =================================================
        // TEST 0 : UART ENABLE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 0 : UART ENABLE");
        $display("----------------------------------------");


        r_enable = 1'b1;
        r_txEn   = 1'b1;
        r_rxEn   = 1'b1;


        repeat (3)
                @(posedge clk);


        if (w_uartTx !== 1'b1) begin

                $display(
                        "FAIL: UART TX IDLE"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: UART TX IDLE = 1"
                );

        end


        // =================================================
        // TEST 1 : TX DISABLE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : TX DISABLE");
        $display("----------------------------------------");


        r_txEn = 1'b0;


        tx_write(
                8'h33
        );


        repeat (20)
                @(posedge clk);


        if (w_txFifoCount !== 5'd0) begin

                $display(
                        "FAIL: TX FIFO COUNT = %0d",
                        w_txFifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX WRITE BLOCKED"
                );

        end


        if (w_uartTx !== 1'b1) begin

                $display(
                        "FAIL: TX LINE should stay HIGH"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX LINE = IDLE"
                );

        end


        // =================================================
        // TEST 2 : RX DISABLE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : RX DISABLE");
        $display("----------------------------------------");


        r_txEn = 1'b1;
        r_rxEn = 1'b0;


        tx_write(
                8'h55
        );


        wait (
                w_txBusy
        );


        wait (
                !w_txBusy
        );


        repeat (10)
                @(posedge clk);


        if (w_rxFifoCount !== 5'd0) begin

                $display(
                        "FAIL: RX FIFO COUNT expected=0 actual=%0d",
                        w_rxFifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX DATA IGNORED"
                );

        end


        // =================================================
        // TEST 3 : TX + RX ENABLE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : TX + RX ENABLE");
        $display("----------------------------------------");


        r_txEn = 1'b1;
        r_rxEn = 1'b1;


        tx_write(
                8'h5A
        );


        wait (
                w_rxFifoCount == 5'd1
        );


        repeat (3)
                @(posedge clk);


        if (w_rxFifoCount !== 5'd1) begin

                $display(
                        "FAIL: RX FIFO COUNT expected=1 actual=%0d",
                        w_rxFifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO COUNT = 1"
                );

        end


        rx_read_check(
                8'h5A
        );


        repeat (3)
                @(posedge clk);


        // =================================================
        // TEST 4 : UART DISABLE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : UART DISABLE");
        $display("----------------------------------------");


        r_enable = 1'b0;


        tx_write(
                8'hAA
        );


        repeat (20)
                @(posedge clk);


        if (w_txFifoCount !== 5'd0) begin

                $display(
                        "FAIL: UART DISABLE TX FIFO COUNT = %0d",
                        w_txFifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: UART DISABLE BLOCKS TX"
                );

        end


        if (w_uartTx !== 1'b1) begin

                $display(
                        "FAIL: UART DISABLE TX LINE"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: UART DISABLE TX LINE = IDLE"
                );

        end


        // =================================================
        // RESULT
        // =================================================
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V3 TX_EN / RX_EN: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V3 TX_EN / RX_EN: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");

        end


        #100;

        $finish;

end


// Timeout
initial begin

        #30000000;

        $display("");
        $display("========================================");
        $display(" UART V3 TX_EN / RX_EN: TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule
