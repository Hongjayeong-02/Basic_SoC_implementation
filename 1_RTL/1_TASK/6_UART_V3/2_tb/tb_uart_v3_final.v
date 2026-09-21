`timescale 1ns/1ps

module tb_uart_v3_final;


localparam ADDR_TXDATA      = 8'h00;
localparam ADDR_RXDATA      = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_CTRL        = 8'h0C;
localparam ADDR_BAUDDIV     = 8'h10;
localparam ADDR_IRQ_EN      = 8'h14;
localparam ADDR_IRQ_STATUS  = 8'h18;
localparam ADDR_FIFO_LEVEL  = 8'h1C;


localparam CTRL_LOOPBACK_8N1 = 32'h0000_0087;
localparam CTRL_TX_LOOPBACK  = 32'h0000_0083;
localparam CTRL_RX_LOOPBACK  = 32'h0000_0085;

localparam CTRL_RX_8E1       = 32'h0000_000D;
localparam CTRL_LOOPBACK_7O2 = 32'h0000_00F7;


localparam BAUD_DIV = 16'd8;


reg             clk;
reg             rst_n;

reg             r_psel;
reg             r_penable;
reg             r_pwrite;

reg     [7:0]   r_paddr;
reg     [31:0]  r_pwdata;

reg             r_uartRx;


wire    [31:0]  w_prdata;
wire            w_pready;
wire            w_pslverr;

wire            w_uartTx;
wire            w_irq;


reg     [31:0]  r_readData;

integer         r_errorCnt;
integer         r_index;


// DUT
uart_apb uut (
        .clk            (clk),
        .rst_n          (rst_n),

        .i_psel         (r_psel),
        .i_penable      (r_penable),
        .i_pwrite       (r_pwrite),

        .i_paddr        (r_paddr),
        .i_pwdata       (r_pwdata),

        .o_prdata       (w_prdata),
        .o_pready       (w_pready),
        .o_pslverr      (w_pslverr),

        .i_uartRx       (r_uartRx),
        .o_uartTx       (w_uartTx),

        .o_irq          (w_irq)
);


// 48 MHz
always #10.41667 clk = ~clk;


// =========================================================
// DUT RESET
// =========================================================
task reset_dut;

        begin

                @(negedge clk);

                rst_n       = 1'b0;

                r_psel      = 1'b0;
                r_penable   = 1'b0;
                r_pwrite    = 1'b0;

                r_paddr     = 8'd0;
                r_pwdata    = 32'd0;

                r_uartRx    = 1'b1;


                repeat (5)
                        @(posedge clk);


                @(negedge clk);

                rst_n = 1'b1;


                repeat (5)
                        @(posedge clk);

        end

endtask


// =========================================================
// APB WRITE
// =========================================================
task apb_write;

        input [7:0]  addr;
        input [31:0] data;

        begin

                @(negedge clk);

                r_psel    = 1'b1;
                r_penable = 1'b0;
                r_pwrite  = 1'b1;

                r_paddr   = addr;
                r_pwdata  = data;


                @(negedge clk);

                r_penable = 1'b1;


                @(posedge clk);

                while (!w_pready)
                        @(posedge clk);


                if (w_pslverr) begin

                        $display(
                                "FAIL: APB WRITE addr=%02h",
                                addr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = 8'd0;
                r_pwdata  = 32'd0;

        end

endtask


// =========================================================
// APB READ
// =========================================================
task apb_read;

        input   [7:0]   addr;
        output  [31:0]  data;

        begin

                @(negedge clk);

                r_psel    = 1'b1;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = addr;
                r_pwdata  = 32'd0;


                @(negedge clk);

                r_penable = 1'b1;


                @(posedge clk);

                while (!w_pready)
                        @(posedge clk);


                #1;

                data = w_prdata;


                if (w_pslverr) begin

                        $display(
                                "FAIL: APB READ addr=%02h",
                                addr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = 8'd0;

        end

endtask


// =========================================================
// LOOPBACK SEND
// =========================================================
task loopback_send;

        input [7:0] data;
        input [4:0] expectedCount;

        begin

                wait (
                        !uut.w_txBusy
                );


                repeat (2)
                        @(posedge clk);


                apb_write(
                        ADDR_TXDATA,
                        {24'd0, data}
                );


                wait (
                        uut.w_rxFifoCount ==
                        expectedCount
                );


                wait (
                        !uut.w_txBusy
                );


                repeat (2)
                        @(posedge clk);

        end

endtask


// =========================================================
// RX DATA CHECK
// =========================================================
task rx_check;

        input [7:0] expectedData;
        input       expectedParity;
        input       expectedFrame;

        begin

                apb_read(
                        ADDR_RXDATA,
                        r_readData
                );


                if (
                        r_readData[7:0] !==
                        expectedData
                ) begin

                        $display(
                                "FAIL: RX expected=%02h actual=%02h",
                                expectedData,
                                r_readData[7:0]
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: RX DATA = %02h",
                                r_readData[7:0]
                        );

                end


                if (
                        r_readData[8] !==
                        expectedParity
                ) begin

                        $display(
                                "FAIL: PARITY META expected=%b actual=%b",
                                expectedParity,
                                r_readData[8]
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                if (
                        r_readData[9] !==
                        expectedFrame
                ) begin

                        $display(
                                "FAIL: FRAME META expected=%b actual=%b",
                                expectedFrame,
                                r_readData[9]
                        );

                        r_errorCnt = r_errorCnt + 1;

                end

        end

endtask


// =========================================================
// EXTERNAL UART FRAME
// EVEN PARITY
// =========================================================
task send_external_frame;

        input [7:0] data;
        input       badParity;
        input       badStop;

        integer     bitIndex;

        reg         parityBit;

        begin

                parityBit = ^data;


                if (badParity)
                        parityBit = ~parityBit;


                // Idle
                r_uartRx = 1'b1;


                repeat (3)
                        @(posedge
                                uut.uut_uart_core.w_tick16
                        );


                // Start
                @(negedge
                        uut.uut_uart_core.w_tick16
                );

                r_uartRx = 1'b0;


                repeat (16)
                        @(posedge
                                uut.uut_uart_core.w_tick16
                        );


                // Data
                for (
                        bitIndex = 0;
                        bitIndex < 8;
                        bitIndex = bitIndex + 1
                ) begin

                        @(negedge
                                uut.uut_uart_core.w_tick16
                        );

                        r_uartRx = data[bitIndex];


                        repeat (16)
                                @(posedge
                                        uut.uut_uart_core.w_tick16
                                );

                end


                // Parity
                @(negedge
                        uut.uut_uart_core.w_tick16
                );

                r_uartRx = parityBit;


                repeat (16)
                        @(posedge
                                uut.uut_uart_core.w_tick16
                        );


                // Stop
                @(negedge
                        uut.uut_uart_core.w_tick16
                );


                if (badStop)
                        r_uartRx = 1'b0;
                else
                        r_uartRx = 1'b1;


                repeat (16)
                        @(posedge
                                uut.uut_uart_core.w_tick16
                        );


                // Idle
                r_uartRx = 1'b1;


                repeat (4)
                        @(posedge
                                uut.uut_uart_core.w_tick16
                        );

        end

endtask


// =========================================================
// TEST
// =========================================================
initial begin

        $dumpfile("uart_v3_final.vcd");
        $dumpvars(0, tb_uart_v3_final);


        clk         = 1'b0;
        rst_n       = 1'b0;

        r_psel      = 1'b0;
        r_penable   = 1'b0;
        r_pwrite    = 1'b0;

        r_paddr     = 8'd0;
        r_pwdata    = 32'd0;

        r_uartRx    = 1'b1;

        r_readData  = 32'd0;

        r_errorCnt  = 0;


        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        repeat (5)
                @(posedge clk);


        $display("");
        $display("========================================");
        $display(" UART V3 FINAL REGRESSION");
        $display("========================================");


        // =================================================
        // TEST 0 : RESET
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 0 : RESET");
        $display("----------------------------------------");


        apb_read(
                ADDR_CTRL,
                r_readData
        );


        if (r_readData[7:0] !== 8'h00) begin

                $display(
                        "FAIL: CONTROL RESET"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: CONTROL RESET"
                );

        end


        apb_read(
                ADDR_BAUDDIV,
                r_readData
        );


        if (r_readData[15:0] !== 16'd325) begin

                $display(
                        "FAIL: BAUD RESET"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: BAUD RESET = 325"
                );

        end


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (r_readData[15:0] !== 16'd0) begin

                $display(
                        "FAIL: FIFO RESET"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FIFO RESET"
                );

        end


        // Fast Simulation Baud
        apb_write(
                ADDR_BAUDDIV,
                BAUD_DIV
        );


        // =================================================
        // TEST 1 : 8N1 LOOPBACK + RX IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : 8N1 LOOPBACK + RX IRQ");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_LOOPBACK_8N1
        );


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0001
        );


        loopback_send(
                8'h55,
                5'd1
        );


        loopback_send(
                8'hAA,
                5'd2
        );


        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: RX IRQ"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX IRQ = 1"
                );

        end


        rx_check(
                8'h55,
                1'b0,
                1'b0
        );


        rx_check(
                8'hAA,
                1'b0,
                1'b0
        );


        repeat (3)
                @(posedge clk);


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: RX IRQ CLEAR BY EMPTY"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX IRQ CLEAR BY EMPTY"
                );

        end


        // =================================================
        // TEST 2 : 7BIT / ODD / 2 STOP
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : 7BIT / ODD / 2 STOP");
        $display("----------------------------------------");


        apb_write(
                ADDR_IRQ_EN,
                32'd0
        );


        apb_write(
                ADDR_CTRL,
                CTRL_LOOPBACK_7O2
        );


        loopback_send(
                8'h55,
                5'd1
        );


        rx_check(
                8'h55,
                1'b0,
                1'b0
        );


        $display(
                "PASS: 7O2 LOOPBACK"
        );


        // =================================================
        // TEST 3 : TX_EN / RX_EN
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : TX_EN / RX_EN");
        $display("----------------------------------------");


        // TX Disable
        apb_write(
                ADDR_CTRL,
                CTRL_RX_LOOPBACK
        );


        apb_write(
                ADDR_TXDATA,
                32'h0000_0033
        );


        repeat (50)
                @(posedge clk);


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (r_readData[7:0] !== 8'd0) begin

                $display(
                        "FAIL: TX_EN BLOCK"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX_EN BLOCK"
                );

        end


        // RX Disable
        apb_write(
                ADDR_CTRL,
                CTRL_TX_LOOPBACK
        );


        apb_write(
                ADDR_TXDATA,
                32'h0000_0033
        );


        wait (
                uut.w_txBusy
        );


        wait (
                !uut.w_txBusy
        );


        repeat (10)
                @(posedge clk);


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (r_readData[15:8] !== 8'd0) begin

                $display(
                        "FAIL: RX_EN BLOCK"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX_EN BLOCK"
                );

        end


        // =================================================
        // TEST 4 : RX METADATA
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : RX METADATA");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_RX_8E1
        );


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_000C
        );


        // Parity Error
        send_external_frame(
                8'hA5,
                1'b1,
                1'b0
        );


        wait (
                uut.w_rxFifoCount ==
                5'd1
        );


        // Frame Error
        send_external_frame(
                8'h3C,
                1'b0,
                1'b1
        );


        wait (
                uut.w_rxFifoCount ==
                5'd2
        );


        r_uartRx = 1'b1;


        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: ERROR IRQ"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: ERROR IRQ"
                );

        end


        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (r_readData[7:6] !== 2'b11) begin

                $display(
                        "FAIL: ERROR STICKY STATUS = %02b",
                        r_readData[7:6]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: PARITY + FRAME STICKY"
                );

        end


        rx_check(
                8'hA5,
                1'b1,
                1'b0
        );


        rx_check(
                8'h3C,
                1'b0,
                1'b1
        );


        // Error Sticky Clear
        apb_write(
                ADDR_IRQ_STATUS,
                32'h0000_000C
        );


        repeat (3)
                @(posedge clk);


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        if (r_readData[3:2] !== 2'b00) begin

                $display(
                        "FAIL: ERROR RW1C"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: ERROR RW1C"
                );

        end


        // =================================================
        // TEST ISOLATION RESET
        //
        // Frame Error 주입 과정에서 생길 수 있는
        // 추가 RX Frame / False Start 상태를 제거하고
        // Overflow Test를 깨끗한 상태에서 시작
        // =================================================
        reset_dut();


        // Reset restores BAUD_DIV to its board default (325, tuned for
        // CORE-5300's 50MHz PL clock) - re-apply the fast simulation
        // baud setting for this testbench.
        apb_write(
                ADDR_BAUDDIV,
                BAUD_DIV
        );


        // =================================================
        // TEST 5 : RX OVERFLOW
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 5 : RX OVERFLOW");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_LOOPBACK_8N1
        );


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0010
        );


        // RX FIFO Depth = 8 (spec sec.8.3 / sec.16 default; uart_core's
        // RX_FIFO_DEPTH parameter default)
        for (
                r_index = 0;
                r_index < 8;
                r_index = r_index + 1
        ) begin

                loopback_send(
                        8'h40 + r_index,
                        r_index + 1
                );

        end


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (r_readData[15:8] !== 8'd8) begin

                $display(
                        "FAIL: RX FIFO DEPTH = %0d",
                        r_readData[15:8]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO DEPTH = 8"
                );

        end


        // 9th Byte
        // FIFO Full -> New Byte Drop
        wait (
                !uut.w_txBusy
        );


        repeat (2)
                @(posedge clk);


        apb_write(
                ADDR_TXDATA,
                32'h0000_00AA
        );


        wait (
                uut.w_txBusy
        );


        wait (
                !uut.w_txBusy
        );


        wait (
                uut.w_irqStatus[4] ==
                1'b1
        );


        repeat (3)
                @(posedge clk);


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (r_readData[15:8] !== 8'd8) begin

                $display(
                        "FAIL: OVERFLOW COUNT"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: NEW BYTE DROPPED"
                );

        end


        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: OVERFLOW IRQ"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: OVERFLOW IRQ"
                );

        end


        // Original 8 Bytes Preserved
        for (
                r_index = 0;
                r_index < 8;
                r_index = r_index + 1
        ) begin

                rx_check(
                        8'h40 + r_index,
                        1'b0,
                        1'b0
                );

        end


        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: OVERFLOW STICKY"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: OVERFLOW STICKY"
                );

        end


        apb_write(
                ADDR_IRQ_STATUS,
                32'h0000_0010
        );


        repeat (3)
                @(posedge clk);


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: OVERFLOW CLEAR"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: OVERFLOW CLEAR"
                );

        end


        // =================================================
        // TEST 6 : MID-TRAFFIC RESET
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 6 : MID-TRAFFIC RESET");
        $display("----------------------------------------");


        apb_write(
                ADDR_IRQ_EN,
                32'd0
        );


        apb_write(
                ADDR_CTRL,
                CTRL_LOOPBACK_8N1
        );


        apb_write(
                ADDR_TXDATA,
                32'h0000_005A
        );


        wait (
                uut.w_txBusy
        );


        // Reset while transmitting
        @(negedge clk);

        rst_n = 1'b0;


        repeat (5)
                @(posedge clk);


        @(negedge clk);

        rst_n = 1'b1;


        repeat (5)
                @(posedge clk);


        if (w_uartTx !== 1'b1) begin

                $display(
                        "FAIL: RESET TX LINE"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RESET TX LINE = IDLE"
                );

        end


        apb_read(
                ADDR_CTRL,
                r_readData
        );


        if (r_readData[7:0] !== 8'h00) begin

                $display(
                        "FAIL: RESET CONTROL"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RESET CONTROL"
                );

        end


        apb_read(
                ADDR_BAUDDIV,
                r_readData
        );


        if (r_readData[15:0] !== 16'd325) begin

                $display(
                        "FAIL: RESET BAUD"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RESET BAUD = 325"
                );

        end


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (r_readData[15:0] !== 16'd0) begin

                $display(
                        "FAIL: RESET FIFO LEVEL"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RESET FIFO LEVEL = 0"
                );

        end


        // =================================================
        // FINAL RESULT
        // =================================================
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V3 FINAL REGRESSION: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V3 FINAL REGRESSION: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");

        end


        #100;

        $finish;

end


// =========================================================
// TIMEOUT
// =========================================================
initial begin

        #100000000;

        $display("");
        $display("========================================");
        $display(" UART V3 FINAL REGRESSION: TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule

