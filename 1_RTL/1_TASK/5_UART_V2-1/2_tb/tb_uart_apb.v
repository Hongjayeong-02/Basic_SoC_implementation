`timescale 1ns/1ps

module tb_uart_apb;


localparam ADDR_CTRL        = 8'h00;
localparam ADDR_BAUDDIV     = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_TXDATA      = 8'h0C;
localparam ADDR_RXDATA      = 8'h10;
localparam ADDR_ERRCLR      = 8'h14;

localparam ADDR_IRQ_EN      = 8'h18;
localparam ADDR_IRQ_STATUS  = 8'h1C;
localparam ADDR_IRQ_CLEAR   = 8'h20;


localparam CTRL_8N1 = 32'h0000_0001;
localparam CTRL_8E2 = 32'h0000_0015;
localparam CTRL_7O1 = 32'h0000_000B;


reg             clk;
reg             rst_n;

reg             r_psel;
reg             r_penable;
reg             r_pwrite;

reg     [7:0]   r_paddr;
reg     [31:0]  r_pwdata;

reg             r_loopbackEn;
reg             r_uartRxDrive;


wire    [31:0]  w_prdata;
wire            w_pready;
wire            w_pslverr;

wire            w_uartTx;
wire            w_uartRx;

wire            w_irq;


integer         r_errorCnt;

reg     [31:0]  r_readData;


assign w_uartRx =
        r_loopbackEn ?
        w_uartTx :
        r_uartRxDrive;


// ---------------------------------------------------------
// DUT
// ---------------------------------------------------------
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

        .i_uartRx       (w_uartRx),
        .o_uartTx       (w_uartTx),

        .o_irq          (w_irq)
);


// ---------------------------------------------------------
// 48 MHz Clock
// ---------------------------------------------------------
always #10.41667 clk = ~clk;


// ---------------------------------------------------------
// APB Write
// ---------------------------------------------------------
task apb_write;

        input   [7:0]   addr;
        input   [31:0]  data;

        begin

                // Setup Phase
                @(negedge clk);

                r_psel    = 1'b1;
                r_penable = 1'b0;
                r_pwrite  = 1'b1;

                r_paddr   = addr;
                r_pwdata  = data;


                // Access Phase
                @(negedge clk);

                r_penable = 1'b1;


                @(posedge clk);

                while (!w_pready)
                        @(posedge clk);


                #1;


                if (w_pslverr) begin

                        $display(
                                "FAIL: APB WRITE ERROR addr=%02h data=%08h",
                                addr,
                                data
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // End Transfer
                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = 8'd0;
                r_pwdata  = 32'd0;

        end

endtask


// ---------------------------------------------------------
// APB Read
// ---------------------------------------------------------
task apb_read;

        input   [7:0]   addr;
        output  [31:0]  data;

        begin

                // Setup Phase
                @(negedge clk);

                r_psel    = 1'b1;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = addr;
                r_pwdata  = 32'd0;


                // Access Phase
                @(negedge clk);

                r_penable = 1'b1;


                @(posedge clk);

                while (!w_pready)
                        @(posedge clk);


                #1;

                data = w_prdata;


                if (w_pslverr) begin

                        $display(
                                "FAIL: APB READ ERROR addr=%02h",
                                addr
                        );

                        r_errorCnt = r_errorCnt + 1;

                end


                // End Transfer
                @(negedge clk);

                r_psel    = 1'b0;
                r_penable = 1'b0;
                r_pwrite  = 1'b0;

                r_paddr   = 8'd0;

        end

endtask


// ---------------------------------------------------------
// RX DATA Read / Check
// ---------------------------------------------------------
task rx_read_check;

        input [7:0] expectedData;

        reg [31:0] rxData;

        begin

                apb_read(
                        ADDR_RXDATA,
                        rxData
                );


                if (rxData[7:0] !== expectedData) begin

                        $display(
                                "FAIL: RX expected=%02h actual=%02h",
                                expectedData,
                                rxData[7:0]
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: RX expected=%02h actual=%02h",
                                expectedData,
                                rxData[7:0]
                        );

                end

        end

endtask


// ---------------------------------------------------------
// Wait RX FIFO Count
// ---------------------------------------------------------
task wait_rx_count;

        input [4:0] expectedCount;

        begin

                wait (
                        uut.w_rxFifoCount ==
                        expectedCount
                );

                repeat (2)
                        @(posedge clk);

        end

endtask


// ---------------------------------------------------------
// Wait UART Idle
// ---------------------------------------------------------
task wait_uart_idle;

        begin

                wait (uut.w_txFifoEmpty);
                wait (!uut.w_txBusy);
                wait (!uut.w_rxBusy);

                repeat (2)
                        @(posedge clk);

        end

endtask


// ---------------------------------------------------------
// False Start Injection
// ---------------------------------------------------------
task inject_false_start;

        begin

                r_loopbackEn   = 1'b0;
                r_uartRxDrive  = 1'b1;


                repeat (5)
                        @(posedge clk);


                // Align near tick boundary
                @(negedge uut.uut_uart_core.w_tick16);


                // Short Start-like LOW pulse
                r_uartRxDrive = 1'b0;


                repeat (4)
                        @(negedge uut.uut_uart_core.w_tick16);


                // Return HIGH before center sampling
                r_uartRxDrive = 1'b1;


                // Wait for RX false-start pulse
                wait (uut.w_falseStart);


                repeat (3)
                        @(posedge clk);

        end

endtask


// ---------------------------------------------------------
// Main Test
// ---------------------------------------------------------
initial begin

        $dumpfile("uart_apb_irq.vcd");
        $dumpvars(0, tb_uart_apb);


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


        // -------------------------------------------------
        // Reset
        // -------------------------------------------------
        repeat (5)
                @(posedge clk);

        rst_n = 1'b1;

        repeat (2)
                @(posedge clk);


        // =================================================
        // TEST 0 : REGISTER RESET
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 0 : APB + IRQ REGISTER RESET");
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


        if (r_readData[15:0] !== 16'd312) begin

                $display(
                        "FAIL: BAUDDIV RESET"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: BAUDDIV RESET = 312"
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
                        "PASS: IRQ_EN RESET = 00000"
                );

        end


        // TX FIFO is empty after reset
        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        if (r_readData[4:0] !== 5'b00010) begin

                $display(
                        "FAIL: IRQ_STATUS RESET expected=00010 actual=%05b",
                        r_readData[4:0]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: IRQ_STATUS RESET = 00010"
                );

        end


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: IRQ should be LOW after reset"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: IRQ = 0"
                );

        end


        // =================================================
        // TEST 1 : TX FIFO EMPTY IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : APB TX FIFO EMPTY IRQ");
        $display("----------------------------------------");


        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0002
        );


        #1;


        if (w_irq !== 1'b1) begin

                $display(
                        "FAIL: TX EMPTY IRQ expected=1 actual=%b",
                        w_irq
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX EMPTY IRQ = 1"
                );

        end


        // Disable
        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0000
        );


        #1;


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: IRQ disable failed"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: IRQ DISABLE"
                );

        end


        // =================================================
        // TEST 2 : RX FIFO NOT EMPTY IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : APB RX FIFO IRQ + DATA PATH");
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

        apb_write(
                ADDR_TXDATA,
                32'h0000_00AA
        );

        apb_write(
                ADDR_TXDATA,
                32'h0000_0012
        );

        apb_write(
                ADDR_TXDATA,
                32'h0000_0034
        );


        wait_rx_count(5'd4);


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        if (r_readData[0] !== 1'b1) begin

                $display(
                        "FAIL: RX FIFO IRQ STATUS"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO IRQ STATUS = 1"
                );

        end


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


        rx_read_check(8'h55);
        rx_read_check(8'hAA);
        rx_read_check(8'h12);
        rx_read_check(8'h34);


        wait_uart_idle;


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        if (r_readData[0] !== 1'b0) begin

                $display(
                        "FAIL: RX FIFO IRQ did not clear"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO IRQ cleared by FIFO empty"
                );

        end


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: IRQ should be LOW after RX empty"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: IRQ = 0 after RX empty"
                );

        end


        // =================================================
        // TEST 3 : FALSE START STICKY IRQ
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 3 : FALSE START STICKY IRQ");
        $display("----------------------------------------");


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


        // STATUS sticky error bit check
        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (r_readData[9] !== 1'b1) begin

                $display(
                        "FAIL: STATUS FALSE START bit"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: STATUS FALSE START = 1"
                );

        end


        // IRQ Clear
        apb_write(
                ADDR_IRQ_CLEAR,
                32'h0000_0010
        );


        repeat (2)
                @(posedge clk);


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        if (r_readData[4] !== 1'b0) begin

                $display(
                        "FAIL: FALSE START IRQ CLEAR"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FALSE START IRQ CLEAR"
                );

        end


        if (w_irq !== 1'b0) begin

                $display(
                        "FAIL: IRQ should be LOW after clear"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: IRQ = 0 after clear"
                );

        end


        // Return to loopback
        r_loopbackEn  = 1'b1;
        r_uartRxDrive = 1'b1;


        repeat (10)
                @(posedge clk);


        // Disable IRQ during regression
        apb_write(
                ADDR_IRQ_EN,
                32'h0000_0000
        );


        // =================================================
        // TEST 4 : 8BIT / EVEN / 2 STOP REGRESSION
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : UART 8BIT / EVEN / 2 STOP");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_8E2
        );


        apb_write(
                ADDR_TXDATA,
                32'h0000_005A
        );

        apb_write(
                ADDR_TXDATA,
                32'h0000_00A5
        );

        apb_write(
                ADDR_TXDATA,
                32'h0000_003C
        );


        wait_rx_count(5'd3);


        rx_read_check(8'h5A);
        rx_read_check(8'hA5);
        rx_read_check(8'h3C);


        wait_uart_idle;


        // =================================================
        // TEST 5 : 7BIT / ODD / 1 STOP REGRESSION
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 5 : UART 7BIT / ODD / 1 STOP");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_7O1
        );


        apb_write(
                ADDR_TXDATA,
                32'h0000_00D5
        );

        apb_write(
                ADDR_TXDATA,
                32'h0000_00AA
        );

        apb_write(
                ADDR_TXDATA,
                32'h0000_00CD
        );


        wait_rx_count(5'd3);


        rx_read_check(8'h55);
        rx_read_check(8'h2A);
        rx_read_check(8'h4D);


        wait_uart_idle;


        // =================================================
        // FINAL STATUS
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" FINAL STATUS CHECK");
        $display("----------------------------------------");


        apb_read(
                ADDR_STATUS,
                r_readData
        );


        if (r_readData[20:16] !== 5'd0) begin

                $display(
                        "FAIL: TX FIFO COUNT = %0d",
                        r_readData[20:16]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX FIFO COUNT = 0"
                );

        end


        if (r_readData[28:24] !== 5'd0) begin

                $display(
                        "FAIL: RX FIFO COUNT = %0d",
                        r_readData[28:24]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: RX FIFO COUNT = 0"
                );

        end


        if (r_readData[9:7] !== 3'b000) begin

                $display(
                        "FAIL: ERROR STATUS = %03b",
                        r_readData[9:7]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: ERROR STATUS = 000"
                );

        end


        apb_read(
                ADDR_IRQ_STATUS,
                r_readData
        );


        // TX FIFO Empty only
        if (r_readData[4:0] !== 5'b00010) begin

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
                        "FAIL: FINAL IRQ expected=0"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: FINAL IRQ = 0"
                );

        end


        // =================================================
        // Final Result
        // =================================================
        if (r_errorCnt == 0) begin

                $display("");
                $display("========================================");
                $display(" UART V2 APB + IRQ: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V2 APB + IRQ: %0d ERROR(S)",
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

        #500000000;

        $display("");
        $display("========================================");
        $display(" FAIL: UART APB IRQ SIMULATION TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule
