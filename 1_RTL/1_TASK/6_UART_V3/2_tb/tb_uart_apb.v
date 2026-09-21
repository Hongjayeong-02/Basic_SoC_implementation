`timescale 1ns/1ps

module tb_uart_apb;


localparam ADDR_TXDATA      = 8'h00;
localparam ADDR_RXDATA      = 8'h04;
localparam ADDR_STATUS      = 8'h08;
localparam ADDR_CTRL        = 8'h0C;
localparam ADDR_FIFO_LEVEL  = 8'h1C;


localparam CTRL_ALL_OFF     = 32'h0000_0000;

// UART + TX
localparam CTRL_TX_ONLY     = 32'h0000_0003;

// UART + RX + LOOPBACK
localparam CTRL_RX_ONLY_LB  = 32'h0000_0085;

// UART + TX + LOOPBACK
localparam CTRL_TX_ONLY_LB  = 32'h0000_0083;

// UART + TX + RX + LOOPBACK
localparam CTRL_ALL_ON_LB   = 32'h0000_0087;


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


// APB Write
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


// Expected APB Write Error
task apb_write_error;

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


                if (!w_pslverr) begin

                        $display(
                                "FAIL: APB ERROR expected"
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: TX WRITE BLOCKED"
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


// APB Read
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

        end

endtask


// RX Data Check
task rx_check;

        input [7:0] expectedData;

        begin

                apb_read(
                        ADDR_RXDATA,
                        r_readData
                );


                if (r_readData[7:0] !== expectedData) begin

                        $display(
                                "FAIL: RX expected=%02h actual=%02h",
                                expectedData,
                                r_readData[7:0]
                        );

                        r_errorCnt = r_errorCnt + 1;

                end else begin

                        $display(
                                "PASS: RX expected=%02h actual=%02h",
                                expectedData,
                                r_readData[7:0]
                        );

                end

        end

endtask


initial begin

        $dumpfile("uart_apb_v3_enable.vcd");
        $dumpvars(0, tb_uart_apb);


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

        repeat (3)
                @(posedge clk);


        $display("");
        $display("========================================");
        $display(" UART V3 APB TX_EN / RX_EN TEST");
        $display("========================================");


        // =================================================
        // TEST 0 : CONTROL REGISTER
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 0 : CONTROL REGISTER");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_ALL_ON_LB
        );


        apb_read(
                ADDR_CTRL,
                r_readData
        );


        if (r_readData[7:0] !== 8'h87) begin

                $display(
                        "FAIL: CONTROL expected=87 actual=%02h",
                        r_readData[7:0]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: CONTROL = 87"
                );

        end


        // =================================================
        // TEST 1 : TX DISABLE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 1 : TX DISABLE");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_RX_ONLY_LB
        );


        // NOTE: this uart_apb (STRICT_APB_ERR = 0, the default) never
        // asserts o_pslverr for a TXDATA write while TX is disabled — it
        // just silently drops the write (i_txEn gates w_txWrEn inside
        // uart_core). So this checks a normal, error-free APB write, and
        // the TX FIFO count / TX line checks below confirm the byte was
        // dropped rather than transmitted.
        apb_write(
                ADDR_TXDATA,
                32'h0000_0033
        );


        apb_read(
                ADDR_FIFO_LEVEL,
                r_readData
        );


        if (r_readData[7:0] !== 8'd0) begin

                $display(
                        "FAIL: TX FIFO COUNT = %0d",
                        r_readData[7:0]
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: TX FIFO COUNT = 0"
                );

        end


        if (w_uartTx !== 1'b1) begin

                $display(
                        "FAIL: UART TX should be HIGH"
                );

                r_errorCnt = r_errorCnt + 1;

        end else begin

                $display(
                        "PASS: UART TX = IDLE"
                );

        end


        // =================================================
        // TEST 2 : RX DISABLE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 2 : RX DISABLE");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_TX_ONLY_LB
        );


        apb_write(
                ADDR_TXDATA,
                32'h0000_0055
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
                        "FAIL: RX FIFO COUNT = %0d",
                        r_readData[15:8]
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


        apb_write(
                ADDR_CTRL,
                CTRL_ALL_ON_LB
        );


        apb_write(
                ADDR_TXDATA,
                32'h0000_005A
        );


        wait (
                uut.w_rxFifoCount == 5'd1
        );


        repeat (3)
                @(posedge clk);


        rx_check(
                8'h5A
        );


        // =================================================
        // TEST 4 : UART DISABLE
        // =================================================
        $display("");
        $display("----------------------------------------");
        $display(" TEST 4 : UART DISABLE");
        $display("----------------------------------------");


        apb_write(
                ADDR_CTRL,
                CTRL_ALL_OFF
        );


        // Same as TEST 1: no pslverr with STRICT_APB_ERR = 0, the write
        // is simply ignored while the UART is fully disabled.
        apb_write(
                ADDR_TXDATA,
                32'h0000_00AA
        );


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
                $display(" UART V3 APB TX_EN / RX_EN: ALL PASS");
                $display("========================================");
                $display("");

        end else begin

                $display("");
                $display("========================================");
                $display(
                        " UART V3 APB TX_EN / RX_EN: %0d ERROR(S)",
                        r_errorCnt
                );
                $display("========================================");
                $display("");

        end


        #100;
        $finish;

end


initial begin

        #30000000;

        $display("");
        $display("========================================");
        $display(" UART V3 APB TX_EN / RX_EN: TIMEOUT");
        $display("========================================");
        $display("");

        $finish;

end


endmodule
