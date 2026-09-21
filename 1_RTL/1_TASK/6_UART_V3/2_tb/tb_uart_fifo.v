`timescale 1ns/1ps

module tb_uart_rx_fifo;


localparam BAUD_DIV = 16'd8;

localparam PARITY_NONE = 2'b00;
localparam PARITY_EVEN = 2'b01;
localparam PARITY_ODD  = 2'b10;


reg             clk;
reg             rst_n;

reg             r_enable;
reg     [15:0]  r_baudDiv;

reg             r_uartRx;

reg             r_data7;
reg     [1:0]   r_parityMode;
reg             r_stop2;

reg             r_rdEn;


wire            w_tick16;

wire    [7:0]   w_rdData;
wire            w_rdParityErr;
wire            w_rdFrameErr;

wire            w_fifoFull;
wire            w_fifoEmpty;
wire    [4:0]   w_fifoCount;

wire            w_rxValid;
wire            w_rxBusy;

wire            w_parityErr;
wire            w_frameErr;
wire            w_falseStart;


integer         r_errorCnt;


// Baud Generator
uart_baud_gen uut_baud_gen (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_enable       (r_enable),
        .i_baudDiv      (r_baudDiv),

        .o_tick16       (w_tick16)
);


// RX FIFO
uart_rx_fifo uut (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (w_tick16),
        .i_uartRx       (r_uartRx),

        .i_data7        (r_data7),
        .i_parityMode   (r_parityMode),
        .i_stop2        (r_stop2),

        .i_rdEn         (r_rdEn),

        .o_rdData       (w_rdData),
        .o_rdParityErr  (w_rdParityErr),
        .o_rdFrameErr   (w_rdFrameErr),

        .o_fifoFull     (w_fifoFull),
        .o_fifoEmpty    (w_fifoEmpty),
        .o_fifoCount    (w_fifoCount),

        .o_rxValid      (w_rxValid),
        .o_rxBusy       (w_rxBusy),

        .o_parityErr    (w_parityErr),
        .o_frameErr     (w_frameErr),
        .o_falseStart   (w_falseStart)
);


// 48 MHz Clock
always #10.41667 clk = ~clk;


// ---------------------------------------------------------
// UART Frame Send
//
// badParity = 1
// -> wrong parity bit
//
// badStop = 1
// -> stop bit LOW
// ---------------------------------------------------------
task send_frame;

        input   [7:0]   data;
        input           badParity;
        input           badStop;

        integer         bitIndex;

        reg             parityBit;

        begin

                // Even Parity
                parityBit = ^data;


                if (badParity)
                        parityBit = ~parityBit;


                // Idle
                r_uartRx = 1'b1;

                repeat (3)
                        @(posedge w_tick16);


                // Start Bit
                @(negedge w_tick16);

                r_uartRx = 1'b0;


                repeat (16)
                        @(posedge w_tick16);


                // Data Bit
                for (
                        bitIndex = 0;
                        bitIndex < 8;
                        bitIndex = bitIndex + 1
                ) begin

                        @(negedge w_tick16);

                        r_uartRx = data[bitIndex];


                        repeat (16)
                                @(posedge w_tick16);

                end


                // Parity Bit
                @(negedge w_tick16);

                r_uartRx = parityBit;


                repeat (16)
                        @(posedge w_tick16);


                // Stop Bit
                @(negedge w_tick16);


                if (badStop)
                        r_uartRx = 1'b0;
                else
                        r_uartRx = 1'b1;


                repeat (16)
                        @(posedge w_tick16);


                // Return HIGH
                @(negedge w_tick16);

                r_uartRx = 1'b1;


                repeat (4)
                        @(posedge w_tick16);

        end

endtask


// FIFO Read Check
task fifo_read_check;

        input   [7:0]   expectedData;
        input           expectedParityErr;
        input           expectedFrameErr;

        begin

                @(negedge clk);

                r_rdEn = 1'b1;


                @(negedge clk);

                r_rdEn = 1'b0;


                #1;


                if (w_rdData !== expectedData) begin

                        $display(
                                "FAIL: DATA expected=%02h actual=%02h",
                                expectedData,
                                w_rdData
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: DATA = %02h",
                                w_rdData
                        );

                end


                if (
                        w_rdParityErr !==
                        expectedParityErr
                ) begin

                        $display(
                                "FAIL: PARITY expected=%b actual=%b",
                                expectedParityErr,
                                w_rdParityErr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: PARITY ERROR = %b",
                                w_rdParityErr
                        );

                end


                if (
                        w_rdFrameErr !==
                        expectedFrameErr
                ) begin

                        $display(
                                "FAIL: FRAME expected=%b actual=%b",
                                expectedFrameErr,
                                w_rdFrameErr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: FRAME ERROR = %b",
                                w_rdFrameErr
                        );

                end

        end

endtask


initial begin

        $dumpfile("uart_rx_fifo_v3.vcd");
        $dumpvars(0, tb_uart_rx_fifo);


        clk             = 1'b0;
        rst_n           = 1'b0;

        r_enable        = 1'b0;
        r_baudDiv       = BAUD_DIV;

        r_uartRx        = 1'b1;

        r_data7         = 1'b0;
        r_parityMode    = PARITY_EVEN;
        r_stop2         = 1'b0;

        r_rdEn          = 1'b0;

        r_errorCnt      = 0;


        // Reset
        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        r_enable = 1'b1;


        repeat (5)
                @(posedge clk);


        $display("");
        $display("========================================");
        $display(" UART V3 RX 10-BIT FIFO TEST");
        $display("========================================");


        // =================================================
        // TEST 1 : NORMAL DATA
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : NORMAL DATA");
        $display("----------------------------------------");


        send_frame(
                8'h5A,
                1'b0,
                1'b0
        );


        wait (
                w_fifoCount == 5'd1
        );


        $display(
                "PASS: RX FIFO COUNT = 1"
        );


        // =================================================
        // TEST 2 : PARITY ERROR DATA
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : PARITY ERROR DATA");
        $display("----------------------------------------");


        send_frame(
                8'hA5,
                1'b1,
                1'b0
        );


        wait (
                w_fifoCount == 5'd2
        );


        $display(
                "PASS: RX FIFO COUNT = 2"
        );


        // =================================================
        // TEST 3 : FRAME ERROR DATA
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : FRAME ERROR DATA");
        $display("----------------------------------------");


        send_frame(
                8'h3C,
                1'b0,
                1'b1
        );


        wait (
                w_fifoCount == 5'd3
        );


        // Line is restored HIGH immediately after bad stop.
        r_uartRx = 1'b1;


        $display(
                "PASS: RX FIFO COUNT = 3"
        );


        // =================================================
        // TEST 4 : FIFO ENTRY CHECK
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : 10-BIT FIFO ENTRY");
        $display("----------------------------------------");


        // Normal
        fifo_read_check(
                8'h5A,
                1'b0,
                1'b0
        );


        // Parity Error
        fifo_read_check(
                8'hA5,
                1'b1,
                1'b0
        );


        // Frame Error
        fifo_read_check(
                8'h3C,
                1'b0,
                1'b1
        );


        repeat (3)
                @(posedge clk);


        // =================================================
        // TEST 5 : FINAL STATUS
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 5 : FINAL STATUS");
        $display("----------------------------------------");


        if (w_fifoEmpty !== 1'b1) begin

                $display(
                        "FAIL: RX FIFO should be EMPTY"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO EMPTY"
                );

        end


        if (w_fifoCount !== 5'd0) begin

                $display(
                        "FAIL: RX FIFO COUNT = %0d",
                        w_fifoCount
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO COUNT = 0"
                );

        end


        // =================================================
        // RESULT
        // =================================================
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V3 RX 10-BIT FIFO: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V3 RX 10-BIT FIFO: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");

        end


        #100;

        $finish;

end


initial begin

        #50000000;

        $display("");
        $display("========================================");
        $display(" UART V3 RX 10-BIT FIFO: TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule
