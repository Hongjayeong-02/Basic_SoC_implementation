`timescale 1ns/1ps

module tb_uart_rx;

localparam BAUD_DIV = 16'd312;

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

wire            w_tick16;

wire    [7:0]   w_rxData;
wire            w_rxValid;
wire            w_rxBusy;

wire            w_parityErr;
wire            w_frameErr;
wire            w_falseStart;

integer         r_errorCnt;


uart_baud_gen uut_baud_gen (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_enable       (r_enable),
        .i_baudDiv      (r_baudDiv),

        .o_tick16       (w_tick16)
);


uart_rx uut_rx (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_tick16       (w_tick16),
        .i_uartRx       (r_uartRx),

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


// 48 MHz Clock
always #10.41667 clk = ~clk;


// UART Frame Transmission and RX Verification
task send_and_check;

        input   [7:0]   data;
        input           data7;
        input   [1:0]   parityMode;
        input           stop2;

        input           badParity;
        input           badStop;

        integer         i;
        integer         dataBitCount;
        integer         previousErrorCount;

        reg             parityBit;
        reg             expectedParityErr;
        reg             expectedFrameErr;
        reg     [7:0]   expectedData;

        begin

                previousErrorCount = r_errorCnt;

                r_data7         = data7;
                r_parityMode    = parityMode;
                r_stop2         = stop2;


                if (data7)
                        dataBitCount = 7;
                else
                        dataBitCount = 8;


                if (data7)
                        expectedData = {1'b0, data[6:0]};
                else
                        expectedData = data;


                if (parityMode == PARITY_EVEN) begin

                        if (data7)
                                parityBit = ^data[6:0];
                        else
                                parityBit = ^data[7:0];

                end else if (parityMode == PARITY_ODD) begin

                        if (data7)
                                parityBit = ~^data[6:0];
                        else
                                parityBit = ~^data[7:0];

                end else begin
                        parityBit = 1'b0;
                end


                if (
                        badParity &&
                        (parityMode != PARITY_NONE)
                )
                        parityBit = ~parityBit;


                if (
                        badParity &&
                        (parityMode != PARITY_NONE)
                )
                        expectedParityErr = 1'b1;
                else
                        expectedParityErr = 1'b0;


                if (badStop)
                        expectedFrameErr = 1'b1;
                else
                        expectedFrameErr = 1'b0;


                wait (!w_rxBusy);

                @(negedge w_tick16);


                // Start Bit
                r_uartRx = 1'b0;

                repeat (16)
                        @(negedge w_tick16);


                // Data Bits
                for (
                        i = 0;
                        i < dataBitCount;
                        i = i + 1
                ) begin

                        r_uartRx = data[i];

                        repeat (16)
                                @(negedge w_tick16);

                end


                // Parity Bit
                if (parityMode != PARITY_NONE) begin

                        r_uartRx = parityBit;

                        repeat (16)
                                @(negedge w_tick16);

                end


                // First Stop Bit
                if (badStop)
                        r_uartRx = 1'b0;
                else
                        r_uartRx = 1'b1;

                repeat (16)
                        @(negedge w_tick16);


                // Second Stop Bit
                if (stop2) begin

                        r_uartRx = 1'b1;

                        repeat (16)
                                @(negedge w_tick16);

                end


                r_uartRx = 1'b1;


                wait (w_rxValid);

                #1;


                // RX Data Check
                if (w_rxData !== expectedData) begin

                        $display(
                                "FAIL: RX data expected=%02h actual=%02h",
                                expectedData,
                                w_rxData
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // Parity Error Check
                if (w_parityErr !== expectedParityErr) begin

                        $display(
                                "FAIL: parityErr expected=%b actual=%b",
                                expectedParityErr,
                                w_parityErr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // Frame Error Check
                if (w_frameErr !== expectedFrameErr) begin

                        $display(
                                "FAIL: frameErr expected=%b actual=%b",
                                expectedFrameErr,
                                w_frameErr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                if (previousErrorCount == r_errorCnt) begin

                        $display(
                                "PASS: data=%02h data7=%b parity=%02b stop2=%b badParity=%b badStop=%b",
                                data,
                                data7,
                                parityMode,
                                stop2,
                                badParity,
                                badStop
                        );

                end else begin

                        $display(
                                "FAIL: data=%02h data7=%b parity=%02b stop2=%b badParity=%b badStop=%b",
                                data,
                                data7,
                                parityMode,
                                stop2,
                                badParity,
                                badStop
                        );

                end


                @(posedge clk);

        end

endtask


// False Start Verification
task check_false_start;

        integer previousErrorCount;

        begin

                previousErrorCount = r_errorCnt;

                wait (!w_rxBusy);

                @(negedge w_tick16);


                // Short LOW Pulse
                r_uartRx = 1'b0;

                repeat (4)
                        @(negedge w_tick16);


                // Return HIGH Before Center Sampling
                r_uartRx = 1'b1;


                wait (w_falseStart);

                #1;


                if (!w_falseStart) begin

                        $display(
                                "FAIL: False Start was not detected"
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                if (w_rxValid) begin

                        $display(
                                "FAIL: rxValid asserted during False Start"
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                if (previousErrorCount == r_errorCnt) begin

                        $display(
                                "PASS: FALSE START DETECTION"
                        );

                end else begin

                        $display(
                                "FAIL: FALSE START DETECTION"
                        );

                end


                @(posedge clk);

        end

endtask


initial begin

        $dumpfile("uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);


        clk             = 1'b0;
        rst_n           = 1'b0;

        r_enable        = 1'b0;
        r_baudDiv       = BAUD_DIV;

        r_uartRx        = 1'b1;

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


        // 8-bit / 1 Stop
        send_and_check(
                8'h55,
                1'b0,
                PARITY_NONE,
                1'b0,
                1'b0,
                1'b0
        );

        send_and_check(
                8'h55,
                1'b0,
                PARITY_EVEN,
                1'b0,
                1'b0,
                1'b0
        );

        send_and_check(
                8'h55,
                1'b0,
                PARITY_ODD,
                1'b0,
                1'b0,
                1'b0
        );


        // 8-bit / 2 Stop
        send_and_check(
                8'hAA,
                1'b0,
                PARITY_NONE,
                1'b1,
                1'b0,
                1'b0
        );

        send_and_check(
                8'hAA,
                1'b0,
                PARITY_EVEN,
                1'b1,
                1'b0,
                1'b0
        );

        send_and_check(
                8'hAA,
                1'b0,
                PARITY_ODD,
                1'b1,
                1'b0,
                1'b0
        );


        // 7-bit / 1 Stop
        send_and_check(
                8'h55,
                1'b1,
                PARITY_NONE,
                1'b0,
                1'b0,
                1'b0
        );

        send_and_check(
                8'h55,
                1'b1,
                PARITY_EVEN,
                1'b0,
                1'b0,
                1'b0
        );

        send_and_check(
                8'h55,
                1'b1,
                PARITY_ODD,
                1'b0,
                1'b0,
                1'b0
        );


        // 7-bit / 2 Stop
        send_and_check(
                8'h2A,
                1'b1,
                PARITY_NONE,
                1'b1,
                1'b0,
                1'b0
        );

        send_and_check(
                8'h2A,
                1'b1,
                PARITY_EVEN,
                1'b1,
                1'b0,
                1'b0
        );

        send_and_check(
                8'h2A,
                1'b1,
                PARITY_ODD,
                1'b1,
                1'b0,
                1'b0
        );


        // Wrong Even Parity
        send_and_check(
                8'h5A,
                1'b0,
                PARITY_EVEN,
                1'b0,
                1'b1,
                1'b0
        );


        // Wrong Odd Parity
        send_and_check(
                8'h35,
                1'b1,
                PARITY_ODD,
                1'b0,
                1'b1,
                1'b0
        );


        // Frame Error
        send_and_check(
                8'hA5,
                1'b0,
                PARITY_NONE,
                1'b0,
                1'b0,
                1'b1
        );


        // False Start
        check_false_start;


        // Final Result
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V2 CONFIGURABLE RX: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V2 CONFIGURABLE RX: %0d ERROR(S)",
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

        #50000000;

        $display("");
        $display("========================================");
        $display(" FAIL: SIMULATION TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end

endmodule

