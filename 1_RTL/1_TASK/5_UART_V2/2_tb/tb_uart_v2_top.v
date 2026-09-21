`timescale 1ns/1ps

module tb_uart_v2_top;


// =========================================================
// Register Address
// =========================================================
localparam ADDR_CTRL        = 8'h00;
localparam ADDR_BAUDDIV     = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_TXDATA      = 8'h0C;
localparam ADDR_RXDATA      = 8'h10;
localparam ADDR_ERRCLR      = 8'h14;

localparam ADDR_IRQ_EN      = 8'h18;
localparam ADDR_IRQ_STATUS  = 8'h1C;
localparam ADDR_IRQ_CLEAR   = 8'h20;


// =========================================================
// UART Configuration
// =========================================================
localparam CTRL_8N1 = 32'h0000_0001;
localparam CTRL_8E1 = 32'h0000_0005;
localparam CTRL_8O1 = 32'h0000_0009;

localparam CTRL_8N2 = 32'h0000_0011;
localparam CTRL_8E2 = 32'h0000_0015;
localparam CTRL_8O2 = 32'h0000_0019;

localparam CTRL_7N1 = 32'h0000_0003;
localparam CTRL_7E1 = 32'h0000_0007;
localparam CTRL_7O1 = 32'h0000_000B;

localparam CTRL_7N2 = 32'h0000_0013;
localparam CTRL_7E2 = 32'h0000_0017;
localparam CTRL_7O2 = 32'h0000_001B;


// =========================================================
// Parity
// =========================================================
localparam PARITY_NONE = 2'b00;
localparam PARITY_EVEN = 2'b01;
localparam PARITY_ODD  = 2'b10;


// =========================================================
// Baud Divider
// =========================================================
localparam BAUD_DIV = 16'd312;


// =========================================================
// Signals
// =========================================================
reg             clk;
reg             rst_n;

reg             r_psel;
reg             r_penable;
reg             r_pwrite;

reg     [7:0]   r_paddr;
reg     [31:0]  r_pwdata;

wire    [31:0]  w_prdata;
wire            w_pready;
wire            w_pslverr;

reg             r_loopbackEn;
reg             r_uartRxDrive;

wire            w_uartRx;
wire            w_uartTx;

wire            w_irq;

integer         r_errorCnt;
integer         i;

reg     [31:0]  r_readData;


// =========================================================
// UART RX Input MUX
// =========================================================
assign w_uartRx =
        r_loopbackEn ?
        w_uartTx :
        r_uartRxDrive;


// =========================================================
// DUT
// =========================================================
uart_v2_top uut (
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

        .i_uartRx       (w_uartRx),
        .o_uartTx       (w_uartTx),

        .o_irq          (w_irq)
);


// =========================================================
// 48 MHz Clock
// =========================================================
always #10.41667 clk = ~clk;


// =========================================================
// Reset
// =========================================================
task apply_reset;

        begin

                r_psel        = 1'b0;
                r_penable     = 1'b0;
                r_pwrite      = 1'b0;

                r_paddr       = 8'd0;
                r_pwdata      = 32'd0;

                r_loopbackEn  = 1'b1;
                r_uartRxDrive = 1'b1;

                rst_n = 1'b0;

                repeat (5)
                        @(posedge clk);

                rst_n = 1'b1;

                repeat (3)
                        @(posedge clk);

        end

endtask


// =========================================================
// APB Write
// =========================================================
task apb_write;

        input   [7:0]   addr;
        input   [31:0]  data;

        reg             sampledError;

        begin

                sampledError = 1'b0;

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


                sampledError = w_pslverr;


                if (sampledError) begin

                        $display(
                                "FAIL: APB WRITE addr=%02h data=%08h",
                                addr,
                                data
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
// APB Write - Expected Error
// =========================================================
task apb_write_error;

        input   [7:0]   addr;
        input   [31:0]  data;

        reg             sampledError;

        begin

                sampledError = 1'b0;


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


                sampledError = w_pslverr;


                if (!sampledError) begin

                        $display(
                                "FAIL: FIFO FULL WRITE was not blocked"
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: FIFO FULL WRITE BLOCKED"
                        );

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
// APB Read
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
                r_pwdata  = 32'd0;

        end

endtask


// =========================================================
// Wait RX FIFO Count
// =========================================================
task wait_rx_count;

        input [4:0] count;

        begin

                wait (
                        uut.uut_uart_apb.w_rxFifoCount ==
                        count
                );

                repeat (3)
                        @(posedge clk);

        end

endtask


// =========================================================
// Wait UART Idle
// =========================================================
task wait_uart_idle;

        begin

                wait (
                        uut.uut_uart_apb.w_txFifoEmpty
                );

                wait (
                        !uut.uut_uart_apb.w_txBusy
                );

                wait (
                        !uut.uut_uart_apb.w_rxBusy
                );

                repeat (4)
                        @(posedge clk);

        end

endtask


// =========================================================
// RX FIFO Read + Check
// =========================================================
task rx_read_check;

        input [7:0] expectedData;

        reg [31:0] readData;

        begin

                apb_read(
                        ADDR_RXDATA,
                        readData
                );


                if (readData[7:0] !== expectedData) begin

                        $display(
                                "FAIL: RX expected=%02h actual=%02h",
                                expectedData,
                                readData[7:0]
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: RX expected=%02h actual=%02h",
                                expectedData,
                                readData[7:0]
                        );

                end

        end

endtask


// =========================================================
// UART Mode Regression
// =========================================================
task run_uart_mode;

        input   integer testNumber;

        input   [31:0]  ctrl;

        input   [7:0]   txData0;
        input   [7:0]   txData1;

        input   [7:0]   expected0;
        input   [7:0]   expected1;

        begin

                $display("");
                $display("----------------------------------------");
                $display(
                        " TEST %0d : UART MODE CTRL=%02h",
                        testNumber,
                        ctrl[4:0]
                );
                $display("----------------------------------------");


                apb_write(
                        ADDR_CTRL,
                        ctrl
                );


                apb_write(
                        ADDR_TXDATA,
                        {24'd0, txData0}
                );


                apb_write(
                        ADDR_TXDATA,
                        {24'd0, txData1}
                );


                wait_rx_count(
                        5'd2
                );


                wait_uart_idle;


                rx_read_check(
                        expected0
                );


                rx_read_check(
                        expected1
                );


                if (
                        uut.uut_uart_apb.w_rxFifoEmpty !==
                        1'b1
                ) begin

                        $display(
                                "FAIL: RX FIFO should be EMPTY"
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: RX FIFO EMPTY"
                        );

                end

        end

endtask


// =========================================================
// External UART Frame Injection
// =========================================================
task drive_uart_frame;

        input   [7:0]   data;
        input   [1:0]   parityMode;

        input           badParity;
        input           badStop;

        integer         bitIndex;

        reg             parityBit;

        begin

                r_loopbackEn  = 1'b0;
                r_uartRxDrive = 1'b1;


                repeat (5)
                        @(posedge clk);


                // -----------------------------------------
                // Parity Calculation
                // -----------------------------------------
                if (parityMode == PARITY_EVEN)
                        parityBit = ^data;

                else if (parityMode == PARITY_ODD)
                        parityBit = ~^data;

                else
                        parityBit = 1'b0;


                if (
                        badParity &&
                        (parityMode != PARITY_NONE)
                )
                        parityBit = ~parityBit;


                // -----------------------------------------
                // Tick Alignment
                // -----------------------------------------
                @(negedge
                        uut.uut_uart_apb
                           .uut_uart_core
                           .w_tick16
                );


                // -----------------------------------------
                // Start Bit
                // -----------------------------------------
                r_uartRxDrive = 1'b0;


                repeat (16)
                        @(negedge
                                uut.uut_uart_apb
                                   .uut_uart_core
                                   .w_tick16
                        );


                // -----------------------------------------
                // Data Bits
                // -----------------------------------------
                for (
                        bitIndex = 0;
                        bitIndex < 8;
                        bitIndex = bitIndex + 1
                ) begin

                        r_uartRxDrive =
                                data[bitIndex];


                        repeat (16)
                                @(negedge
                                        uut.uut_uart_apb
                                           .uut_uart_core
                                           .w_tick16
                                );

                end


                // -----------------------------------------
                // Parity Bit
                // -----------------------------------------
                if (parityMode != PARITY_NONE) begin

                        r_uartRxDrive =
                                parityBit;


                        repeat (16)
                                @(negedge
                                        uut.uut_uart_apb
                                           .uut_uart_core
                                           .w_tick16
                                );

                end


                // -----------------------------------------
                // Normal Stop Bit
                // -----------------------------------------
                if (!badStop) begin

                        r_uartRxDrive = 1'b1;


                        repeat (16)
                                @(negedge
                                        uut.uut_uart_apb
                                           .uut_uart_core
                                           .w_tick16
                                );

                end else begin

                        // ---------------------------------
                        // Frame Error Injection
                        // ---------------------------------

                        // Invalid stop bit
                        r_uartRxDrive = 1'b0;


                        // Wait until RX STOP state reaches
                        // the final sampling interval.
                        wait (
                                (
                                        uut.uut_uart_apb
                                           .uut_uart_core
                                           .uut_rx_fifo
                                           .uut_rx
                                           .r_state ==
                                        3'd4
                                ) &&
                                (
                                        uut.uut_uart_apb
                                           .uut_uart_core
                                           .uut_rx_fifo
                                           .uut_rx
                                           .r_tickCnt ==
                                        4'd15
                                )
                        );


                        // Wait for next tick pulse.
                        @(posedge
                                uut.uut_uart_apb
                                   .uut_uart_core
                                   .w_tick16
                        );


                        // External RX goes HIGH.
                        //
                        // Due to 2-FF synchronizer,
                        // internal r_rxSync is still LOW
                        // when STOP bit is sampled.
                        r_uartRxDrive = 1'b1;


                        // Confirm Frame Error
                        wait (
                                uut.uut_uart_apb.w_frameErr
                        );


                        repeat (5)
                                @(posedge clk);

                end


                // -----------------------------------------
                // Return Idle
                // -----------------------------------------
                r_uartRxDrive = 1'b1;


                wait (
                        !uut.uut_uart_apb.w_rxBusy
                );


                repeat (5)
                        @(posedge clk);

        end

endtask


// =========================================================
// False Start Injection
// =========================================================
task inject_false_start;

        begin

                r_loopbackEn  = 1'b0;
                r_uartRxDrive = 1'b1;


                repeat (5)
                        @(posedge clk);


                @(negedge
                        uut.uut_uart_apb
                           .uut_uart_core
                           .w_tick16
                );


                r_uartRxDrive = 1'b0;


                repeat (4)
                        @(negedge
                                uut.uut_uart_apb
                                   .uut_uart_core
                                   .w_tick16
                        );


                r_uartRxDrive = 1'b1;


                wait (
                        uut.uut_uart_apb.w_falseStart
                );


                repeat (5)
                        @(posedge clk);

        end

endtask


// =========================================================
// Main Test
// =========================================================
initial begin

        $dumpfile("uart_v2_top.vcd");
        $dumpvars(0, tb_uart_v2_top);


        clk             = 1'b0;
        rst_n           = 1'b0;

        r_psel          = 1'b0;
        r_penable       = 1'b0;
        r_pwrite        = 1'b0;

        r_paddr         = 8'd0;
        r_pwdata        = 32'd0;

        r_loopbackEn    = 1'b1;
        r_uartRxDrive   = 1'b1;

        r_errorCnt      = 0;
        r_readData      = 32'd0;


        apply_reset;


        $display("");
        $display("========================================");
        $display(" UART V2 FINAL REGRESSION START");
        $display("========================================");


        // =================================================
        // TEST 0 : REGISTER RESET
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 0 : REGISTER RESET");
        $display("----------------------------------------");


        apb_read(
                ADDR_CTRL,
                r_readData
        );


        if (r_readData[4:0] !== 5'b00000) begin

                $display(
                        "FAIL: CTRL RESET = %08h",
                        r_readData
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: CTRL RESET"
                );

        end


        apb_read(
                ADDR_BAUDDIV,
                r_readData
        );


        if (r_readData[15:0] !== BAUD_DIV) begin

                $display(
                        "FAIL: BAUDDIV expected=%0d actual=%0d",
                        BAUD_DIV,
                        r_readData[15:0]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: BAUDDIV = %0d",
                        r_readData[15:0]
                );

        end


        apb_read(
                ADDR_IRQ_EN,
                r_readData
        );


        if (r_readData[4:0] !== 5'b00000) begin

                $display(
                        "FAIL: IRQ_EN RESET"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: IRQ_EN RESET"
                );

        end


        // =================================================
        // TEST 1 : TX FIFO FULL
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : TX FIFO FULL");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                32'h0000_0000
        );


        i = 0;


        while (
                (
                        !uut.uut_uart_apb.w_txFifoFull
                ) &&
                (i < 32)
        ) begin

                apb_write(
                        ADDR_TXDATA,
                        i
                );

                i = i + 1;

        end


        if (
                uut.uut_uart_apb.w_txFifoFull !==
                1'b1
        ) begin

                $display(
                        "FAIL: TX FIFO did not become FULL"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX FIFO FULL = 1"
                );

        end


        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (r_readData[1] !== 1'b1) begin

                $display(
                        "FAIL: STATUS TX FIFO FULL = 0"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: STATUS TX FIFO FULL = 1"
                );

        end


        if (r_readData[20:16] !== 5'd16) begin

                $display(
                        "FAIL: TX FIFO COUNT expected=16 actual=%0d",
                        r_readData[20:16]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX FIFO COUNT = 16"
                );

        end


        apb_write_error(
                ADDR_TXDATA,
                32'h0000_00FF
        );


        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (r_readData[20:16] !== 5'd16) begin

                $display(
                        "FAIL: FIFO COUNT changed after blocked write"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FIFO COUNT REMAINS 16"
                );

        end


        apply_reset;


        // =================================================
        // TEST 2 : APB REGISTER READ / WRITE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : APB REGISTER READ / WRITE");
        $display("----------------------------------------");


        apb_write(
                ADDR_BAUDDIV,
                BAUD_DIV
        );


        apb_write(
                ADDR_CTRL,
                CTRL_8N1
        );


        apb_read(
                ADDR_CTRL,
                r_readData
        );


        if (
                r_readData[4:0] !==
                CTRL_8N1[4:0]
        ) begin

                $display(
                        "FAIL: CTRL READ / WRITE"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: CTRL READ / WRITE"
                );

        end


        apb_read(
                ADDR_BAUDDIV,
                r_readData
        );


        if (
                r_readData[15:0] !==
                BAUD_DIV
        ) begin

                $display(
                        "FAIL: BAUDDIV READ / WRITE"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: BAUDDIV READ / WRITE"
                );

        end


        // =================================================
        // TEST 3 : TX EMPTY IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : TX EMPTY IRQ");
        $display("----------------------------------------");


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0002
        );


        #1;


        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: TX EMPTY IRQ expected=1"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX EMPTY IRQ = 1"
                );

        end


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0000
        );


        #1;


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: IRQ DISABLE"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: IRQ DISABLE"
                );

        end


        // =================================================
        // TEST 4 : RX FIFO IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : RX FIFO IRQ");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_8N1
        );


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0001
        );


        apb_write(
                ADDR_TXDATA,
                32'h0000_0055
        );


        wait_rx_count(
                5'd1
        );


        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: RX FIFO IRQ expected=1"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO IRQ = 1"
                );

        end


        rx_read_check(
                8'h55
        );


        repeat (3)
                @(posedge clk);


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: RX IRQ should clear when FIFO empty"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX IRQ CLEAR BY FIFO EMPTY"
                );

        end


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0000
        );


        // =================================================
        // TEST 5 : 8N1
        // =================================================
        run_uart_mode(
                5,
                CTRL_8N1,
                8'h55,
                8'hAA,
                8'h55,
                8'hAA
        );


        // =================================================
        // TEST 6 : 8E1
        // =================================================
        run_uart_mode(
                6,
                CTRL_8E1,
                8'h5A,
                8'hA5,
                8'h5A,
                8'hA5
        );


        // =================================================
        // TEST 7 : 8O1
        // =================================================
        run_uart_mode(
                7,
                CTRL_8O1,
                8'h3C,
                8'hC3,
                8'h3C,
                8'hC3
        );


        // =================================================
        // TEST 8 : 8N2
        // =================================================
        run_uart_mode(
                8,
                CTRL_8N2,
                8'h96,
                8'h69,
                8'h96,
                8'h69
        );


        // =================================================
        // TEST 9 : 8E2
        // =================================================
        run_uart_mode(
                9,
                CTRL_8E2,
                8'h12,
                8'h34,
                8'h12,
                8'h34
        );


        // =================================================
        // TEST 10 : 8O2
        // =================================================
        run_uart_mode(
                10,
                CTRL_8O2,
                8'hF0,
                8'h0F,
                8'hF0,
                8'h0F
        );


        // =================================================
        // TEST 11 : 7N1
        // =================================================
        run_uart_mode(
                11,
                CTRL_7N1,
                8'hD5,
                8'hAA,
                8'h55,
                8'h2A
        );


        // =================================================
        // TEST 12 : 7E1
        // =================================================
        run_uart_mode(
                12,
                CTRL_7E1,
                8'hC3,
                8'hB6,
                8'h43,
                8'h36
        );


        // =================================================
        // TEST 13 : 7O1
        // =================================================
        run_uart_mode(
                13,
                CTRL_7O1,
                8'hCD,
                8'h95,
                8'h4D,
                8'h15
        );


        // =================================================
        // TEST 14 : 7N2
        // =================================================
        run_uart_mode(
                14,
                CTRL_7N2,
                8'hFE,
                8'h81,
                8'h7E,
                8'h01
        );


        // =================================================
        // TEST 15 : 7E2
        // =================================================
        run_uart_mode(
                15,
                CTRL_7E2,
                8'hEB,
                8'hA7,
                8'h6B,
                8'h27
        );


        // =================================================
        // TEST 16 : 7O2
        // =================================================
        run_uart_mode(
                16,
                CTRL_7O2,
                8'hCC,
                8'hBD,
                8'h4C,
                8'h3D
        );


        // =================================================
        // TEST 17 : PARITY ERROR + IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 17 : PARITY ERROR + IRQ");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_8E1
        );


        apb_write(
                ADDR_IRQ_CLEAR,
                32'h0000_001C
        );


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0004
        );


        drive_uart_frame(
                8'h5A,
                PARITY_EVEN,
                1'b1,
                1'b0
        );


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        if (r_readData[2] !== 1'b1) begin

                $display(
                        "FAIL: PARITY IRQ STATUS"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: PARITY IRQ STATUS = 1"
                );

        end


        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: PARITY IRQ expected=1"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: PARITY IRQ = 1"
                );

        end


        rx_read_check(
                8'h5A
        );


        apb_write(
                ADDR_IRQ_CLEAR,
                32'h0000_0004
        );


        repeat (3)
                @(posedge clk);


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: PARITY IRQ CLEAR"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: PARITY IRQ CLEAR"
                );

        end


        // =================================================
        // TEST 18 : FRAME ERROR + IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 18 : FRAME ERROR + IRQ");
        $display("----------------------------------------");


        apb_write(
                ADDR_IRQ_CLEAR,
                32'h0000_001C
        );


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0008
        );


        drive_uart_frame(
                8'hA5,
                PARITY_EVEN,
                1'b0,
                1'b1
        );


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        if (r_readData[3] !== 1'b1) begin

                $display(
                        "FAIL: FRAME IRQ STATUS"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FRAME IRQ STATUS = 1"
                );

        end


        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: FRAME IRQ expected=1"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FRAME IRQ = 1"
                );

        end


        if (
                uut.uut_uart_apb.w_rxFifoEmpty ==
                1'b0
        ) begin

                rx_read_check(
                        8'hA5
                );

        end else begin

                $display(
                        "FAIL: FRAME ERROR DATA missing from RX FIFO"
                );

                r_errorCnt = r_errorCnt + 1;

        end


        apb_write(
                ADDR_IRQ_CLEAR,
                32'h0000_001C
        );


        repeat (3)
                @(posedge clk);


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: FRAME IRQ CLEAR"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FRAME IRQ CLEAR"
                );

        end


        // =================================================
        // TEST 19 : FALSE START + IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 19 : FALSE START + IRQ");
        $display("----------------------------------------");


        apb_write(
                ADDR_IRQ_CLEAR,
                32'h0000_001C
        );


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0010
        );


        inject_false_start;


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        if (r_readData[4] !== 1'b1) begin

                $display(
                        "FAIL: FALSE START IRQ STATUS"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FALSE START IRQ STATUS = 1"
                );

        end


        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: FALSE START IRQ expected=1"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FALSE START IRQ = 1"
                );

        end


        apb_write(
                ADDR_IRQ_CLEAR,
                32'h0000_0010
        );


        repeat (3)
                @(posedge clk);


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: FALSE START IRQ CLEAR"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FALSE START IRQ CLEAR"
                );

        end


        // =================================================
        // Return to Loopback
        // =================================================
        r_loopbackEn  = 1'b1;
        r_uartRxDrive = 1'b1;


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0000
        );


        apb_write(
                ADDR_IRQ_CLEAR,
                32'h0000_001C
        );


        repeat (5)
                @(posedge clk);


        // =================================================
        // TEST 20 : FINAL STATUS
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 20 : FINAL STATUS");
        $display("----------------------------------------");


        wait_uart_idle;


        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (
                r_readData[20:16] !==
                5'd0
        ) begin

                $display(
                        "FAIL: FINAL TX FIFO COUNT = %0d",
                        r_readData[20:16]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FINAL TX FIFO COUNT = 0"
                );

        end


        if (
                r_readData[28:24] !==
                5'd0
        ) begin

                $display(
                        "FAIL: FINAL RX FIFO COUNT = %0d",
                        r_readData[28:24]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FINAL RX FIFO COUNT = 0"
                );

        end


        if (
                r_readData[9:7] !==
                3'b000
        ) begin

                $display(
                        "FAIL: FINAL ERROR STATUS = %03b",
                        r_readData[9:7]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FINAL ERROR STATUS = 000"
                );

        end


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        if (
                r_readData[4:0] !==
                5'b00010
        ) begin

                $display(
                        "FAIL: FINAL IRQ STATUS expected=00010 actual=%05b",
                        r_readData[4:0]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FINAL IRQ STATUS = 00010"
                );

        end


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: FINAL IRQ expected=0 actual=%b",
                        w_irq
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FINAL IRQ = 0"
                );

        end


        // =================================================
        // FINAL RESULT
        // =================================================
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V2 FINAL REGRESSION: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V2 FINAL REGRESSION: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");

        end


        #100;

        $finish;

end


// =========================================================
// Global Timeout
// =========================================================
initial begin

        #200000000;

        $display("");
        $display("========================================");
        $display(" FAIL: UART V2 FINAL SIMULATION TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule
